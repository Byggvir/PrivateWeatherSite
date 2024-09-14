#!/usr/bin/env Rscript
#
#
# Script: Weather.r
#
# Stand: 2024-09-09
# (c) 2024 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

options(OutDec=',')

require(data.table)
library(tidyverse)
library(grid)
library(gridExtra)
library(gtable)
library(lubridate)
library(ggplot2)
library(viridis)
library(hrbrthemes)
library(scales)
library(ragg)
library(xml2)
library(jsonlite)
# 
# Set Working directory to git root

if (rstudioapi::isAvailable()){
  
  # When called in RStudio
  SD <- unlist(str_split(dirname(rstudioapi::getSourceEditorContext()$path),'/'))
  
} else {
  
  #  When called from command line 
  SD = (function() return( if(length(sys.parents())==1) getwd() else dirname(sys.frame(1)$ofile) ))()
  SD <- unlist(str_split(SD,'/'))
  
}

WD <- paste(SD[1:(length(SD))],collapse='/')

setwd(WD)
# print(WD)

source("lib/myfunctions.r")
source("lib/sql.r")


outdir <- '../png/Wetter/'

dir.create( outdir , showWarnings = FALSE, recursive = FALSE, mode = "0777")
T_Date <- function( Datum , intercept, slope) {
  
  return (intercept + slope * cospi( as.numeric(Datum - as.Date("2021-07-20"))/182.5))
  
}

today <- Sys.Date()
heute <- format(today, "%Y%m%d")

daten <- jsonlite::read_json('http://worldweather.wmo.int/de/json/56_de.xml')

n = length(daten$city$forecast$forecastDay)

WeatherForecast = data.table(
    Datum = rep(today,n)
    , Weather = rep("",n)
    , MinTemp = rep(-999,n)
    , MaxTemp = rep(-999,n)
)

for ( i in 1:n) {
  
  wf = unlist( daten$city$forecast$forecastDay[[i]])
  WeatherForecast[i,Datum := as.Date(wf[1])]
  WeatherForecast[i,weather := wf[3] ]
  WeatherForecast[i,minTemp := as.numeric( wf[4]) ]
  WeatherForecast[i,maxTemp := as.numeric( wf[5]) ]
  
}

WeatherForecast %>% ggplot() + 
  
  geom_line( aes(x=Datum, y = maxTemp, colour = 'Max' )) +
  geom_line( aes(x=Datum, y = minTemp, colour = 'Min' )) +
  
  scale_x_date( breaks = '1 day' ) + 
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_fill_viridis(discrete = TRUE) +
  labs(  title = paste( 'Wettervorhersage' )
         , subtitle = 'Minimale / Maximale Temperatur des Tages'
         , x = "Datum"
         , y = "Temperatur [°C]"
         , colour = 'Legende'
  ) +
  theme(  plot.title = element_text( size = 24 )
          , legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
          , strip.text.x = element_text (
            size = 12
            , color = "black"
            , face = "bold.italic"
          ) ) +
  theme_ipsum() -> P

ggsave(   
  file = paste( outdir, 'Wettervorhersage.png', sep='')
  , plot = P
  , device = 'png'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 144
)
