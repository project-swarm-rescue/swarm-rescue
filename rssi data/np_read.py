from os import path
import numpy as np

filepath = "data/1-Centre1"
xy_data = []

#function to take values and store them in a numpy array
def read_values():
	for line in f:
		ldata = [int(s) for s in line.split() if s.isdigit()]
		print(ldata)
		if(len(ldata)>0):
			xy_data.append(ldata)
	np_xy_data = np.array(xy_data)
	print("np array: {}".format(np_xy_data))
	f.close()

#File opening
if path.exists(filepath):
	try:
		 f=open(filepath)
	except:
		print("The file {} exists but an exception occured".format(filepath))
	else:
		print("The file {} was opened successfully".format(filepath))
		read_values()
else:
	print("The file {} does not exist".format(filepath))

del filepath, f
