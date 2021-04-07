#######################################################################
##                              Charisma                             ##
##  Automatic Detection of Color Classes for Color Pattern Analysis  ##
##                      <shawnschwartz@ucla.edu>                     ##
#######################################################################

## Initialize Main
validate <- FALSE
source("compile.R")

## Get Images
path <- "demo/birds"
imgs <- getImgPaths(path)

## Call Colors
calls <- list()
for(i in 1:length(imgs)) {
  img <- readImg(imgs[i])
  calls[[i]] <- callColors(img, mapping)
}
names(calls) <- basename(imgs)

## Preview Color Calls Data
glimpse(calls$a.png)
table(calls$a.png$total)
