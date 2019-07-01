
--registration of callbacks
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED,function(t)
print(t.ssid)
print("Disconnected")
end)
wifi.eventmon.register(wifi.eventmon.AP_STACONNECTED,function(t)
print(t.MAC)
print("AP on and connected b")
end)

--VALUES OF ' PROCESS CONSTANTS'
SURVEYING = 0     --right becomes a subset of this  
AHEAD = 1         --when both right and left values are less than centre
LEFT_SURVEY = 2   --otherwise(left>right and centre is intermediate)

--MAX NO OF STEPS IN EACH PROCESS
steps_max= {}
steps_max[SURVEYING] =3
steps_max[AHEAD]        = 3
steps_max[LEFT_SURVEY]  = 3


state = {}
RSSI_values ={}



--specifying motorpins
motorpins={}
motorpins.left1=1
motorpins.left2=2
motorpins.right1=6
motorpins.right2=5


pwm_freq = 100
pwm_duty = 250
--setup of pwm for motorpins
pwm.setup(motorpins.left1,pwm_freq,0)
pwm.setup(motorpins.left2,pwm_freq,0)
pwm.setup(motorpins.right1,pwm_freq,0)
pwm.setup(motorpins.right2,pwm_freq,0)
pwm.start(motorpins.left1)
pwm.start(motorpins.left2)
pwm.start(motorpins.right1)
pwm.start(motorpins.right2)


--setting pwm to perform movements
function left()
        pwm.setduty(motorpins.left1,0)
        pwm.setduty(motorpins.left2,pwm_duty)
        pwm.setduty(motorpins.right1,pwm_duty)
        pwm.setduty(motorpins.right2,0)
        print("Left Turn",'\n')
end

function right()
        pwm.setduty(motorpins.left1,pwm_duty)
        pwm.setduty(motorpins.left2,0)
        pwm.setduty(motorpins.right1,0)
        pwm.setduty(motorpins.right2,pwm_duty)
        print("Right turn",'\n')
end

function forward()  
        pwm.setduty(motorpins.left1,pwm_duty)
        pwm.setduty(motorpins.left2,0)
        pwm.setduty(motorpins.right1,pwm_duty)
        pwm.setduty(motorpins.right2,0)
        print("Forward",'\n')
end

function stop()
        pwm.setduty(motorpins.left1,0)
        pwm.setduty(motorpins.left2,0)
        pwm.setduty(motorpins.right1,0)
        pwm.setduty(motorpins.right2,0)
        print("Stopped")
end

survey_func = {
    [3] = left,
    [2] = function() RSSI_values.left = wifi.sta.getrssi(); right() end,
    [1] = function() RSSI_values.centre = wifi.sta.getrssi() ;  right() end,
    [0] = function()
            RSSI_values.right = wifi.sta.getrssi()
            if RSSI_values.centre>=RSSI_values.right and RSSI_values.centre>=RSSI_values.left then
                state.process = AHEAD
                state.step = steps_max[AHEAD]
                left()
            elseif RSSI_values.right>RSSI_values.left then
                --process remains the same
                --shifting rssi values and taking a subset of SURVEYING
                RSSI_values.left = RSSI_values.centre
                RSSI_values.centre = RSSI_values.right                
                state.step = steps_max[SURVEYING] - 2
                right()
            else   
                state.process = LEFT_SURVEY
                state.step = steps_max[LEFT_SURVEY]
                left()
                
            end
          end,
}
ahead_func = {
    [2] = forward,
    [1] = forward,
    [0] = function() 
            state.process = SURVEYING
            state.step = steps_max[SURVEYING]
            left()
          end,
}

left_func = {
    [2] = function() RSSI_values.right =  wifi.sta.getrssi(); left() end,
    [1] = function() RSSI_values.centre = wifi.sta.getrssi(); left() end,
    [0] = function()
            RSSI_values.left = wifi.sta.getrssi()
            if RSSI_values.centre>=RSSI_values.right and RSSI_values.centre>=RSSI_values.left then
                state.process = AHEAD
                state.step = steps_max[AHEAD]
                right()
            elseif RSSI_values.left>RSSI_values.right then
                --process remains the same
                --shifting rssi values and taking a subset of SURVEYING
                RSSI_values.right  = RSSI_values.centre
                RSSI_values.centre = RSSI_values.left                
                state.step = steps_max[LEFT_SURVEY] - 2
                left()
            else   
                state.process = SURVEYING
                state.step = steps_max[SURVEYING]
                right()
            end
          end,
}



main_func = {
    [SURVEYING]   = function() survey_func[state.step](); state.step = state.step-1;print("SURVEYING step"..state.step) end,
    [AHEAD]       = function() ahead_func[state.step](); state.step = state.step-1; print("AHEAD step"..state.step) end,
    [LEFT_SURVEY] = function() left_func[state.step](); state.step = state.step-1; print("LEFT_SURVEY"..state.step) end,
   
 }

--callback after connection
wifi.eventmon.register(wifi.eventmon.STA_CONNECTED,function(t)
    print(t.SSID)
    print("Connected")
    --INITIALISING VALUES
    state.process = SURVEYING
    state.step = 3
    RSSI_values.left = -1000
    RSSI_values.right = -1000
    RSSI_values.centre = -1000

    timer=tmr.create()
    timer:alarm(1000,tmr.ALARM_AUTO,main_func[state.process])

    

end)

mode=wifi.setmode(wifi.STATIONAP)

sta={}
sta.ssid="sreekar"
sta.pwd="omsairam"
wifi.sta.config(sta)






