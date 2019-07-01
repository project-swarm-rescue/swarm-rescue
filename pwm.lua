wifi.eventmon.register(wifi.eventmon.STA_CONNECTED,function(t)
print(t.SSID)
print("Connected")
timer=tmr.create()
timer:alarm(1000,tmr.ALARM_AUTO,main_func)
end)

wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED,function(t)
print(t.ssid)
print("Disconnected")
end)

wifi.eventmon.register(wifi.eventmon.AP_STACONNECTED,function(t)
print(t.MAC)
print("AP on and connected b")
end)

motorpins={}
motorpins.left1=1
motorpins.left2=2
motorpins.right1=6
motorpins.right2=5


pwm.setup(motorpins.left1,100,0)
pwm.setup(motorpins.left2,100,0)
pwm.setup(motorpins.right1,100,0)
pwm.setup(motorpins.right2,100,0)
pwm.start(motorpins.left1)
pwm.start(motorpins.left2)
pwm.start(motorpins.right1)
pwm.start(motorpins.right2)
prev_RSSI=-1000
num=0
function main_func()
current_RSSI=wifi.sta.getrssi()
print(prev_RSSI,'\t',current_RSSI,'\n')

if num ==0 then
    if current_RSSI>prev_RSSI then
        pwm.setduty(motorpins.left1,0)
        pwm.setduty(motorpins.left2,500)
        pwm.setduty(motorpins.right1,500)
        pwm.setduty(motorpins.right2,0)
        print("turning left",'\n')
    
    else
        pwm.setduty(motorpins.left1,500)
        pwm.setduty(motorpins.left2,0)
        pwm.setduty(motorpins.right1,0)
        pwm.setduty(motorpins.right2,500)
        print("turning right",'\n')
        num=1
    end

else
        pwm.setduty(motorpins.left1,500)
        pwm.setduty(motorpins.left2,0)
        pwm.setduty(motorpins.right1,500)
        pwm.setduty(motorpins.right2,0)
    print("Going straight",'\n')
    num=num-1
end
prev_RSSI=current_RSSI
end
mode=wifi.setmode(wifi.STATIONAP)

print(mode,'\n')

sta={}
sta.ssid="OnePlus 6T"
sta.pwd="12345678"
wifi.sta.config(sta)

ap={}
ap.ssid="NODE_MCU"
ap.pwd="connecthere"
config=wifi.ap.config(ap)






