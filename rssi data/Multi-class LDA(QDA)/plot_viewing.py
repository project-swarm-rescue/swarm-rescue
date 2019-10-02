import numpy as np
from scipy.signal import savgol_filter

from matplotlib import pyplot as plt
from pick import pick

#Open and read files
positions = [0,8,16,24,72,80,88,96]
				
def prepare_figure():
	plt.figure()
	i=1
	while True:
		[pos,pos_index]=pick(positions.append(100),'plot {}'.format(i))
		if pos==100:return
		else:
			[selection,select_index]=pick(titles[pos_index],'Distance,Take')
			i=i+1
			filename = '/home/sreekar/Work/swarm-robotics-project/swarm-rescue/rssi data/data/intervals of 8 pwm data/{}data.txt'.format(pos)
			with open(filename) as file:
				data = np.loadtxt(file)[select_index*96:((select_index+1)*96)-1,1]#using RIGHT TO LEFT data
				print(data)
				smooth_data = savgol_filter(data,11,3)
				plt.plot(data,label='{}_{}_{}'.format(pos,selection[0],selection[1]))
	return

titles=[]
#load all the data titles (to know indices)
for pos in positions:
	filename = '/home/sreekar/Work/swarm-robotics-project/swarm-rescue/rssi data/data/intervals of 8 pwm data/{0:d}data.txt'.format(pos)
	pos_titles=[]
	with open(filename) as fi:
	    for ln in fi:
	        if ln.startswith('#{}_'.format(pos)):
	        	[p,dist,take]=ln[1:].split('_')
	        	# print('p:{} dist:{} take:{}'.format(p,dist,take))
	        	pos_titles.append([int(dist),int(take)])
	titles.append(pos_titles)
for title_set in titles:
	print('{}'.format(title_set))

while True:

	[o,index]=	pick(['Create new figure','Exit'],'')
	if index==0:prepare_figure()
	else:exit()
