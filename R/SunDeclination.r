#!/usr/bin/env Rscript
#
#
# Script: Weather.r
#
# Stand: 2022-01-21
# (c) 2021 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

MyScriptName <- "SunDeclination"

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
source("lib/sql.r")

today <- Sys.Date()
heute <- format(today, "%Y%m%d")

MyPos <- list( lat = 50.620941424520026, long = 6.961696767218697)

e = 23.43639 / 180 * pi # Neigung der Ekliptik 

Deklination <- function( x ) {

  T = as.numeric(x - as.Date("2022-01-01"))
  
  return ( e * sin(0.016906*(T-81.086)) * 180 / pi  + (90 - MyPos$lat) )
  
}

SunDeclination <- data.table(
  
  Datum = seq(from=as.Date("2022-01-01"), to=as.Date("2022-12-31"), by = 1 )
  
)

SunDeclination$Winkel <- Deklination(SunDeclination$Datum)

SunDeclination %>% ggplot( aes(x = Datum) ) + 
  geom_function( fun = Deklination, size = 2, color = 'black' ) +
  scale_x_date( breaks = '1 month', date_labels = "%b %Y" ) + 
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_fill_viridis(discrete = TRUE) +
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
  ) +
  labs(  title = paste( 'Höhe der Sonne Rheinbach' )
         , subtitle = 'Höhe zur Mittagszeit'
         , x = "Datum"
         , y = "Winkel [°]"
         , colour = 'Tagestemperatur'
         , caption = paste( "Stand:", heute )
  ) -> P

ggsave(  paste( 
  file = '../png/', MyScriptName, '_T.png', sep='')
  , plot = P
  , device = 'png'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 150
)
