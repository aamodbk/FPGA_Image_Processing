import serial           # import the module
import struct
import time

def binaryToDecimal(binary):
    decimal, i = 0, 0
    while(binary != 0):
        dec = binary % 10
        decimal = decimal + dec * pow(2, i)
        binary = binary//10
        i += 1
    return decimal

ComPort = serial.Serial('COM6') # for windows users- check from device manager

ComPort.baudrate = 115200 # set Baud rate to 115200
ComPort.bytesize = 7    # Number of data bits = 7
ComPort.parity   = 'N'  # No parity
ComPort.stopbits = 1    # Number of Stop bits = 1

fb = open("input_matrices_b.txt","r")

print("Sending data in 7 bit frames:")
count = 0
while(fb):
    count += 1
    for i in range(7):
        s = fb.readline(7)
        if(s==';'):
                break
        # print(s + ' next')
        print('num = '+str(binaryToDecimal(int(s))))
        out = ComPort.write(struct.pack('>B', binaryToDecimal(int(s))))    #for sending data to FPGA
    fb.readline()
    if (not s) or (s==';'):
        break
    print(f" {count}")