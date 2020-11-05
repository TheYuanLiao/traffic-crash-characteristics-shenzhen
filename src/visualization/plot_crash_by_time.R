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
df <- read.csv('data/data_s3.csv')
df <- select(df, c('id', 'injs_num', 'deaths_num'))
df2 <- read.csv('data/data_s1.csv')
df2 <- select(df2, c('id', 'time'))
df <- merge(df, df2, by='id')
df <- df[!duplicated(df), ]

# Convert time into month, weekday, and hour
df <- df %>%
  mutate(injs_deaths = injs_num + deaths_num) %>%
  mutate(time = ymd_hms(time)) %>%
  mutate(Month = month(time),
         Year = year(time),
         Day = factor(weekdays(time, abbreviate = TRUE),
                      levels = c('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun')),
         Hour = hour(time))

# Calculate max and min for each Month, Day, and Hour
month <- df %>%
  group_by(Month, Year) %>%
  summarise(Crash=n(), Injuries_and_deaths=sum(injs_deaths)) %>%
  group_by(Month) %>%
  summarise(Crash_min=min(Crash),
            Crash_max=max(Crash),
            Crash_m=mean(Crash),
            Injuries_and_deaths_min=min(Injuries_and_deaths),
            Injuries_and_deaths_max=max(Injuries_and_deaths),
            Injuries_and_deaths_m=mean(Injuries_and_deaths),
  )

day <- df %>%
  group_by(Day, Year) %>%
  summarise(Crash=n(), Injuries_and_deaths=sum(injs_deaths)) %>%
  group_by(Day) %>%
  summarise(Crash_min=min(Crash),
            Crash_max=max(Crash),
            Crash_m=mean(Crash),
            Injuries_and_deaths_min=min(Injuries_and_deaths),
            Injuries_and_deaths_max=max(Injuries_and_deaths),
            Injuries_and_deaths_m=mean(Injuries_and_deaths),
  )

hour <- df %>%
  group_by(Hour, Year) %>%
  summarise(Crash=n(), Injuries_and_deaths=sum(injs_deaths)) %>%
  group_by(Hour) %>%
  summarise(Crash_min=min(Crash),
            Crash_max=max(Crash),
            Crash_m=mean(Crash),
            Injuries_and_deaths_min=min(Injuries_and_deaths),
            Injuries_and_deaths_max=max(Injuries_and_deaths),
            Injuries_and_deaths_m=mean(Injuries_and_deaths),
  )
var.list <- c("var_level", "Crash_min", "Crash_max", "Crash_m",
              "Injuries_and_deaths_min", "Injuries_and_deaths_max", "Injuries_and_deaths_m")
colnames(month) <- var.list
colnames(day) <- var.list
colnames(hour) <- var.list

# Prepare the matrix of day x hour
hour_day <- with(df, table(Day, Hour))
hour_day <- data.frame(hour_day)

# Plot crash by day
g1 <- ggplot(data = day, aes(x=as.factor(var_level))) + theme_minimal() +
  geom_point(aes(y=Crash_m, group=1, color='# of crashes'), size=2) +
  geom_line(aes(y=Crash_m, group=1, color='# of crashes'), size=1) +
  geom_point(aes(y=Injuries_and_deaths_m*1, group=1, color='# of injureis and deaths'), size=2) +
  geom_line(aes(y=Injuries_and_deaths_m*1, group=1, color='# of injureis and deaths'), size=1) +

  geom_ribbon(aes(x=as.factor(var_level), ymin = Crash_min, ymax = Crash_max, group = 1, fill='# of crashes'), alpha = 0.4) +
  geom_ribbon(aes(x=as.factor(var_level), ymin = Injuries_and_deaths_min, ymax = Injuries_and_deaths_max,
                  group = 1, fill='# of injureis and deaths'), alpha = 0.4) +

  scale_color_manual("", values = c('#3c40c6', '#05c46b')) +
  scale_fill_manual("", values = c('#3c40c6', '#05c46b')) +
  theme(legend.position = c(0.7, 0.07)) +
  labs(x = "Day of week", y = "Count")


# Plot crash by month
g2 <- ggplot(data = month, aes(x=as.factor(var_level))) + theme_minimal() +
  geom_point(aes(y=Crash_m, group=1, color='# of crashes'), size=2) +
  geom_line(aes(y=Crash_m, group=1, color='# of crashes'), size=1) +
  geom_point(aes(y=Injuries_and_deaths_m*1, group=1, color='# of injureis and deaths'), size=2) +
  geom_line(aes(y=Injuries_and_deaths_m*1, group=1, color='# of injureis and deaths'), size=1) +

  geom_ribbon(aes(x=as.factor(var_level), ymin = Crash_min, ymax = Crash_max, group = 1, fill='# of crashes'), alpha = 0.4) +
  geom_ribbon(aes(x=as.factor(var_level), ymin = Injuries_and_deaths_min, ymax = Injuries_and_deaths_max,
                  group = 1, fill='# of injureis and deaths'), alpha = 0.4) +

  scale_color_manual("", values = c('#3c40c6', '#05c46b')) +
  scale_fill_manual("", values = c('#3c40c6', '#05c46b')) +
  theme(legend.position = c(0.7, 0.07)) +
  labs(x = "Month of year", y = "Count")

# Plot crash by hour
g3 <- ggplot(data = hour, aes(x=as.factor(var_level))) + theme_minimal() +
  geom_point(aes(y=Crash_m, group=1, color='# of crashes'), size=2) +
  geom_line(aes(y=Crash_m, group=1, color='# of crashes'), size=1) +
  geom_point(aes(y=Injuries_and_deaths_m*1, group=1, color='# of injureis and deaths'), size=2) +
  geom_line(aes(y=Injuries_and_deaths_m*1, group=1, color='# of injureis and deaths'), size=1) +

  geom_ribbon(aes(x=as.factor(var_level), ymin = Crash_min, ymax = Crash_max, group = 1, fill='# of crashes'), alpha = 0.4) +
  geom_ribbon(aes(x=as.factor(var_level), ymin = Injuries_and_deaths_min, ymax = Injuries_and_deaths_max,
                  group = 1, fill='# of injureis and deaths'), alpha = 0.4) +

  scale_color_manual("", values = c('#3c40c6', '#05c46b')) +
  scale_fill_manual("", values = c('#3c40c6', '#05c46b')) +
  theme(legend.position = c(0.7, 0.07)) +
  scale_x_discrete(limits=hour$var_level,breaks=hour$var_level[seq(1,length(hour$var_level),by=2)]) +
  labs(x = "Time of day", y = "Count")


h <- 3.5
G <- ggarrange(g2, g1, g3,
               labels = c("a", "b", "c"),
               ncol = 3, nrow = 1, common.legend = TRUE, legend="bottom")
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