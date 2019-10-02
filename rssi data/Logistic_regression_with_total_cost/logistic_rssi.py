import numpy as np
import batchGD as bGD
import glob

alpha = 0.03
lam = 0.003

sigmoid = lambda val : np.exp(val)/(1+np.exp(val)) #sigmoid of a numpy array

#Open and read files
class_names = ['farRight','Right','Centre','Left','farLeft']

x = np.empty((0,96),int) #to act as head for appending
y = np.empty((0,len(class_names)),int)


for class_name in class_names:
	print('class_name:{}'.format(class_name))
	for filename in glob.glob('data/'+class_name+'*.txt'):
		with open(filename) as datafile:
			print(filename)
			data=np.loadtxt(datafile)
			print('data:\n{}\nshape:{}'.format(data[:,1],data[:,1].shape))
			x = np.append(x, np.array(data[:,1],ndmin=2),axis=0)	#taking right to left data for now
			y = np.append(y,np.zeros((1,len(class_names))),axis=0)
			print('class_index:{}'.format(class_names.index(class_name)))
			y[y.shape[0]-1,class_names.index(class_name)]=1

print('x:{},dimension: {} shape:{}'.format(x,x.ndim,x.shape))
print('y:{},dimension:{},shape:{}'.format(y,y.ndim,y.shape))



#feature scaling
x_scaled=(x - np.mean(x))/np.std(x)
print('scaled values:{}'.format(x_scaled))

# stack a column of ones with x
X_scaled =np.column_stack((np.ones(x_scaled.shape[0]),x_scaled))
print("X_scaled :\n{}\n".format(X_scaled))

#initialise theta and implement GD
epsilon = 0.5
theta = np.random.rand(len(class_names),X_scaled.shape[1])*2*epsilon - epsilon
print('initial theta:{}'.format(theta))
theta=bGD.gradDesc(theta,X_scaled,y,alpha,lam)

print("calculated parameters : \n{}".format(theta))

#predictions for training data
p=sigmoid(X_scaled@theta.T)
print('probability outcome for training data set\n {}'.format(p))

#Accuracy
predicty = (p>0.5).astype(int)
prediction = np.column_stack((x,predicty))
print('prediction:{}'.format(prediction))

Accuracy = (np.sum(np.equal(predicty,y))/y.size)*100
print('Accuracy of the model for the training set: {}%'.format(Accuracy))