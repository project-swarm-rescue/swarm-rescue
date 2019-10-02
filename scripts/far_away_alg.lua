-- far_away_alg
-- algo triggered when rssi value to ap is < RSSI_THRESH
SSID="OnePlus 6T"
PASSWORD="12345678"

PWM_FREQ=100
PWM_DUTY_DEFAULT=700
PWM_DUTY=PWM_DUTY_DEFAULT

SCL_PIN = 1
SDA_PIN = 2 

RIGHT1=5
RIGHT2=6
LEFT1=7
LEFT2=8

RSSI_THRESH=-30

pwm.setup(LEFT1,PWM_FREQ,0)
pwm.setup(LEFT2,PWM_FREQ,0)
pwm.setup(RIGHT1,PWM_FREQ,0)
pwm.setup(RIGHT2,PWM_FREQ,0)

pwm.start(LEFT1)
pwm.start(RIGHT1)
pwm.start(LEFT2)
pwm.start(RIGHT2)


--setting up functions for the bot movement
function forward()
	pwm.setduty(LEFT1,PWM_DUTY)
	pwm.setduty(LEFT2,0)
	pwm.setduty(RIGHT1,PWM_DUTY)
	pwm.setduty(RIGHT2,0)
end

function left()
	pwm.setduty(LEFT1,0)
	pwm.setduty(LEFT2,PWM_DUTY)
	pwm.setduty(RIGHT1,PWM_DUTY)
	pwm.setduty(RIGHT2,0)
end

function right()
	pwm.setduty(LEFT1,PWM_DUTY)
	pwm.setduty(LEFT2,0)
	pwm.setduty(RIGHT1,0)
	pwm.setduty(RIGHT2,PWM_DUTY)
end

function backward()
	pwm.setduty(LEFT1,0)
	pwm.setduty(LEFT2,PWM_DUTY)
	pwm.setduty(RIGHT1,0)
	pwm.setduty(RIGHT2,PWM_DUTY)
end

function stop()
	pwm.setduty(LEFT1,0)
	pwm.setduty(LEFT2,0)
	pwm.setduty(RIGHT1,0)
	pwm.setduty(RIGHT2,0)
end


--setting up the wifi
mode=wifi.setmode(wifi.STATION)

sta={}
sta.ssid=SSID
sta.pwd=PASSWORD
wifi.sta.config(sta)
step=0 --setting as global variable

--registration of callbacks
--Disconnected from AP callback
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED,function(t)
	print("Disconnected from AP : ",t.ssid)
	--random movement
end)

step_timer=tmr.create()

--Once connected to AP check rssi and start callback timer for far_movements
wifi.eventmon.register(wifi.eventmon.STA_CONNECTED,function(t)
	print(t.ssid)
	print("Connected!!")
	rssi=wifi.sta.getrssi()
    print('initial rssi '..rssi)
	if rssi<RSSI_THRESH then
		print("Starting far away alg")
		step=4
		step_timer:alarm(1000,tmr.ALARM_AUTO,far_movements)
	end
end)


turn_timer=tmr.create()

function far_movements(step_t)

	--moving forward
	if step==4 then
		print('moving forward')
		a1_rssi=wifi.sta.getrssi()
		forward()
		step=step-1
	--turning left
	elseif step==3 then
		heading_1=compass_reading()
			--identifying the target heading angle
			if heading_1-90<0 then
				heading_90=heading_1-90+360
			else
				heading_90=heading_1-90
			end	
		a2_rssi=wifi.sta.getrssi()
		step_t:stop()
		PWM_DUTY=PWM_DUTY_DEFAULT-300
		left()
		turn_timer:alarm(10,tmr.ALARM_AUTO,function(t)
			curr_heading=compass_reading()
			print('turning left')
			if math.abs(curr_heading-heading_90)<=5 then
				stop()
				t:unregister()
				print('unregistered')
				step=step-1
                PWM_DUTY=PWM_DUTY_DEFAULT
				step_timer:start()
				print('registered again')
			end
		end)
	
	--moving forward
	elseif step==2 then
		b1_rssi=wifi.sta.getrssi()
		forward()
		step=step-1
	--last step
	elseif step==1 then
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
		stop()
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
				if math.abs(curr_heading-target_heading)<=5 then
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
				if math.abs(curr_heading-target_heading)<=5 then
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
	print(a,b)
	if b>0 and a>0 then
		return math.atan(a/b)*radian_to_angle,'right'
	elseif a<0 and b<0 then
		return 180-math.atan(a/b)*radian_to_angle,'left'
	elseif a>0 and b<0 then
		return 180-math.atan(-a/b)*radian_to_angle,'right'
	else 
		return math.atan(a/-b)*radian_to_angle,'left'
	end
end


--keep moving after far away alg till rssi<threshold rssi
check_timer=tmr.create()
function keep_moving_till_closer()
	check_timer:alarm(200,tmr.ALARM_AUTO,function(c_t)
		if wifi.sta.getrssi>RSSI_THRESH then
			stop()
			c_t:unregister()
		end
	
	end)
end



--Define declination of location from where measurement going to be done.
--e.g. here we have added declination from location Pune city, India.
--we can get it from http://www.magnetic-declination.com 
pi = 3.14159265358979323846
Declination = -0.0189077335 --chennai: -1deg5'


function arcsin(value)
    local val = value
    local sum = value 
    if(value == nil) then
        return 0
    end
	-- as per equation it needs infinite iterations to reach upto 100% accuracy
	-- but due to technical limitations we are using
	-- only 10000 iterations to acquire reliable accuracy
    for i = 1, 10000, 2 do
        val = (val*(value*value)*(i*i)) / ((i+1)*(i+2))
        sum = sum + val;
    end
    return sum
end

function arctan(value)
    if(value == nil) then
        return 0
    end
    local _value = value/math.sqrt((value*value)+1)
    return arcsin(_value)
end

function atan2(y, x)
    if(x == nil or y == nil) then
        return 0
    end

    if(x > 0) then
        return arctan(y/x)
    end
    if(x < 0 and 0 <= y) then
        return arctan(y/x) + pi
    end
    if(x < 0 and y < 0) then
        return arctan(y/x) - pi
    end
    if(x == 0 and y > 0) then
        return pi/2
    end
    if(x == 0 and y < 0) then
        return -pi/2
    end
    if(x == 0 and y == 0) then
        return 0
    end
    return 0
end


id  = 0 -- always 0
i2c.setup(id, SDA_PIN, SCL_PIN, i2c.SLOW) -- call i2c.setup() only once
hmc5883l.setup()

function compass_reading()  --read and print accelero, gyro and temperature value
    local x,y,z = hmc5883l.read()
    Heading = atan2(y, x) + Declination

    if (Heading>2*pi) then    --Due to declination check for >360 degree 
        Heading = Heading - 2*pi
    end
    if (Heading<0) then       --Check for sign
        Heading = Heading + 2*pi
    end

    Heading = Heading*180/pi  --convert radian to degree
    print(string.format("Heading angle : %d", Heading))
    return Heading
end

