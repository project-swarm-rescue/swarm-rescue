
--functions used all across files

--motorpins setup
motor_pwm_freq=100

left1=1
left2=2
right1=5
right2=6

pwm.setup(left1,motor_pwm_freq,0)
pwm.setup(left2,motor_pwm_freq,0)
pwm.setup(right1,motor_pwm_freq,0)
pwm.setup(right2,motor_pwm_freq,0)

pwm.start(left1)
pwm.start(right1)
pwm.start(left2)
pwm.start(right2)

function forward()
	pwm.setduty(left1,pwm_duty)
	pwm.setduty(left2,0)
	pwm.setduty(right1,pwm_duty)
	pwm.setduty(right2,0)
end

function left()
	pwm.setduty(left1,0)
	pwm.setduty(left2,pwm_duty)
	pwm.setduty(right1,pwm_duty)
	pwm.setduty(right2,0)
end

function right()
	pwm.setduty(left1,pwm_duty)
	pwm.setduty(left2,0)
	pwm.setduty(right1,0)
	pwm.setduty(right2,pwm_duty)
end

function backward()
	pwm.setduty(left1,0)
	pwm.setduty(left2,pwm_duty)
	pwm.setduty(right1,0)
	pwm.setduty(right2,pwm_duty)
end

function stop()
	pwm.setduty(left1,0)
	pwm.setduty(left2,0)
	pwm.setduty(right1,0)
	pwm.setduty(right2,0)
end

function compass_reading()
end
