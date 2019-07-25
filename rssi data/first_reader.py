f=open('5-Right1','r')
RSSI1=[]
RSSI2=[]
RSSI3=[]
sno=[]
smoothened1=[]
smoothened2=[]
smoothened3=[]
for line in f:
        if '#' not in line and line!='\n':

            line=line.split('\t')
            line=line[1].split('\n')
            line=line[0].split()
            sno.append(int(line[0]))
            RSSI1.append(float(line[1]))
            RSSI2.append(float(line[2]))
            RSSI3.append(float(line[3]))
def smoothen(RSSI):
    i=1
    smoothened_value=[]
    smoothened_value.append(RSSI[0])
    while i<len(RSSI)-1:
        if RSSI[i]>=RSSI[i-1] and RSSI[i]<=RSSI[i+1]:
            smoothened_value.append(RSSI[i])
        elif RSSI[i]<=RSSI[i-1] and RSSI[i]>=RSSI[i+1]:
            smoothened_value.append(RSSI[i])
        else:
            smoothened_value.append((RSSI[i-1]+RSSI[i+1])/2)

        i=i+1
    smoothened_value.append(RSSI[len(RSSI)-1])
    return smoothened_value

def plot():
    import matplotlib.pyplot as plt
    fig,ax=plt.subplots(3,1)
    ax[0].plot(sno,RSSI1)
    ax[0].plot(sno,RSSI2)
    ax[0].plot(sno,RSSI3)
    ax[1].plot(sno,smoothened1)
    ax[1].plot(sno,smoothened2)
    ax[1].plot(sno,smoothened3)
    ax[2].plot(sno,smoothened3)
    ax[2].plot(sno,RSSI3)

    plt.show()
smoothened1=smoothen(RSSI1)
smoothened2=smoothen(RSSI2)
smoothened3=smoothen(RSSI3)
plot()
# i=0
# smoothen=[]
# s=[]
# while i <len(RSSI1)-2:
#     smoothen.append((RSSI1[i]+RSSI1[i+1]+RSSI1[i+2])/3)
#     s.append(i+1)
#     i=i+3
# import matplotlib.pyplot as plt
# plt.plot(s,smoothen)
# plt.plot(sno,RSSI1)
# plt.show()
# import matplotlib.pyplot as plt
# plt.plot(sno,RSSI1)
# plt.plot(sno,RSSI2)
# plt.plot(sno,RSSI3)
# plt.show()