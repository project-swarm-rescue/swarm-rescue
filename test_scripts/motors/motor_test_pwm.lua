
--specifying motorpins
motorpins={}
motorpins.right1=5
motorpins.right2=6
motorpins.left1=7
motorpins.left2=8



pwm_freq = 500
pwm_duty =1023
--setup of pwm for motorpins
pwm.setup(motorpins.left1,pwm_freq,pwm_duty)
pwm.setup(motorpins.left2,pwm_freq,0)
pwm.setup(motorpins.right1,pwm_freq,pwm_duty)
pwm.setup(motorpins.right2,pwm_freq,0)
pwm.start(motorpins.left1)
pwm.start(motorpins.left2)
pwm.start(motorpins.right1)
pwm.start(motorpins.right2)

