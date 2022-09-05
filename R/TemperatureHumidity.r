#!/usr/bin/env Rscript
#
#
# Script: Weather.r
#
# Stand: 2022-01-21
# (c) 2021 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

MyScriptName <- "TemperatureHumidity"

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

outdir <- '../png/Humidity/'
dir.create( outdir , showWarnings = FALSE, recursive = FALSE, mode = "0777")

MyPos <- list( lat = 50.620941424520026, long = 6.961696767218697)

T_Date <- function( Datum , intercept, slope) {
  
  return (intercept + slope * cospi( as.numeric(Datum - as.Date("2021-07-20"))/182.5))
  
}

SQL <- paste( 'select'
              , 'year(dateutc) as Jahr '
              , ', month(dateutc) as Monat '
              , ', Fahrenheit_Celsius(tempf) as Temperature'
              , ', humidity as Humidity'
              , 'from reports'
              , ';'
)

TTRF <- RunSQL(SQL)

TTRF$Jahre <- factor(TTRF$Jahr, levels = unique(TTRF$Jahr), labels = paste('Jahr', unique(TTRF$Jahr)))
TTRF$Monate <- factor(TTRF$Monat,levels = 1:12, labels = Monatsnamen)
TTRF$AbsHumidity <- SaettigungWasser(TTRF$Temperatur+273.15) * TTRF$Humidity / 100

today <- Sys.Date()
heute <- format(today, "%Y%m%d")

TTRF %>% ggplot() + 
  geom_point( aes( x = Temperature, y = Humidity, colour = Jahre ), size = 0.1 , alpha = 0.05) +
  scale_x_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  # scale_fill_viridis(discrete = TRUE) +
  facet_wrap(vars(Monate), nrow = 3) +
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
  ) +
  labs(  title = paste( 'Temperaturen / rel. Luftfeuchte' )
         , subtitle = 'Wetterstation Rheinbach'
         , x = "Temperatur [°C]"
         , y = "Rel. Luftfeuchte [%]"
         , caption = paste( "Stand:", heute )
  ) -> P

ggsave(  
  file = paste( outdir, MyScriptName, '.png', sep='')
  , plot = P
  , device = 'png'
  , bg = "white"
  , width = 1920 
  , height = 1080
  , units = "px"
  , dpi = 144
)


TTRF %>% ggplot() + 
  geom_point( aes( x = Temperature, y = AbsHumidity, colour = Jahre ), size = 0.5, alpha = 0.05 ) +
  scale_x_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  # scale_fill_viridis(discrete = TRUE) +
  facet_wrap(vars(Monate), nrow = 3) +
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
  ) +
  labs(  title = paste( 'Temperaturen / Absolute Luftfeuchte' )
         , subtitle = 'Wetterstation Rheinbach'
         , x = "Temperatur [°C]"
         , y = "Abs. Luftfeuchte [kg/m³]"
         , caption = paste( "Stand:", heute )
  ) -> P

ggsave(  
  file = paste( outdir, MyScriptName, '_Abs.png', sep='')
  , plot = P
  , device = 'png'
  , bg = "white"
  , width = 1920 * 2
  , height = 1080 * 2
  , units = "px"
  , dpi = 144
)
