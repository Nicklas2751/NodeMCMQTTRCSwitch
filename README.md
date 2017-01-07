# NodeMCMQTTRCSwitch
Lua scripts to control 433mhz rc switches via MQTT


## How it works
The scripts using the NodeMCU modul "rc" which is eqaul to the rcswitch libary. To turn a 433mhz rc switch on or of the right code have to been send on the right gpio pin. For me its GPIO 4 and a pulse length of 185. Each of my codes has a length of 24. Because I have an "Type B" (See [RCSwitch](https://github.com/sui77/rc-switch/wiki/HowTo_OperateLowCostOutlets)) i had to convert my House and device codes to the deciaml format. For this I copied the functions `sendTriState` and `getCodeWordB` of RCSwitch in a new C++ file and generated the codes for my devices.

This is what my nodeMCU does:
1. Connect to local WLAN
2. Connect to MQTT Server
3. Log informations to local console and to "switches/433mhz/log"
3. Listen to topic "switches/433mhz/"
4. If got a message send it as data code with "rc" 

So i only have to send my device codes via MQTT to the topic "switches/433mhz"

## How to get it run

1. You need a NodeMCU Firmware with MQTT and "rc"
2. Edit the WLAN settings in the config.lua
3. Edit the MQTT broker informations in the config.lua
4. Set the topic of your choice in the config.lua
5. If needed change the rc settings in line 76 of run.lua
 - The call works so: `rc.send([GPIO-Pin-number],[DeciamlCode including house- and devicecode and if it should be on or off], [Pules length], [protocol number], [repeat x times])`
  - For more informations to this part see: https://github.com/nodemcu/nodemcu-firmware/pull/478 and [RCSwitch](https://github.com/sui77/rc-switch/wiki/HowTo_OperateLowCostOutlets)
