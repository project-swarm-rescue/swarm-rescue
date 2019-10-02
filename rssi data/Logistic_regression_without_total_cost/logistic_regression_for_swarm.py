#Header files
import numpy as np
import matplotlib.pyplot as plt
import math

#The reader
def reader(file_name):
    f = open(file_name, 'r')
    rssi_avg = []
    for line in f:
        if '#' not in line and line != '\n':
            line = line.split('\t')
            line = line[1].split('\n')
            line = line[0].split()
            rssi_avg.append(float(line[3]))
    rssi_avg.append(1)
    return rssi_avg

#Initialises the variables
def initialise_variables(files,direction):
    X=np.zeros((len(files),97))

    output=np.zeros((len(files),len(direction)))
    return X,output

def initialise_coeff():
    coeff=np.random.rand(97,1)
    return coeff

#returns the prediction
def h(coeff,X):
    p=X@coeff
    h=1/(1+np.exp(-p))
    return h

#feature rescaling
def feature_rescale(array):
    array=(array-np.mean(array))/np.std(array)
    return array

#to calculate cost
def calc_cost(cost,H,Y,files,i):
    ones=np.ones((len(files),1))
    c=(1/len(files)*(-Y[:,i]@np.log(H)-(ones.T-Y[:,i])@np.log(ones-H)))
    cost.append(c[0][0])
    return cost

learning_rate=0.001
#update coeff
def update_coeff(files,coeff,H,Y,X,i):
    diff=H-Y[:,[i]]
    deriv=X.T@diff
    coeff=coeff-learning_rate*deriv/len(files)
    return coeff

files=['Centre1.txt','Centre2.txt','Centre3.txt','Left1.txt','Left2.txt','Left3.txt','farLeft1.txt','farLeft2.txt','Right1.txt','Right2.txt','Right3.txt','farRight1.txt','farRight2.txt']
direction=['Centre','Left','farLeft','Right','farRight']
#This is the main function
def main():
    X,Y=initialise_variables(files,direction)
    directory='/home/mukund/swarm-rescue/rssi data/data/'
    #populating X
    for i in range(len(files)):
        rssi_avg=reader(directory+files[i])
        for j in range(len(rssi_avg)):
            X[i][j]=rssi_avg[j]
    #populating Y
    for i in range(len(direction)):
        for j in range(len(files)):
            if direction[i]=='Left' or direction[i]=='Right':
                if direction[i] in files[j] and 'far' not in files[j]:
                    Y[j][i] = 1
                else:
                    Y[j][i]=0
            else:
                if direction[i]in files[j]:
                    Y[j][i]=1
                else:
                    Y[j][i]=0
    X=feature_rescale(X)
    coefficients=[]
    for i in range(len(direction)):
        coeff=initialise_coeff()
        cost=[]
        H=h(coeff,X)
        cost=calc_cost(cost,H,Y,files,i)
        iter=0
        while cost[len(cost)-1]>0.01:
            coeff=update_coeff(files,coeff,H,Y,X,i)
            H=h(coeff,X)
            cost=calc_cost(cost,H,Y,files,i)
            iter=iter+1
        print(iter)
        coefficients.append(coeff)
        a=np.arange(0,iter+1,1)
        plt.plot(a,cost)
        plt.show()

    #to check the coefficients

    for j in range(len(files)):
        prediction = []
        for i in coefficients:
            p=X[j,:]@i
            prob=1/(1+np.exp(-p))
            prediction.append(prob[0])
        print(prediction)
        print("Actually:{0} ".format(files[j]))
        maximum=max(prediction)
        for i in range(len(prediction)):
            if prediction[i]==maximum:
                key=i
        print("Predicted: ")
        if key==0:
            print("Centre and probability is {0}".format(prediction[key]))
        if key==1:
            print("Left and probability is {0}".format(prediction[key]))
        if key==2:
            print("farLeft and probability is {0}".format(prediction[key]))
        if key==3:
            print("Right and probability is {0}".format(prediction[key]))
        if key==4:
            print("farRight and probability is {0}".format(prediction[key]))
    return coefficients

def test_alg(coefficients):
    filename=input("Enter file name : ")
    directory = '/home/mukund/swarm-rescue/rssi data/data/'
    X=np.zeros((1,97))
    rssi_avg=reader(directory+filename)
    for i in range(len(rssi_avg)):
        X[0][i]=rssi_avg[i]
    X=feature_rescale(X)
    prediction=[]
    for i in coefficients:
        p=X@i
        prob = 1 / (1 + np.exp(-p))
        prediction.append(prob[0][0])
    print(prediction)
    print("Actually:{0} ".format(filename))
    maximum = max(prediction)
    for i in range(len(prediction)):
        if prediction[i] == maximum:
            key = i
    print("Predicted: ")
    if key == 0:
        print("Centre and probability is {0}".format(prediction[key]))
    if key == 1:
        print("Left and probability is {0}".format(prediction[key]))
    if key == 2:
        print("farLeft and probability is {0}".format(prediction[key]))
    if key == 3:
        print("Right and probability is {0}".format(prediction[key]))
    if key == 4:
        print("farRight and probability is {0}".format(prediction[key]))





def run():
    ch=int(input("Do you want to train the model? (1/0)"))
    if ch==1:
        coefficients=main()
    ch=int(input("Do you want to test the model? (1/0)"))
    if ch==1:
        cont=1
        while cont==1:
            test_alg(coefficients)
            cont=int(input("Do you want to test again?(1/0) "))
run()

