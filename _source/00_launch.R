#################################################################
##                       Setup Workspace                       ##
#################################################################

#################################################################
##                       Launch charisma                       ##
#################################################################
cat("Loading charisma...\n")

##################################################################
##                  Install Required Libraries                  ##
##################################################################
required_libraries <- c("colordistance", "pavo", "tidyverse", "plyr", "optparse")
if(length(setdiff(required_libraries, rownames(installed.packages()))) > 0)
{
  install.packages(setdiff(required_libraries, rownames(installed.packages())))
}

#################################################################
##                   Load Required Libraries                   ##
#################################################################
for(libs in required_libraries)
{
  eval(bquote(library(.(libs))))
}

cat("Finished loading charisma!\n\n")