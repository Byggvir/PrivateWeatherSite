#!/usr/bin/env Rscript
#
#
# Script: Weather.r
#
# Stand: 2022-03-10
# (c) 2021 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

MyScriptName <- "TempC72h"

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
#library(extrafont)
#extrafont::loadfonts()

# Set Working directory to git root

if (rstudioapi::isAvailable()){
  
  # When called in RStudio
  SD <- unlist(str_split(dirname(rstudioapi::getSourceEditorContext()$path),'/'))
  
} else {
  
  #  When called from command line 
  SD = ( function() return( if(length(sys.parents())==1) getwd() else dirname(sys.frame(1)$ofile) ) )()
  SD <- unlist(str_split(SD,'/'))
  
}

WD <- paste(SD[1:(length(SD))],collapse='/')
if ( SD[length(SD)] != "R" ) {
  
  WD <- paste( WD,"/R", sep = '')

}

setwd(WD)

source("lib/myfunctions.r")
source("lib/mytheme.r")
source("lib/sql.r")

T_Date <- function( Datum , intercept, slope) {
  
  return (intercept + slope * cospi( as.numeric(Datum - as.Date("2021-07-20"))/182.5))
  
}

SQL <- paste( 
    'select dateutc as Zeit, Fahrenheit_Celsius(tempf) as temperature'
  , ', Barom_in2hPa(baromin) as rel_air_pressure'
  , ', Barom_in2hPa(absbaromin) as abs_air_pressure'
  , ', solarradiation'
  , ' from reports where dateutc > date(SUBDATE(now(), INTERVAL 72 HOUR)) ;'
)
daten <- RunSQL(SQL)

today <- Sys.Date()
heute <- format(today, "%Y%m%d")

daten %>% ggplot() + 
  geom_line( aes( x = Zeit, y = temperature, colour = 'Temperatur' ), size = 0.1 ) +

  scale_x_datetime( ) + # breaks = '1 hour' ) + 
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_fill_viridis(discrete = TRUE) +

  theme_ta() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
          , strip.text.x = element_text (
              color = "black"
            , face = "bold.italic"
          ) ) +
  labs(  title = paste( 'Temperaturen Rheinbach' )
         , subtitle = 'Letzte 4 Tage'
         , x = "Datum/Zeit"
         , y = "Temperatur [°C]"
         , colour = 'Legende'
         , caption = paste( "Stand:", heute )
  ) -> P

ggsave(  paste( 
  file = '../png/temperature_72h.svg', sep='')
  , plot = P
  , device = 'svg'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 72
)

daten %>% ggplot() + 
  geom_line( aes( x = Zeit, y = rel_air_pressure, colour = 'Relativ' ), size = 0.1 ) +
  geom_line( aes( x = Zeit, y = abs_air_pressure, colour = 'Absolut' ), size = 0.1 ) +
  
  scale_x_datetime( ) + # breaks = '1 hour' ) + 
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_fill_viridis(discrete = TRUE) +
  theme_ta() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
          , strip.text.x = element_text (
            color = "black"
            , face = "bold.italic"
          ) ) +
  labs(  title = paste( 'Luftdruck Rheinbach' )
         , subtitle = 'Letzte 4 Tage'
         , x = "Datum/Zeit"
         , y = "Luftdruck [hPa]"
         , colour = 'Legende'
         , caption = paste( "Stand:", heute )
  ) -> P

ggsave(  paste( 
  file = '../png/air_pressure_72h.svg', sep='')
  , plot = P
  , device = 'svg'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 72
)


daten %>% ggplot() + 
  geom_line( aes( x = Zeit, y = solarradiation, colour = 'Leistung' ), size = 0.1 ) +

  scale_x_datetime( ) + # breaks = '1 hour' ) + 
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_fill_viridis(discrete = TRUE) +
  theme_ta() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
          , strip.text.x = element_text (
            color = "black"
            , face = "bold.italic"
          ) ) +
  labs(  title = paste( 'Sonneneinstrahlung Rheinbach' )
         , subtitle = 'Letzte 4 Tage'
         , x = "Datum/Zeit"
         , y = "Leistung [W/m²]"
         , colour = 'Legende'
         , caption = paste( "Stand:", heute )
  ) -> P

ggsave(  paste( 
  file = '../png/Sonneneinstrahlung_72h.svg', sep='')
  , plot = P
  , device = 'svg'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 72
)
