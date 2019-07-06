pwm.setup(5,50,0)
a=0
pwm.start(5)

timer = tmr.create()
timer:alarm(2000,tmr.ALARM_AUTO,function()
a=a+10
print(a) 
pwm.setduty(5,a)
end)