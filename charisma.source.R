#################################################################
##                       charisma source                       ##
##                    ('charisma.source.R')                    ##
#################################################################

### @Author: Shawn T. Schwartz
### @Email: <shawnschwartz@ucla.edu>
### @Description: Source functions for charisma (automatic detection of color classes)
### @Acknowledgements: Thank you to Hannah Weller, Brown University, for helpful insights and 
###   discussions regarding the methodology and functionality behind our approach presented here.

#load source modules
source_dir <- "_source"
for(f in list.files(source_dir, pattern="*.R"))
{
    source(f)
}