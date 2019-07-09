sda, scl = 1,2
print(i2c.setup(0, sda, scl, i2c.SLOW))-- call i2c.setup() only once

hmc5883l.setup()

timer = tmr.create()

function read_hmc()
x,y,z = hmc5883l.read()
print("x = "..x.." y= "..y.." z ="..z)
end

timer:alarm(500,tmr.ALARM_AUTO,read_hmc)
