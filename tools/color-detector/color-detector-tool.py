##Adapted from programming_fever
##https://medium.com/programming-fever/color-detection-using-opencv-python-6eec8dcde8c7

##Imports
import cv2
import numpy as np
import pandas as pd
import os
import sys
from tkinter import Tk # from tkinter import Tk for Python 3.x
from tkinter.filedialog import askopenfilename

Tk().withdraw() # we don't want a full GUI, so keep the root window from appearing
filename = askopenfilename() # show an "Open" dialog box and return the path to the selected file
print("opening {}".format(filename))

img_path = filename

img = cv2.imread(img_path)
print('Original Dimensions : ', img.shape)

##scale images to 1000 pixels
scale_factor = 1000 / img.shape[1]
width = int(img.shape[1] * scale_factor)
height = int(img.shape[0] * scale_factor)
dim = (width, height)
img = cv2.resize(img, dim, interpolation = cv2.INTER_AREA)
print('Rescaled Dimensions : ', img.shape)

clicked = False
r = g = b = xpos = ypos = 0



def test_black(df):
	return((((df['H'].ge(0) & df['H'].lt(360))) & ((df['S'].ge(0) & df['S'].lt(100))) & ((df['V'].ge(0) & df['V'].lt(19)))))
 

def test_white(df):
	return((((df['H'].ge(0) & df['H'].lt(360))) & ((df['S'].ge(0) & df['S'].lt(19))) & ((df['V'].ge(86) & df['V'].lt(100)))))
 

def test_grey(df):
	return((((df['H'].ge(0) & df['H'].lt(360))) & ((df['S'].ge(0) & df['S'].lt(35))) & ((df['V'].ge(20) & df['V'].lt(30)))) | (((df['H'].ge(0) & df['H'].lt(360))) & ((df['S'].ge(0) & df['S'].lt(25))) & ((df['V'].ge(31) & df['V'].lt(40)))) | (((df['H'].ge(0) & df['H'].lt(360))) & ((df['S'].ge(0) & df['S'].lt(19))) & ((df['V'].ge(41) & df['V'].lt(60)))) | (((df['H'].ge(0) & df['H'].lt(360))) & ((df['S'].ge(0) & df['S'].lt(19))) & ((df['V'].ge(61) & df['V'].lt(75)))) | (((df['H'].ge(0) & df['H'].lt(360))) & ((df['S'].ge(0) & df['S'].lt(15))) & ((df['V'].ge(76) & df['V'].lt(85)))))
 

def test_brown(df):
	return((((df['H'].ge(0) & df['H'].lt(54)) | (df['H'].ge(300) & df['H'].lt(360))) & ((df['S'].ge(36) & df['S'].lt(100))) & ((df['V'].ge(20) & df['V'].lt(30)))) | (((df['H'].ge(0) & df['H'].lt(54)) | (df['H'].ge(300) & df['H'].lt(360))) & ((df['S'].ge(26) & df['S'].lt(100))) & ((df['V'].ge(31) & df['V'].lt(40)))) | (((df['H'].ge(0) & df['H'].lt(54)) | (df['H'].ge(300) & df['H'].lt(360))) & ((df['S'].ge(20) & df['S'].lt(100))) & ((df['V'].ge(41) & df['V'].lt(60)))) | (((df['H'].ge(16) & df['H'].lt(54))) & ((df['S'].ge(20) & df['S'].lt(100))) & ((df['V'].ge(61) & df['V'].lt(75)))))
 

def test_red(df):
	return((((df['H'].ge(0) & df['H'].lt(15)) | (df['H'].ge(300) & df['H'].lt(360))) & ((df['S'].ge(20) & df['S'].lt(100))) & ((df['V'].ge(61) & df['V'].lt(75)))) | (((df['H'].ge(0) & df['H'].lt(19)) | (df['H'].ge(300) & df['H'].lt(360))) & ((df['S'].ge(16) & df['S'].lt(100))) & ((df['V'].ge(76) & df['V'].lt(85)))) | (((df['H'].ge(0) & df['H'].lt(19)) | (df['H'].ge(300) & df['H'].lt(360))) & ((df['S'].ge(20) & df['S'].lt(100))) & ((df['V'].ge(86) & df['V'].lt(100)))))
 

def test_orange(df):
	return((((df['H'].ge(20) & df['H'].lt(45))) & ((df['S'].ge(16) & df['S'].lt(100))) & ((df['V'].ge(76) & df['V'].lt(85)))) | (((df['H'].ge(20) & df['H'].lt(40))) & ((df['S'].ge(20) & df['S'].lt(100))) & ((df['V'].ge(86) & df['V'].lt(100)))))
 

def test_yellow(df):
	return((((df['H'].ge(46) & df['H'].lt(61))) & ((df['S'].ge(16) & df['S'].lt(100))) & ((df['V'].ge(76) & df['V'].lt(85)))) | (((df['H'].ge(41) & df['H'].lt(61))) & ((df['S'].ge(20) & df['S'].lt(100))) & ((df['V'].ge(86) & df['V'].lt(100)))))
 

def test_green(df):
	return((((df['H'].ge(55) & df['H'].lt(165))) & ((df['S'].ge(36) & df['S'].lt(100))) & ((df['V'].ge(20) & df['V'].lt(30)))) | (((df['H'].ge(55) & df['H'].lt(165))) & ((df['S'].ge(26) & df['S'].lt(100))) & ((df['V'].ge(31) & df['V'].lt(40)))) | (((df['H'].ge(55) & df['H'].lt(165))) & ((df['S'].ge(20) & df['S'].lt(100))) & ((df['V'].ge(41) & df['V'].lt(60)))) | (((df['H'].ge(55) & df['H'].lt(165))) & ((df['S'].ge(20) & df['S'].lt(100))) & ((df['V'].ge(61) & df['V'].lt(75)))) | (((df['H'].ge(62) & df['H'].lt(165))) & ((df['S'].ge(16) & df['S'].lt(100))) & ((df['V'].ge(76) & df['V'].lt(85)))) | (((df['H'].ge(62) & df['H'].lt(165))) & ((df['S'].ge(20) & df['S'].lt(100))) & ((df['V'].ge(86) & df['V'].lt(100)))))
 

def test_blue(df):
	return((((df['H'].ge(166) & df['H'].lt(266))) & ((df['S'].ge(36) & df['S'].lt(100))) & ((df['V'].ge(20) & df['V'].lt(30)))) | (((df['H'].ge(166) & df['H'].lt(266))) & ((df['S'].ge(26) & df['S'].lt(100))) & ((df['V'].ge(31) & df['V'].lt(40)))) | (((df['H'].ge(166) & df['H'].lt(266))) & ((df['S'].ge(20) & df['S'].lt(100))) & ((df['V'].ge(41) & df['V'].lt(60)))) | (((df['H'].ge(166) & df['H'].lt(266))) & ((df['S'].ge(20) & df['S'].lt(100))) & ((df['V'].ge(61) & df['V'].lt(75)))) | (((df['H'].ge(166) & df['H'].lt(266))) & ((df['S'].ge(16) & df['S'].lt(100))) & ((df['V'].ge(76) & df['V'].lt(85)))) | (((df['H'].ge(166) & df['H'].lt(266))) & ((df['S'].ge(20) & df['S'].lt(100))) & ((df['V'].ge(86) & df['V'].lt(100)))))
 

def test_purple(df):
	return((((df['H'].ge(267) & df['H'].lt(299))) & ((df['S'].ge(36) & df['S'].lt(100))) & ((df['V'].ge(20) & df['V'].lt(30)))) | (((df['H'].ge(267) & df['H'].lt(299))) & ((df['S'].ge(26) & df['S'].lt(100))) & ((df['V'].ge(31) & df['V'].lt(40)))) | (((df['H'].ge(267) & df['H'].lt(299))) & ((df['S'].ge(20) & df['S'].lt(100))) & ((df['V'].ge(41) & df['V'].lt(60)))) | (((df['H'].ge(267) & df['H'].lt(299))) & ((df['S'].ge(20) & df['S'].lt(100))) & ((df['V'].ge(61) & df['V'].lt(75)))) | (((df['H'].ge(267) & df['H'].lt(299))) & ((df['S'].ge(16) & df['S'].lt(100))) & ((df['V'].ge(76) & df['V'].lt(85)))) | (((df['H'].ge(267) & df['H'].lt(299))) & ((df['S'].ge(20) & df['S'].lt(100))) & ((df['V'].ge(86) & df['V'].lt(100)))))

##identify color
def colorID(h,s,v):
	color = None
	d = {'H': [round(h, 2)], 'S': [round(s, 2)], 'V': [round(v, 2)]}
	df = pd.DataFrame(data=d)
	choices = ['black', 'white', 'grey', 'brown', 'red', 'orange', 'yellow', 'green', 'blue', 'purple']
	conditions = [test_black(df), test_white(df), test_grey(df), test_brown(df), test_red(df), test_orange(df), test_yellow(df), test_green(df), test_blue(df), test_purple(df)]
	color = np.select(conditions, choices, default=None)
	print('the color is {}'.format(color[0]))
	return(color)

def rgb_to_hsv_2(r,g,b):
    r, g, b = r/255.0, g/255.0, b/255.0
    mx = max(r, g, b)
    mn = min(r, g, b)
    df = mx-mn
    if mx == mn:
        h = 0
    elif mx == r:
        h = (60 * ((g-b)/df) + 360) % 360
    elif mx == g:
        h = (60 * ((b-r)/df) + 120) % 360
    elif mx == b:
        h = (60 * ((r-g)/df) + 240) % 360
    if mx == 0:
        s = 0
    else:
        s = (df/mx)*100
    v = mx*100
    return h, s, v

##function to get x,y coordinates of mouse double click
def draw_function(event, x,y,flags,param):
    if event == cv2.EVENT_LBUTTONDOWN:
        global b,g,r,xpos,ypos, clicked
        clicked = True
        xpos = x
        ypos = y
        b,g,r = img[y,x]
        b = int(b)
        g = int(g)
        r = int(r)
cv2.namedWindow('Charisma - Color Detection Diagnostics Tool')
cv2.setMouseCallback('Charisma - Color Detection Diagnostics Tool',draw_function)

##main window activity
while(1):

    cv2.imshow("Charisma - Color Detection Diagnostics Tool",img)
    if (clicked):
   
        #cv2.rectangle(image, startpoint, endpoint, color, thickness)-1 fills entire rectangle 
        cv2.rectangle(img,(20,20), (980,60), (b,g,r), -1) 

        h,s,v = rgb_to_hsv_2(r,g,b)

        hsvcolor = colorID(h,s,v)
        
        #Creating text string to display( Color name and RGB values )
        if(hsvcolor != None):
            text = "{} H={:.1f} S={:.1f} V={:.1f} xpos{} ypos{}".format(hsvcolor[0].capitalize(), h,s,v,xpos,ypos)
        else:
            text = "{} H={:.1f} S={:.1f} V={:.1f} xpos{} ypos{}".format("NO COLOR ERROR", h,s,v,xpos,ypos)
        cv2.putText(img, text,(50,50),2,0.8,(255,255,255),2,cv2.LINE_AA)

        #for very light colours we will display text in black colour
        if(r+g+b>=600):
            cv2.putText(img, text,(50,50),2,0.8,(0,0,0),2,cv2.LINE_AA)
            
        clicked=False

    if cv2.waitKey(20) & 0xFF ==27:
        break
    
cv2.destroyAllWindows()