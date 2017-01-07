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
