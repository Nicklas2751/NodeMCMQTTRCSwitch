-------------------------------------------------------------------------------
-- Script to run 433mhz switch with Lua on NodeMCU
-- https://github.com/nicklas2751/
--
-- Copyright (c) 2017, Nicklas2751
-- MIT LICENSE
--
-- Authors:
-- Nicklas2751
-------------------------------------------------------------------------------

wifi.setmode(wifi.NULLMODE)
print('WSS started')

-------------------------------------------------------------------------------
-- load configuration file
-------------------------------------------------------------------------------

config                    = {}
config.net                = {}
config.broker             = {}
config.topic              = {}
config.topic.switch433mhz = {}
config.codes              = {}
config.codes.device1      = {}
config.codes.device2      = {}
config.codes.device3      = {}
config.codes.device4      = {}

dofile('config.lua')

-------------------------------------------------------------------------------
-- utility functions
-------------------------------------------------------------------------------

-- prints a message on serial and publishes to MQTT if available
function log(msg)
  print(msg)
  if(MQTTON) then
    MQTTC:publish(config.topic.switch433mhz.path..'log',msg,config.topic.switch433mhz.qos,config.topic.switch433mhz.retain)
  end
end

-------------------------------------------------------------------------------
-- callback functions
-------------------------------------------------------------------------------
function gotip()
  log('IP: '..wifi.sta.getip())

  MQTTC = mqtt.Client(config.broker.clientid,60,config.broker.user,config.broker.pass,true)

  MQTTC:lwt(config.topic.switch433mhz.path..'log','keepalive timed out',config.topic.switch433mhz.qos,config.topic.switch433mhz.retain)
  MQTTC:on('connect',mqtt_connected)
  MQTTC:on('offline',mqtt_offline)

  MQTTC:connect(config.broker.addr,config.broker.port,config.broker.useSSL,true)
end

function mqtt_connected(client)
  MQTTON = true
  log('MQTT connected')
  startListen()
end

function mqtt_offline(client)
  MQTTON = false
  log('MQTT disconnected')
end

function sendCode(code)
  rc.send(4,code,24,185,1,2) --Sends the data via GPIO pin 4 to the rc switch.
end

function startListen()
  log('Start listening...')
--  MQTTC:publish(config.topic.inp.path,'Test',config.topic.inp.qos,config.topic.inp.retain)
  MQTTC:subscribe(config.topic.switch433mhz.path,config.topic.switch433mhz.qos,function(conn)
    log('Conntected to:'..config.topic.switch433mhz.path)
  end)

  MQTTC:on("message", function(conn, topic, data)
    if data ~= nil and topic == config.topic.switch433mhz.path then
      log("Recived: "..data)

      --Set off
      if data == "10" then -- Device 1 off
        sendCode(config.codes.device1.off)
      elseif data == "20" then -- Device 2 off
        sendCode(config.codes.device2.off)
      elseif data == "30" then -- Device 3 off
        sendCode(config.codes.device3.off)
      elseif data == "40" then -- Device 4 off
        sendCode(config.codes.device4.off)
      
      --Set on
      elseif data == "11" then -- Device 1 on
        sendCode(config.codes.device1.on)
      elseif data == "21" then -- Device 2 on
        sendCode(config.codes.device2.on)
      elseif data == "31" then -- Device 3 on
        sendCode(config.codes.device3.on)
      elseif data == "41" then -- Device 4 on
        sendCode(config.codes.device4.on)
      
      --Special commands
      elseif data == "restart" then -- Restart the nodeMCU
        node.restart()
      else
        log("Got invalid data: "..data)
        log("-------------------------")
        log("This are the codes for the devices: ")
        log("Device 01: 10 OFF | 11 ON")
        log("Device 02: 20 OFF | 21 ON")
        log("Device 03: 30 OFF | 31 ON")
        log("Device 04: 40 OFF | 41 ON")
        log("-------------------------")
        log("This are the special commands:")
        log("restart    | Restarts the nodeMCU")
        log("-------------------------")
      end
      
    end
  end)
end

-------------------------------------------------------------------------------
-- main routine
-------------------------------------------------------------------------------

-- initializing global vars
MQTTON = false

-- configuring network
wifi.setmode(wifi.STATION)
wifi.sta.config(config.net.ssid,config.net.pass,0)
ssid, _, _, _ = wifi.sta.getconfig()
log('WiFi configuration:')
log('SSID: '..ssid)
ssid = nil

wifi.sta.eventMonReg(wifi.STA_IDLE, function() log('STATION_IDLE') end)
wifi.sta.eventMonReg(wifi.STA_CONNECTING, function() log('STATION_CONNECTING') end)
wifi.sta.eventMonReg(wifi.STA_WRONGPWD, function() log('STATION_WRONG_PASSWORD') end)
wifi.sta.eventMonReg(wifi.STA_APNOTFOUND, function() log('STATION_AP_NOT_FOUND') end)
wifi.sta.eventMonReg(wifi.STA_FAIL, function() log('STATION_CONNECT_FAILED') end)
wifi.sta.eventMonReg(wifi.STA_GOTIP,gotip)
wifi.sta.eventMonStart()

wifi.sleeptype(wifi.LIGHT_SLEEP)
wifi.sta.sethostname(config.net.hostname)
log('hostname: '..wifi.sta.gethostname())
wifi.sta.connect()
log('WIFI started')
log('MAC: '..wifi.sta.getmac())

-- now everything is handled by callback functions
