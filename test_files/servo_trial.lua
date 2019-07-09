
servopin =8
a=10
pwm.setup(servopin,50,a)

pwm.start(servopin)

timer = tmr.create()
timer:alarm(3000,tmr.ALARM_AUTO,function()

print(a) 
pwm.setduty(servopin,a)

if a ==130 then 
timer:unregister()
end

a=a+10
end)
