

function sta_connect_cb(T)
    print('STATION CONNECTED MAC: '..T.MAC)
end

wifi.eventmon.register(wifi.eventmon.AP_STACONNECTED,sta_connect_cb)

wifi.setmode(wifi.SOFTAP)
ap_cfg={}
ap_cfg.ssid = "esp"
ap_cfg.password = "connecthere"
wifi.ap.config(ap_cfg)


config_ip = {}  -- set IP,netmask, gateway
config_ip.ip = "192.168.2.1"
config_ip.netmask = "255.255.255.0"
config_ip.gateway = "192.168.2.1"
wifi.ap.setip(config_ip)

server = net.createServer(net.TCP)-- create TCP server

function SendHTML(sck) -- Send LED on/off HTML page
   
   htmlstring = [[<!DOCTYPE html>
   					<html>
   						<head>
   							<title>RSSI collection</title>
   						</head>
   						<body>
   							<h1>RSSI data</h1>\r\n]]
   	
   	htmlstring=htmlstring..[[</body>
   					</html>
   				]]
   sck:send(htmlstring)
end

function receiver(sck,data)
  SendHTML(sck)
end

if server then
  server:listen(80, function(conn)-- listen to the port 80
  conn:on("receive", receiver)
  end)
end
