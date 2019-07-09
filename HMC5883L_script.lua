id  = 0 -- always 0
scl = 2 -- set pin 6 as scl
sda = 1 -- set pin 7 as sda


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


i2c.setup(id, sda, scl, i2c.SLOW) -- call i2c.setup() only once
hmc5883l.setup()

function read_heading()  --read and print accelero, gyro and temperature value
    local x,z,y = hmc5883l.read()
    Heading = atan2(y, x) + Declination

    if (Heading>2*pi) then    --Due to declination check for >360 degree 
        Heading = Heading - 2*pi
    end
    if (Heading<0) then       --Check for sign
        Heading = Heading + 2*pi
    end

    Heading = Heading*180/pi  --convert radian to angle
    print(string.format("Heading angle : %d", Heading))
end


timer = tmr.create()
timer:alarm(500,tmr.ALARM_AUTO,read_heading)
