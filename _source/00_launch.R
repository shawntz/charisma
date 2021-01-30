#################################################################
##                       Setup Workspace                       ##
#################################################################

#################################################################
##                       Launch charisma                       ##
#################################################################
cat("\n    Initializing charisma...\n")

options(warn=-1)
##################################################################
##                  Install Required Libraries                  ##
##################################################################
required_libraries <- c("colordistance", "pavo", "tidyverse", "plyr", "optparse", "magick", "progress", "gridExtra")
if(length(setdiff(required_libraries, rownames(installed.packages()))) > 0)
{
  install.packages(setdiff(required_libraries, rownames(installed.packages())),
                   repos = "https://ftp.osuosl.org/pub/cran/") #set CRAN mirror
}

#################################################################
##                   Load Required Libraries                   ##
#################################################################
for(libs in required_libraries)
{
  eval(bquote(suppressMessages(library(.(libs)))))
}

cat("\n    Finished loading charisma!\n\n")