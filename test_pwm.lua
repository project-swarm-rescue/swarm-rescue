
--specifying motorpins
motorpins={}
motorpins.left1=1
motorpins.left2=2
motorpins.right1=6
motorpins.right2=5


pwm_freq = 500
pwm_duty = 250
--setup of pwm for motorpins
pwm.setup(motorpins.left1,pwm_freq,pwm_duty)
pwm.setup(motorpins.left2,pwm_freq,0)
pwm.setup(motorpins.right1,pwm_freq,pwm_duty)
pwm.setup(motorpins.right2,pwm_freq,0)
pwm.start(motorpins.left1)
pwm.start(motorpins.left2)
pwm.start(motorpins.right1)
pwm.start(motorpins.right2)

