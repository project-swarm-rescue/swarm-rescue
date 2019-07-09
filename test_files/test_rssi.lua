timer=tmr.create()

wifi.eventmon.register(wifi.eventmon.STA_CONNECTED,function(t)
print(t.SSID)
print("Connected")
timer:alarm(1000,tmr.ALARM_AUTO,rssi_print)
end)

wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED,function(t)
print("Disconnected")
timer:unregister()

end)


function rssi_print()
    print('RSSI :'..wifi.sta.getrssi())
end

wifi.setmode(wifi.STATION)
sta={}
sta.ssid="sreekar"
sta.pwd="omsairam"
wifi.sta.config(sta)
