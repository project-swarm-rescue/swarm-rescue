servopin =7
duty=120
pwm.setup(servopin,50,duty)
pwm.start(servopin)

timer = tmr.create()
timer:alarm(1000,tmr.ALARM_AUTO,function()
pwm.setduty(servopin,duty)
print(duty)
if duty == 1023 then
timer:unregister()
end
duty=duty+1
end)
