Márton:
	Linux 2
	R3
	R4
	
Bendegúz:
	Linux 1
	R1
	R2
	
Szabó Csaba git repója: https://github.com/lordworld/szabo_csaba_thesis/blob/main/linux_config.sh
	(ez az általa írt LEGFRISSEBB script, itt ugyan kellet pár hibát kijavítani, de alapvetően futott (és a hálózatot leterhelte))

Routerek:
	módosítottuk a 4 router configját (R1-R4.config)
	mivel a routerek direkt összeköttetései (GigEth 1-3) nem használhatók vlannak, ezeket kihagytuk, és a vlanokat a GigEth6 szubinterfészein húztuk fel
		természetesen a direkt linkek (GigEth 1-3) címezhetőek, és pingelik is egymást, de vlan nem működik itt
	ezután a pingek működtek
	a routerek egy speciális, rejtett összeköttetéssel vannak összekötve (esxitopo.pdf), ezek szerint kell összekötni a lábakat
		részletesebb ábra a topológiáról: esxitopo_addresses.jpg
	a 999 vlanon keresztül érhető (lenne) el a külvilág
		minden routernek 10.255.255.0/24 tartományból adtunk címet (a default gw 10.255.255.1)
	

A környezet felépítésének lépései:
	1. OpenVpn letöltése, fájlok bemásolni a /config mappába (tanár odaadja, ami kell)
	
	2. a megadott jelszóval belépni ide: https://vme1.hit.bme.hu/
	
	3. érdemes letölteni a VMRC (VMware Remote Console) klienst a könnyebb munkához (ingyenes, max regisztrálni kell)
	
	4. a linuxokat a default beállításokkal feltelpíteni (itt jelszó/felhasználónév: linux1/linux1 és linux2/linux2)
		+ snapshotot is érdemes csinálni
		
	!!! LINUX_CONFIG.SH HELYETT FRISEBB KONFIGOK: DOCKER_ENV_SETUP.SH, DOCKER_ENV_START.SH !!!
		a "SAJÁT VM KÖRNYEZETBEN" részben jobban kifejtve
		
	
	5. az inicializáló bash scripteket .iso-vá alakítani, majd felmásolni (VMRC/removable devices/cd dvd drive): https://www.lifewire.com/how-to-mount-dvds-and-cd-roms-using-ubuntu-4075034
		+ unmountolni, miután csináltunk egy másolatot pl a /scripts/DOCKER_ENV_SETUP.SH néven, (ebből lehet +1 másolatot is akár)
	
	6. előfordulhat, hogy nem akarja a futtatni, ekkor az alábbi kód segíthet (miután a "sudo chmod a+wrx <script_nev>" parancsot kiadtuk): sed -i -e 's/\r$//' DOCKER_ENV_SETUP.SH
		ezután futtaható a --help kapcsolóval
		A scriptify.sh <script név> a jogosultságokat és a "sed-elést" megoldja, akkor a fentieket nem kell kézzel kiadni.
	
	7. INTERNET A LINUXOKRA:
		a 999 vlanon keresztül érhető el a külvilág
		ehhez a /scripts/vlan_up.sh scriptet készítettük, melyet a sudo ./vlan_up.sh linux1 (vagy linux2) paranccsal futtatunk
		ezt mindig le kell futtatni, ha a gép indul, mert nem permanens, cserébe nem marad nyitva a belső hálózat a világ fele (NEM BUG, HANEM FEATURE)
		a (tanszéki) nameserver(eke)t a /etc/resolv.conf fájlban állítottuk be: https://support.nordvpn.com/Connectivity/Linux/1134945702/Change-your-DNS-servers-on-Linux.htm
	
		HA AZ INTERNET ELMEGY: az oka nálunk (és Csabánál is valószínűleg) az volt, hogy a konténerek hatalmas forgalmat generálnak valami hálózati félrekonfigurálás végett.
		Emiatt ha lekapcsoljuk az OVS-eket, akkor a hálózat terheltége megszűnik/lecsökken. Tehát internet van, csak annyira terhelt a belső hálózat, hogy pl. a pingek nem jutnak ki.
		A hiba megoldásán (a loop megszakításán) dolgozunk.
		
		Érdemes a net tools hálózat karbantartó program csomagot feltelepíteni a linuxokra (ha a net megint "elmenne" = loopba kerül a belső hálózat és telítődik).
		
		LOOP MEGOLDÁS: hibás macvlan configuráció miatt az egyik ovs és host kétszeresen össze volt kötve, hibát kijavítottuk a DOCKER_ENV_x.SH scriptekben.
	
	
	8. ezután futtatjuk a /srcipts mappában lévő DOCKER_ENV_SETUP.SH scriptet (sudo ./DOCKER_ENV_SETUP.SH linux1) - ez telepíti a dockert és letölti a konténer image-ket
		ennek lefutása után futtassuk a DOCKER_ENV_START.SH scriptet is (ami példányosítja a konténereket és létrehozza a köztük lévő kapcsolatokat).
	
	9. AUTO MOUNT:
		a fájlok másolását a linuxokra a iso_import.sh scripttel oldottuk meg, ez a VMRC-be csatolt .iso fájlt csatolja a linuxra, átmásolja azt a /home/linux1/script/mount mappába, majd lecsatolja azt
		ezután még szükség lehet a 6. pontban leírtakra, és a chmod a+x <shell script> parancs kiadására
	
	10. DOCKER:
		A docker containerek és networkok felszámolásához a "docker container prune", és a "docker network prune" parancsok használhatóak, ha leálltak már a konténerek
		A FUTÓ konténerek újraindításához a "docker restart $(docker ps -q)" aprancsot használjuk, a összes konténer újraindításához a "docker restart $(docker ps -a -q)" parancsot.
		Docker imagekről másolat készítése (ha a nettel baj lenne, lehessen dolgozni velük): https://stackoverflow.com/questions/23935141/how-to-copy-docker-images-from-one-host-to-another-without-using-a-repository
		
		UPDATE: a docker networkok a prune parancsok kiadása után mégsem vagy hibásan számolódnak fel. Helyette egyszerűbb és biztosabb megoldás, hogy a DOCKER_ENV_SETUP.SH futtatása után létrehozunk egy snapshotot, majd csak utána hozzuk létre a konténereket és kapcsolatokat a DOCKER_ENV_START.SH scripttel. Így ha bármilyen hiba lép fel, egyszerűen elég visszaállni a korábbi snapshotra és újra lefuttatni a start scriptet.
	
	11. COPY TO DOCKER:
		A szükséges fájlok felmásolásához az alábbi paranccsal (is) lehetséges:
		
			SOKSZOR NEM VOLT JÓ (a ryu konténeren, de máshol meg jól működött :( )
			sudo docker run -it --name <konténer neve> -v <felmásolandó fájl/mappa útvonala>:<konténerben hova másoljon> <image név> /bin/bash
			(a --rm kapcsoló törli is a konténert, ha ilépünk belőle)
			miután a mappát/fájl felcsaotltuk, fontos, hogy a cp (és NEM az mv) paranccsal készítsünk a felcsatolt elemekről egy másolatot, így az "kisütéskor" is rajta marad az imagen
	
			MŰKÖDŐ MÁSOLÁS:
				Hozz létre egy mappát, benne egy Dockerfile-t, és ezzel süss ki egy friss imaget, amiben a COPY dekorátorral kisütéskor másolod fel a fájlt(okat).
				Mindig újabb fájl esetén süss ki újat, így a legbiztosabb.
				A Ryu-hoz szükséges kódokat (Szabó Csaba code mappa), és még amit fel akarsz vinni (pl saját magad által írt kódok) a /code mappába másold be, amit a Dockerfile majd felmásol a konténerre.
				Pl. a docker_mappa, ezen belül a fájlok, amik kellenek (vagy teljes elérési úton adod meg őket), és egy Dockerfile nevű fájl, melynek tartalma pl.
					
					# syntax=docker/dockerfile:1
					FROM osrg/ryu
					WORKDIR /code
					COPY asd.txt .
					
				Ez az orsg/ryu imageből a /code (frissen létrehozott mappába) másolja az asd.txt-t.
				FIGYELEM! A figyelni kell, melyik könyvtárban vagy /# vagy ~/#, mert könnyű eltévedni. cd és cd.. parancs segít.
	
	12. HA NINCS HELY A GÉPEN:
		töröld a felesleges snapshotokat, a docker attól még teleszemetelheti (sudo df -h)
		a konénerek valamiért pár nap alatt minden szabad helyet felemésztenek
		érdemes egy snapshotot a DOCKER_ENV_START.SH (vagy korábban a linux_config.sh, ami már elavult) futtatása előtt kiadni, hogy ha a docker "eltörik", akkor újra lehessen futtatni a configot, ez a legtisztább módja a környezet létrehozásának (tapasztalataink szerint)
		snapshot visszaállítás után egy újraindítás ajánlott
		
	13. A ryu_init.sh scriptet is felmásoljuk (/code mappa berakjuk, mielőtt a Dockerfile alapján buildelünk) a kontrollerre, és ott futtatjuk azt!!!
		Ezzel lesz internet a ryun, és a networkx, valamint friss(ebb ?) pip, és egyéb hasznos toolok (pl. ping) települnek.
	
	Példa a ryu-manager futtatására:
		az alábbi módon letöltjük, és sp.py néven mentjük a példakódot:
			curl https://raw.githubusercontent.com/castroflavio/ryu/master/ryu/app/shortestpath.py > sp.py
		ezután (ahogy a GetStarted.txt-ben is olvasható):
			ryu-manager sp.py --observe-links
		ehhez még kell forgalom is (namespaces, hogy műküdjön ???)
	
	Példa az OVS-eken végzett műveletekre (itt pl. a controller pingelése):
		sudo docker exec ovs3 ping 172.16.0.10
		
		
	Ha namespace-ekkel dolgozol, előtte telepítsd a vlan csomagot (apt install vlan) a vconfig parancs miatt.
	
	Ha nem namespacekkel dolgozol, lehet pl. Alpine konténerekkel is, ekkor kösd őket be a host1/2/3/4 címével a megfelelő vlan-okhoz (lásd linux_config_3.sh).
	
	
	SAJÁT VM KÖRNYEZETBEN:
		előkészítettünk 2 linux imaget (linux1 és linux2 mintájára)
		ezeken a linux_config.sh egy későbbi változatát futtattuk, ahol a configot 2 részre szedtük, hogy ne kelljen mindig leszedni a dockert, imageket, és utána a config többi (de gyors részét futtatni):
			docker_env_setup.sh: leszedi a dockert, imageket, de nem csinál mást
			docker_env_start.sh: a config többi részét végzi, pl. beköti a macvlanokhoz a konténereket, elindítja őket stb.
		fontos, hogy az ens160 interfészt kézzel adtuk a linuxhoz, ha újraindítjuk, akkor ismét létre kell hozni:
			sudo ip link add ens160 type dummy; sudo ip link set dev ens160 up; sudo ip link set dev ens160 arp on
