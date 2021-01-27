# Title     : Visualize the contingency tables of Crash causation x Crash type, Crash causation x road type
# Objective : Show how different road types and crash types have different crash causation distribution
# Created by: Yuan Liao
# Created on: 2020-11-12

library(ggplot2)
library(ggpubr)
library(dplyr)
library(reshape2)

df <- read.csv('data/causation_x_road.csv')
df <- reshape2::melt(df, value.name = "Crash number")
names(df) <- c('Road type', 'Crash causation', 'Crash number')
df$`Crash causation` <- factor(df$`Crash causation`, levels=unlist(lapply(18:1, function(x){paste0('CC', x)})))
df$`Road type` <- factor(df$`Road type`, levels=unlist(lapply(1:11, function(x){paste0('RT', x)})))

df2 <- read.csv('data/causation_x_type.csv')
df2 <- reshape2::melt(df2, value.name = "Crash number")
names(df2) <- c('Crash type', 'Crash causation', 'Crash number')
df2$`Crash causation` <- factor(df2$`Crash causation`, levels=unlist(lapply(18:1, function(x){paste0('CC', x)})))
df2$`Crash type` <- factor(df2$`Crash type`, levels=unlist(lapply(1:13, function(x){paste0('CT', x)})))


# Plot the matrix of crash causation x road type
g1 <- ggplot(df, aes(x=`Road type`, y=`Crash causation`)) +
  geom_tile(aes(fill = `Crash number`), colour = "white") +
  scale_fill_distiller(name = "# of crashes", palette = "Spectral", direction = -1, trans = 'log10',
                       label = scales::comma) +
  labs(y = "Crash causation", x = "Road type") +
  scale_x_discrete(position = "top") +
  theme_minimal() +
  theme(legend.position = "bottom", legend.key.width = unit(2, "cm"),
        panel.grid = element_blank())

# Plot the matrix of crash causation x crash type
g2 <- ggplot(df2, aes(x=`Crash type`, y=`Crash causation`)) +
  geom_tile(aes(fill = `Crash number`), colour = "white") +
  scale_fill_distiller(name = "# of crashes", palette = "Spectral", direction = -1, trans = 'log10',
                       label = scales::comma) +
  labs(y = "Crash causation", x = "Crash type") +
  scale_x_discrete(position = "top") +
  theme_minimal() +
  theme(legend.position = "bottom", legend.key.width = unit(2, "cm"),
        panel.grid = element_blank())

# Save figure
G <- ggarrange(g1, g2, labels = c("a", "b"),
               ncol = 2, nrow = 1)
h <- 6
ggsave(filename = "figures/crash_causation_x_road_crash.png", plot=G,
       width = 2 * h, height = h, unit = "in", dpi = 300)
