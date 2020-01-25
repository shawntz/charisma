#demo implementation of automatic-color
rm(list = ls())

source("auto-color-functions.R")

#setup
wd <- "~/Developer/automatic-color"
setwd(wd)

#k_out <- run_all_ks("testing",1,5,method = "bkstickup",psi=2, visualize = 1)
k_out <- run_all_ks("testing",1,3,method = "elbow",psi=2, visualize = 1)
k_out
