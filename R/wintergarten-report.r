#!/usr/bin/env Rscript
#
#
# Script: Weather.r
#
# Stand: 2022-03-10
# (c) 2021 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

MyScriptName <- "wintergarten-report"

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

outdir <- '../png/Wintergarten/'
dir.create( outdir , showWarnings = FALSE, recursive = FALSE, mode = "0777")

T_Date <- function( Datum , intercept, slope) {
  
  return (intercept + slope * cospi( as.numeric(Datum - as.Date("2021-07-20"))/182.5))
  
}

today <- Sys.Date()
heute <- format(today, "%Y%m%d")

SQL <- paste( 
    'select name, dateutc as Zeit, Temperature as Temperature, Humidity as Humidity'
  , ' from datalogger as D join logger as L on D.logger = L.id where D.logger = 1'
  , ' union '
  , ' select name as name, dateutc as Zeit, Fahrenheit_Celsius(tempf) as Temperature , humidity as Humidity'
  , ' from reports as R join stations as S on R.id = S.id;'
  )

daten <- RunSQL(SQL)

scl <-  max(daten$Humidity) / max(daten$Temperature)
                                 
daten %>% filter (Zeit > as.Date('2022-08-01 00:00') ) %>% ggplot() + 
# daten %>% ggplot() + 
  geom_line( aes( x = Zeit, y = Temperature, color = name, group = name ) , size = 1 ) +
#  geom_line( aes( x = Zeit, y = Humidity / scl, colour = name , group = name ) , size = 1 ) +
  expand_limits( y = 0 ) +
  scale_x_datetime( ) + # breaks = '1 hour' ) + 
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ),
                      sec.axis = sec_axis( ~.* scl, name = 'Luftfeuchte [%]' ) ) +
#  scale_fill_viridis(discrete = TRUE) +
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
          , strip.text.x = element_text (
              color = "black"
            , face = "bold.italic"
          ) ) +
  labs(  title = paste( 'Wintergaten vs Außentemperatur' )
         , subtitle = 'Temperatur'
         , x = "Datum/Zeit"
         , y = "Temperatur [° C]"
         , colour = 'Quelle'
         , caption = paste( "Stand:", heute )
  ) -> P

ggsave( file = paste( outdir, 'wintergarten', heute, '.png', sep='')
  , plot = P
  , device = 'png'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 144
)

SQL <- paste( 'call Wintergarten();' )

WG <- RunSQL(SQL)

ra <- lm(Wintergarten ~ Aussen, data = WG )
print(summary(ra))

WG %>% ggplot( aes( x = Aussen, y = Wintergarten ) ) + 
  geom_point( size = 1 ) +
  geom_smooth( size = 1, method = 'glm' ) +
  scale_x_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE )) +
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE )) +
  expand_limits( x = 0 , y = 0) +
  coord_fixed() +
  
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
          , strip.text.x = element_text (
            color = "black"
            , face = "bold.italic"
          ) ) +
  labs(  title = paste( 'Wintergaten vs Außentemperatur' )
         , subtitle = 'Temperatur'
         , x = "Außen [° C]"
         , y = "Wintergarten [° C]"
         , colour = 'Quelle'
         , caption = paste( "Stand:", heute )
  ) -> P

ggsave( file = paste( outdir, 'wintergarten', 'scatterplot', ',png', sep='')
        , plot = P
        , device = 'png'
        , bg = "white"
        , width = 1920
        , height = 1080
        , units = "px"
        , dpi = 144
)
