# Title     : Visualise the crash number by month of year, day of week, and time of day
# Objective : 1 crash number by month of year, day of week, and time of day;
# 2 Crash number by day of week x time of day
# Created by: Yuan Liao
# Created on: 2020-08-13

library(ggplot2)
library(ggpubr)
library(dplyr)
library(lubridate)

# Load data and drop duplicated crahes
df <- read.csv('data/data_s1.csv')
df <- select(df, c('id', 'time'))
df <- df[!duplicated(df), ]

# Convert time into month, weekday, and hour
df <- df %>%
  mutate(time = ymd_hms(time)) %>%
  mutate(Month = month(time),
         Year = year(time),
         Day = factor(weekdays(time, abbreviate = TRUE),
                      levels = c('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun')),
         Hour = hour(time))

# Calculate max and min for each Month, Day, and Hour
month <- df %>%
  group_by(Month, Year) %>%
  summarise(Crash=n()) %>%
  group_by(Month) %>%
  summarise(Crash_min=min(Crash),
            Crash_max=max(Crash),
            Crash_m=mean(Crash))

day <- df %>%
  group_by(Day, Year) %>%
  summarise(Crash=n()) %>%
  group_by(Day) %>%
  summarise(Crash_min=min(Crash),
            Crash_max=max(Crash),
            Crash_m=mean(Crash))

hour <- df %>%
  group_by(Hour, Year) %>%
  summarise(Crash=n()) %>%
  group_by(Hour) %>%
  summarise(Crash_min=min(Crash),
            Crash_max=max(Crash),
            Crash_m=mean(Crash))

colnames(month) <- c("var_level", "Crash_min", "Crash_max", "Crash_m")
colnames(day) <- c("var_level", "Crash_min", "Crash_max", "Crash_m")
colnames(hour) <- c("var_level", "Crash_min", "Crash_max", "Crash_m")

# Prepare the matrix of day x hour
hour_day <- with(df, table(Day, Hour))
hour_day <- data.frame(hour_day)

# Plot crash by day
g1 <- ggplot(day, aes(x=as.factor(var_level), y=Crash_m, group=1)) + theme_minimal() +
  geom_point(size=2) +
  geom_line(size=1) +
  labs(x = "Day of week", y = "# of crashes") +
  geom_ribbon(data = day, aes(x = as.factor(var_level), ymin = Crash_min, ymax = Crash_max),
              fill = "gray", alpha = 0.4)

# Plot crash by month
g2 <- ggplot(month, aes(x=as.factor(var_level), y=Crash_m, group=1)) + theme_minimal() +
  geom_point(size=2) + geom_line(size=1) +
  labs(x = "Month of year", y = "# of crashes") +
  geom_ribbon(data = month, aes(x = as.factor(var_level), ymin = Crash_min, ymax = Crash_max),
              fill = "gray", alpha = 0.4)

# Plot crash by hour
g3 <- ggplot(hour, aes(x=as.factor(var_level), y=Crash_m, group=1)) + theme_minimal() +
  geom_point(size=2) + geom_line(size=1) +
  labs(x = "Time of day", y = "# of crashes") +
  geom_ribbon(data = hour, aes(x = as.factor(var_level), ymin = Crash_min, ymax = Crash_max),
              fill = "gray", alpha = 0.4) +
  scale_x_discrete(limits=hour$var_level,breaks=hour$var_level[seq(1,length(hour$var_level),by=2)])

h <- 3.5
G <- ggarrange(g2, g1, g3,
               labels = c("a", "b", "c"),
               ncol = 3, nrow = 1)
ggsave(filename = "figures/crash_time.png", plot=G,
       width = 4 * h, height = h, unit = "in", dpi = 300)

# Plot the matrix of day x hour
g4 <- ggplot(hour_day, aes(Hour, Day)) +
  geom_tile(aes(fill = Freq), colour = "white") +
  scale_fill_distiller(name = "# of crashes", palette = "Spectral", direction = -1) +
  scale_x_discrete(breaks = 0:23, labels = 0:23) +
  labs(x = "Time of day", y = "Day of week") +
  theme_minimal() +
  theme(legend.position = "bottom", legend.key.width = unit(2, "cm"),
        panel.grid = element_blank()) +
  coord_equal()

ggsave(filename = "figures/crash_day_x_hour.png", plot=g4,
       width = 3 * h, height = h, unit = "in", dpi = 300)