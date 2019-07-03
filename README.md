# swarm-rescue
A project that aims to use swarm robots in the context of post-disaster rescue

#update1:
we first tried to make a bot reach a source using rssi techniques
we had two means of doing so: by moving towards increasing signal strength or by finding distance and actually getting the relative position from the bots.
Since RSSI would undergo a lot of attenuation loss we decided to start with the increasing signal strength concept
#alg1:
we make the robot turn left till it reaches a decrease in the signal strength and then move back to the place where it was higher and then move straight from there!
problems: the bot was lefthanded--if it didnt know what to do it moved left
	  Since the bot always moved left there was an issue that the bot will never actually reach the source
#alg2: 
we make the robot move left then go right and compare the two RSSI values. If they are almost equal we come back to the place where we started and move straight. Suppose one of them is higher i move in that direction and further compare the values.
Advantages: Nuetral sided bot not left handed nor right handed
	    Since i am using only two values the number of values which can be fluctuated is less
Disadvantages: Since the difference varies over distance we cannot exactly compare if a constant diff is being used
	       Since we are not able to control as to how much the bot turns since there is no way to keep track.
Scope of improvement:
Well one is to keep changing the difference as the bot gets closer
Another method could be to actually decrease the angle by which the bot rotates as it gets closer. This can be done by either decreasing pwm value or by decreasing the time or can be a combination of both.
Probably if we use a servo since we have more control over the angle it rotates by

#alg3:





As of now we have put algorithm modifications on hold and have decided to make a mini swarm using the existing algs and probably develop on them further
General stuff to look into:
Usability of a servo
Curve fitting algs to make sure that we can account for fluctuations
Making the bot turn or something to account for the change in diff as the bot gets closer


