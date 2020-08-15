# Title     : Visualise crashes on the map
# Objective : Visualise crashes on the map
# Created by: Yuan Liao
# Created on: 2020-08-13

# packages required
library(sf)
library(ggplot2)
library(ggmap)
library(classInt)
library(dplyr)

# Read shapefiles: administrative boundary and grid cells with number of crashes
admin <- st_read("data/geo/shenzhen_admin.shp")
crash_grids <- st_read("data/geo/grids_acc.shp")

# Get basemap as the background
bbox <- st_bbox(admin)
names(bbox) <- c("left", "bottom", "right", "top")
shenzhen_basemap <- get_map(bbox, maptype="toner-lite", source="stamen", zoom = 12)

# get quantile breaks. Add -1 offset to catch the lowest value
breaks_qt <- classIntervals(c(min(crash_grids$acc_num) - 1, crash_grids$acc_num), n = 7, style = "quantile")
crash_grids <- mutate(crash_grids, acc_num_cat = cut(acc_num, breaks_qt$brks))

# Plot
g <- ggmap(shenzhen_basemap) +
  geom_sf(data = admin, colour="white", fill=NA, inherit.aes = FALSE) +
  geom_sf(data = crash_grids, aes(fill=acc_num_cat), color = NA, inherit.aes = FALSE, alpha=0.7) +
  scale_fill_brewer(name = "# of crashes", palette = "Spectral", direction=-1) +
  theme_minimal()
g
# Save figure
h <- 4
ggsave(filename = "figures/crash_map.png", plot=g,
       width = 3 * h, height = h, unit = "in", dpi = 300)