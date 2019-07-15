from os import path
import numpy as np

filepath = "data/1-Centre1"


#function to take values and store them in a numpy array
def read_values():
	xy_data = []
	ldata = []

	for line in f:
		if(line[0]!='#'):		#ignoring header and bottom
			#ldata = [int(s) for s in line.split() if s.isdigit()] - works only for positive integers
			for t in line.split():
				try:
					ldata.append(float(t))
				except ValueError:
					pass
			if(len(ldata)>0):	#checking for empty lines
				xy_data.append(ldata.copy())
				ldata.clear()
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
