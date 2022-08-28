from ryu.lib.mac import haddr_to_bin
from ryu.base import app_manager
from ryu.controller import ofp_event
from ryu.controller.handler import MAIN_DISPATCHER
from ryu.controller.handler import set_ev_cls
from ryu.ofproto import ofproto
from ryu.lib.mac import haddr_to_bin
from ryu.lib.packet import packet
from ryu.lib.packet import ethernet
from ryu.lib.packet import ether_types
from ryu.topology import switches
from ryu.ofproto import ofproto_v1_0
from ryu.ofproto import ofproto_v1_3
from ryu.ofproto import ofproto_v1_3_parser

OFP_NO_BUFFER = 0xffffffff

class OpenFlowHandle(app_manager.RyuApp):

    def __init__(self, *args, **kwargs):
        super(OpenFlowHandle, self).__init__(*args, **kwargs)
        # self.mac_to_port = {}

    """
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
        datapath.send_msg(mod)"""

    # TODO: kész van, csak ki kell törölni a felesleges kommenteket... Végül a használt verzió 1.3
    # https://ryu.readthedocs.io/en/latest/ofproto_v1_5_ref.html#ryu.ofproto.ofproto_v1_5_parser.OFPFlowMod
    def send_flow_mod(self, datapath, actions, ipv4_dst, buffer_id = OFP_NO_BUFFER): # kicsit gány megoldás...
                      # in_port, dst, src, ip_src,
                      # importance = 0):

        ofp = datapath.ofproto
        ofp_parser = datapath.ofproto_parser

        cookie = cookie_mask = 0
        # table_id = 0
        # buffer_id = ofp.OFP_NO_BUFFER
        idle_timeout = hard_timeout = 0
        priority = ofp.OFP_DEFAULT_PRIORITY     # biztos jó ez így?
        command = ofp.OFPFC_ADD
        flags = ofp.OFPFF_SEND_FLOW_REM
        # buffer_id  # NOP.... nem kő... nem tudom honnan tuggya

        # nincs a simple_switch és shortestpath-ban: cookie_mask, table_id,
        #                               buffer_id, out_port, out_group, instruction

        # FONTOS!: match
        #

        inst = [ofp_parser.OFPInstructionActions(ofp.OFPIT_APPLY_ACTIONS,
                                                 actions)]

        # Milyen megegyezési feltételeket akarok megadni?
        # https://ryu.readthedocs.io/en/latest/ofproto_v1_5_ref.html#flow-match-structure
        # Packet type? Incoming IP?
        match = ofp_parser.OFPMatch(ipv4_dst = ipv4_dst)
                # in_port=in_port, ipv4_src = haddr_to_bin(ip_src), dl_dst=haddr_to_bin(dst), dl_src=haddr_to_bin(src))

        mod = ofp_parser.OFPFlowMod(
            datapath = datapath, match = match, cookie = cookie, command = command,
            idle_timeout = idle_timeout, hard_timeout = hard_timeout, buffer_id = buffer_id,
            priority = priority, flags = flags, instruction = inst)  # instruction??

        datapath.send_msg(mod)

    def send_packet_out(self, datapath, buffer_id, in_port,
                        out_port, msg_ser):
        ofp = datapath.ofproto
        ofp_parser = datapath.ofproto_parser

        # TODO: Gondold még át....
        # https://ryu.readthedocs.io/en/latest/ofproto_v1_5_ref.html#ryu.ofproto.ofproto_v1_5_parser.OFPPacketOut

        actions = [ofp_parser.OFPActionOutput(out_port, 0)]
        req = ofp_parser.OFPPacketOut(datapath, buffer_id,
                                      in_port, actions, msg_ser)

        # from shortestpath:
        #actions = [datapath.ofproto_parser.OFPActionOutput(out_port)]
        #out = datapath.ofproto_parser.OFPPacketOut(
        #    datapath=datapath, buffer_id=msg.buffer_id, in_port=msg.in_port,
        #    actions=actions)

        """
        simple switch:
                if out_port != ofproto.OFPP_FLOOD:
            self.add_flow(datapath, msg.in_port, dst, src, actions)

        data = None
        if msg.buffer_id == ofproto.OFP_NO_BUFFER:
            data = msg.data

        # Cs: Send something out
        out = datapath.ofproto_parser.OFPPacketOut(
            datapath=datapath, buffer_id=msg.buffer_id, in_port=msg.in_port,
            actions=actions, data=data)
        datapath.send_msg(out)
        """

        datapath.send_msg(req)
