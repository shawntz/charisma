library(charisma)

# get full paths of demo tangara imgs
tangara <- dir(file.path("inst", "extdata", "tangara"),
             full.names = TRUE)
tangara

# get list of classifications for each specimen
color_classifications <- list()

for(bird in 1:length(tangara)) {
  cat(paste0("[", bird, "/", length(tangara), "]", " Classifying... ", basename(tangara[bird]), "\n"))
  color_classifications[[bird]] <- charisma(tangara[bird])
}

# name list elements for clarity
names(color_classifications) <- basename(tangara)

color_classifications

# save data set to RDS for backup
saveRDS(color_classifications, "color_classifications.RDS")
