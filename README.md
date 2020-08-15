## Introduction

This project is based on a 3-year (2014-2016) dataset of police-reported traffic crashes in Shenzhen, China. The data were
obtained from the Information Sharing Platform for Road Traffic Safety Research in China. In total, 237,255 crashes were reported in the 3 years where 436,412 traffic participants were involved in these crashes.

This repository does not contain any raw data or intermediate datasets. The scripts under src/ show the complete process of data analysis from preprocessing, descriptive analysis, modeling, and visualizing results.


## Data set for profiling the traffic crash occurrance

The main crash variables included and used for analysis in this dataset are:
* **Time**: The time on which the crash occurred in format YYYY-MM-DD H:M:S.
* **Weather**: 1) Sunny; 2) Cloudy; 3) Light rain; 4) Heavy rain; 5) Haze or fog; 6) Unknown.
* **Road type**: 1) Highway; 2) 1st class road; 3) 2nd class road; 4) 3rd class road; 5) 4th class road; 6) Urban expressway; 7) Urban street; 8) Residential road; 9) Public parking space; 10) Public square; 11) Other road
* **Crash causation**: 1) Motor vehicles not driving on the allowed lanes; 2) Unsafe lane change; 3) Unsafe U-turn; 4) Not following traffic rules at signalized intersections; 5) Not yielding pedestrians or straight-going vehicles while turning left; 6) Not yielding the right-hand-side vehicles at unsignalized intersections; 7) Not backing a car following traffic rules; 8) Not following with a safe distance; 9) Other unsafe driver behavior; 10) Not passing vehicles driving in the opposite direction following traffic rules; 11) Opening or closing doors to obstruct vehicles or pedestrians; 12) Driving in the opposite direction; 13) Not driving on the right-side of a road; 14) Illegal use of dedicated lanes; 15) Not following traffic signals; 16) Non-motor vehicles not driving on the allowed lanes; 17) Illegal crossing of non-motor vehicles on lanes for motor vehicles; 18) Not yielding pedestrians at the zebra-crossing area; 19) Others; 20) Unknown
* **Crash type**: 1) Collision with fixed objects; 2) Collision with non-fixed objects; 3) Collision with motor vehicles in transport; 4) Collision with stopped vehicles; 5) Other collision type between vehicles; 6) Scratching pedestrians; 7) Other collision type between vehicles and pedestrians; 8) Vehicle falling down cliffs; 9) Fire; 10) Passenger falling out of vehicles; 11) Crushing pedestrians; 12) Rollover; 13) Other collision type between vehicles and humans; 14) Others; 15) Unknown
* **Injuries**: 1) = 0; 2) (0, 4]; 3) (4, 9]; 4) > 9
* **Deaths**: 1) = 0; 2) (0, 4]; 3) (4, 9]

After reverse geocoding, each crash record was assigned with a land-use cluster representing the land-use pattern where the crash happened using point of interests (POIs).
* **Land-use cluster**: 1) Medium level of land-use intensity with many residential places; 2) Industrial area; 3) Rural area; 4) High land-use intensity with many natural attractions; 5) High land-use intensity; 6) Medium level of land-use intensity with many natural attractions.


Regarding the traffic participants who got involved in the accidents, the below variables are recorded:
* **Travel method**: 1) Walking; 2) Driving non-motor vehicle; 3) Driving motor vehicle; 4) Others; 5) Unknown
* **Gender**: 1) Female; 2) Male; 3) Unknown
* **Age**: 1) < 18; 2) (18, 25]; 3) (25, 30]; 4) (30, 35]; 5) (35, 40]; 6) (40, 45]; 7) (45, 50]; 8) (50, 55]; 9) (55, 60]; 10) (60, 65]; 11) (65, 70]; 12) > 70; 13) Unknown
* **Education level**: 1) Pre-primary (L0); 2) Primary (L1); 3) Lower secondary (L2); 4) Upper/Post- secondary (L3 - L4); 5) Short-cycle tertiary (L5); 6) Bachelor or equivalent (L6); 7) Master/Doctoral or equivalent (L7 - L8); 8) Unknown
* **Vehicle type**: 1) Car; 2) Bus; 3) Truck; 4) Motorcycle; 5) Non-motor vehicle; 6) Others; 7) Unknown
* **Responsibility**: 1) Full responsibility; 2) Major responsibility; 3) Equal responsibility; 4) Minor responsibility; 5) No responsibility; 6) Unable to determine; 7) Unknown


## Code
The code for the project is stored in src. The self-defined help functions are stored in src/lib that are used by the other scripts.

### Analytical scripts
Analytical scripts are stored in src/analysis.
* **s0_geodata_prep.ipynb**
Downloads study area and road network etc.

* **s1_load-from-dbs.ipynb**
Retrieves data from pre-organized database and cleans data include type transformation etc. Output: data_s1.csv.

* **s2_preprocessing.ipynb**
Converts coded variable values to human-readable ones. It is guided by the standard and code book stored in docs/. Output: data_s2.csv.

* **s3_land-use-clusters.ipynb**
1. Finds the zone of the accidents. 

2. Retrieves POI data from Baidu API.

3. Processes POIs to enrich crash dataset.

4. Does land-use clustering to merge 1000+ zones into smaller groups by their land use patterns revealed by POIs. The results are visualised by figures/clusters_parallel.png about Land-use pattern of Shenzhen. (b) Normalized number of POIs of each category. The shaded area indicates the range from 25th percentile to 75th percentile. 

5. Adds land-use cluster to the crash records.

Output: data_s3.csv.

* **s4_descriptive analysis.ipynb**

The results are organized in article_tables.xlsx under docs/.

1. Produces the number & share of crashes, injuries, and deaths by travel method, road type, crash type, weather, crash causation, and land-use cluster.

The below task focuses on the drivers of motor vehicles.

2. Produces the number & share of responsibility by driver gender, driver age, education level of driver, and vehicle type of driver.

3. Prepares data for Bayesian network modelling. It removes the variable of education level because of too many missing values, merge injuries and deaths for the ease of interpretation, and remove all the records if there is any factor’s level is others or unknown.

Output: data_s4.csv

### Modelling script
**src/analysis/s5_bn_acc.R**

1. Takes 235,901 motor-vehicle drivers’ crash records as input, the script produces the interdependence of crash factors.

2. Visualises the network structure by figures/bn.tiff about The interdependence between crash factors. (a) Network structure. (b) A highlighted part of crash causation. 


### Presentation script
Visualisation scripts are stored in src/visualisation. Their outputs are stored in figures/.

**plot_crash_map.R**

crash_map.png

Crash distribution in Shenzhen 

**plot_crash_by_time.R**

1. crash_time.png

Temporal patterns of crash occurrence. (a) Month of year; (b) Day of week; (c) Time of day.

2. crash_day_x_hour.png
The crash occurrence patterns across time of day and day of week.

**plot_land-use_pattern_map.R**

land-use_map.png

Land-use pattern of Shenzhen. (a) Land-use cluster (LUC) of where crashes happened during 2014-2016.

**plot_crash_causation.R**

crash_causation_bn.png as figure (c) of bn.tiff

Conditional probability of crash causation on crash type and the responsibility of motor-vehicle drivers.
