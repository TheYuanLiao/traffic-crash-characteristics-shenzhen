# Title     : Land-use pattern
# Objective : Visualise land-use cluster on the map
# Created by: Yuan Liao
# Created on: 2020-08-13

# packages required
library(sf)
library(ggplot2)
library(ggmap)
library(classInt)
library(dplyr)

# Read cluster data
df_c <- read.csv("data/zone_poi_cluster.csv")

# Read shapefiles: administrative boundary and grid cells with number of crashes
admin <- st_read("data/geo/shenzhen_admin.shp")
grids <- st_read("data/geo/grids.shp")

# Put cluster information to grids
grids <- merge(grids, df_c, by.x = 'zone', by.y = 'zone')

# Convert cluster into cluster names
grids <- mutate(grids, cluster=paste0('LUC', as.character(cluster)))

# Plot
g <- ggplot(data = admin) +
  geom_sf(data = admin, colour="gray", fill=NA, inherit.aes = FALSE) +
  geom_sf(data = grids, aes(fill=as.factor(cluster)), color = NA, inherit.aes = FALSE, alpha=0.7) +
  scale_fill_brewer(name = "Land-use cluster", palette = "Set2") +
  theme_void()
g

# Save figure
h <- 4
ggsave(filename = "figures/land-use_map.png", plot=g,
       width = 2 * h, height = h, unit = "in", dpi = 300)