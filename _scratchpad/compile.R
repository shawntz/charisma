#### Launch Frontmatter ####
cat("\n\n    #######################################################################
    ##                              Charisma                             ##
    ##  Automatic Detection of Color Classes for Color Pattern Analysis  ##
    ##                      <shawnschwartz@ucla.edu>                     ##
    #######################################################################\n\n\n")

#### Begin Initialization ####
cat("\n    Initializing Charisma...\n")
options(warn=-1)

#### Install Required Libraries ####
required_libraries <- c("tidyverse", "dplyr", "readtext", "raster")
if(length(setdiff(required_libraries, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(required_libraries, rownames(installed.packages())),
                   repos = "https://ftp.osuosl.org/pub/cran/") #set CRAN mirror
}

#### Load Required Libraries ####
for(libs in required_libraries) {
  eval(bquote(suppressMessages(library(.(libs)))))
}

#### Finish Initialization ####
cat("\n    Finished loading Charisma!\n\n")

#### Compile Source Modules ####
for(f in list.files("_source/R", pattern = "*.R")) 
{
  source(paste0("_source/R", "/", f))
}

#### Load Mapping Into Memory and Validate ####
mapping <- readMapping("_source/data/mapping.csv")
if(validate) {
  cat("\n    Validating color boundaries...")
  missingColorCalls <- validateMapping(mapping)
}

#### Set Constants ####
freq_threshold <- .05
spatial_threshold <- .02
output <- "_output"