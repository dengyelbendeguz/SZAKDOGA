# This application is for Hybrid SDN project which has the goal to handle OSPF communication to reach legacy routers in the network


from ryu.base import app_manager
from ryu.controller import ofp_event
from ryu.controller.handler import set_ev_cls, MAIN_DISPATCHER
from ryu.ofproto import ofproto_v1_0
from ryu.ofproto import ofproto_v1_2
from ryu.ofproto import ofproto_v1_3
import ryu.app.ospf.network_discovery_cs
from ryu.topology import event, switches
from ryu.topology.api import get_switch, get_link, get_host, get_all_host
from ryu.lib.packet import ospf

import ryu.app.ospf.ospf_handle_cs as valami

from ryu.lib.packet import packet

# Simple switch imports
from ryu.base import app_manager
from ryu.controller import mac_to_port      # Whut is tihs?
from ryu.controller import ofp_event
from ryu.controller.handler import MAIN_DISPATCHER, CONFIG_DISPATCHER
from ryu.controller.handler import set_ev_cls
# Melyik OF protokol verziót használjam?
from ryu.ofproto import ofproto_v1_0, ofproto_v1_4, ofproto_v1_3, ofproto_v1_2, ofproto_v1_5
from ryu.lib.mac import haddr_to_bin
from ryu.lib.packet import packet
from ryu.lib.packet import ethernet
from ryu.lib.packet import ether_types
from ryu.topology import switches
import array

# From shortespath project:
from ryu.topology.api import get_switch, get_link
from ryu.app.wsgi import ControllerBase
from ryu.topology import event, switches
import networkx as nx
import sched, time

# My packets
from ryu.app.ospf.graph import *
# import ryu.app.ospf.graph
from ryu.app.ospf.network_discovery_cs import NetworkDB as netdiscover
import ryu.app.ospf.openflow_handle_cs as ofhandler
import ryu.app.ospf.ospf_handle_cs as ospfhandler

# from ryu.controller import ofp_event

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! #
# ATTENTION: make sure you run ryu-manager sp.py --observe-links #
#           Install networkx: sudo pip install networkx          #
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! #

'''
class SimpleSwitch(app_manager.RyuApp):
    OFP_VERSIONS = [ofproto_v1_0.OFP_VERSION]

    def __init__(self, *args, **kwargs):
        super(SimpleSwitch, self).__init__(*args, **kwargs)
        self.mac_to_port = {}

    def add_flow(self, datapath, in_port, dst, src, actions):
        ofproto = datapath.ofproto

        match = datapath.ofproto_parser.OFPMatch(
            in_port=in_port,
            dl_dst=haddr_to_bin(dst), dl_src=haddr_to_bin(src))

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

        if eth.ethertype == ether_types.ETH_TYPE_LLDP:
            # ignore lldp packet
            return
        dst = eth.dst
        src = eth.src

        dpid = datapath.id
        self.mac_to_port.setdefault(dpid, {})

        self.logger.info("packet in %s %s %s %s", dpid, src, dst, msg.in_port)

        # learn a mac address to avoid FLOOD next time.
        self.mac_to_port[dpid][src] = msg.in_port

        if dst in self.mac_to_port[dpid]:
            out_port = self.mac_to_port[dpid][dst]
        else:
            out_port = ofproto.OFPP_FLOOD

        actions = [datapath.ofproto_parser.OFPActionOutput(out_port)]

        # install a flow to avoid packet_in next time
        if out_port != ofproto.OFPP_FLOOD:
            self.add_flow(datapath, msg.in_port, dst, src, actions)

        data = None
        if msg.buffer_id == ofproto.OFP_NO_BUFFER:
            data = msg.data

        out = datapath.ofproto_parser.OFPPacketOut(
            datapath=datapath, buffer_id=msg.buffer_id, in_port=msg.in_port,
            actions=actions, data=data)
        datapath.send_msg(out)

    @set_ev_cls(ofp_event.EventOFPPortStatus, MAIN_DISPATCHER)
    def _port_status_handler(self, ev):
        msg = ev.msg
        reason = msg.reason
        port_no = msg.desc.port_no

        ofproto = msg.datapath.ofproto
        if reason == ofproto.OFPPR_ADD:
            self.logger.info("port added %s", port_no)
        elif reason == ofproto.OFPPR_DELETE:
            self.logger.info("port deleted %s", port_no)
        elif reason == ofproto.OFPPR_MODIFY:
            self.logger.info("port modified %s", port_no)
        else:
            self.logger.info("Illeagal port state %s %s", port_no, reason)

    # topology discovery...
    # from: https://sdn-lab.com/2014/12/31/topology-discovery-with-ryu/
    @set_ev_cls(event.EventSwitchEnter)
    def get_topology_data(self, ev):
        switch_list = get_switch(self.topology_api_app, None)
        switches = [switch.dp.id for switch in switch_list]
        links_list = get_link(self.topology_api_app, None)
        links = [(link.src.dpid, link.dst.dpid, {'port': link.src.port_no}) for link in links_list]
'''


s = sched.scheduler(time.time, time.sleep)

class RyuOspf(app_manager.RyuApp):

    OFP_VERISON = [ofproto_v1_3.OFP_VERSION]
    # grp = graph.Graph()

    def __init__(self, *args, **kwargs):
        super(RyuOspf, self).__init__(*args,**kwargs)
        self.ospf_handler = ospfhandler.OspfProtocolHandler()
        self.network = netdiscover()
        # self.ospf_handler.send_init_hello()
        self.get_topology_data()

        # handle passive ports
        # init scheduler

    def is_ospf(self, msg):
        # ryu.lib.packet.packet.Packet(bytearray)
        result = False
        pkt = packet.Packet(msg.data)
        for p in pkt:
            if p.protocol_name == 'ospf':
                # TODO
                result = True
        return result

    def new_vswitch_connected(self):
        pass

    def new_router_connected(self):
        pass

    def add_new_element(self):
        pass

    # init everything I need
    # When an OpenFlow packet arrives
    # Two function should run, when a OF packet arrives:
    # 1.: Check, if the source or destination switch is in the topology map.
    #     If not, than add
    #     If the destination MAC is know: SPF, next hop in path, get output port for next-hop
    # 2.: Check, if OSPF. If yes than add to topology tree
    #     Calculate next-hop
    @set_ev_cls(ofp_event.EventOFPacketIn, MAIN_DISPATCHER)
    def _packet_in_handler(self, ev):
        # TODO: OpenFlow comes.. mayday mayday
        # What to do with the packet arrived
        # Here I need to handle OSPF packets,

        # OpenFlow packe
        # First: decode incoming packet
        msg = ev.msg
        dp = msg.datapath
        dpid = dp.id
        ofproto = dp.ofproto

        # Open packet
        # pont switch case eset.... mindegy....
        pkt = packet.Packet(array.array('B', msg.data))
        for p in pkt:
            if p.protocol_name == 'ospf':
                pck_type = ospfhandler.check_packet_in(p, self.network) # TODO How to check packet type
                #if pck_type == 'Hello':
                #    ospfhandler.OspfPackageHandler.hello_protocol(
                #        self.ospf_handler, msg.data)

                #elif pck_type == 'LSA':
                #    pass
            if p.protocol_name == 'eth':
                src = p.src
                dst = p.dst
                dpid = dp.id
                self.mac_to_port.setdefault(dpid, {})

                self.network.handle_swtitch_msg(src, dst, self.network, dpid)
            ospf_pkt = pkt.get_protocol(ospf.ospf)
            eth = pkt.get_protocol(ethernet.ethernet)
        # if ospf.
        # osppkt.get_protocols(ospf.ospf)


        self.check_ospf(msg)

    # When a new OpenvSwitch Enters
    @set_ev_cls(event.EventSwitchEnter)
    def get_topology_data(self, ev):
        self.network.build_network(ev, self.network)

        # TODO: legyen külső osztály???
        # netdiscover.build_network()

        '''
        # First get switches and add to my graph
        switch_list = get_switch(self.topology_api_app, None)
        switches = [switch.dp.id for switch in switch_list]
        self.net.add_nodes_from(switches)

        # After discover links
        links_list = get_link(self.topology_api_app, None)
        # From source address
        links = [(link.src.dpid, link.dst.dpid, {'port': link.src.port_no}) for link in links_list]
        self.net.add_edges_from(links)
        # From destination address
        links = [(link.dst.dpid, link.src.dpid, {'port': link.dst.port_no}) for link in links_list]
        self.net.add_edges_from(links)

        '''

        # Network topology has built

    # What do I need to handle

    def counter(self, sleep):
        s.enter(sleep,1,ospfhandler.send_hello())



#    ryu.app.ospf.ospf_handle.ospf_handle()

# if __name__ == "__name__":
    # Buildup graphs from the controller topology
    # 1. Get topology map of the controller
    # 2. Build my topology map
    # 2.1 Graphic logic
    # 3. calculate Disjktra
    # 4. Send first route with OF Modifiy massage
    # 4.1 To each routers

    pass