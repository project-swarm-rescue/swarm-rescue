

wifi.eventmon.register(wifi.eventmon.STA_CONNECTED,function()
	print("connected to ap")

	--bring servo to middle(TODO)
	
	if wifi.sta.getrssi() <-60 then
		step=4
		dir_move(step)
	end

end)

wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED,function()
print("Disconnected from ap")
end)

wifi.setmode(wifi.STATION)

--station configuration
sta_cfg= {}
sta_cfg.ssid = "esp123"
sta_cfg.pwd="connecthere"
wifi.sta.config(sta_cfg)

--wheel setup
--specifying motorpins
motorpins={}
motorpins.left1=1
motorpins.left2=2
motorpins.right1=6
motorpins.right2=5

pwm_freq = 150
pwm_duty = 375
--setup of pwm for motorpins
pwm.setup(motorpins.left1,pwm_freq,0)
pwm.setup(motorpins.left2,pwm_freq,0)
pwm.setup(motorpins.right1,pwm_freq,0)
pwm.setup(motorpins.right2,pwm_freq,0)
pwm.start(motorpins.left1)
pwm.start(motorpins.left2)
pwm.start(motorpins.right1)
pwm.start(motorpins.right2)

--setting pwm to perform bot movements
function left()
        pwm.setduty(motorpins.left1,0)
        pwm.setduty(motorpins.left2,pwm_duty)
        pwm.setduty(motorpins.right1,pwm_duty)
        pwm.setduty(motorpins.right2,0)
        print("left")
end
function right()
    pwm.setduty(motorpins.left1,pwm_duty)
    pwm.setduty(motorpins.left2,0)
    pwm.setduty(motorpins.right1,0)
    pwm.setduty(motorpins.right2,pwm_duty)
    print("right")
end

function forward()  
    pwm.setduty(motorpins.left1,pwm_duty)
    pwm.setduty(motorpins.left2,0)
    pwm.setduty(motorpins.right1,pwm_duty)
    pwm.setduty(motorpins.right2,0)
    print("forward")
end
function reverse()
	pwm.setduty(motorpins.left1,pwm_duty)
    pwm.setduty(motorpins.left2,0)
    pwm.setduty(motorpins.right1,pwm_duty)
    pwm.setduty(motorpins.right2,0)
    print("reverse")
end

function stop()
    pwm.setduty(motorpins.left1,0)
    pwm.setduty(motorpins.left2,0)
    pwm.setduty(motorpins.right1,0)
    pwm.setduty(motorpins.right2,0)
    print("stopped")
end

step_timer=tmr.create()



dir_move=function(step)
	
	step_timer:alarm(2000, tmr.ALARM_AUTO,function()

		if step==4 then
			a1_rssi= wifi.sta.getrssi()
			forward()
			step=step-1
		else if step==3 then
			step_timer:unregister()
			heading1=compass_reading()
			target_heading = heading1-90
			if (target_heading<0) then
				target_heading=target_heading+360
			a2_rssi=wifi.sta.getrssi()
			left()
			turn_timer=tmr.create()
			turn_timer:alarm(100,tmr.ALARM_AUTO,function()
				heading2=compass_reading()
				if(heading2<=target_heading) then
					stop()
					turn_timer:unregister()
					dir_move()
				end
			end)
			step=step-1
		else if step==2 then
			b1_rssi=wifi.sta.getrssi()
			forward()
			step=step-1
		else if step==1 then
			b2_rssi= wifi.sta.getrssi()
			if a2_rssi-a1_rssi==0 then
				keep_moving()
			else
				reverse()
				step=step-1
			end
		else 
			req_heading=math.atan((a2_rssi-a1_rssi)/(b2_rssi-b1_rssi))


	end)

keep_moving = function()
	forward()
	keep_checking_timer == tmr.create()
	keep_checking_timer:alarm(200,tmr.ALARM_AUTO,function()
		rssi = wifi.sta.getrssi()
		if rssi>-60 then
			stop()--change to servo_nav later
		end
	end)
end	

compass_reading=function ()
	x,y,z=hmc5883l.read

	--conversions
	return heading_angle
end
