# This moule handles the OSPF network topology, add new elements

from ryu.app.ryu_ospf_cs import RyuOspf

from ryu.topology.api import get_switch, get_link
from ryu.app.wsgi import ControllerBase
from ryu.topology import event, switches
import networkx as nx
import timeit
from ryu.base import app_manager
import ryu.app.ospf.openflow_handle_cs as openflow

#  This is part of our final project for the Computer Networks Graduate Course at Georgia Tech
#    You can take the official course online too! Just google CS 6250 online at Georgia Tech.
#
#  Contributors:
#
#    Akshar Rawal (arawal@gatech.edu)
#    Flavio Castro (castro.flaviojr@gmail.com)
#    Logan Blyth (lblyth3@gatech.edu)
#    Matthew Hicks (mhicks34@gatech.edu)
#    Uy Nguyen (unguyen3@gatech.edu)
#
#  To run:
#
#    ryu--manager --observe-links shortestpath.py
#
# Copyright (C) 2014, Georgia Institute of Technology.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""
An OpenFlow 1.0 shortest path forwarding implementation.
"""

""" 
import logging
import struct

from ryu.base import app_manager
from ryu.controller import mac_to_port
from ryu.controller import ofp_event
from ryu.controller.handler import MAIN_DISPATCHER, CONFIG_DISPATCHER
from ryu.controller.handler import set_ev_cls
from ryu.ofproto import ofproto_v1_0
from ryu.lib.mac import haddr_to_bin
from ryu.lib.packet import packet
from ryu.lib.packet import ethernet

from ryu.topology.api import get_switch, get_link
from ryu.app.wsgi import ControllerBase
from ryu.topology import event, switches
import networkx as nx


class ProjectController(app_manager.RyuApp):
    OFP_VERSIONS = [ofproto_v1_0.OFP_VERSION]

    def __init__(self, *args, **kwargs):
        super(ProjectController, self).__init__(*args, **kwargs)
        self.mac_to_port = {}
        self.topology_api_app = self
        self.net = nx.DiGraph()
        self.nodes = {}
        self.links = {}
        self.no_of_nodes = 0
        self.no_of_links = 0
        self.i = 0

    # Handy function that lists all attributes in the given object
    def ls(self, obj):
        print("\n".join([x for x in dir(obj) if x[0] != "_"]))

    def add_flow(self, datapath, in_port, dst, actions):
        ofproto = datapath.ofproto

        match = datapath.ofproto_parser.OFPMatch(
            in_port=in_port, dl_dst=haddr_to_bin(dst))

        mod = datapath.ofproto_parser.OFPFlowMod(
            datapath=datapath, match=match, cookie=0,
            command=ofproto.OFPFC_ADD, idle_timeout=0, hard_timeout=0,
            priority=ofproto.OFP_DEFAULT_PRIORITY,
            flags=ofproto.OFPFF_SEND_FLOW_REM, actions=actions)
        datapath.send_msg(mod)

    @set_ev_cls(ofp_event.EventOFPPacketIn, MAIN_DISPATCHER)
    def _packet_in_handler(self, ev):
        msg = ev.msg
        datapath = msg.datapath
        ofproto = datapath.ofproto

        pkt = packet.Packet(msg.data)
        eth = pkt.get_protocol(ethernet.ethernet)

        dst = eth.dst
        src = eth.src
        dpid = datapath.id
        self.mac_to_port.setdefault(dpid, {})
        # print "nodes"
        # print self.net.nodes()
        # print "edges"
        # print self.net.edges()
        # self.logger.info("packet in %s %s %s %s", dpid, src, dst, msg.in_port)
        if src not in self.net:
            self.net.add_node(src)
            self.net.add_edge(dpid, src, {'port': msg.in_port})
            self.net.add_edge(src, dpid)
        if dst in self.net:
            # print (src in self.net)
            # print nx.shortest_path(self.net,1,4)
            # print nx.shortest_path(self.net,4,1)
            # print nx.shortest_path(self.net,src,4)

            path = nx.shortest_path(self.net, src, dst)
            next = path[path.index(dpid) + 1]
            out_port = self.net[dpid][next]['port']
        else:
            out_port = ofproto.OFPP_FLOOD

        actions = [datapath.ofproto_parser.OFPActionOutput(out_port)]

        # install a flow to avoid packet_in next time
        if out_port != ofproto.OFPP_FLOOD:
            self.add_flow(datapath, msg.in_port, dst, actions)

        out = datapath.ofproto_parser.OFPPacketOut(
            datapath=datapath, buffer_id=msg.buffer_id, in_port=msg.in_port,
            actions=actions)
        datapath.send_msg(out)

    @set_ev_cls(event.EventSwitchEnter)
    def get_topology_data(self, ev):
        switch_list = get_switch(self.topology_api_app, None)
        switches = [switch.dp.id for switch in switch_list]
        self.net.add_nodes_from(switches)

        # print "**********List of switches"
        # for switch in switch_list:
        # self.ls(switch)
        # print switch
        # self.nodes[self.no_of_nodes] = switch
        # self.no_of_nodes += 1

        links_list = get_link(self.topology_api_app, None)
        # print links_list
        links = [(link.src.dpid, link.dst.dpid, {'port': link.src.port_no}) for link in links_list]
        # print links
        self.net.add_edges_from(links)
        links = [(link.dst.dpid, link.src.dpid, {'port': link.dst.port_no}) for link in links_list]
        # print links
        self.net.add_edges_from(links)
        print
        "**********List of links"
        print
        self.net.edges()
        # for link in links_list:
        # print link.dst
        # print link.src
        # print "Novo link"
        # self.no_of_links += 1

    # print "@@@@@@@@@@@@@@@@@Printing both arrays@@@@@@@@@@@@@@@"
    # for node in self.nodes:
#    print self.nodes[node]
# for link in self.links:
#    print self.links[link]
# print self.no_of_nodes
# print self.no_of_links

# @set_ev_cls(event.EventLinkAdd)
# def get_links(self, ev):
# print "################Something##############"
# print ev.link.src, ev.link.dst

"""


class NetworkDB(app_manager.RyuApp):    # , nx):

    def __init__(self, *args, **kwargs):
        super(NetworkDB, self).__init__(*args, **kwargs)
        net = nx.Graph()
        self.mac_to_port = {}
        self.topology_api_app = self

        # nézd át még a dokumentációt...
        self.net = nx.Graph() # TODO: Legyen own osztály?
        # rid, mask

        self.nodes = {}
        self.links = {}
        self.no_of_nodes = 0
        self.no_of_links = 0
        self.i = 0
        # self.lsid = 0


    def add_node(self, node, rid, mask, lsid):
        self.net.add_node(node, {"rid": rid, "mask": mask, "lsid": lsid})
        # Ask attribute: net[1]["rid"]
        # Full graph: net.nodes.daga()

    # at nodes: you need to give rid, mask, lsid attr-s to each node
    # correct form: [(1, {"ipv4": "", "rid": "1.1.1.1", "mask": "255.255.255.248", "lsid": 0x80000007}),
    #                (2, {"ipv4": "", "rid": "2.2.2.2", "mask": "255.255.255.248", "lsid": 0x80000003}),
    #                (3, {"ipv4": "", "rid": "3.3.3.3", "mask": "255.255.255.248", "lsid": 0x80000001})]
    def add_nodes(self, nodes, **attr):
        # net = self.net
        self.add_nodes_from(nodes, **attr)

        for src in self.net:
            for dst in self.net:
                path = nx.shortest_path(self.net, src, dst)


    def add_edge(self, net, in_node, out_node, **attr):
        # net = self.net

        net.add_edge(net, in_node, out_node, **attr)

    def add_edge(self, net, in_node, out_node, **attr):
        # net = self.net
        net.add_edge(net, in_node, out_node, **attr)

    def delete_topology_entry(self):
        pass

    def find_topology_entry(self):
        pass

    def modify_topology_entry(self):
        pass

    def print_topology(self):
        pass

    def calculate_djikstra(self):
        pass

    def add_next_hop(self):
        pass

    def host_lost(self):
        pass

    def link_off(self):
        pass

    def get_neighbors(self, ipv4):
        # TODO s: !!
        pass

    def get_hellodata(self, ipv4_src):

        # TODO: ezt még át kell gondolni!!! Hogy lesz a struktúra???
        mask = self.net[ipv4_src]["mask"] # majd meg kell keresni
        neighbors = self.get_neighbors(ipv4_src) #self.net[ipv4_src]["neighbors"]
        rid = self.net[ipv4_src]["rid"]

        # default values if it is needed
        """
            def __init__(self, length=None, router_id='0.0.0.0', area_id='0.0.0.0',
                 au_type=1, authentication=0, checksum=None, version=_VERSION,
                 mask='0.0.0.0', hello_interval=10, options=0, priority=1,
                 dead_interval=40, designated_router='0.0.0.0',
                 backup_router='0.0.0.0', neighbors=None):
                neighbors = neighbors if neighbors else []
                super(OSPFHello, self).__init__(OSPF_MSG_HELLO, length, router_id,
                                                area_id, au_type, authentication,
                                                checksum, version)
                """
        hello_interval = 10
        dead_interval = 40
        priority = 1
        options = 0
        designated_router = "0.0.0.0"
        backup_router = "0.0.0.0"

        return {
            "mask": mask,
            "hello_interval": hello_interval,
            "options": options,
            "priority": priority,
            "dead_interval": dead_interval,
            "designated_router": designated_router,
            "backup_router": backup_router,
            "neighbors": neighbors,
            "rid": rid
        }

    def build_network(self, event):
        # First get switches and add to my graph
        switch_list = get_switch(self.topology_api_app, None)
        switches = [switch.dp.id for switch in switch_list]

        ## Get RID-s from the parameter of router
        # attr = ''
        for sw in switches:
            attr = "".join(str(sw),str(sw),'.',str(sw),str(sw),'.'+str(sw), str(sw) , '.' ,str(sw), str(sw))


        self.add_nodes(switches, attr)

        # After discover links
        links_list = get_link(self.topology_api_app, None)
        # From source address
        links = [(link.src.dpid, link.dst.dpid, {'port': link.src.port_no}) for link in links_list]
        self.add_edges(links)
        # From destination address
        links = [(link.dst.dpid, link.src.dpid, {'port': link.dst.port_no}) for link in links_list]
        self.add_edges(links)

        # TODO When new host added send LSU

        # Network topology has built
        # TODO: Handle network discovery and build own topology...

    def handle_swtitch_msg(self, src, dst, net, dpid ):
        return False

