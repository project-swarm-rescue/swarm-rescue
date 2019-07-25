
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



--initialising servopin
servopin=7
pwm.setup(servopin,50,26)
pwm.start(servopin)



--creating servo timer object
servo_timer=tmr.create()
--function near_movements

function servo_movements()
	if step==2 then
		N=96
		RSSI = {}  -- create the matrix
		for i=1,N do
      		RSSI[i] = {}     -- create a new row
      		for j=1,2 do
        		RSSI[i][j] = 0
      		end
    	end
		--setting initial position
		pwm.setduty(servopin,26)
		pwm_position=26
		--servo_timer making it rotate anti clockwise
		servo_timer:alarm(1000,tmr.ALARM_AUTO,function()

			RSSI[0][pwm_position-25]=wifi.sta.getrssi()
			--checking if it has reached 96th turn
			if pwm_position==26+96 then
				servo_timer:unregister()
			else
				pwm_position=pwm_position+1
				pwm.setduty(servopin,pwm_position)
			end
		end)
		step=step-1
	end
	if step==1 then
		--setting initial position
		pwm.setduty(servopin,26+96)
		pwm_position=96+26
				--servo_timer making it rotate clockwise
		servo_timer:alarm(1000,tmr.ALARM_AUTO,function()

			RSSI[1][pwm_position-25]=wifi.sta.getrssi()
			--checking if it has reached 96th turn
			if pwm_position==26 then
				servo_timer:unregister()
			else
				pwm_position=pwm_position-1
				pwm.setduty(servopin,pwm_position)
			end
		end)
		--finding rssi_avg
		rssi_avg={}
		for i =1,96 do
			rssi_avg=(RSSI[0][i]+RSSI[1][i])/2
		end

		
	end
	return rssi_avg
end

--do the calculations
function predict()
	return predicted_pwm

--creating turn_timer object
turn_timer=tmr.create()

--function to turn the bot
function turn_bot()
	heading_1=compass_reading()
	pwm.setduty(servopin,predicted_pwm)
	t=tmr.create()
	t:alarm(200,tmr.ALARM_SINGLE,function(t)
		print("turning to predicted_pwm")
	end)
	heading_2=compass_reading()
	if math.abs(heading_2-heading_1)>180 then
		diff_heading=360-math.abs(heading_2-heading_1)
	else
		diff_heading=math.abs(heading_2-heading_1)
	end

	if heading_2-diff_heading<0 then
		target_heading=heading_2-diff_heading+360
	else 
		target_heading=heading_2-diff_heading
	end

	left()
	turn_timer:register(100,tmr.ALARM_AUTO,function(t)
		curr_heading=compass_reading()
		if curr_heading<=target_heading then
			stop()
			t:unregister()
			
		end
	end)
end

	

			
--setting up the wifi
mode=wifi.setmode(wifi.STATION)

sta={}
sta.ssid="OnePlus6T"
sta.pwd="12345678"

--registration of callbacks
--Disconnected from AP callback
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED,function(t)
print(t.ssid)
print("Disconnected from AP")
--obstacle avoid
end)

--Once connected to AP
move_forward_tmr=tmr.create()
wifi.eventmon.register(wifi.eventmon.STA_CONNECTED,function(t)
	print(t.ssid)
	print("Connected!!")
	rssi=wifi.sta.getrssi()
	while rssi>-60 and rssi<-30 do
		servo_step=2
		servo_movements()
		predict()
		turn_bot()
		move_forward_tmr:alarm(500,tmr.ALARM_SINGLE,function (t)
			forward()
		end)
	end
end)






