import pandas as pd
from tqdm import tqdm

def twosCom_decBin(dec, digit):
        if dec>=0:
                bin1 = bin(dec).split("0b")[1]
                while len(bin1)<digit :
                        bin1 = '0'+bin1
                return bin1
        else:
                #spent way too much time in finding 2's compliment
                return "1"*9

df = pd.read_csv('image_grey_2.csv', header = None)

## add padding to make the size of image divisible be 3

# end of padding

## create five coe files and putting header
fb = open("input_matrices_b.txt","w")
#fb.write("memory_initialization_radix=2;\nmemory_initialization_vector=\n")

# file created
data_width = 16

## creating the sequence
# print(range(len(df) - 2))
# print(range(0,len(df.columns)-1,3))
count = 0
for vp in tqdm(range(len(df) - 2)):
	for hp in range(0,len(df.columns)-1,3):
                print(count)
                count+=1
                matrix = df.loc[vp:vp+2, hp:hp+2]
                # number = (matrix.loc[vp+0,hp+0] + matrix.loc[vp+1,hp+0] * 2**data_width + matrix.loc[vp+2,hp+0]*2**(2*data_width))
                # if(number > 0):
                #         print(matrix)
                #         print(" ")
                #         print(twosCom_decBin(number,24))
                number1 = (matrix.loc[vp+0,hp+0] + matrix.loc[vp+1,hp+0] * 2**data_width + matrix.loc[vp+2,hp+0]*2**(2*data_width))
                number2 = (matrix.loc[vp+0,hp+1] + matrix.loc[vp+1,hp+1] * 2**data_width + matrix.loc[vp+2,hp+1]*2**(2*data_width))
                number3 = (matrix.loc[vp+0,hp+2] + matrix.loc[vp+1,hp+2] * 2**data_width + matrix.loc[vp+2,hp+2]*2**(2*data_width))

                fb.write("1"+str(twosCom_decBin(number1,(3*data_width)))+",\n")
                fb.write("1"+str(twosCom_decBin(number2,(3*data_width)))+",\n")
                fb.write("1"+str(twosCom_decBin(number3,(3*data_width)))+",\n")

# sequence created

fb.write(";");

fb.close();

