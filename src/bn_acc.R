# Title     : Bayesian Network of accident records
# Objective : Create a BN and visualise its structure
# Created by: Yuan Liao
# Created on: 2020-06-29

library(bnlearn)
library(visNetwork)
library(webshot)
library(bnviewer)
library(htmlwidgets)
library(webshot)
library(lattice)
library(dplyr)

# Load data
d_bn <- read.csv("data/data_s4.csv", header = TRUE, check.names = FALSE)

## Remove irrelevant columns
d_bn <- select(d_bn, -c("id", "Injuries", "Deaths", "Injuries (bin)", "Deaths (bin)", "Travel method"))

## Use the categorical columns and rename them
names(d_bn)[names(d_bn) == "Age"] <- "Driver age"
names(d_bn)[names(d_bn) == "Gender"] <- "Driver gender"
names(d_bn)[names(d_bn) == "Responsibility"] <- "Driver responsibility"

for (var in names(d_bn)) {
  d_bn[, var] <- as.factor(d_bn[, var])
}

## Define a blacklist based on common sense
## - Day of week, time of day etc do not dependent on crash consequences
b1 <- tiers2blacklist(list('Day of week', 'Time of day', 'Weather',
                           'Driver age', 'Driver gender', 'Vehicle type', 'Driver responsibility',
                           c('Land-use cluster', 'Crash type', 'Crash causation', 'Road type', 'Injuries and deaths')))

b2 <- tiers2blacklist(list('Land-use cluster', 'Crash type', 'Crash causation',
                           'Road type', 'Vehicle type', 'Injuries and deaths'))
b2 <- subset(b2, !(b2[,'from'] %in% list('Land-use cluster', 'Crash type', 'Crash causation',
                                         'Road type', 'Vehicle type')))
b1 <- rbind(b1, b2)

## Learn the structure
bn.tb <- tabu(d_bn, blacklist = b1)
bn.tb

## Visualise the learned bn
plot<- viewer(bn.tb,
     bayesianNetwork.width = "100%",
     bayesianNetwork.height = "80vh",
     bayesianNetwork.layout = "layout_with_sugiyama",
	 node.colors = list(background = "white", border = "#2b7ce9"),
     node.shape = "box"
)
plot
saveWidget(plot, "bn_structure.html")
webshot("bn_structure.html", "bn_structure.png")

## Find nodes' conditional dependency tables
fit <- bn.fit(bn.tb, d_bn)

## Write conditional dependencies out
write.table(fit$`Crash causation`$prob, file="data/Crash causation.csv", sep = ",", col.names=NA)

