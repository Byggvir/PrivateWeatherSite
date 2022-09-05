#!/usr/bin/env Rscript
#
#
# Script: Weather.r
#
# Stand: 2022-03-10
# (c) 2021 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

MyScriptName <- "datalogger"

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
source("lib/mytheme.r")
source("lib/sql.r")

outdir <- '../png/datalogger/'
dir.create( outdir , showWarnings = FALSE, recursive = FALSE, mode = "0777")

T_Date <- function( Datum , intercept, slope) {
  
  return (intercept + slope * cospi( as.numeric(Datum - as.Date("2021-07-20"))/182.5))
  
}

SQL <- paste( 
    'select dateutc as Zeit, L.name as Quelle, L.Ort as Ort, Temperature as Temperature, Humidity as Humidity'
  , ' from datalogger as D join logger as L on L.id = D.logger;'
)

DL <- RunSQL(SQL)

today <- Sys.Date()
heute <- format(today, "%Y%m%d")

for ( l in unique(DL$Ort) ) {
  
  L <- DL %>% filter( Ort == l )
  scl <- max(L$Temperature) / max(L$Humidity)
  
  L %>% ggplot() + 
    geom_line( aes( x = Zeit, y = Temperature, colour = 'Temperatur' ) , size = 1 ) +
    geom_line( aes( x = Zeit, y = Humidity * scl, colour = 'Luftfeuchte' ) , size = 1 ) +
    scale_x_datetime() + # ( breaks = '1 hour' ) + 
    scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ),
                        sec.axis = sec_axis( ~. / scl, name = "Humidity"
                                             , labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ))) +
    # expand_limits( y = 0) +
    theme_ipsum() +
    theme(  legend.position="right"
            , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1) ) +
    labs( title = paste( 'Data Logger:', l )
          , subtitle = 'Temperatur und Luftfeuchte'
          , x = "Datum/Zeit"
          , y = "Temperatur [°C]"
          , colour = 'Parameter'
          , caption = paste( "Stand:", heute )
    ) -> P

  ggsave(   
    file = paste( outdir, l, '.png', sep='')
    , plot = P
    , device = 'png'
    , bg = "white"
    , width = 1920
    , height = 1080
    , units = "px"
    , dpi = 144
  )

}