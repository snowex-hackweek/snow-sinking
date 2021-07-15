setwd(dirname(rstudioapi::getSourceEditorContext()$path))
setwd("..")

folder <- "Run 9 (wi_assim_SNEXCSSMStn)/"
files<-list.files(path=folder,pattern = ".nc")

start <- "2020-01-28"
end <- "2020-02-12"

e <- extent(c(738270,751230,4320480,4328010))
c <- crs("+proj=utm +zone=12 +ellps=GRS80 +units=m +no_defs")

# Reformat date names to those that SnowModel outputs use.
start <- format(start, "X%Y.%m.%d")
end <- format(end, "X%Y.%m.%d")

for(file in files) {
  v <- substr(file,nchar(file)-6,nchar(file)-3)
  b <- brick(paste0(folder,file), varname=v)
  extent(b) <- e
  crs(b) <- c
  writeRaster(b,filename = paste0(folder,v,".tif"),overwrite = T)
}
