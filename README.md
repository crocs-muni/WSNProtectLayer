WSNProtectLayer
===============

TinyOS layer for configurable protection of message privacy, intrusion detection and key distribution

Design and implementation was supported by project VG20102014031 of Ministry of Interior, Czech Republic
"Experimentální vývoj bezpečnostní softwarové platformy se systémem detekce průniku a režimy ochrany soukromí pro bezdrátové senzorové sítě" (in Czech)

===============
##How to get ProtectLayer##
- Fork your own repository (at Github)
- or create local clone of repository (desktop)
- or download all sources in single zip file (Download ZIP)

===============
##What you will get##

**Core components**
- ProtectLayer ... implementation of ProtectLayer middleware with all core functions. Other applications are wired against this implementation
- ProtectLayerConfigurator ... configuration application responsible for storage of cryptographic keys into flash memory during predistribution
- Uploader ... server side Java application communicating with ProtectLayerConfigurator and providing predistributed keys

**Scenario-specific applications**
- PL_BaseStation ... base station node with ProtectLayer middleware 
- PL_BlinkToRadio ... testing application with network communication with ProtectLayer middleware 
- PL_PoliceApp ... application for ordinary nodes inside network. Supports detection of MSNs, emitting still alive packets
- IntruderApp ... application used for special nodes used as mobile beacon reported to BS (MSN, virtual attacker)   

**Hardware extensions**
- Zilog ... application with ability to sample and respond on movement detection sensor Zilog ePir
- rfid ... application with ability to sample and respond on wireless card close to connected RFID reader

**Management and statistics gathering applications** 
- ManagementApp ... set of server-side scripts for batch control of nodes 
- TOSCTP ... application usable for testing CTP routing discover protocol performance
- rssi_csv_to_tossim ... application usable for testing signal propagation and RSSI 
- BlinkNodeIDApp ... testing application without any network communication. Node blinks its own ID

===============
##How to use it##

- Compile and upload Base station node: 
```
  cd /tinyos/PL_BaseStation/src
  make telosb install,14 bsl,/dev/ttyUSB0
  run listener:java net.tinyos.tools.PrintfClient -comm serial@/dev/ttyUSB0:telosb
```
- Wire ProtectLayer instead of AMSend and Receive interfaces
```
  components ProtectLayerC;
  App.Packet -> ProtectLayerC.Packet; 
  App.AMControl -> ProtectLayerC.AMControl;
  App.AMSend -> ProtectLayerC.AMSend;
  App.Receive -> ProtectLayerC.Receive;
```
- Compile and upload Ordinary node with your application (e.g., PL_PoliceApp): 
```
  cd /tinyos/PL_PoliceApp/src
  make telosb install,21 bsl,/dev/ttyUSB1
  run listener:java net.tinyos.tools.PrintfClient -comm serial@/dev/ttyUSB1:telosb
```
- Compile and upload Sniffer for additional network informations (raw packets): 
```
  cd /opt/tinyos-2.1.1/apps/BaseStation
  make telosb install,14 bsl,/dev/ttyUSB2
  run listener: java net.tinyos.tools.Listen -comm serial@/dev/ttyUSB2:telosb
```
