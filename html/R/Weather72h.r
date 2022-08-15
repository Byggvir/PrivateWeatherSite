#!/usr/bin/env Rscript
#
#
# Script: Weather.r
#
# Stand: 2022-03-10
# (c) 2021 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

MyScriptName <- "Weather72h"

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

windvector <- function ( d, v ) {
  
  x <- sin(d) * v
  y <- cos(d) * v 
  w <- data.table(
    x = x
    , y = y
  )
  return (w)
  
}

SQL <- 'select * from stations where id = 1;'

Stations <- RunSQL(SQL)

SQL <- paste( 
    'select dateutc as Zeit, Fahrenheit_Celsius(tempf) as temperature'
  , ', Barom_in2hPa(baromin) as rel_air_pressure'
  , ', Barom_in2hPa(absbaromin) as abs_air_pressure'
  , ', winddir'
  , ', mph_ms(windspeedmph) as windspeed'
  , ', solarradiation'
  , ', UV'
  , ', humidity'
  , ' from reports '
  , ' where id = 1 '
  , ' and dateutc > date(SUBDATE(now(), INTERVAL 168 HOUR)) ;'
)

daten <- RunSQL(SQL)

today <- Sys.Date()
heute <- format(today, "%Y%m%d")


minZ <- min(daten$Zeit)
maxT <- max(daten$temperature)

UVmax = max(c(daten$UV,10))
SRmax = max(c(daten$solarradiation,1000))

scl = ( UVmax / SRmax )

for (Zeitraum in c(72, 168) ) {
     
daten %>%  filter(Zeit > today - Zeitraum / 24 ) %>% ggplot() + 
  geom_line( aes( x = Zeit, y = temperature, colour = 'Temperatur' ), size = 1 ) +
  # scale_x_datetime( ) + # breaks = '1 hour' ) + 
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_fill_viridis(discrete = TRUE) +
  
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
          ) +
  labs(  title = paste( 'Temperaturen', Stations$name[1] )
         , subtitle = paste('Letzte', Zeitraum,'Stunden - Stand:', format(Sys.time(), "%Y-%m-%d %H:%M" ))
         , x = "Datum/Zeit"
         , y = "Temperatur [°C]"
         , colour = 'Legende'
         , caption = paste( "Stand:", heute )
  ) -> P

ggsave(  paste( 
  file = '../png/temperature_',Zeitraum,'h.svg', sep='')
  , plot = P
  , device = 'svg'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 150
)


daten %>%  filter(Zeit > today - Zeitraum / 24) %>% ggplot() + 
  geom_line( aes( x = Zeit, y = humidity, colour = 'Luftfeuchte' ), size = 1 ) +
  # scale_x_datetime( ) + # breaks = '1 hour' ) + 
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_fill_viridis(discrete = TRUE) +
  expand_limits( y = 0) +
  expand_limits( y = 100 ) +
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
  ) +
  labs(  title = paste( 'Luftfeuchte', Stations$name[1] )
         , subtitle = paste('Letzte', Zeitraum,'Stunden - Stand:', format(Sys.time(), "%Y-%m-%d %H:%M" ))
         , x = "Datum/Zeit"
         , y = "Luftfeuchte [%]"
         , colour = 'Legende'
         , caption = paste( "Stand:", heute )
  ) -> P

ggsave(  paste( 
  file = '../png/humidity_',Zeitraum,'h.svg', sep='')
  , plot = P
  , device = 'svg'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 150
)

daten %>%  filter(Zeit > today - Zeitraum / 24) %>% ggplot() + 
  geom_line( aes( x = Zeit, y = rel_air_pressure, colour = 'Relativ' ), size = 1 ) +
  geom_line( aes( x = Zeit, y = abs_air_pressure, colour = 'Absolut' ), size = 1 ) +
  
  scale_x_datetime( ) + # breaks = '1 hour' ) + 
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_fill_viridis(discrete = TRUE) +
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
  ) +
  labs(  title = paste( 'Luftdruck', Stations$name[1] )
         , subtitle = paste('Letzte', Zeitraum,'Stunden - Stand:', format(Sys.time(), "%Y-%m-%d %H:%M" ))
         , x = "Datum/Zeit"
         , y = "Luftdruck [hPa]"
         , colour = 'Legende'
         , caption = paste( "Stand:", heute )
  ) -> P

ggsave(  paste( 
  file = '../png/air_pressure_',Zeitraum,'h.svg', sep='')
  , plot = P
  , device = 'svg'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 150
)

daten %>%  filter(Zeit > today - Zeitraum / 24) %>% ggplot() + 
  geom_line( aes( x = Zeit, y = solarradiation, colour = 'Leistung' ), size = 1 ) +
  geom_line( aes( x = Zeit, y = UV / scl, colour = 'UV Index' ), size = 1 ) +
  
  scale_x_datetime( ) + # breaks = '1 hour' ) + 
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ),
                      sec.axis = sec_axis( ~.* scl, name = "UV Index"
                                           , labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ))) +
  scale_fill_viridis(discrete = TRUE) +
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
  ) +
  labs(  title = paste( 'Sonneneinstrahlung', Stations$name[1] )
         , subtitle = paste( 'Letzte', Zeitraum,'Stunden - Stand:', format(Sys.time(), "%Y-%m-%d %H:%M" ))
         , x = "Datum/Zeit"
         , y = "Leistung [W/m²]"
         , colour = 'Legende'
         , caption = paste( "Stand:", heute )
  ) -> P

ggsave(  paste( 
  file = '../png/solarradiation_',Zeitraum,'h.svg', sep='')
  , plot = P
  , device = 'svg'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 150
)

daten %>%  filter(Zeit > today - Zeitraum / 24) %>% ggplot() + 
  geom_point( aes( x = Zeit, y = windspeed, colour = 'Geschwindigkeit' ), size = 1 ) +
  geom_smooth( aes( x = Zeit, y = windspeed, colour = 'Geschwindigkeit' ), size = 1 ) +
  
  scale_x_datetime( ) + # breaks = '1 hour' ) + 
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_fill_viridis(discrete = TRUE) +
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
  ) +
  labs(  title = paste( 'Windgeschwindigkeit', Stations$name[1] )
         , subtitle = paste( 'Letzte', Zeitraum,'Stunden - Stand:', format(Sys.time(), "%Y-%m-%d %H:%M" ))
         , x = "Datum/Zeit"
         , y = "Geschwindigkeit [m/s]"
         , colour = 'Legende'
         , caption = paste( "Stand:", heute )
  ) -> P

ggsave(  paste( 
  file = '../png/windspeed_',Zeitraum,'h.svg', sep='')
  , plot = P
  , device = 'svg'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 150
)

daten %>%  filter(Zeit > today - Zeitraum / 24) %>% ggplot() + 
  geom_point( aes( x = Zeit, y = winddir, colour = 'Richtung' ), size = 1 ) +

  scale_x_datetime( ) + # breaks = '1 hour' ) + 
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_fill_viridis(discrete = TRUE) +
  expand_limits( y = 0 ) +
  expand_limits( y = 360 ) +
  
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
  ) +
  labs(  title = paste( 'Windrichtung', Stations$name[1] )
         , subtitle = paste( 'Letzte', Zeitraum,'Stunden - Stand:', format(Sys.time(), "%Y-%m-%d %H:%M" ))
         , x = "Datum/Zeit"
         , y = "Richtung [°]"
         , colour = 'Legende'
         , caption = paste( "Stand:", heute )
  ) -> P

ggsave(  paste( 
  file = '../png/winddir_',Zeitraum,'h.svg', sep='')
  , plot = P
  , device = 'svg'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 150
)

wind <-windvector(daten$winddir[daten$Zeit > today - Zeitraum / 24],daten$windspeed[daten$Zeit > today - Zeitraum / 24])

wind %>%  ggplot() + 
  geom_point( aes( x = x, y = y, colour = 'Richtung' ), alpha = 0.5, size = 1 ) +
  scale_x_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_fill_viridis(discrete = TRUE) +
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
  ) +
  labs(  title = paste( 'Windrichtung und -stärke', Stations$name[1] )
         , subtitle = paste( 'Letzte', Zeitraum,'Stunden - Stand:', format(Sys.time(), "%Y-%m-%d %H:%M" ))
         , x = "x [m/s]"
         , y = "y [m/s]"
         , colour = 'Legende'
         , caption = paste( "Stand:", heute )
  ) -> P

ggsave(  paste( 
  file = '../png/wind_',Zeitraum,'h.svg', sep='')
  , plot = P
  , device = 'svg'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 150
)

}