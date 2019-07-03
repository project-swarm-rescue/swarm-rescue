# swarm-rescue
A project that aims to use swarm robots in the context of post-disaster rescue

## Movement algorithm trials:

The only information we are currently using is that of RSSI(received signal strength indicator) values. 

we first tried to make a bot reach a source using rssi techniques
we had two means of doing so: by moving towards increasing signal strength or by finding distance and actually getting the relative position from the bots.
Since RSSI would undergo a lot of attenuation loss we decided to start with the increasing signal strength concept

These are the developments in our algorithm in a chronological order
In all of them, the robot acts as a station connecting to an access point

1. ## Simple left-sided search: [pwm.lua](https://github.com/project-swarm-rescue/swarm-rescue/blob/master/pwm.lua)
	The robot turns left until a decrease in the signal strength is observed. The bot then turns back one step to the direction where it was higher and then move straight from there!(for a finite distance). This is repeated till it comes in close proximity to the access point. 

	Problem(s): 
	- The bot was left-handed (biased towards the left) i.e., if it didn't know what to do it moved left
	  This caused an issue that the bot would never actually reach the source in certain test cases. 

2. ## Two-value comparison: [newalg.lua](https://github.com/project-swarm-rescue/swarm-rescue/blob/master/newalg.lua)
	The robot is moved left, then (twice) right (RSSI values noted at both orientations) and the two values of RSSI are compared. If they are almost equal(within a specific range of each other) it is turned back to the orientation it started at and moves straight. Otherwise, it is moved in the direction of higher RSSI(Left or right).

	Problems overcome/Advantages:
	- Direction-neutral rather than left-handed nor right-handed
	- Since i am using only two values the number of values which can be fluctuated is less

	Disadvantages: 
	- Since the difference in values varies over distance we cannot exactly compare if a constant diff is being used to 
	- Since we are not able to control as to how much the bot turns since there is no way to keep track.

	**Scope for improvement:**
	Well one is to keep changing the difference as the bot gets closer
	Another method could be to actually decrease the angle by which the bot rotates as it gets closer. This can be done 	    by either decreasing pwm value or by decreasing the time or can be a combination of both.
	Probably if we use a servo since we have more control over the angle it rotates by

3. ## Three-value comparison: [3ValAlg.lua](https://github.com/project-swarm-rescue/swarm-rescue/blob/master/3ValAlgo.lua)
	In this approach, the bot is rotated to record the RSSI values on the left, centre and right. The actions of the bot are based on the following conditions:

No. |Condition | Action performed
--- | -------- | ----------------
1 | centre > both R&L | Go ahead
2 | 1 not satisfied and R > L | Continue search on right
3 | Otherwise | Continue search on left

Problem(s) overcome:
	- The test case where the bot is in a direction directly opposite to its aim is solved. It does not go straight like the previous case

Problem(s) that remain:
	- The bots' movement is still at the mercy of RSSI fluctuations. However, because this process is repeated several times, the bot ultimately reaches the access point.

---
As of now we have put algorithm improvements on hold and have decided to make a mini swarm using the existing algs and probably develop on them further

**General stuff to look into:**
- Possibility of using a servo to have control angular movement of module
- Using a compass sensor to have an absolute reference for relative direction
- Curve fitting algs to make sure that we can account for fluctuations
- Making the bot turn smaller angles to account for the decreasing change in difference in RSSI values as the bot gets closer
-  Checkout Kalmann filters - to account for fluctuations of RSSI values
