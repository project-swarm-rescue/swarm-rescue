import numpy as np
import glob
from sklearn.discriminant_analysis import QuadraticDiscriminantAnalysis as qda 
from scipy.signal import savgol_filter
import random


class_names = [0,8,16,24,72,80,88,96]
feature_count=16 #no of features(must be a factor of 96)
X =X_test= np.empty((0,feature_count))
y=y_test=np.empty(0,int)

for class_name in class_names:
	x_k=np.empty((0,feature_count),int)
	y_k=np.empty(0,int)
	# print('class_name:{}'.format(class_name))
	for filename in glob.glob('/home/sreekar/Work/swarm-robotics-project/swarm-rescue/rssi data/data/intervals of 8 pwm data/{0:d}data.txt'.format(class_name)):
		# print('opening..{}'.format(filename))
		with open(filename) as datafile:
			# print(filename)
			data=np.loadtxt(datafile)
			# print('data:\n{}\nshape:{}'.format(data[:,1],data[:,1].shape))
			while data.shape[0]>=96:
				raw_data = data[:96,1]#choosing first sequence of values(right to left data)
				scaled_data = (raw_data-np.mean(raw_data))/np.std(raw_data) #feature scaling to limit the magnitudes
				smooth_tuple = savgol_filter(scaled_data, 11, 3) # window size 11, polynomial order 3
				reduced_feature_tuple = np.mean(smooth_tuple.reshape(feature_count,int(smooth_tuple.size/feature_count)),axis=1)		
				x_k = np.append(x_k, np.array(reduced_feature_tuple,ndmin=2),axis=0)	#taking right to left data for now
				data = data[96:,:]
				y_k=np.append(y_k,np.array(class_name))
	
	train_count=22
	select_index=random.sample(range(x_k.shape[0]),train_count)#randomly select 20 indices
	# print(select_index)
	X=np.append(X,x_k[select_index,:],axis=0)
	y=np.append(y,y_k[select_index],axis=0)
	test_index=list(set(range(x_k.shape[0])).difference(set(select_index)))#selecting the complement indices
	X_test=np.append(X_test,x_k[test_index,:],axis=0)
	y_test=np.append(y_test,y_k[test_index],axis=0)

print('X:\n{}\nshape:{}'.format(X,X.shape))
print('y:\n{}\nshape:{}'.format(y,y.shape))

print('X_test:\n{}\nshape:{}'.format(X_test,X_test.shape))
print('y_test:\n{}\nshape:{}'.format(y_test,y_test.shape))

clf=qda()

clf.fit(X,y)


#on TRAINING data
train_prediction=clf.predict(X)
train_score = clf.score(X,y)

print('prediction on training set:\n{}'.format(train_prediction))
train_prediction = np.expand_dims(train_prediction,axis=1)
y= np.expand_dims(y,axis=1)
print('prediction - truth  array for TEST data: \n{}'.format(np.hstack((train_prediction,y))))
print('score on training set: {}'.format(train_score))

#on TEST data
test_prediction=clf.predict(X_test)
test_score=clf.score(X_test,y_test)

print('prediction on test set:\n{}'.format(test_prediction))
test_prediction = np.expand_dims(test_prediction,axis=1)
y_test= np.expand_dims(y_test,axis=1)
print('prediction - truth  array for TEST data: \n{}'.format(np.hstack((test_prediction,y_test))))
print('score on test set: {}'.format(test_score))



	


