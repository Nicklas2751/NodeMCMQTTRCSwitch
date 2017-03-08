-- network config
config.net.ssid            = 'Herzausgold'
config.net.pass            = 'herzausgold'
config.net.hostname        = 'WSS-'..node.chipid()

-- MQTT broker config
config.broker.addr         = 'mqtt.local'
config.broker.port         = '1883'
config.broker.useSSL       = false
config.broker.clientid     = config.net.hostname
config.broker.user         = ''
config.broker.pass         = ''

-- Topic config

config.topic.switch433mhz.path      = 'switches/433mhz/' -- include trailing slash!
config.topic.switch433mhz.qos       = 0
config.topic.switch433mhz.retain    = 0

-- Codes
config.codes.device1.on     = 4527445
config.codes.device1.off    = 4527444

config.codes.device2.on     = 4539733
config.codes.device2.off    = 4539732

config.codes.device3.on     = 4542805
config.codes.device3.off    = 4542804

config.codes.device4.on     = 4543573
config.codes.device4.off    = 4543572
