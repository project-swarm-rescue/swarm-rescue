
function sta_connect_cb(T)
    print('STATION CONNECTED MAC: '..T.MAC)
end

wifi.eventmon.register(wifi.eventmon.AP_STACONNECTED,sta_connect_cb)

wifi.setmode(wifi.SOFTAP)
ap_cfg={}
ap_cfg.ssid = "esp"
ap_cfg.password = "connecthere"
wifi.ap.config(ap_cfg)



