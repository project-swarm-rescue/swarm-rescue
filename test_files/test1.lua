motorpins={}
motorpins.left1=1
motorpins.left2=2
motorpins.right1=6
motorpins.right2=5


gpio.mode(motorpins.left1,gpio.OUTPUT)
gpio.mode(motorpins.left2,gpio.OUTPUT)
gpio.mode(motorpins.right1,gpio.OUTPUT)
gpio.mode(motorpins.right2,gpio.OUTPUT)
    gpio.write(motorpins.left1,gpio.HIGH)
    gpio.write(motorpins.left2,gpio.LOW)
    gpio.write(motorpins.right1,gpio.HIGH)
    gpio.write(motorpins.right2,gpio.LOW)
    print("Going straight",'\n')
