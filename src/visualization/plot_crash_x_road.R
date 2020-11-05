# Title     : Visualize the contingency table of crash type x road type
# Objective : Show how different road types have different crash type distribution
# Created by: Yuan Liao
# Created on: 2020-11-05

library(ggplot2)
library(ggpubr)
library(dplyr)
library(reshape2)

df <- read.csv('data/crash_x_road.csv')
df <- reshape2::melt(df, value.name = "Crash number")
names(df) <- c('Road type', 'Crash type', 'Crash number')
df$`Road type` <- factor(df$`Road type`, levels=unlist(lapply(11:1, function(x){paste0('RT', x)})))
df$`Crash type` <- factor(df$`Crash type`, levels=unlist(lapply(1:13, function(x){paste0('CT', x)})))

# Plot the matrix of crash type x road type
g1 <- ggplot(df, aes(y=`Road type`, x=`Crash type`)) +
  geom_tile(aes(fill = `Crash number`), colour = "white") +
  scale_fill_distiller(name = "# of crashes", palette = "Spectral", direction = -1, trans = 'log10') +
  labs(x = "Crash type", y = "Road type") +
  scale_x_discrete(position = "top") +
  theme_minimal() +
  theme(legend.position = "bottom", legend.key.width = unit(2, "cm"),
        panel.grid = element_blank())

h <- 4
ggsave(filename = "figures/crash_crash_x_road.png", plot=g1,
       width = 2 * h, height = h, unit = "in", dpi = 300)
