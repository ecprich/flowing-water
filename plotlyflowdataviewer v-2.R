# make sure all these library("packages") are installed on your machine
library(RODBC)
library(BESdata)
library(plotly)
library(dplyr)
library(lubridate)
library(bindrcpp)

# pull the rain data with the date range you want first
rain.start <- as.Date("2018-09-27") #starting date for flow and rain data
rain.end <- as.Date("2018-11-01") #end date for flow and rain data
# change the rain gague with station = ###
# change the interval the rain gague is reporting with daypart = "x" and interval = x
rain <- read.rain(station = 4, start = rain.start, end = rain.end, daypart = "hour", interval = 1) 
rain$cumu <- cumsum(na.omit(rain$rainfall.amount.inches))

#pick your hansen id here
mh.id <- c('ACD362')
# pulls all the flow data from the hansen id you just picked
allflow <- read.flow(mv.manhole_hansen_id = mh.id)
# restricts the data to the same date range as the rain data you pulled
flowdate <- allflow %>% filter(reading_datetime >= rain.start & reading_datetime <= rain.end) 
# merges the rain data and the flow data into one dataframe
mydata<- merge(allflow, rain[,c('end.local','rainfall.amount.inches', 'cumu')], 
                by.x = 'reading_datetime', by.y = 'end.local', all.x = FALSE)



# graph, don't change anything here
p1 <- plot_ly() %>% add_trace(data = mydata, x =~reading_datetime, y =~depth_inches, type = "scatter", mode = "lines", 
                              name = "Depth (inches)")


p2 <- plot_ly() %>% add_trace(data = mydata, x =~reading_datetime, y =~velocity_fps, type = "scatter", mode = "lines", 
                              name = "Velocity (fps)")


p3 <- plot_ly() %>% add_trace(data = mydata, x =~reading_datetime, y =~flow_cfs_AxV, type = "scatter", mode = "lines", 
                              name = "Flow (Cfs)")


p4 <- plot_ly() %>% add_trace(data = mydata, x =~reading_datetime, y =~rainfall.amount.inches, type = "scatter", mode = "lines", 
                              name = "Rainfall (inches) at X rain gague") 


p5 <- plot_ly() %>% add_trace(data = mydata, x =~reading_datetime, y =~cumu, type = "scatter", mode = "lines", 
                              name = "Cumulative Rainfall")



# full plot with cumulative rainfall
z <- subplot(p1, p2, p3, p4,p5, nrows = 5, shareX = TRUE) %>%
  layout(title = "Depth, Velocity, Flow, Rainfall, Cumulative Rainfall",
         xaxis = list(
           rangeslider = list(type = "date"), 
           namelength = -1,
           ticks = "inside",
           showspikes = TRUE,
           spikethickness = 1,
           spikemode = "across",
           showgrid = FALSE))
z
