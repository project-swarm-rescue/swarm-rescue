import numpy as np 
from matplotlib import pyplot as plt 
threshold  =0.05

sigmoid = lambda val : np.exp(val)/(1+np.exp(val)) #sigmoid of a numpy array


costFunction = lambda h,y,lam,theta : (np.sum(y*np.log(h) + (1-y)*np.log(1-h))/(-y.shape[0])) + lam*np.sum(theta**2)
hypothesis = lambda X,theta:sigmoid(X@theta.T)
	


def gradDesc(theta,X,y,alpha,lam):
	i=0
	cost=np.empty(0)
	while True:
		
		#Included regularisation term to prevent overfitting
		regtheta = theta
		regtheta[:,0]=0
		theta = theta - alpha*((hypothesis(X,theta)-y).T@X) - lam*regtheta

		cost =np.append(cost, costFunction(hypothesis(X,theta),y,lam,theta))
		# print('Theta:{} Cost:{}'.format(theta,cost))					
		if cost[i] < threshold:
			plt.figure(1)#plot the variation of cost with iterations
			plt.plot(range(len(cost)),cost,'r.',label='cost')
			plt.legend()
			plt.show(block=False)
			return theta
		i=i+1