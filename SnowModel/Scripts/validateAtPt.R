library(tidyverse)
library(Metrics)
library(hydroGOF)

setwd(dirname(rstudioapi::getSourceEditorContext()$path))
setwd("..")
source(paste0(dirname(rstudioapi::getSourceEditorContext()$path),"/getDataAtStn.R"))

e <- extent(c(738270,751230,4320480,4328010))
c <- crs("+proj=utm +zone=12 +ellps=GRS80 +units=m +no_defs")
run <- "Run 9 (wi_assim_SNEXCSSMStn)/"

r <- brick(paste0(run,"swed.nc"),varname="swed")
extent(r) <- e
crs(r) <- c
file<-list.files(pattern = ".csv")
file <- file[grepl("validation", file)]

dta.obsv <- read.csv(file)
dta.obsv$date <- dta.obsv$date %>%
  str_replace_all("-",".") %>%
  paste0("X",.)
dta.obsv<-dta.obsv[!duplicated(dta.obsv$site), ]
dta.obsv <- dta.obsv[which(dta.obsv$easting > e[1] & dta.obsv$easting < e[2] & dta.obsv$northing > e[3] & dta.obsv$northing < e[4]),]

pts<-data.frame(dta.obsv$easting,dta.obsv$northing)
names(pts) <- c("easting","northing")
pts<-SpatialPoints(pts,proj4string=c)
pts <- pts[which(pts$easting > e[1] & pts$easting < e[2] & pts$northing > e[3] & pts$northing < e[4])]
stations <- unique(dta.obsv$site)

result <- as.data.frame(matrix(data=NA,nrow=nrow(dta.obsv),ncol=1))
result <- cbind(dta.obsv$site,result)

for(i in 1:length(stations)){
  result[which(dta.obsv$site==stations[i]),]$V1<-round(t(raster::extract(readAll(r[[which(names(r) == dta.obsv$date[i])]]),pts[i])),4)
}

dta.obsv$swe_mod<-result[,2]

r <- brick(paste0(run,"sden.nc"),varname="sden")
extent(r) <- e
crs(r) <- c

result <- as.data.frame(matrix(data=NA,nrow=nrow(dta.obsv),ncol=1))
result <- cbind(dta.obsv$site,result)

for(i in 1:length(stations)){
  result[which(dta.obsv$site==stations[i]),]$V1<-round(t(raster::extract(readAll(r[[which(names(r) == dta.obsv$date[i])]]),pts[i])),4)
}

dta.obsv$sden_mod<-result[,2]

dta.obsv <- dta.obsv %>%
  select(-X) %>%
  relocate(swe_mod,.after = swe) %>%
  relocate(sden_mod,.after = last_col())
dta.obsv$date <- as.Date(dta.obsv$date, tryFormats = "X%Y.%m.%d")

write.csv(dta.obsv,paste0(run,"model_val.csv"),row.names = F)

Metrics::rmse(dta.obsv$swe,dta.obsv$swe_mod)
Metrics::rmse(dta.obsv$sden,dta.obsv$sden_mod)

rsr(dta.obsv$swe_mod,dta.obsv$swe)
rsr(dta.obsv$sden_mod,dta.obsv$sden)

NSE(dta.obsv$swe_mod,dta.obsv$swe)
NSE(dta.obsv$sden_mod,dta.obsv$sden)

cor(dta.obsv$swe_mod,dta.obsv$swe)
cor(dta.obsv$sden_mod,dta.obsv$sden)

pbias(dta.obsv$swe_mod,dta.obsv$swe)
pbias(dta.obsv$sden_mod,dta.obsv$sden)

getDataAtStn(dta.obsv,e=e,'swed.nc')
getDataAtStn(dta.obsv,e=e,'sden.nc')
getDataAtStn(dta.obsv,e=e,'snod.nc')