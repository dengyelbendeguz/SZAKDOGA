# [Szakdolgozat](thesis_szabo_csaba.pdf) 

---

### [OneDrive](https://bmeedu-my.sharepoint.com/personal/dengyel_b_edu_bme_hu/_layouts/15/onedrive.aspx?id=%2Fpersonal%2Fdengyel_b_edu_bme_hu%2FDocuments%2FÖnlab&ga=1)
[Marci önlab kiírás](https://www.hit.bme.hu/edu/project/data?id=19938)
<br>
[Bende önlab kiírás](https://www.hit.bme.hu/edu/project/data?id=19952)

---

## Linkek nagyobb fájlokhoz (50+ MB)

- [GNS3 projekt fileok](https://bmeedu-my.sharepoint.com/:f:/g/personal/dengyel_b_edu_bme_hu/Epaqy3DbUINAujsJr4uuJrwB_lLvTGTR-QPHntcrUNYCig?e=ABxVVR)

---

## [GNS3 topológia](GNS3_NW_topo.md)

![](pictures/GNS3_topology.png)

---

### TODOs
- PULL!!!
- MARCI: ryu működése
- BENDE: router ovs ping?
- BENDE: save conifg on OVS and Ryu
- következő teendők kitűzése
- projekt feltölteni
- COMMIT AND PUSH!!!

---

### OVS:
- set port vlan tag: https://medium.com/@arrosid/vlan-configuration-on-open-vswitch-83459d8c0cfc
- set port ip address: https://docs.openvswitch.org/en/latest/faq/vlan/

### Ryu:
- ip cím konfig: 192.168.122.111
- default route
- dns konfig
- ezután apt update + többi cucc ryu_init.sh-ból

File felmásolás ryura:
- ryu configban (gns3) létrehozni shareed foldert
- jobb klikk, file manager
- itt berakni shared folderbe a cuccokat
- ryuból ezeket eléred a gns3volumes mappában

### Internet GNS 3:
- cloud (virbr0 interfész)
- router
- ezek összekötnni
- dhcp címet kérni
- natolás
- https://docs.gns3.com/docs/using-gns3/advanced/connect-gns3-internet/
- https://www.yourictmagazine.com/howtos/434-basics-to-configure-a-cisco-router-to-connect-to-internet
