#!/usr/bin/env Rscript
#
#
# Script: TempCompareDays.r
#
# Stand: 2022-03-10
# (c) 2021 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

MyScriptName <- "TempCompareDays.r"

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
source("lib/sql.r")

today <- Sys.Date()
heute <- format(today, "%Y%m%d")

outdir <- '../png/Temperatur/'
dir.create( outdir , showWarnings = FALSE, recursive = TRUE, mode = "0777" )

SQL <- paste( 
    'select dateutc as Datum, 1 as Tag, Fahrenheit_Celsius(tempf) as temperature'
  , ' from reports where date(dateutc) = "2022-07-19" '
  , ' union '
  , 'select dateutc as Datum, 2 as Tag, Fahrenheit_Celsius(tempf) as temperature'
  , ' from reports where date(dateutc) =', paste0('"', heute, '"'), ';'
)

daten <- RunSQL(SQL)
daten$Zeit <- hour(daten$Datum)+ minute(daten$Datum) / 60 + second(daten$Datum) / 3600
daten$Tage <- factor( daten$Tag, levels = 1:2, labels = c ("Jahr 2022","Jahr 2023") )
                     
daten %>% ggplot() +
  geom_line( aes( x = Zeit, y = temperature, colour = Tage ), linewidth = 2 ) +

  scale_x_continuous( breaks = 0:24, labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_fill_viridis(discrete = TRUE) +
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
          , strip.text.x = element_text (
              color = "black"
            , face = "bold.italic"
          ) ) +
  labs(  title = paste( 'Temperaturvergleich zweier Tage' )
         , subtitle = paste('2022-07-19 vs',format(today, "%Y-%m-%d") )
         , x = "UTC [h]"
         , y = "Temperatur [°C]"
         , colour = 'Legende'
         , caption = paste( "Stand:", heute )
  ) -> P

ggsave(  file = paste0( outdir, 'TemperaturVergleich_', heute, '.png', sep='')
  , plot = P
  , device = 'png'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 144
)
