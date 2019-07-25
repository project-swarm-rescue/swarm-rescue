
-- the motor pins setup and start
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


pwm_duty=500
--setting up functions for the bot movement
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


--setting up the wifi
mode=wifi.setmode(wifi.STATION)

sta={}
sta.ssid="OnePlus6T"
sta.pwd="12345678"

step=0 --setting as global variable

--registration of callbacks
--Disconnected from AP callback
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED,function(t)
print(t.ssid)
print("Disconnected from AP")
--obstacle avoid
end)

--creating timer object called step_timer
step_timer=tmr.create()
--Once connected to AP
wifi.eventmon.register(wifi.eventmon.STA_CONNECTED,function(t)
	print(t.ssid)
	print("Connected!!")
	rssi=wifi.sta.getrssi()
	if rssi<-60 then
		print("Starting far away alg")
		step=4
		step_timer:alarm(1000,tmr.ALARM_AUTO,far_movements)
	end
end)


--creating turn timer object
turn_timer=tmr.create()

--function far_movements
function far_movements(step_t)
	--moving forward
	if step==4 then
		a1_rssi=wifi.sta.getrssi()
		forward()
		step=step-1

	--turning left
	else if step==3 then
		heading_1=compass_reading()
			--identifying the target heading angle
			if heading_1-90<0 then
				heading_90=heading_1-90+360
			else
				heading_90=heading_1-90
			end	
		a2_rssi=wifi.sta.getrssi()
		step_t:unregister()
		left()
		turn_timer:alarm(100,tmr.ALARM_AUTO,function(t)
			curr_heading=compass_reading()
			if curr_heading<=heading_90 then
				stop()
				t:unregister()
			end
		end)
		step=step-1
		step_t:register(1000,tmr.ALARM_AUTO,far_movements)
	
	--moving forward
	else if step==2 then
		b1_rssi=wifi.sta.getrssi()
		forward()
		step=step-1
	--last step
	else if step==1 then
		b2_rssi=wifi.sta.getrssi()
		--checking a2_rssi-a1_rssi to avoid going back and then coming back
		if a2_rssi-a1_rssi==0 then
			forward()
			step_t:unregister()
			keep_moving_till_closer() 		
		else
			backward()
			step=step-1
		end
	else
		step_t:unregister()--steps done after all
		heading_1=compass_reading()
		a=a2_rssi-a1_rssi
		b=b2_rssi-b1_rssi
		required_angle,direction=return_angle_direction(a,b)

		if direction=='left' then 
			if heading_1-required_angle<0 then
				target_heading=heading_1-required_angle+360
			else 
				target_heading=heading_1-required_angle
			end

			left()
			turn_timer:register(100,tmr.ALARM_AUTO,function(t)
				curr_heading=compass_reading()
				if curr_heading<=target_heading then
					stop()
					t:unregister()
					keep_moving_till_closer()
				end
			end)	
		else --'right'
			if heading_1+required_angle>360 then
				target_heading=heading_1+required_angle-360
			else 
				target_heading=heading_1+required_angle
			end

			right()
			turn_timer:register(100,tmr.ALARM_AUTO,function(t)
				curr_heading=compass_reading()
				if curr_heading>=target_heading then
					stop()
					t:unregister()
					keep_moving_till_closer()
				end
			end)
		end
		
	end
end





radian_to_angle=180/math.pi
function return_angle_direction(a,b)
	if b>0 and a>0 then
		return math.atan(a/b)*radian_to_angle,'right'
	else if a<0 and b<0 then
		return 180-math.atan(a/b)*radian_to_angle,'left'
	else if a>0 and b<0 then
		return 180-math.atan(-a/b)*radian_to_angle,'right'
	else 
		return math.atan(a/-b)*radian_to_angle,'left'
	end
end




--keep moving after far away alg till rssi<threshold rssi
check_timer=tmr.create()
function keep_moving_till_closer()
	check_timer:alarm(200,tmr.ALARM_AUTO,function(c_t)
		if wifi.sta.getrssi>-60 then
			stop()
			c_t:unregister()
		end
	
	end)
end

