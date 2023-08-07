#!/usr/bin/env Rscript
#
#
# Script: TempCYear.r
#
# Stand: 2022-01-21
# (c) 2021 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

MyScriptName <- "TempCYear"

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
print(WD)

source("lib/myfunctions.r")
source("lib/sql.r")

outdir <- '../png/Temperatur/'
dir.create( outdir , showWarnings = FALSE, recursive = TRUE, mode = "0777" )

MyPos <- list( lat = 50.620941424520026, long = 6.961696767218697)

T_Date <- function( Datum , intercept, slope) {
  
  return (intercept + slope * cospi( as.numeric(Datum - as.Date("2021-07-20"))/182.5))
  
}

SQL <- paste( 'select'
              , 'dateutc as Datum '
              , ', Fahrenheit_Celsius(tempf) as Temperatur'
              , 'from reports'
              , 'where id = 1 '
              , ';'
)

TT <- RunSQL(SQL)

# Jahr

J <- year(TT$Datum)
JJ <- unique(J)

# Year of calendarweek

isoJ <- isoyear(TT$Datum)
isoJJ <- unique(isoJ)

# Factor dateutc

TT$Jahre <- factor( J, levels = JJ, labels = JJ)
TT$Monate <- factor( month(TT$Datum), levels = 1:12, labels = Monatsnamen)

TT$KwJahre <- factor( isoJ, levels = isoJJ, labels = isoJJ)
TT$Kw <- factor( isoweek(TT$Datum), levels = 1:53, labels = paste('Kw', 1:53))


today <- Sys.Date()
heute <- format(today, "%Y%m%d")

TT %>% ggplot(aes( x = Monate, y = Temperatur )) + 
  geom_boxplot( aes( fill = Jahre ) ) +
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 0, vjust = 0.5, hjust=0.5)
  ) +
  labs(  title = paste( 'Temperaturen Rheinbach - Mittelerde' )
         , subtitle = 'Minutenwerte der dnt WeatherScreen Pro'
         , x = 'Monat'
         , y = 'Temperatur [°C]'
         , colour = 'Jahre'
         , caption = paste( "Stand:", heute )
  ) -> P3

ggsave(  paste( 
  file = outdir, MyScriptName, '_Monate.png', sep='')
  , plot = P3
  , device = 'png'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 144
)


TT %>% ggplot(aes( x = Kw, y = Temperatur )) + 
  geom_boxplot( aes( fill = KwJahre ) ) +
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=0.5)
  ) +
  labs(  title = paste( 'Temperaturen Rheinbach - Mittelerde' )
         , subtitle = 'Minutenwerte der dnt WeatherScreen Pro'
         , x = 'Kalenderwoche'
         , y = 'Temperatur [°C]'
         , colour = 'Jahre'
         , caption = paste( "Stand:", heute )
  ) -> P3

ggsave(  paste( 
  file = outdir, MyScriptName, '_Wochen.png', sep='')
  , plot = P3
  , device = 'png'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 144
)
