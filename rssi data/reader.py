f=open('take2.dat','r')
RSSI1=[]
RSSI2=[]
RSSI3=[]
sno=[]

for line in f:
    if '#' not in line and line!='\n':

        line=line.split('\t')
        line=line[1].split('\n')
        line=line[0].split()
        sno.append(int(line[0]))
        RSSI1.append(float(line[1]))
        RSSI2.append(float(line[2]))
        RSSI3.append(float(line[3]))

# use matplot lib for plotting the data the first value is appended onto RSSI1, second onto RSSI2 and the average onto RSSI3
