#demo implementation of automatic-color
rm(list = ls())

source("auto-color-functions.R")

#setup
wd <- "~/Developer/automatic-color"
setwd(wd)

#k_out <- run_all_ks("testing",1,5,method = "bkstickup",psi=2, visualize = 1)
k_out <- run_all_ks("testing",1,3,method = "elbow",psi=2, visualize = 1)
k_out


color_fishes_out <- run_all_ks("colors",1,20,method="elbow",visualize = 1)
color_fishes_out
