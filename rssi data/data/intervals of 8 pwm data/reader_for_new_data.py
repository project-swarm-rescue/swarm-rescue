directory='data/intervals of 8 pwm data/'
files=['0data.txt','8data.txt','16data.txt','24data.txt','80data.txt','88data.txt','96data.txt']
data_titles=[]
rssi_1=[]
rssi_2=[]
rssi_3=[]

for i in files:
    file=open(directory+i,'r')
    for line in file:
        line=line.replace('\n','')
        if '#' in line:
            line=line.replace(' ','')
            data_titles.append(line)
            temp_1=[]
            temp_2=[]
            temp_3=[]

        else:
            line=line.split()
            if line!=[]:
                temp_1.append(float(line[1]))
                temp_2.append(float(line[2]))
                temp_3.append(float(line[3]))
                if len(temp_1)==96:

                    rssi_1.append(temp_1)
                    rssi_2.append(temp_3)
                    rssi_3.append(temp_2)

import numpy as np
import matplotlib.pyplot as plt
a=np.arange(0,96,1)
for i in range(len(data_titles)):
    plt.figure()
    plt.plot(a,rssi_1[i])
    plt.plot(a,rssi_2[i])
    plt.plot(a,rssi_3[i])
    plt.title(data_titles[i])

plt.show()