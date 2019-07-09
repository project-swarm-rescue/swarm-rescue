mode=wifi.setmode(wifi.STATION)
print(mode,'\n')
station={}
station.ssid="OnePlus 6T"
station.pwd="12345678"
wifi.sta.config(station)
wifi.eventmon.register(wifi.eventmon.STA_CONNECTED,function()
print("Connected",'\n')
timer=tmr.create()
timer:alarm(500,tmr.ALARM_AUTO,func1)
end)
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED,function()
print("Disconnected",'\n')
end)
function func1()
    
end
left1=1
left2=2
right1=5
right2=6
pwm_duty=500
pwm.setup(left1,100,0)
pwm.setup(left2,100,0)
pwm.setup(right1,100,0)
pwm.setup(right2,100,0)
pwm.start(left1)
pwm.start(left2)
pwm.start(right1)
pwm.start(right2)

function forward()
    pwm.setduty(left1,pwm_duty)
    pwm.setduty(left2,0)
    pwm.setduty(right1,pwm_duty)
    pwm.setduty(right2,0)
end
function reverse()
    pwm.setduty(left1,0)
    pwm.setduty(left2,pwm_duty)
    pwm.setduty(right1,0)
    pwm.setduty(right2,pwm_duty)
end
function right()
    pwm.setduty(left1,0)
    pwm.setduty(left2,pwm_duty)
    pwm.setduty(right1,pwm_duty)
    pwm.setduty(right2,0)
end
function left()
    pwm.setduty(left1,pwm_duty)
    pwm.setduty(left2,0)
    pwm.setduty(right1,0)
    pwm.setduty(right2,pwm_duty)
end     