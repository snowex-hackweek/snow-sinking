require(spatial)
require(raster)

# Set working directory.
setwd(paste0(dirname(rstudioapi::getSourceEditorContext()$path),"/Input Data/Rasters"))

# Gather location and names of tif files.
files<-list.files(path = "TIFs", pattern = ".tif")

# Convert and save each tif as an ASCII file..
for(file in files){
  r<-raster(paste0("TIFs/",file))
  name<-substr(file,1,nchar(file)-4)
  writeRaster(r, paste0(name,"_ASCII"), format="ascii",overwrite=TRUE, datatype='INT4S',NAflag=-9999)
}

# Plot for testing/verification.
plot(dem.r)
plot(landcover.r)
