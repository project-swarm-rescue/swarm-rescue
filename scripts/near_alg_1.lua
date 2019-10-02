
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



--setting up wifi mode
wifi.setmode(wifi.STATION)

--station configuration
sta={}
sta.ssid="OnePlus 6T"
sta.pwd="12345678"
wifi.sta.config(sta)

--registration of callbacks
--Disconnected from AP callback
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED,function(t)
print(t.ssid)
print("Disconnected from AP")
end)

--initialsiing servopins
servopin=7
pwm.setup(servopin,50,26)
pwm.start(servopin)

--initialsiing rssi array
RSSI = {}  -- create the matrix
for i=1,N do
      RSSI[i] = {}     -- create a new row
      for j=1,2 do
        RSSI[i][j] = 0
      end
    end
RSSI_AVG = {}
--initialsing global variable
step=3
pwm_pos=26
--creating timer object called move_timer
move_timer=tmr.create()
servo_time=tmr.create()
done_scanning=false
--Once connected to AP
wifi.eventmon.register(wifi.eventmon.STA_CONNECTED,function(t)
	print(t.ssid)
	print("Connected!!")
	move_timer:alarm(1000,tmr.ALARM_AUTO,function(t)
		if done_scanning==true then
			forward()
			done_scanning=false
			step=3
			servo_timer:register(1000,tmr.ALARM_AUTO,servo_scan)
		end
	end)
	servo_timer:alarm(1000,tmr.ALARM_AUTO,servo_scan)
end)

turn_timer=tmr.create()
function servo_scan()

	--anticlockwise rotation
	if step==3 then
		--checking for end_limits
		if pwm_pos==97+26 then
		
			print("Stopping anticlockwise rotation next clockwise")
			step=step-1
			pwm_pos=pwm_pos-1
		
		else
			RSSI[0][pwm_pos-25]=wifi.sta.getrssi()
			pwm_pos=pwm_pos+1
		end
	--clockwise rotation
	else if step==2 then
		--checking for end_limits
		if pwm_pos==25 then
			print("Stopping clockwise rotation next step is turning the bot")
			pwm.setduty(servopin,26+48)--whatever angle is the 90 degree position
			step=step-1
		else
			RSSI[1][pwm_pos-25]=wifi.sta.getrssi()
			pwm_pos=pwm_pos-1
		end
	else if step==1 then
		heading_1=compass_reading()
		predicted_pwm_value,predicted_direction=prediction()--returns predicted_pwm_value and direction from mean
		pwm.setduty(servopin,predicted_pwm_value)
	else 
		heading_2=compass_reading()
		servo_timer:unregister()
		if math.abs(heading_2-heading_1)>50 then
			diff_angle=360-math.abs(heading_2-heading_1)
		else 
			diff_angle=math.abs(heading_2-heading_1)
		end

		if direction=='left' then 
			if heading_1-diff_angle<0 then
				target_heading=heading_1-diff_angle+360
			else 
				target_heading=heading_1-diff_angle
			end

			left()
			turn_timer:register(100,tmr.ALARM_AUTO,function(t)
				curr_heading=compass_reading()
				if curr_heading<=target_heading then
					stop()
					t:unregister()
					done_scanning=true
					
				end
			end)	
		else --'right'
			if heading_1+diff_angle>360 then
				target_heading=heading_1+diff_angle-360
			else 
				target_heading=heading_1+diff_angle
			end

			right()
			turn_timer:register(100,tmr.ALARM_AUTO,function(t)
				curr_heading=compass_reading()
				if curr_heading>=target_heading then
					stop()
					t:unregister()
					done_scanning=true
					
				end
			end)
		end

	end
end