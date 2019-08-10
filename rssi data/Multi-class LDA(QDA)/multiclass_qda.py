import numpy as np
import glob
from math import pi
from scipy.signal import savgol_filter
import random


class_names = np.array((0,8,16,24,72,80,88,96))
feature_count=16 #no of features
X =X_test= np.empty((0,feature_count))
y=y_test=np.empty(0,int)
x_cov= np.empty((0,feature_count,feature_count))
x_k_mean = np.empty(0,int)
y_prob = np.empty(0,int)


def prediction(x):
	#prediction
	#taking m(no of training examples) in x to 4th index, and class number to 3rd index
	x = np.expand_dims(np.expand_dims(x,axis=1),axis=1)
	centred_xs=x-x_k_mean

	cov_inv=np.linalg.inv(x_cov)
	# print('inverse:{}\nshape:{}'.format(cov_inv,cov_inv.shape))

	numerator= np.squeeze(-0.5*(centred_xs@cov_inv@centred_xs.transpose(0,1,3,2)))
	# print('numerator(argument to exponent):{}\nshape:{}'.format(numerator,numerator.shape))

	Px_y= np.exp(numerator)/(np.sqrt(2*pi*cov_det));
	# print('P(X|y=k):\n {}'.format(Px_y))

	Py_x =Px_y*y_prob
	Py_x = Py_x/(np.expand_dims(np.sum(Py_x,axis=1), axis=1))

	# print('P(y=k|X):{}\nshape:{}'.format(Py_x,Py_x.shape))
	# print('sum check of probabilities:{}'.format(np.sum(Py_x,axis=1)))
	pred = class_names[np.argmax(Py_x,axis=1)]
	return pred



def performance_calc(pred,truth):
	diff = pred-truth

	pred = np.expand_dims(pred,axis=1)
	truth= np.expand_dims(truth,axis=1)
	print('prediction - truth  array: \n{}'.format(np.hstack((pred,truth))))

	accuracy = 100*np.mean(diff==0)
	
	cost = np.std(diff)

	return accuracy

#extracting data from files class by class
for class_name in class_names:
	x_k=np.empty((0,feature_count),int)
	y_k=np.empty(0)
	y_prob=np.append(y_prob,np.zeros(1))

	# print('y_prob:{}'.format(y_prob))
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
				x_k = np.append(x_k, np.array(reduced_feature_tuple,ndmin=2),axis=0)	
				y_k=np.append(y_k,np.array(class_name))
				data = data[96:,:] #cuts off the front

	train_count=21
	#random selection of training and test data
	select_index=random.sample(range(x_k.shape[0]),train_count)#randomly select 18 indices
	# print(select_index)
	X=np.append(X,x_k[select_index,:],axis=0)
	y=np.append(y,y_k[select_index],axis=0)
	test_index=list(set(range(x_k.shape[0])).difference(set(select_index)))#selecting the complement indices
	X_test=np.append(X_test,x_k[test_index,:],axis=0)
	y_test=np.append(y_test,y_k[test_index],axis=0)
	
	y_prob[y_prob.size-1]= train_count#taking a fixed number of tuples for each of the classes

	#covariance matrix and mean calculations for each class
	cov_matrix = np.expand_dims(np.cov(x_k[select_index,:],rowvar=False),axis=0)
	x_cov=np.append(x_cov,cov_matrix,axis=0)
	mean_temp_array=np.array([np.mean(x_k[select_index,:])])
	x_k_mean = np.append(x_k_mean,mean_temp_array,axis=0)
	
total_examples=np.sum(y_prob)
y_prob = y_prob/total_examples
del total_examples


# print('x_cov:{},dimension: {} shape:{}'.format(x_cov,x_cov.ndim,x_cov.shape))
# print('x_k_mean:{},dimension:{} shape{}'.format(x_k_mean,x_k_mean.ndim,x_k_mean.shape))
# print('y_prob:{},dimension:{},shape:{}'.format(y_prob,y_prob.ndim,y_prob.shape))

cov_det =np.linalg.det(x_cov)
# print('cov_det values\n {} \nshape:{}'.format(cov_det,cov_det.shape))

x_k_mean = np.expand_dims(np.expand_dims(np.expand_dims(x_k_mean,axis=0),axis=2),axis=3)

print('ON TRAINING SET:')
train_predict=prediction(X)
train_perf=performance_calc(train_predict,y)
print('performance on training set:{}'.format(train_perf))

print('ON TEST SET')
test_predict=prediction(X_test)
test_perf =performance_calc(test_predict,y_test)
print('performance on test set:{}'.format(test_perf))





