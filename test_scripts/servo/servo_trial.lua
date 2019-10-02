
servopin =7
angle =0
pwm.setup(servopin,50,angle)

pwm.start(servopin)


function angle_servo()
print(angle.." degrees")
local duty = 25.575 + (angle/180)*102.3
pwm.setduty(servopin,duty)
end

timer = tmr.create()
timer:alarm(3000,tmr.ALARM_AUTO,function()

if angle == 180 then
timer:unregister()
end
angle_servo()
angle=angle+1
end)
