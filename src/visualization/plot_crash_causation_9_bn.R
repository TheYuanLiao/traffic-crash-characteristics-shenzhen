# Title     : Crash causation as in the Bayesian network - single value
# Objective : Crash causation==CC9 | Driver responsibility, Crash type
# Created by: Yuan Liao
# Created on: 2020-08-17


library(dplyr)
library(ggplot2)

df <- read.csv('data/Crash causation.csv')

df <- df %>%
  filter(Crash.causation == "CC9") %>%
  mutate(Driver.responsibility = factor(Driver.responsibility,
                                        levels = c('Full', 'Major', 'Equal', 'Minor', 'No'))) %>%
  mutate(Crash.type = as.factor(as.numeric(gsub("\\D", "", Crash.type))))

df[is.na(df$Freq), 'Freq'] <- 0

# Plot the matrix of day x hour
g <- ggplot(df, aes(x=Crash.type, y=Driver.responsibility)) +
  geom_tile(aes(fill = Freq), colour = "white") +
  scale_fill_distiller(name = "Conditional prob.", palette = "Spectral", direction = -1) +
  scale_x_discrete(breaks = 1:13, labels = 1:13) +
  scale_y_discrete(limits = rev(levels(df$Driver.responsibility))) +

  labs(x = "Crash type (CT)", y = "Driver responsibility",
       title = "CC9- Other unsafe driver behavior") +
  theme_minimal() +
  theme(legend.position = "right", legend.key.width = unit(0.5, "cm"),
        panel.grid = element_blank()) +
  coord_equal()

h <- 5
ggsave(filename = "figures/crash_causation_9_bn.png", plot=g,
       width = 2*h, height = h, unit = "in", dpi = 300)