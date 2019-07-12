servoPin=7
duty=26
N=103

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

function avg_findMax()
    for i=1,N,1 do
        RSSI_AVG[i] = (RSSI[1][i] +RSSI[2][i] )/2
        print(i.." "..RSSI[1][i].." "..RSSI[2][i].." "..RSSI_AVG[i],'\n')
    end
    for i=1,N,1 do
        if RSSI_AVG[i]>MAX_RSSI then
            MAX_RSSI = RSSI_AVG[i]
            KEY_MAX = i
         end
    end
    pwm.setduty(servoPin,KEY_MAX +25)
    print("key max"..KEY_MAX.." RSSI_MAX"..MAX_RSSI)
    
end
dir=1
function read_move()
  --setup code to reverse direction if false
    rssi_val = wifi.sta.getrssi()
    print(rssi_val)
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

wifi.eventmon.register(wifi.eventmon.STA_CONNECTED,function()
pwm.setup(servoPin,50,duty)
print("connected")
pwm.start(servoPin)
timer=tmr.create()
timer:alarm(700,tmr.ALARM_AUTO,read_move)
end)

wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED,function()
print("Disconnected")
end)

wifi.setmode(wifi.STATION)
cfg= {}
cfg.ssid = "esp"
cfg.pwd="connecthere"
wifi.sta.config(cfg)
