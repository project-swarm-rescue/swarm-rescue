mode=wifi.setmode(wifi.SOFTAP)
print(mode,'\n')
ap={}
ap.ssid="NODE_MCU"
ap.pwd="connecthere"
config=wifi.ap.config(ap)
if config==true then
print("Success!!")
end