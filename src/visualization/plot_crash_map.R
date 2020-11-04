# Title     : Visualise crashes on the map
# Objective : Visualise crashes on the map
# Created by: Yuan Liao
# Created on: 2020-08-13

# packages required
library(sf)
library(ggplot2)
library(ggpubr)
library(ggmap)
library(classInt)
library(dplyr)
library(sp)
options(scipen=10000)

# Read shapefiles: administrative boundary and grid cells with number of crashes
admin <- st_read("data/geo/shenzhen_admin.shp")
crash_grids <- st_read("data/geo/grids_acc.shp")

admin_dist <- st_read("data/geo/shenzhen_districts.shp")
centroids <- data.frame(st_coordinates(st_centroid(admin_dist)))
names(centroids) <- c('X', 'Y')

# Get basemap as the background
bbox <- st_bbox(admin)
names(bbox) <- c("left", "bottom", "right", "top")
shenzhen_basemap <- get_map(bbox, maptype="toner-lite", source="stamen", zoom = 12)

# get quantile breaks. Add -1 offset to catch the lowest value
breaks_qt <- classIntervals(c(min(crash_grids$acc_num) - 1, crash_grids$acc_num), n = 5, style = "quantile")
breaks_qt_dist <- classIntervals(c(min(admin_dist$acc_area) - 1, admin_dist$acc_area), n = 5, style = "quantile")
crash_grids <- mutate(crash_grids, acc_num_cat = cut(acc_num, breaks_qt$brks))
admin_dist <- mutate(admin_dist, acc_per_km_cat = cut(acc_area, breaks_qt_dist$brks))

# Plot
g1 <- ggmap(shenzhen_basemap) +
  geom_sf(data = admin, colour="white", fill=NA, inherit.aes = FALSE) +
  geom_sf(data = crash_grids, aes(fill=acc_num_cat), color = NA, inherit.aes = FALSE, alpha=0.7) +
  scale_fill_brewer(name = "# of crashes", palette = "Spectral", direction=-1) +
  theme_minimal()

g2 <- ggplot() +
  geom_sf(data = admin_dist, aes(fill=acc_per_km_cat), color = 'white', inherit.aes = FALSE, alpha=0.7) +
  scale_fill_brewer(name =expression("# of crashes per km"^"2"), palette = "Spectral", direction=-1) +
  geom_text(data=centroids, aes(label = admin_dist$name, x=X, y=Y), size = 3, hjust = 0.5)+
  theme_void()

# Save figure
G <- ggarrange(g1, g2, labels = c("a", "b"),
               ncol = 2, nrow = 1)
h <- 3
ggsave(filename = "figures/crash_map.png", plot=G,
       width = 4.5 * h, height = h, unit = "in", dpi = 300)