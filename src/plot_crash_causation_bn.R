# Title     : Crash causation as in the Bayesian network
# Objective : Crash causation | Driver responsibility, Crash type
# Created by: Yuan Liao
# Created on: 2020-08-14

library(dplyr)
library(ggplot2)

df <- read.csv('data/Crash causation.csv')

df <- df %>%
  filter(Crash.causation %in% c("CC9", "CC8", "CC2", "CC5", "CC10", "CC7")) %>%
  mutate(Driver.responsibility = factor(Driver.responsibility,
                                        levels = c('Full', 'Major', 'Equal', 'Minor', 'No'))) %>%
  mutate(Crash.type = as.factor(as.numeric(gsub("\\D", "", Crash.type))))

g <- ggplot(data=df, aes(x=Crash.type, y=Crash.causation)) +
  geom_tile(aes(fill = Freq), colour = "white") +
  scale_fill_distiller(name = "Frequency rate of crash", palette = "Spectral", direction = -1) +
  facet_grid(cols = vars(Driver.responsibility)) +
  labs(x = "Crash type (CT)", y = "Crash causation", title='Driver responsibility') +
  theme_minimal() +
  theme(legend.position = "bottom", legend.key.width = unit(2, "cm"),
        panel.grid = element_blank())

h <- 3
ggsave(filename = "figures/crash_causation_bn.png", plot=g,
       width = 4 * h, height = h, unit = "in", dpi = 300)