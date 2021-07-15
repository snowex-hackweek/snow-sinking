library(tidyverse)

# Set working directory and data location.
setwd("C:/Users/blueg/OneDrive/Grad School/SnowEx Hackweek/SnowModel")
dta.loc <- "C:/Users/blueg/OneDrive/Grad School/SnowEx Hackweek/SnowModel/SnowEx20_SnowPits_GMIOP_Summary_SWE_2020_v01.csv"

# Proportion of data to use as input data vs. validation data.
n <- 1/50

# Load in SnowEx data, select columns of interest and rename.
pit <- read.csv(dta.loc) %>%
  select(c(Site,
           starts_with("Date"),
           starts_with("Easting"),
           starts_with("Northing"),
           starts_with("SWE.Mean"),
           starts_with("Density.Mean"))
         ) %>%
  rename(c(site = Site,
           date = starts_with("Date"),
           easting = starts_with("Easting"),
           northing = starts_with("Northing"),
           swe = starts_with("SWE.Mean"),
           sden = starts_with("Density.Mean")))

# Drop time value from dates.
pit$date <- str_split_fixed(pit$date,"T",2)[,1] %>% 
  as.Date(tryFormats="%Y-%m-%d")

# Convert site IDs to factors.
pit$site <- as.factor(pit$site)

pit$swe <- pit$swe/1000

# Select subset of data and sort by date, site.
set.seed(1)
inside<-ave(seq_along(pit$date),pit$date,FUN=function(x) sample(length(x)))
outside<-ave(inside,inside,FUN=function(x) sample(seq_along(x)))
pit.input <- pit[order(inside,outside),][c(1:floor(nrow(pit)*n)),] %>% 
  arrange(date,site)
pit.validation <- pit[order(inside,outside),][c(floor(nrow(pit)*n)):nrow(pit),] %>% 
  arrange(date,site)

# Save validation data for later calibration/verification
write.csv(pit.validation, "validation_data.csv")

# Change station id to station numbers
site_id <- levels(pit.input$site)
site_idnew <- as.factor(seq(from=100,to=length(site_id)+99))
pit.input$site <- site_idnew[match(pit.input$site, site_id)] 

# Save input data in SnowModel required format
dates <- unique(pit.input$date)
nyears <- as.Date(pit$date, tryFormats="%Y-%m-%d") %>%
  format("%Y") %>%
  as.numeric()
nyears <- max(nyears) - min(nyears) + 1

# Indexing for purposes of writing header.
i <- 1

# Write SWE data in required format.
f <- file('swe_obs.dat', open = 'a')
for(d in dates) {
  if(i==1){
    writeLines(c(sprintf("%i",nyears),sprintf("%i",length(dates))),f,sep="\n")
    i <- i + 1
  }
  vals <- pit.input %>% filter(date == d)
  writeLines(c(str_replace_all(dates[dates==d],"-"," "),nrow(vals),sprintf("%s  %i   %i   %.2f",vals$site,vals$easting,vals$northing,vals$swe)),f,sep="\n")
}
close(f)

# Write density data in required format.
f <- file('snow_density_data.dat', open = 'a')
for(d in dates) {
  vals <- pit.input %>% filter(date == d)
  writeLines(c(str_replace_all(dates[dates==d],"-"," "),nrow(vals),sprintf("%s   %i   %i   %.2f",vals$site,vals$easting,vals$northing,vals$sden)),f,sep="\n")
}
close(f)
