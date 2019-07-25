# swarm-rescue
A project that aims to use swarm robots in the context of post-disaster rescue

## Movement algorithm trials:

The only information we are currently using is that of RSSI(received signal strength indicator) values. 

we first tried to make a bot reach a source using rssi techniques
we had two means of doing so: by moving towards increasing signal strength or by finding distance and actually getting the relative position from the bots.
Since RSSI would undergo a lot of attenuation loss we decided to start with the increasing signal strength concept

These are the developments in our algorithm in a chronological order
In all of them, the robot acts as a station connecting to an access point

## 1. Simple left-sided search: [pwm.lua](https://github.com/project-swarm-rescue/swarm-rescue/blob/master/pwm.lua)
The robot turns left until a decrease in the signal strength is observed. The bot then turns back one step to the direction where it was higher and then move straight from there!(for a finite distance). This is repeated till it comes in close proximity to the access point. 

### Problem(s): 
- The bot was left-handed (biased towards the left) i.e., if it didn't know what to do it moved left. This caused an issue that the bot would never actually reach the source in certain test cases. 

## 2. Two-value comparison: [newalg.lua](https://github.com/project-swarm-rescue/swarm-rescue/blob/master/newalg.lua)
The robot is moved left, then (twice) right (RSSI values noted at both orientations) and the two values of RSSI are compared. If they are almost equal(within a specific range of each other) it is turned back to the orientation it started at and moves straight. Otherwise, it is moved in the direction of higher RSSI(Left or right).

### Problems overcome/Advantages:
- Direction-neutral rather than left-handed nor right-handed
- Since i am using only two values the number of values which can be fluctuated is less

### Disadvantages: 
- Since the difference in values varies over distance we cannot exactly compare if a constant diff is being used to 
- Since we are not able to control as to how much the bot turns since there is no way to keep track.

**Scope for improvement:**
Well one is to keep changing the difference as the bot gets closer
Another method could be to actually decrease the angle by which the bot rotates as it gets closer. This can be done 	    by either decreasing pwm value or by decreasing the time or can be a combination of both.
Probably if we use a servo since we have more control over the angle it rotates by

## 3. Three-value comparison: [3ValAlg.lua](https://github.com/project-swarm-rescue/swarm-rescue/blob/master/3ValAlgo.lua)
In this approach, the bot is rotated to record the RSSI values on the left, centre and right. The actions of the bot are based on the following conditions:

No. |Condition | Action performed
--- | -------- | ----------------
1 | centre > both R&L | Go ahead
2 | 1 not satisfied and R > L | Continue search on right
3 | Otherwise | Continue search on left

### Problem(s) overcome:
- The test case where the bot is in a direction directly opposite to its aim is solved. It does not go straight like the previous case

### Problem(s) that remain:
- The bots' movement is still at the mercy of RSSI fluctuations. However, because this process is repeated several times, the bot ultimately reaches the access point.

---
As of now we have put algorithm improvements on hold and have decided to make a mini swarm using the existing algs and probably develop on them further

**General stuff to look into:**
- Possibility of using a servo to have control angular movement of module
- Using a compass sensor to have an absolute reference for relative direction
- Curve fitting algs to make sure that we can account for fluctuations
- Making the bot turn smaller angles to account for the decreasing change in difference in RSSI values as the bot gets closer
-  Checkout Kalmann filters - to account for fluctuations of RSSI values

### Using a servo to control angular movement:
- We have used a servo on top of a robot and attached a node mcu on top of it to control the angular movement of the module. We then take reading for every angle corresponding to an integral value of pwm. From this RSSI data we find the maximum and then turn towards that direction. We also took the value twice and then averaged them to see if there are any differences.

### Problem(s) overcome:
- Initially we could'nt control the angular movement of the robot but now we are able to control the amount by which the bot turns. 
- Without averaging the values, we found that at times the bot finally turned to positions which were not even close to the AP. But upon averaging the values we were able to turn the bot to the right direction (off by a maximum of 20 degrees).
- We were now able to plot the RSSI vs angle readings are was able to notice some patterns in it. (But they were no way related to the plots we expected)
- The issue that RSSI is giving some random values is not resolved and clarified. The RSSI is not related to the patterns we expected but definitely has some similarities when compared along different distances and angles.

### Problem(s) that remain:
- The servo can rotate to all angles ranging from 0 to 180 degrees. But the pwm which can be provided can only be integer values and hence we are limited to the actual number of angles we can turn the servo given the particular frequency at which a servo operates.
- We are still not able to understand why the RSSI values are varying by a lot when measured from right-left and vice versa. 

### Using a compass sensor to find absolute reference angles for relative direction
- We thought we had an HMC5883L sensor but looks like we have got a QMC5883L sensor.
- To actually use the sensor we had to build a custom firmware and then upload it onto the nodemcu to actual read values from the QMC5883L

### Problem(s) that remain:
- We see that the heading angle values are repeating. Probably its because of the code we have used. We havent spent much time on it and so we cannot comment on it.

### Future scope:
- We can definitely point out the angles using the QMC5883L and require it to turn the bot to the required direction and maybe to also pin-point the location of the target.
- We first need to implement this onto the far-away algorithm.

### Far-away algorithm:
- We are yet to work on this algorithm. 
- The crux of the algorithm is that at far away distances we move the bot radially in different directions and compare the RSSI values and then we can pin point that the source is somewhere between two values and hence we can determine the zone of interest.

### Problems we hope to overcome:
- We believe that the issue where the RSSI values dont actually vary by a lot at far away distances can be avoided by this algorithm since here we are actually moving the bot by some distance and then comparing the values.


### Similarities in the plots:





### Smoothening algs we have used so far: (can't call them smoothening algs, rather something we made our own to remove the sudden kinks on the plot)
- We take a value compare the previous and the next. If its not between them we take the mean and replace the data with that. Else we just continue. (This algorithm was able to reduce the suddenk peaks)
- Next we decided to take three values and then take the mean of them and replace the 2nd with this value and remove the rest as well. This reduced the number of points as well.( However this significantly changed the peaks)


### What we plan to do:
- We will be making ML algorithms to implement on the data set.
-- Hence we need to first look upon which algorithm is best suited for this purpose.
-- As of now we have two ideas. One to directly predict the angle upon entering the data read. Second is to use nueral networks to predict the probability that a given data can be the maximum.
- We also would like to make the far-away algorithm.
- Check the code for the heading angle.
- Decide on the smoothening algorithm to use.(First whether to use or not and then which one as well)

### Ml Algs implemented
- We had tried implementing logistic regression on the limited data set available and was succesfully able to classify them into classes (data limited to 5 classes)
- We have also tried implementing nueral networks and qda which can be used for classifying complicated data and hence we need to take the required data for it
- Nueral networks have been tested on the limited data we have and has porovided good results. Qda has some issues due to the limited data we have.
- Data is being collected for intervals of 8 pwm values. with 12 positions in each and two iterations at each position. However the data collected is not perfect and more are yet to be done.
- As of now we plan to use this data which we are collecting to improve on the bot

### Far away algorithm
- We have made a different algorithm at far away distances cause the rssi values at far away distances dont vary much with angle. 
- When the rssi is below a threshold value we say that the bot goes forward by some distance, Turns left then moves forward. 
- It creates a vectorised denotion of the rssi at these two perpendicular directions. (as we like to call it)
- Then we try to vectorially sum them up and then decide on the direction of strenght (as in the resultant of the two)
- Then we move in the resultant's direction and once we reach the threshhold's rssi we switch algs.

### What we need to do next
- We plan on implementing a swarm.
- This requires us to fix the heading angle issue.
- This also requires us to make the code ready for controlling the bot.
- for the ML algs to work properly we need to get the data as quickly as possibly and feed on the ML alg.
- This requires us to decide on the specifics of which alg we want to use.
- Next we need to check on how the bots get connected and so on.


