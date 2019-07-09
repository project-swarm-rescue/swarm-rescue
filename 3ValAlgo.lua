--TODO
--CREATE FUNCTION TO RESTART THE runtimer if the sum of rssi values goes below required 
--see if there is an automatic way to arrange for the callback regarding starting and restarting

sta={}
sta.ssid="OnePlus 6T"
sta.pwd="12345678"

ap_cfg = {}
ap_cfg.ssid = "bot1"
ap_cfg.password = "connecthere"

--registration of callbacks
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED,function(t)
print(t.ssid)
print("Disconnected from AP")
end)

wifi.eventmon.register(wifi.eventmon.AP_STACONNECTED,function(t)
print("new station connected: "..t.MAC)
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


--setting pwm to perform movements
function left()
        pwm.setduty(motorpins.left1,0)
        pwm.setduty(motorpins.left2,pwm_duty)
        pwm.setduty(motorpins.right1,pwm_duty)
        pwm.setduty(motorpins.right2,0)
        print("Left Turn")
end

function right()
        pwm.setduty(motorpins.left1,pwm_duty)
        pwm.setduty(motorpins.left2,0)
        pwm.setduty(motorpins.right1,0)
        pwm.setduty(motorpins.right2,pwm_duty)
        print("Right turn")
end

function forward()  
        pwm.setduty(motorpins.left1,pwm_duty)
        pwm.setduty(motorpins.left2,0)
        pwm.setduty(motorpins.right1,pwm_duty)
        pwm.setduty(motorpins.right2,0)
        print("Forward")
end

function stop()
        pwm.setduty(motorpins.left1,0)
        pwm.setduty(motorpins.left2,0)
        pwm.setduty(motorpins.right1,0)
        pwm.setduty(motorpins.right2,0)
        print("Stopped")
end

function rssi_print()
    print('left :'..RSSI_values.left..'\tcentre :'..RSSI_values.centre..'\tright: '..RSSI_values.right)
    check_reached_stop()
end



survey_func = {
    [3] = left,
    [2] = function() RSSI_values.left = wifi.sta.getrssi(); right() end,
    [1] = function() RSSI_values.centre = wifi.sta.getrssi() ;  right() end,
    [0] = function()
            RSSI_values.right = wifi.sta.getrssi()
            rssi_print()
            if RSSI_values.centre>=RSSI_values.right and RSSI_values.centre>=RSSI_values.left then
                print('surveying to ahead')
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
                print('surveying to left')
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
            print('ahead to surveying')
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
            rssi_print()
            if RSSI_values.centre>=RSSI_values.right and RSSI_values.centre>=RSSI_values.left then
                print('left_survey to ahead')
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
                print('left_survey to surveying')
                state.process = SURVEYING
                state.step = steps_max[SURVEYING]
                right()
            end
          end,
}



main_func = {
    [SURVEYING]   = function() print('SURVEYING');survey_func[state.step](); state.step = state.step-1 end,
    [AHEAD]   = function() print('AHEAD'); ahead_func[state.step](); state.step = state.step-1  end,
    [LEFT_SURVEY]   = function() print('LEFT_SURVEY') ;left_func[state.step](); state.step = state.step-1;  end,
   
 }

function test()
    print('\nProcess number running:'..state.process)
    print('step: '..state.step..' of ') 
    main_func[state.process]()
end

--callback after connection
wifi.eventmon.register(wifi.eventmon.STA_CONNECTED,function(t)
    print(t.SSID)
    print("Connected")
    wifi.ap.config(ap_cfg)
    --INITIALISING VALUES
    state.process = SURVEYING
    state.step = 3
    RSSI_values.left = -1000
    RSSI_values.right = -1000
    RSSI_values.centre = -1000

    runtimer=tmr.create()
    runtimer:alarm(600,tmr.ALARM_AUTO,test)

    offsettimer = tmr.create()
    offsettimer:alarm(300,tmr.ALARM_SINGLE,function()
        stoptimer = tmr.create()
        stoptimer:alarm(600,tmr.ALARM_AUTO,stop)
    end)    

end)
--function to check if the bot has reached close enough
function check_reached_stop()
    if RSSI_values.left+RSSI_values.centre+RSSI_values.right > -90 then
        runtimer:stop()
    end    
end

mode=wifi.setmode(wifi.STATIONAP)


wifi.sta.config(sta)







