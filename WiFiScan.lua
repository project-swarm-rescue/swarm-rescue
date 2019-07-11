servoPin=7
duty=25

N=65
RSSI = {}  -- create the matrix
    for i=1,N do
      RSSI[i] = {}     -- create a new row
      for j=1,2 do
        RSSI[i][j] = 0
      end
    end

k=0
function avg_findMax()

end

function read_move(dir)
  --setup code to reverse direction if false
  if k == N+26 then
    avg_findMax()
    timer:unregister()
  else
    RSSI[k]=wifi.sta.getrssi()
    k=k+1
  end
end

wifi.eventmon.register(wifi.STA_CONNECTED,function()
pwm.setup(servoPin,50,duty)
pwm.start(servoPin)

timer=tmr.create()
timer:alarm(500,tmr.ALARM_AUTO,read_move(true)
end)

wifi.setmode(WiFi.STATION)
cfg= {}
cfg.ssid = "esp"
cfg.password="connecthere"
wifi.sta.config(cfg)
