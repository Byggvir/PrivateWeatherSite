#!/usr/bin/env Rscript
#
#
# Script: TempMaxMin.r
#
# Stand: 2022-01-21
# (c) 2021 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

options(OutDec = ',')

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
# print(WD)

source("lib/myfunctions.r")
source("lib/sql.r")

outdir <- '../png/Temperatur/'
dir.create( outdir , showWarnings = FALSE, recursive = TRUE, mode = "0777" )

MyPos <- list( lat = 50.620941424520026, long = 6.961696767218697)

T_Date <- function( Datum , intercept, slope) {
  
  return (intercept + slope * cospi( as.numeric(Datum - as.Date("2021-07-20"))/182.5))
  
}

SQL <- paste( 'select'
              , 'date(dateutc) as Datum '
              , ',"Min" as Parameter '
              , ', Fahrenheit_Celsius(min(tempf)) as Temperatur'
              , 'from reports'
              , 'where id = 1'
              , 'group by Datum'
              , 'union'
              , 'select'
              , 'date(dateutc) as Datum '
              , ',"Max" as Parameter '
              , ', Fahrenheit_Celsius(max(tempf)) as Temperatur'
              , 'from reports'
              , 'where id = 1'
              , 'group by Datum'
              , ';'
)

TT <- RunSQL(SQL)

today <- Sys.Date()
heute <- format(today, "%Y%m%d")

TT %>% ggplot() + 
  geom_density( aes( x = Temperatur
                       , colour = Parameter 
                       # , fill = Parameter
                       ) 
                #, binwidth = 0.5 
                ) +
  scale_x_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  # facet_wrap ( vars( Parameter ) ) +
  labs(  title = paste( 'Temperaturen Rheinbach - Mittelerde' )
         , subtitle = 'dnt WeatherScreen Pro'
         , x = 'Temperatur'
         , y = 'Dichte'
         , colour = 'Temperatur'
         # , fill = 'Temperatur'
         , caption = paste( "Stand:", heute )
  ) +
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 0, vjust = 0.5, hjust=0.5)
  ) -> p

ggsave(  file = paste(outdir , 'TempMaxMin.png', sep='')
  , plot = p
  , device = 'png'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 144
)
