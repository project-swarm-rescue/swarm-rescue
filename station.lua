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


gpio.mode(motorpins.left1,gpio.OUTPUT)
gpio.mode(motorpins.left2,gpio.OUTPUT)
gpio.mode(motorpins.right1,gpio.OUTPUT)
gpio.mode(motorpins.right2,gpio.OUTPUT)

prev_RSSI=-1000
num=0
function main_func()
current_RSSI=wifi.sta.getrssi()
print(prev_RSSI,'\t',current_RSSI,'\n')
if num ==0 then
    if current_RSSI>prev_RSSI then
        gpio.write(motorpins.left1,gpio.LOW)
        gpio.write(motorpins.left2,gpio.HIGH)
        gpio.write(motorpins.right1,gpio.HIGH)
        gpio.write(motorpins.right2,gpio.LOW)
        print("turning left",'\n')
    
    else
        gpio.write(motorpins.left1,gpio.HIGH)
        gpio.write(motorpins.left2,gpio.LOW)
        gpio.write(motorpins.right1,gpio.LOW)
        gpio.write(motorpins.right2,gpio.HIGH)
        print("turning right",'\n')
        num=2
    end

else
    gpio.write(motorpins.left1,gpio.HIGH)
    gpio.write(motorpins.left2,gpio.LOW)
    gpio.write(motorpins.right1,gpio.HIGH)
    gpio.write(motorpins.right2,gpio.LOW)
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






