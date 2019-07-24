servoPin=8
duty=26
N=96


RSSI = {}  -- create the matrix
for i=1,N do
      RSSI[i] = {}     -- create a new row
      for j=1,2 do
        RSSI[i][j] = 0
      end
    end
RSSI_AVG = {}
k=1
MAX_RSSI = -1000
KEY_MAX = 1
rssidatastring=""
function avg_findMax()
    for i=1,N,1 do
        RSSI_AVG[i] = (RSSI[1][i] +RSSI[2][i] )/2
        print(i.." "..RSSI[1][i].." "..RSSI[2][i].." "..RSSI_AVG[i],'\n')
        rssidatastring=rssidatastring..i.." "..RSSI[1][i].." "..RSSI[2][i].." "..RSSI_AVG[i].."<br>"

    end
    for i=1,N,1 do
        if RSSI_AVG[i]>MAX_RSSI then
            MAX_RSSI = RSSI_AVG[i]
            KEY_MAX = i
         end
    end
    pwm.setduty(servoPin,KEY_MAX +25)
    print("key max"..KEY_MAX.." RSSI_MAX"..MAX_RSSI)

    --wifi.setmode(wifi.SOFTAP)
    wifi.sta.disconnect()
    wifi.ap.config(ap_cfg)    
    server = net.createServer(net.TCP)-- create TCP server
    

    if server then
      server:listen(80, function(conn)-- listen to the port 80
      conn:on("receive", receiver)
      end)
    end

end
dir=1
function read_move()
  --setup code to reverse direction if false
    rssi_val = wifi.sta.getrssi()
    print(k..' '..rssi_val)
    if dir==1 then
        RSSI[1][k] =rssi_val
        if k==N then
            dir = -1    
        else
            pwm.setduty(servoPin,k+26)
        end 
    end      
    if dir ==-1 then
        RSSI[2][k] =rssi_val
        if k==1 then
            timer:unregister()
            avg_findMax()
        else
            pwm.setduty(servoPin,k+24)
        end
    end     
   k = k+dir   
end

wifi.eventmon.register(wifi.eventmon.AP_STACONNECTED,function(T)
    print('STATION CONNECTED MAC: '..T.MAC)
end)
wifi.eventmon.register(wifi.eventmon.AP_STADISCONNECTED,function(T)
  print('STATION DISCONNECTED MAC: '..T.MAC)
end)

wifi.eventmon.register(wifi.eventmon.STA_CONNECTED,function()
pwm.setup(servoPin,50,duty)
print("connected to ap")
pwm.start(servoPin)
timer=tmr.create()
timer:alarm(1000,tmr.ALARM_AUTO,read_move)
end)

wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED,function()
print("Disconnected from ap")
end)

wifi.setmode(wifi.STATIONAP)

--station configuration
sta_cfg= {}
sta_cfg.ssid = "esp456"
sta_cfg.pwd="connecthere"
wifi.sta.config(sta_cfg)

--ap config
ap_cfg={}
ap_cfg.ssid = "esp2"
ap_cfg.password = "connecthere1"

config_ip = {}  -- set IP,netmask, gateway
config_ip.ip = "192.168.2.2"
config_ip.netmask = "255.255.255.0"
config_ip.gateway = "192.168.2.2"
wifi.ap.setip(config_ip)

--RESPONSE TO REQUESTS
function receiver(sck,data) -- Send LED on/off HTML page
   
   htmlstring = [[<!DOCTYPE html>
                       <html>
                        <head>
                            <title>RSSI data</title>
                        </head>
                        <body>
                            <h1>RSSI data</h1>]]
    htmlstring = htmlstring..rssidatastring
    htmlstring=htmlstring..[[</body>
                    </html>
                ]]
   sck:send(htmlstring)
end

