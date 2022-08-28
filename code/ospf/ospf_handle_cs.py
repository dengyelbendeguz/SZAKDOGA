# Some useful information about OSPF to make programming easier

"""
# How neighborhood gets alive (RFC2328 Page 106):
#        +---+                                      +---+
#        |RT1|                                      |RT2|
#        +---+                                      +---+
#        Down                                       Down
#                       Hello(DR=0,seen=0)
#               ------------------------------>
#                   Hello (DR=RT2,seen=RT1,...)     Init
#               <------------------------------
#                   ExStart D-D (Seq=x,I,M,Master)
#               ------------------------------>
#                   D-D (Seq=y,I,M,Master)          ExStart
#               <------------------------------
#       Exchange        D-D (Seq=y,M,Slave)
#               ------------------------------>
#                   D-D (Seq=y+1,M,Master)          Exchange
#               <------------------------------
#                   D-D (Seq=y+1,M,Slave)
#               ------------------------------>
#                              ...
#                              ...
#                              ...
#                   D-D (Seq=y+n, Master)
#               <------------------------------
#                   D-D (Seq=y+n, Slave)
#       Loading ------------------------------>
#                       LS Request                  Full
#               ------------------------------>
#                       LS Update
#               <------------------------------
#                       LS Request
#               ------------------------------>
#                       LS Update
#               <------------------------------
#       Full
"""

'''
# OSPF Packet Header (RFC2328 Page 190):
#       0                   1                   2                   3
#        0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
#       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#       |   Version #   |       Type    |           Packet length       |
#       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#       |                           Router ID                           |
#       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#       |                           Area ID                             |
#       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#       |           Checksum            |               AuType          |
#       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#       |                           Authentication                      |
#       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#       |                           Authentication                      |
#       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
'''

import ryu.lib.packet.ospf as ospf
from ryu.lib.packet.packet import Packet
from ryu.app.ospf.network_discovery_cs import NetworkDB
from ryu.app.ospf.openflow_handle_cs import OpenFlowHandle

_VERSION = 2


class OspfPacket(ospf.OSPFMessage):

    def __init__(self, *args, **kwargs):
        super(OspfPacket, self).__init__(*args, **kwargs)


class Hello(OspfPacket, ospf.OSPFHello):

    def __init__(self, *args, **kwargs):
        super(Hello, self).__init__(*args, **kwargs)
        self.timer = self.hello_interval

    def check_hello_validity(sefl, ospf_msg):
        return True

    def send_hello(self):
        #
        pass

    def hello_in(self, msg, network):
        pass
        # for i in network.

class DBD(OspfPacket, ospf.OSPFDBDesc):

    def __init__(self, *args, **kwargs):
        super(DBD,self).__init__(*args, **kwargs)


class LSR(OspfPacket, ospf.OSPFLSReq):

    def __init__(self, *args, **kwargs):
        super(LSR,self).__init__(*args, **kwargs)
        # self.timer = self.


class LSU(OspfPacket, ospf.OSPFLSUpd):
    def __init__(self, *args, **kwargs):
        super(LSU,self).__init__(*args, **kwargs)



class LsAck(OspfPacket, ospf.OSPFLSAck):
    def __init__(self, *args, **kwargs):
        super(LsAck,self).__init__(*args, **kwargs)
    pass


class OSPFRouter:
    def __init__(self, router_id = 0, area_id = 0, lsuinterval = 30, interfaces = []):
        self.rid = router_id
        self.area = area_id
        self.lsuint = lsuinterval
        # TODO: Ezt gondolt majd át!!!!
        self.intf = []
        # Majd intf.append(OSPFInterface(parameters))-el kell meghívni

    pass


class OSPFInterface:
    def __init__(self, ip_address="0.0.0.0", subnet_mask="255.255.255.255",
                 hello_interval=10, neighbor_id="0.0.0.0", neighbor_ip="0.0.0.0"):
        self.ipaddr = ip_address
        self.mask = subnet_mask
        self.helloint = hello_interval
        self.neighid = neighbor_id
        self.neighip = neighbor_ip
    pass


"""
OSPF Hello Protocol:
Discover and maintain the state of available links
Broadcast and listens periodical HELLO pacets
Every helloint seconds: message to ALLSPFRouters ("244.0.0.4"/0xe0000005)

Incoming Hello:
    1. Invalid              --> drop
    2. Unknown              --> Add to neighborhood
    3. Known from neighbors --> Mark the time recievend (restart)
    
"""


class HelloProtocol():
    pass


class OspfProtocolHandler:
    hello = ospf.OSPF_MSG_HELLO

    def __init__(self, version=_VERSION, ospf_packet_type=0, packet_length=0,
                 router_id="0.0.0.0", area_id= 0, hello_int = 20, lsu_int = 30,
                 mask='255.255.255.252'):

        """
        ospf_version = version
        package_type = ospf_packet_type
        length = packet_length
        rid = router_id
        area = area_id
        """
        # self.network = NetworkDB()
        self.hello_int = hello_int
        self.lsu_int = lsu_int
        self.mask = mask
        self.hello = Hello()
        self.lsu = LSU()


        pass


    # TODO: What do I need to do with OSPF?
    # First: Check header: LSA, LSU, LSAck, Hello,

    def add_node(self, new_node, **attr):
        self.network.add_node(self.network.net, )

    def add_link(self, link):
        self.network.add_edge(self.network.net, )

    def check_ospf_version(self):
        pass

    def check_checksum(self):
        pass

    def check_area(self, area_id1, area_id2):
        return area_id1 == area_id2

    def send_hello(self, of_manager, network, ipv4_src, ipv4_dst):
        hello_datas = network.get_hello_data(ipv4_src)
        # version = 2

        # kelleni fog: RID, mask, neighbors...

        msg = Hello(router_id=hello_datas.RID, neighbors=hello_datas.neighbors)
        hello = Hello(router_id=hello_datas.RID, mask = hello_datas.mask)
        hello.serialize()


    def hello_regular(self):
        pass

    # Tehát: Hello bejön, leellenőrzöm, hogy valid Hello csomag-e
    # (hello int, validity, subnet mask, etc)
    # Nem valid: drop/ignore....
    # Valid: ismerem? Nem ismerem?
    # Nem ismerem: add to topology table
    # Ismerem: reset timer (?) - nekem valszeg nem kell ezzel foglalkoznom
    # Ennyi
    def hello_protocol(self, ospf_hello_msg, network):
        # check the validity of a recieved Hello packet
        # (IP header, OSPF header)
        # (network mask, HelloInt fields with local values)
        # do I need to?....


        if not self.hello.check_hello_validity(ospf_hello_msg):
            return

        if self.hello_interval != 10:   # != network.net[ipv4_src]["hello_interval"]
                                        # or like this....
            # OpenFlowHandle.drop() # ?
            return

        ipv4 = "0.0.0.0" # TODO - i need to check incoming packet...
        if self.mask != network.net[ipv4]["mask"]:
            # OpenFlowHandle.drop()
            return

        # TODO
        # If the source router is in our topology politely ignore...
        # Check neighbor interfaces in neighbor list

        # TODO nézd át
        if ospf_hello_msg.router_id not in network.rid_list:
            network.add_every_neighbor(ospf_hello_msg.neighbors)
        else:
            ospf_hello_msg.timer = self.hello_int


        #

    def hello_in(self, ospf_hello_msg, network):
        self.hello_protocol(ospf_hello_msg, network)

    def ospf_packet_in(self, ospf_msg, network):
        if(ospf_msg.get_protocol(ospf.OSPFHello)):
            self.hello_in(ospf_msg, network)
        elif(ospf_msg.get_protocol(ospf.OSPFDBDesc)):
            self.dbd_in(ospf_msg, network)
        elif(ospf_msg.get_protocol(ospf.OSPFLSReq)):
            self.lsreq_in(ospf_msg, network)
        elif(ospf_msg.get_protocol(ospf.OSPFLSUpd)):
            self.lsu_in(ospf_msg, network)
        elif(ospf_msg.get_protocol(ospf.OSPFLSAck)):
            self.lsack_in(ospf_msg, network)
        else:
            print("It wasn't an OSPF packet")

        return ospf_msg.get_protocol(ospf.ospf)

    def check_packet_type(self, msg):
        # switch msg:
        #case
        pass


    """
    def check_lsa_header(self):
        pass

    def is_ospf(self):
        boolen = False
        return boolen

    def ospf_parser(self):
        pass

    def hello_packet_in(self, pck):
        # if is_hello(pck)
        pass 
        
    """


def send_hello():
    return None