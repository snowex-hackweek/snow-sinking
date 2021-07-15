library(spatial)

# Set working directory to one directory up from where script is (this is particular to my file structure so change this to wherever your folder that contains the .nc files is).
setwd(dirname(rstudioapi::getSourceEditorContext()$path))
setwd("..")

# Set name of folder that contains .nc files and list all .nc files within.
folder <- "Run 9 (wi_assim_SNEXCSSMStn)/"
files<-list.files(path=folder,pattern = ".nc")

# Set extent and CRS.
e <- extent(c(738270,751230,4320480,4328010))
c <- crs("+proj=utm +zone=12 +ellps=GRS80 +units=m +no_defs")

# Loop through .nc files, set spatial references and write to raster format.
for(file in files) {
  v <- substr(file,nchar(file)-6,nchar(file)-3)
  b <- brick(paste0(folder,file), varname=v)
  extent(b) <- e
  crs(b) <- c
  writeRaster(b,filename = paste0(folder,v,".tif"),overwrite = T)
}
