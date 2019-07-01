wifi.eventmon.register(wifi.eventmon.STA_CONNECTED,function(t)
print(t.SSID)
print("Connected")
timer=tmr.create()
timer:alarm(500,tmr.ALARM_AUTO,main_func)
end)

wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED,function(t)
print(t.ssid)
print("Disconnected")
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
RSSI_1=0
RSSI_2=0
num=3
duty_cycle = 300
flag=0
function main_func()
if wifi.sta.getrssi()>-30 then
        pwm.setduty(motorpins.left1,0)
        pwm.setduty(motorpins.left2,0)
        pwm.setduty(motorpins.right1,0)
        pwm.setduty(motorpins.right2,0)
end
if flag==1 then
        pwm.setduty(motorpins.left1,0)
        pwm.setduty(motorpins.left2,duty_cycle )
        pwm.setduty(motorpins.right1,duty_cycle )
        pwm.setduty(motorpins.right2,0)
        print("turning left",'\n')
        flag=0
        num=3
else
if num==3 then
        pwm.setduty(motorpins.left1,0)
        pwm.setduty(motorpins.left2,duty_cycle )
        pwm.setduty(motorpins.right1,duty_cycle )
        pwm.setduty(motorpins.right2,0)
        print("turning left",'\n')
        num=num-1

elseif num==2 then
        RSSI_1=wifi.sta.getrssi()
        print("left rssi value="..RSSI_1..'\n')
        pwm.setduty(motorpins.left1,duty_cycle )
        pwm.setduty(motorpins.left2,0)
        pwm.setduty(motorpins.right1,0)
        pwm.setduty(motorpins.right2,duty_cycle )
        print("turning right",'\n')
        num=num-1

elseif num==1 then
        pwm.setduty(motorpins.left1,duty_cycle )
        pwm.setduty(motorpins.left2,0)
        pwm.setduty(motorpins.right1,0)
        pwm.setduty(motorpins.right2,duty_cycle )
        print("turning right",'\n')
        num=num-1

elseif num==0 then    
        RSSI_2=wifi.sta.getrssi()
        print("right rssi value = "..RSSI_2..'\n')
        if math.abs(RSSI_1-RSSI_2)<=1  then
            pwm.setduty(motorpins.left1,0)
            pwm.setduty(motorpins.left2,duty_cycle )
            pwm.setduty(motorpins.right1,duty_cycle )
            pwm.setduty(motorpins.right2,0)
            print("turning left",'\n')    
            num=5
        
        elseif RSSI_2>RSSI_1 then
            num=3
        else
            pwm.setduty(motorpins.left1,0)
            pwm.setduty(motorpins.left2,duty_cycle )
            pwm.setduty(motorpins.right1,duty_cycle )
            pwm.setduty(motorpins.right2,0)
            print("turning left",'\n') 
            flag=flag+1
    
        end

elseif num>3 then
        pwm.setduty(motorpins.left1,duty_cycle )
        pwm.setduty(motorpins.left2,0)
        pwm.setduty(motorpins.right1,duty_cycle )
        pwm.setduty(motorpins.right2,0)
        print("Going straight",'\n')
        num=num-1        
end        
end       
end
mode=wifi.setmode(wifi.STATIONAP)

print(mode,'\n')

sta={}
sta.ssid="OnePlus 6T"
sta.pwd="12345678"
wifi.sta.config(sta)







