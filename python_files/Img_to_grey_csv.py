from PIL import Image

#Converting the Image to GrayScale
image = "colour.jpg"
img = Image.open(image)
ImageGray = img.convert("L")

ImageGray = ImageGray.resize((256, 256), Image.LANCZOS)

#Converting the pixel value into a list
px_val = list(Image.Image.getdata(ImageGray))
#print(data[1:3])
ImageGray = ImageGray.resize((256, 256), Image.LANCZOS)

# print(ImageGray.size)
# Integer to Binary
with open("image_grey_1.csv", "w") as output:
    for i in range(0, 256+3):
        output.write(str(px_val[i*256:(i+1)*256])[1:-1]+"\n")


with open("image_grey_2.csv", "w") as output:
    for i in range(0, 256):
        output.write(str(px_val[i*256:(i+1)*256])[1:-1]+"\n")

#print(max(px_val))

ImageGray.show()
