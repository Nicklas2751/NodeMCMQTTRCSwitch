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

function startListen()
  log('Start listening...')
--  MQTTC:publish(config.topic.inp.path,'Test',config.topic.inp.qos,config.topic.inp.retain)
  MQTTC:subscribe(config.topic.switch433mhz.path,config.topic.switch433mhz.qos,function(conn)
    log('Conntected to:'..config.topic.switch433mhz.path)
  end)

  MQTTC:on("message", function(conn, topic, data)
    log('debug msg for:'..topic)
    if data ~= nil and topic == config.topic.switch433mhz.path then
      -- do something, we have received a message
      log("Recived: "..data)
      rc.send(4,data,24,185,1,10) --Sends the data via GPIO pin 4 to the rc switch.
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
