#!/usr/bin/env Rscript
#
#
# Script: Temp_Koeln.r
#
# Stand: 2024-04-06
# (c) 2021 by Thomas Arend, Rheinbach
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

outdir <- '../png/Rain/'
dir.create( outdir , showWarnings = FALSE, recursive = TRUE, mode = "0777" )

SQL <- paste( 'select H.Jahr, H.Monat, H.Regen as RR_Rhb, K.MO_RR as RR_Koe from RainMonth as H join dwd.monthly as K on K.Jahr = H.Jahr and K.Monat = H.Monat where K.Stations_Id = 2667 and K.MO_RR >= 0 and H.Regen > 0 and H.Jahr > 2021;' )

daten <- RunSQL(SQL)

daten %>% ggplot( aes( x = RR_Rhb, y = RR_Koe) ) +
  geom_point( ) +
  geom_smooth( formula = y ~x, method = 'lm') +
  scale_x_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  coord_equal() +
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
          , strip.text.x = element_text (
              color = "black"
            , face = "bold.italic"
          ) ) +
  labs(  title = paste( 'Köln/Bonn vs Rheinbach' )
         , subtitle = paste( 'Monatliche Regenmenge' )
         , x = "Regenmenge Rheinbach [mm]"
         , y = "Regenmenge Köln/Bonn [mm]"
         , colour = 'Legende'
         , caption = paste( "Stand:", heute )
  ) -> P

ggsave(  file = paste0( outdir, 'ScatterKoeRhb.png', sep='')
  , plot = P
  , device = 'png'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 144
)

ra = lm ( data = daten , formula = RR_Koe ~ RR_Rhb )
ci = confint(ra)

print(ra$coefficients)
print(ci)

