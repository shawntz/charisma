## Imports
import numpy as np
import pandas as pd
import os
from datetime import datetime

## Make Results Directory
if not os.path.exists('results'): os.makedirs('results')

## Build HSV Vectors
h = np.linspace(0, 360, (361*2))
s = np.linspace(0, 100, (101*2))
v = s

## Generate All HSV Combinations
colors = np.array(np.meshgrid(h, s, v)).T.reshape(-1,3)

## Convert to Pandas
colors = pd.DataFrame(colors, columns = ['H', 'S', 'V'])

## Define Color Functions



def test_black(df):
	return((((df['H'].ge(0.0000) & df['H'].lt(360.9999))) & ((df['S'].ge(0.0000) & df['S'].lt(100.9999))) & ((df['V'].ge(0.0000) & df['V'].lt(30.9999)))))
 

def test_white(df):
	return((((df['H'].ge(0.0000) & df['H'].lt(360.9999))) & ((df['S'].ge(0.0000) & df['S'].lt(19.9999))) & ((df['V'].ge(86.0000) & df['V'].lt(100.9999)))))
 

def test_grey(df):
	return((((df['H'].ge(0.0000) & df['H'].lt(360.9999))) & ((df['S'].ge(0.0000) & df['S'].lt(25.9999))) & ((df['V'].ge(31.0000) & df['V'].lt(40.9999)))) | (((df['H'].ge(0.0000) & df['H'].lt(360.9999))) & ((df['S'].ge(0.0000) & df['S'].lt(19.9999))) & ((df['V'].ge(41.0000) & df['V'].lt(60.9999)))) | (((df['H'].ge(0.0000) & df['H'].lt(360.9999))) & ((df['S'].ge(0.0000) & df['S'].lt(19.9999))) & ((df['V'].ge(61.0000) & df['V'].lt(75.9999)))) | (((df['H'].ge(0.0000) & df['H'].lt(360.9999))) & ((df['S'].ge(0.0000) & df['S'].lt(15.9999))) & ((df['V'].ge(76.0000) & df['V'].lt(85.9999)))))
 

def test_brown(df):
	return((((df['H'].ge(0.0000) & df['H'].lt(54.9999)) | (df['H'].ge(300.0000) & df['H'].lt(360.9999))) & ((df['S'].ge(26.0000) & df['S'].lt(100.9999))) & ((df['V'].ge(31.0000) & df['V'].lt(40.9999)))) | (((df['H'].ge(0.0000) & df['H'].lt(54.9999)) | (df['H'].ge(300.0000) & df['H'].lt(360.9999))) & ((df['S'].ge(20.0000) & df['S'].lt(100.9999))) & ((df['V'].ge(41.0000) & df['V'].lt(60.9999)))) | (((df['H'].ge(16.0000) & df['H'].lt(54.9999))) & ((df['S'].ge(20.0000) & df['S'].lt(100.9999))) & ((df['V'].ge(61.0000) & df['V'].lt(75.9999)))))
 

def test_red(df):
	return((((df['H'].ge(0.0000) & df['H'].lt(15.9999)) | (df['H'].ge(300.0000) & df['H'].lt(360.9999))) & ((df['S'].ge(20.0000) & df['S'].lt(100.9999))) & ((df['V'].ge(61.0000) & df['V'].lt(75.9999)))) | (((df['H'].ge(0.0000) & df['H'].lt(19.9999)) | (df['H'].ge(300.0000) & df['H'].lt(360.9999))) & ((df['S'].ge(16.0000) & df['S'].lt(100.9999))) & ((df['V'].ge(76.0000) & df['V'].lt(85.9999)))) | (((df['H'].ge(0.0000) & df['H'].lt(19.9999)) | (df['H'].ge(300.0000) & df['H'].lt(360.9999))) & ((df['S'].ge(20.0000) & df['S'].lt(100.9999))) & ((df['V'].ge(86.0000) & df['V'].lt(100.9999)))))
 

def test_orange(df):
	return((((df['H'].ge(20.0000) & df['H'].lt(45.9999))) & ((df['S'].ge(16.0000) & df['S'].lt(100.9999))) & ((df['V'].ge(76.0000) & df['V'].lt(85.9999)))) | (((df['H'].ge(20.0000) & df['H'].lt(35.9999))) & ((df['S'].ge(20.0000) & df['S'].lt(100.9999))) & ((df['V'].ge(86.0000) & df['V'].lt(100.9999)))))
 

def test_yellow(df):
	return((((df['H'].ge(46.0000) & df['H'].lt(61.9999))) & ((df['S'].ge(16.0000) & df['S'].lt(100.9999))) & ((df['V'].ge(76.0000) & df['V'].lt(85.9999)))) | (((df['H'].ge(36.0000) & df['H'].lt(61.9999))) & ((df['S'].ge(20.0000) & df['S'].lt(100.9999))) & ((df['V'].ge(86.0000) & df['V'].lt(100.9999)))))
 

def test_green(df):
	return((((df['H'].ge(55.0000) & df['H'].lt(165.9999))) & ((df['S'].ge(26.0000) & df['S'].lt(100.9999))) & ((df['V'].ge(31.0000) & df['V'].lt(40.9999)))) | (((df['H'].ge(55.0000) & df['H'].lt(165.9999))) & ((df['S'].ge(20.0000) & df['S'].lt(100.9999))) & ((df['V'].ge(41.0000) & df['V'].lt(60.9999)))) | (((df['H'].ge(55.0000) & df['H'].lt(165.9999))) & ((df['S'].ge(20.0000) & df['S'].lt(100.9999))) & ((df['V'].ge(61.0000) & df['V'].lt(75.9999)))) | (((df['H'].ge(62.0000) & df['H'].lt(165.9999))) & ((df['S'].ge(16.0000) & df['S'].lt(100.9999))) & ((df['V'].ge(76.0000) & df['V'].lt(85.9999)))) | (((df['H'].ge(62.0000) & df['H'].lt(165.9999))) & ((df['S'].ge(20.0000) & df['S'].lt(100.9999))) & ((df['V'].ge(86.0000) & df['V'].lt(100.9999)))))
 

def test_blue(df):
	return((((df['H'].ge(166.0000) & df['H'].lt(266.9999))) & ((df['S'].ge(26.0000) & df['S'].lt(100.9999))) & ((df['V'].ge(31.0000) & df['V'].lt(40.9999)))) | (((df['H'].ge(166.0000) & df['H'].lt(266.9999))) & ((df['S'].ge(20.0000) & df['S'].lt(100.9999))) & ((df['V'].ge(41.0000) & df['V'].lt(60.9999)))) | (((df['H'].ge(166.0000) & df['H'].lt(266.9999))) & ((df['S'].ge(20.0000) & df['S'].lt(100.9999))) & ((df['V'].ge(61.0000) & df['V'].lt(75.9999)))) | (((df['H'].ge(166.0000) & df['H'].lt(266.9999))) & ((df['S'].ge(16.0000) & df['S'].lt(100.9999))) & ((df['V'].ge(76.0000) & df['V'].lt(85.9999)))) | (((df['H'].ge(166.0000) & df['H'].lt(266.9999))) & ((df['S'].ge(20.0000) & df['S'].lt(100.9999))) & ((df['V'].ge(86.0000) & df['V'].lt(100.9999)))))
 

def test_purple(df):
	return((((df['H'].ge(267.0000) & df['H'].lt(299.9999))) & ((df['S'].ge(26.0000) & df['S'].lt(100.9999))) & ((df['V'].ge(31.0000) & df['V'].lt(40.9999)))) | (((df['H'].ge(267.0000) & df['H'].lt(299.9999))) & ((df['S'].ge(20.0000) & df['S'].lt(100.9999))) & ((df['V'].ge(41.0000) & df['V'].lt(60.9999)))) | (((df['H'].ge(267.0000) & df['H'].lt(299.9999))) & ((df['S'].ge(20.0000) & df['S'].lt(100.9999))) & ((df['V'].ge(61.0000) & df['V'].lt(75.9999)))) | (((df['H'].ge(267.0000) & df['H'].lt(299.9999))) & ((df['S'].ge(16.0000) & df['S'].lt(100.9999))) & ((df['V'].ge(76.0000) & df['V'].lt(85.9999)))) | (((df['H'].ge(267.0000) & df['H'].lt(299.9999))) & ((df['S'].ge(20.0000) & df['S'].lt(100.9999))) & ((df['V'].ge(86.0000) & df['V'].lt(100.9999)))))

## Validator
def validate_colors(colors):
	black = test_black(colors)
	white = test_white(colors)
	grey = test_grey(colors)
	brown = test_brown(colors)
	red = test_red(colors)
	orange = test_orange(colors)
	yellow = test_yellow(colors)
	green = test_green(colors)
	blue = test_blue(colors)
	purple = test_purple(colors)

	df = pd.DataFrame({
		'black': black,
		'white': white,
		'grey': grey,
		'brown': brown,
		'red': red,
		'orange': orange,
		'yellow': yellow,
		'green': green,
		'blue': blue,
		'purple': purple
	})

	#check number of True per color
	counts = df[df == True].count(axis = 1)
	multiples = counts[counts > 1]

	#get indices of duplicate color rows
	indices = multiples.index

	#get extracted rows of color calls
	extractions = df.loc[indices]

	#get length of duplicate calls
	multiples_length = len(indices)

	return(multiples_length, extractions)

## Run Validation
print("Running Color Validation along", colors.shape[0], "colors in HSV space. Please wait...")
invalid_length, invalid_calls = validate_colors(colors)

print(invalid_length, "invalid colors!")

date = datetime.now().strftime("%Y_%m_%d-%H.%M.%S")
filename = os.path.join("results", "missing_colors" + "-" + date + ".csv")

print("Writing", invalid_length, "invalid colors to CSV @ `results/missing_colors-date.csv`")

invalid_calls.to_csv(filename, index=False)

print("Done!")