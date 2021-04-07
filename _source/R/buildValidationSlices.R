buildValidationSlices <- function() {
  
  ##create output directory
  dest <- "_source/data/validation_slices"
  if(!dir.exists(dest))
    dir.create(dest)
  
  ##set color params
  ###go through H slices
  red = seq(1, 255, by = 2)
  green = seq(1, 255, by = 2)
  blue = seq(0, 255, length.out = 16) # Here 16 slices
  
  ###generate rectangles
  x1 = seq(0, 254, by = 2)/255
  x2 = seq(2, 256, by = 2)/255
  
  y1 = seq(0, 254, by = 2)/255
  y2 = seq(2, 256, by = 2)/255
  
  ##build plots and save
  for(ii in 1:length(blue)) {
    png(paste0(dest, "/slice_", ii, ".png"), width = 500, height = 500)
    
    print({
      par(mar = c(0,0,0,0))
      plot(0, 0, type = "n", xaxs="i", yaxs="i", xlim = c(0, 1), ylim = c(0, 1), axes = F)
      
      for(jj in 1:length(y1)) {
        rect(xleft = x1, xright = x2, ybottom = y1[jj], ytop = y2[jj], col = hsv(h = red/255, s = green[jj]/255, v = blue[ii]/255), border = NA)
      }
    })
    
    dev.off()
  }
  
}