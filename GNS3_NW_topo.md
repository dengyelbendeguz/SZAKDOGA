# GNS3 környezet

A korábbi Szabó Csaba féle topológiát követve implementáltuk GNS3-ban, amely logikájában (VLAN-ok)
megegyezik az eredeti topológiával, azonban megvalósításban eltér attól.

Minden router egy ethernet switchbe van bekötve, amelyhez csatlakozik a Ryu kontroller is, valamint
azon OVS-ek, amelyek logikailag routerekhez vannak kötve. Az ethernet switchbe csatlakozik még a
`Cloud1`, amely a GNS3-beli "internet" hozzáférést biztosítja annak `virbr0` interfészén keresztül
a `192.168.122.1/24` IP címen.

A GNS3 környezetben nincs szükség a 2 Linux VM-re, mert jelen környezet dockerben futtat sok imaget,
pl. a Ryu-t, OVS-eket, ezáltal kisebb a komplexitás, könnyebb a management, mint pl. file felmásolása,
terminálba/ból másolás stb.

A router konfigok mentve vannak az eszközön. A Ryu és OVS konfigok mentése egyenlőre nem megoldott,
ezeken minden indulásnál ki kell adni a parancsokat.

## Topológia:

![](pictures/GNS3_topology.png)

## Konfigurációs fileok:
- R1 config.txt
- R2 config.txt
- R3 config.txt
- R4 config.txt
- OVS1_config.sh
- OVS2_config.sh
- OVS3_config.sh
- OVS4_config.sh
- RYU_config.sh

## Cloud1:

internet

`virbr0` interfész: `192.168.122.1/24`

## Ethernet Switch 1:

sok port (pl 50)

mindegy, mit hova kötünk benne, "buta switch"

## 4 db Cisco router:

shady helyről van az image

Cisco 3725 124-25.T14

configok githubon

switchen keresztül kommunikálnak, nincs P2P

- `f0/0`: vlanok, egymással sikeresen kommunikálnak

- `f0/1`: wan port, itt a `192.168.122.0/24` hálózaton kommunikálnak a `Cloud1`-gyel, valamint
mindenkivel ezen a hálózaton

korábbi konfighoz képesti változás:
- vlan999 nincs, helyett a `f0/1` lát a netre
- default-gw nincs
- default dns sincs
- ospf router id van

## Ryu kontroller:

2 interfésze van:
- `eth0`:
  - az SDN management lan (VLAN400)
  - `172.16.0.10/28`
  - ezen keresztül kommunikál az OVS-ekkel
- `eth1`:
  - "internet" lan, ezen keresztül közvetve (`Cloud1`) lát ki az internetre
  - azért van rá szükség, mert bizonyos eszközöket (pl. python) telepíteni kellett rá

## OVS switchek:

- egymás közt VLAN-okon kommunikálnak
- közvetlen kapcsolat, nem ethernet switchen keresztül
- az ethernet switchen keresztül kommunikálnak azok az OVS-ek, amelyek routerekkel is kapcsolatban vannak
- nincs közvetlen internet hozzáférésük
- az `eth0` interfész mindegyik az SDN management lan, ez is az ethernet switchbe van kötve
- OVS port leképezés:
  - " eth x goes to ovs x " szerint, azaz az aktuális OVS `eth*` interfésze a szomszédos `OVS*` felé
  van kötve, ahol a `*` a port/OVS száma
  - pl. `OVS1` `eth2` interfésze az `OVS2` `eth1` interfészébe csatlakozik
- a `br0` OVS bridge default tartalmazza az összes `eth*` interfészt, nem kell külön hozzáadni
- a routerekkel összekötött OVS-ek port kiosztása:
  - `R3`-ba az `eth7` megy mindkét OVS-ről
  - `R1`-be az `eth6` megy az OVS1-ből