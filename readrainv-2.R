# rain for janus data entry
# make sure these packages are installed: dplyr, BESdata, plotly, lubridate, RODBC, checkmate, plotly
library(dplyr)
library(BESdata)
library(plotly)
library(lubridate)
library(reshape2)
Sys.setenv("plotly_username"="emma.prichard")
Sys.setenv("plotly_api_key"="u1Ercu2rE3pGojXHY4qz")

# if you want to pull all active rain gagues in the city
# create a vector of all the active stations using the next two lines

st <- BESdata:::stations()
st <- subset(st, is.na(station.end))
# using BESdata
rain.start <- ymd_hm("2019-2-10 00:00")
rain.end <- ymd_hm("2019-2-12 17:00")
rain <- read.rain(station = st$station, start = rain.start, end = rain.end, daypart = "hour", interval = 1)
rain$cumu <- cumsum(na.omit(rain$rainfall.amount.inches))


rain <- rain %>% filter(!is.na(rain$rainfall.amount.inches))
groups <-split(rain$rainfall.amount.inches, rain$station.name)
means <- sapply(groups, sum)
mean(means)

# this sets the formatting for the graph, must run
ay <- list(
  tickfont = list(color = hcl(50,400,60)), #change the color of the numbers on the second y axis
  overlaying = "y",
  side = "right", 
  title = "Cumulative Rainfall (inches)" #title of the second y axis in quotes
)

#pick this one for no cumulative rainfall

n <- plot_ly(data = rain) %>%
  add_trace(x=~end.local, y =~rainfall.amount.inches, type = "scatter", mode = "lines", color = I("steelblue3"), name = 
              "rainfall (hourly)") %>%
  layout(title = "rain", #graph title 
         xaxis = list(title="Date"),
         yaxis = list(title = "Rainfall(inches)")
  )
n


# graph with plot_ly, with cumulative rainfall
p <- plot_ly(data = rain) %>%
  add_trace(x=~end.local, y =~rainfall.amount.inches, type = "scatter", mode = "lines", color = I("steelblue3"), name = 
              "rainfall every 10 minutes") %>%
  add_trace(x=~end.local, y =~cumu, type = "scatter", mode = "lines", yaxis = "y2", color = I("tomato1"), 
            name = "cumulative rainfall")  %>%
  layout( title = "rain", #graph title 
    xaxis = list(title="Date"),
    yaxis = list(title = "Rainfall(inches)"), #title the first y axis here
    yaxis2 = ay)

p


#multistation graph
m <- plot_ly(data = rain) %>%
  add_trace(x=~end.local, y =~rainfall.amount.inches, type = "scatter", mode = "lines", color =~station.name, name = 
              "rainfall (hourly)") %>%
  layout(title = "rain", #graph title 
         xaxis = list(title="Date"),
         yaxis = list(title = "Rainfall(inches)")
  )
m
