#!/usr/bin/Rscript

#### Initialize Source ----
ptm <- proc.time() ## begin run timer
wd <- getwd()
source("charisma.source.compile.R")

imgs <- getImages(images_masked_path)

if(resize == TRUE)
{
  cat(paste0("    Beginning Image Downsampling", " (", scale_value, "%):\n"))
  for(ii in 1:length(imgs))
  {
    cat(paste0("        Downsampling Image: ", imgs[ii], " ...\n"))
    downsampleImage(imgs[ii], resize_dir)
  }
  cat("    Image Downsampling Completed\n\n")
  
  #reload downsampled images
  imgs <- getImages(resize_dir)
}

#### Run Pixel-By-Pixel Classification Pipeline ----
classifications_list <- list()
extracted_colors_list_ALL <- list()
extracted_colors_list_LOCAL <- list()
discrete_colors_list <- list()

for(ii in 1:length(imgs))
{
  cat(paste0("    Classifying ", ii, " of ", length(imgs), ": \n"))
  
  classifications_list[[ii]] <- classifyPixels(imgs[ii])
  extracted_colors_list_ALL[[ii]] <- classifyPixelsPipeline(imgs[ii], classifications_list[[ii]], T)
  extracted_colors_list_LOCAL[[ii]] <- classifyPixelsPipeline(imgs[ii], classifications_list[[ii]], F)
  discrete_colors_list[[ii]] <- getDiscreteColors(classifications_list[[ii]])
  
  if(diagnosticMode)
  {
    plotPixelsPipeline(imgs[ii], extracted_colors_list_ALL[[ii]], extracted_colors_list_LOCAL[[ii]], classifications_list[[ii]], thresh)
  }
}
names(discrete_colors_list) <- basename(imgs)
charisma_calls_df <- sortExtractedColorsPipeline(discrete_colors_list)

## Save RDS and CSV Files with charisma calls
cat(paste0("\n    Saving discrete color class calls to RDS file..."))
saveRDS(charisma_calls_df, file.path(output_dir, "_charisma_calls.RDS"))
cat(paste0("\n    Successfully saved discrete color class calls to RDS file for ", length(imgs), " images!\n"))

cat(paste0("\n    Saving discrete color class calls to CSV file..."))
write.csv(charisma_calls_df, file.path(output_dir, "_charisma_calls.csv"), row.names = F)
cat(paste0("\n    Successfully saved discrete color class calls to CSV file for ", length(imgs), " images!\n"))

#### Clean up charisma's main path ----
if(file.exists("Rplots.pdf"))
{
  cat("\nCleaning up directory...")
  unlink("Rplots.pdf")
  cat("Done!\n")
}

#### Finishing Message ----
final_run_time <- proc.time() - ptm #end run timer
cat(paste("\ncharisma pipeline successfully completed in", final_run_time[[3]], "seconds.\n\n"))
