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
library(igraph)
library(Cairo)


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

## Find nodes' conditional dependency tables
fit <- bn.fit(bn.tb, d_bn)

## Write conditional dependencies out
write.table(fit$`Crash causation`$prob, file="data/Crash causation.csv", sep = ",", col.names=NA)

# Visualisation
arc_strengths <- arc.strength(bn.tb, d_bn)
arc_strengths <- arc_strengths %>%
  mutate(strength = abs(strength)) %>%
  mutate(strength = strength/max(strength) * 3)

## Visualise the learned bn - dynamic view
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

## Visualise the learned bn - static view
nodes <- names(d_bn)
net <- graph_from_data_frame(d=arc_strengths[,c('from', 'to')], vertices=nodes, directed=T)
v_col_list <- c('#6699ff', "gray60", '#6699ff', "gray60",
                "gray60", "gray60", '#6699ff', "gray60",
                "gray60", "gray60", "gray60", "gray60")
V(net)$color <- v_col_list

e_col_list <- c('gray60', "gray60", 'gray60', "#6699ff",
                "gray60", "gray60", 'gray60', "#6699ff",
                "gray60", "gray60", "gray60", "gray60",
                "gray60", "gray60", "gray60", "gray60", "gray60")
E(net)$color <- e_col_list
tkid <- tkplot(net) #tkid is the id of the tkplot that will open
l <- tkplot.getcoords(tkid)
V(net)$label <- V(net)$name

Cairo::Cairo(
  16, #length
  14, #width
  file = paste("figures/crash_causation_bn", ".png", sep = ""),
  type = "png", #tiff
  bg = "white", #white or transparent depending on your requirement
  dpi = 300,
  units = "cm" #you can change to pixels etc
)

plot(0, type="n", ann=FALSE, axes=FALSE, xlim=extendrange(l[,1]),
     ylim=extendrange(l[,2]))

plot(net, vertex.shape="rectangle", vertex.label=V(net)$media, rescale=FALSE, add=TRUE,
     vertex.label.font=2, vertex.label.color=V(net)$color,
     vertex.color='white', vertex.size=(strwidth(V(net)$label) + strwidth("oo")) * 70,
     vertex.size2=strheight("I") * 2 * 100, vertex.frame.color = 'white',
     vertex.label.cex=.7, edge.color=E(net)$color, layout=l) #p is your graph object
dev.off()