#demo implementation of automatic-color
rm(list = ls())

#setup
wd <- "~/Developer/automatic-color"
setwd(wd)

source("auto-color-functions.R")

#k_out <- run_all_ks("testing",1,5,method = "bkstickup",psi=2, visualize = 1)
k_out <- run_all_ks("testing",1,3,method = "elbow",psi=2, visualize = 1)
k_out


color_fishes_out_new <- run_all_ks("colors",1,4,method="elbow",visualize = 1, fileout = "newtest.txt")
color_fishes_out_new
