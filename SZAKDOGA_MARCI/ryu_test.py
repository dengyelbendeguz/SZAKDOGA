### WORK IN PROGRESS ###

from ryu.lib.packet import packet, ethernet, arp, ipv4
import array

@set_ev_cls(ofp_event.EventOFPPacketIn, MAIN_DISPATCHER)
def _packet_in_handler(self, ev):

    ### Mike Pennington's logging modifications
    ## Set up to receive the ethernet src / dst addresses
    pkt = packet.Packet(array.array('B', ev.msg.data))
    eth_pkt = pkt.get_protocol(ethernet.ethernet)
    arp_pkt = pkt.get_protocol(arp.arp)
    ip4_pkt = pkt.get_protocol(ipv4.ipv4)
    if arp_pkt:
        pak = arp_pkt
    elif ip4_pkt:
        pak = ip4_pkt
    else:
        pak = eth_pkt
    self.logger.info('  _packet_in_handler: src_mac -> %s' % eth_pkt.src)
    self.logger.info('  _packet_in_handler: dst_mac -> %s' % eth_pkt.dst)
    self.logger.info('  _packet_in_handler: %s' % pak)
    self.logger.info('  ------')
    src = eth_pkt.src  # Set up the src and dst variables so you can use them
    dst = eth_pkt.dst
    ## Mike Pennington's modifications end here


    msg = ev.msg
    datapath = msg.datapath
    ofproto = datapath.ofproto

    dpid = datapath.id
    self.mac_to_port.setdefault(dpid, {})

    # learn a mac address to avoid FLOOD next time.
    self.mac_to_port[dpid][src] = msg.in_port

    if dst in self.mac_to_port[dpid]:
        out_port = self.mac_to_port[dpid][dst]
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