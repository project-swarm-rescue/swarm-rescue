import numpy as np
import glob
from math import pi

#Open and read files
class_names = ['farRight','Right','Centre','Left','farLeft']
feature_count=96 #no of features
x = np.empty((0,feature_count))
x_cov= np.empty((0,feature_count,feature_count))
x_k_mean = np.empty(0,int)
y_prob = np.empty(0,int)


for class_name in class_names:
	x_k=np.empty((0,feature_count),int)
	y_prob=np.append(y_prob,np.zeros(1))
	# print('y_prob:{}'.format(y_prob))
	# print('class_name:{}'.format(class_name))
	for filename in glob.glob('data/'+class_name+'*.txt'):
		with open(filename) as datafile:
			# print(filename)
			data=np.loadtxt(datafile)
			# print('data:\n{}\nshape:{}'.format(data[:,1],data[:,1].shape))
			x_k = np.append(x_k, np.array(data[:,1],ndmin=2),axis=0)	#taking right to left data for now
		y_prob[y_prob.size-1]= y_prob[y_prob.size-1]+1

	cov_matrix = np.expand_dims(np.cov(x_k,rowvar=False),axis=0)
	x_cov=np.append(x_cov,cov_matrix,axis=0)
	mean_temp_array=np.array([np.mean(x_k)])
	x_k_mean = np.append(x_k_mean,mean_temp_array,axis=0)
	x=np.append(x,x_k,axis=0)#just to have it for testing it on the training set
	del x_k

total_examples=np.sum(y_prob)
# print('y_prob before dividing:{}, total_examples:{}'.format(y_prob,total_examples))
y_prob = y_prob/total_examples
del total_examples
print('x:[0:2]:{} '.format(x[0:2]))
print('x_cov[0]:{},dimension: {} shape:{}'.format(x_cov[0],x_cov[0].ndim,x_cov[0].shape))
print('x_k_mean:{},dimension:{} shape{}'.format(x_k_mean,x_k_mean.ndim,x_k_mean.shape))
print('y_prob:{},dimension:{},shape:{}'.format(y_prob,y_prob.ndim,y_prob.shape))


#taking m(no of training examples) in x to 4th dimension, and
x = np.expand_dims(np.expand_dims(x,axis=1),axis=1)
x_k_mean = np.expand_dims(np.expand_dims(x_k_mean,axis=0),axis=2)
print('x:{}'.format(x))
print('x_k_mean:{}'.format(x_k_mean))

#prediction
cov_det =np.linalg.det(x_cov)
print('cov_det{}'.format(cov_det))
print('inverse:{}'.format(np.linalg.inv(x_cov)))

Px_y= (1/(np.sqrt(2*pi*cov_det)))*np.exp(-0.5*((x-x_k_mean).transpose(0,1,2,3)@np.linalg.inv(x_cov)@(x-x_k_mean)))
print('P(X|y=k):\n{}'.format(Px_y))