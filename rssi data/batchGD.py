import numpy as np 
from matplotlib import pyplot as plt 
from time import sleep

threshold  =0.47

sigmoid = lambda val : np.exp(val)/(1+np.exp(val)) #sigmoid of a numpy array

costFunction = lambda h,y,lam,theta : (np.sum(y*np.log(h) + (1-y)*np.log(1-h))/(-y.shape[0])) + lam*np.sum(theta**2)
hypothesis = lambda X,theta:sigmoid(X@theta.T)
	
def gradDesc(theta,X,y,alpha,lam):
	
	cost=np.empty(0)
	while True:
		hyp = hypothesis(X,theta)
		# print('hypothesis:{}'.format(hyp))
		cost =np.append(cost, costFunction(hyp,y,lam,theta))	
		# stop condition
		if cost[cost.size -1] < threshold:
			print('Final Theta:{}\n Cost variation:{}\n'.format(theta,cost))
			plt.figure(1)#plot the variation of cost with iterations
			plt.plot(range(len(cost)),cost,'r.',label='cost')
			plt.legend()
			plt.show()
			return theta
		#Updation expression - Included regularisation term to prevent overfitting
		regtheta = theta
		regtheta[:,0]=0
		theta = theta - alpha*((hyp-y).T@X) - lam*regtheta
						
		