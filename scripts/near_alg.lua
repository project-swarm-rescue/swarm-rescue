--nearalg
bot_front_servo_pos=46--needs to be set according to how servo is placed on bot
reached_region = false --flag to show if it has reached the region where rssi>-40, where it should stop and setup its own ap(in init after this file is done)

--motor functions and vars(to be moved to common file)
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

--after getting closer(rssi>-60) continuation from far_alg
stop()
if wifi.sta.getrssi() > -40 then
  reached_region=true
end
scan_timer=tmr.create()
scan_timer:alarm(700,tmr.ALARM_AUTO,read_move)


servoPin=7
duty=26
N=96

RSSI = {}  -- create the matrix
for i=1,N do
   RSSI[i] = {}     -- create a new row
      for j=1,2 do
        RSSI[i][j] = 0
      end
end


function read_move(scan_t)
  --setup code to reverse direction if false
    rssi_val = wifi.sta.getrssi()
    print(k..' '..rssi_val)
    if dir==1 then
        RSSI[1][k] =rssi_val
        if k==N then
            dir = -1    
        else
            pwm.setduty(servoPin,k+26)
        end 
    end      
    if dir ==-1 then
        RSSI[2][k] =rssi_val
        if k==1 then
            scan_t:unregister()    
            object_servo_pos=determine_object_servo_pos(RSSI)
            print('target servo calculated'..target_servo_pos)
            

            --moving servo to calculated target_servo_pos and note angle
            pwm.setduty(servoPin,object_servo_pos+25)
            --waits for servo to reach
            tmr.create:alarm(600,tmr.ALARM_SINGLE,function()
              object_angle=compass_reading()
              if reached_region==false then
                turn_to_angle(object_angle)
              else
                print('angular position of object from this bot(in absolute angles from HMC) :'..object_angle)
            end)
        else
            pwm.setduty(servoPin,k+24)
        end
    end     
   k = k+dir   
end


function determine_object_servo_pos(rssi_vals)
  local object_servo_pos
--returns angle using ml parameters
  -- qda
     --import covariance arrays,class means
     --calc class_probabilities=
     --MAX_probab=0
   --  for i=1,N,1 do 
   --    if class_probabilities[i]>MAX_probab then
  --       MAX_probab= RSSI_AVG[i] 
    --     object_servo_pos = i 
     --end 
    -- end
      
  -- logistic
     --import parameter matrix 
     --multiply with rssi data to give hypothesis and get angular position

  -- neural net
     --import parameter matrices for each layer
         --
  return object_servo_pos
end

--matmul copied from https://rosettacode.org/wiki/Matrix_multiplication#Lua

function MatMul( m1, m2 )
  if #m1[1] ~= #m2 then -- inner matrix-dimensions must agree
    return nil 
  end 
 
  local res = {}
 
  for i = 1, #m1 do
    res[i] = {}
    for j = 1, #m2[1] do
      res[i][j] = 0
      for k = 1, #m2 do
        res[i][j] = res[i][j] + m1[i][k] * m2[k][j]
      end
    end
  end
 
return res
end

turn_timer=tmr.create()
function turn_to_angle(target_angle)
  --moving servo head to front of bot to note which direction it's heading in as reference
  pwm.setduty(servoPin,bot_front_servo_pos)
  --convert system of angle for convenient comparison
  target_angle=change_angle_system(target_angle)
  --waits for servo to reach front, start turning and take readings
  tmr.create:alarm(600,tmr.ALARM_SINGLE,function()
    turn_timer(50,tmr.ALARM_AUTO,function(turn_t)
       --this active feedback will help recovering in case of an overshoot also(though it requires more computation)
       bot_heading=change_angle_system(compass_reading())
       
       offset =bot_heading-target_angle
      
      if math.abs(offset) < 1 then
        turn_t:unregister()
        keep_moving_till_final()
      else if offset>0 then
        left()
      else --negative offset
        right()

    end)
   
  end)


end

function keep_moving_till_final()
  forward()
  tmr.create:alarm(100,tmr.ALARM_AUTO,function(keep_moving_t)
    if wifi.sta.getrssi() > -40 then
      stop()
      keep_moving_t:unregister()
      reached_region=true
      scan_timer:register(700,tmr.ALARM_AUTO,read_move)

      
  end)
end

function change_angle_system(angle)
--this changes angles from 0-360 to -180 to +180
  if angle>180
    return angle-360
  else
    return angle
end


--function to be taken from init? because of repeated use in both near algo and far algo
function compass_reading()
end



