#!/usr/bin/env Rscript
#
#
# Script: Weather.r
#
# Stand: 2022-01-21
# (c) 2021 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

MyScriptName <- "Solarradiation"

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
source("lib/mytheme.r")
source("lib/sql.r")

outdir <- '../png/Solar/'
dir.create( outdir , showWarnings = FALSE, recursive = TRUE, mode = "0777" )

MyPos <- list( lat = 50.620941424520026, long = 6.961696767218697)

T_Date <- function( Datum , intercept, slope) {
  
  return (intercept + slope * cospi( as.numeric(Datum - as.Date("2021-07-20"))/182.5))
  
}

PrepareSQL = paste( 'call KeyedTable()'
)
ExecSQL(SQL = PrepareSQL)

SQL <- paste( 
    'select date(R.dateutc) as Datum' 
  , ', year(R.dateutc) as Jahr'
  , ', month(R.dateutc) as Monat'
  , ', sum(delta*R.solarradiation) / 3600000 as Energie'
  , 'from reports as R'
  , 'join TimeUntilNextReport as T'
  , 'on T.dateutc = R.dateutc'
  , 'group by Datum'
  , ';'
)

Solarradiation <- RunSQL(SQL=SQL)
Solarradiation$Jahre <- factor(Solarradiation$Jahr, levels = unique(Solarradiation$Jahr), labels = unique(Solarradiation$Jahr))
Solarradiation$Monate <- factor(Solarradiation$Monat, levels = 1:12, labels = Monatsnamen)

iy <- isoyear(Solarradiation$Datum)
Solarradiation$ISOYear <- factor(iy, levels = unique(iy), labels = unique(iy) )
Solarradiation$ISOWeek <- factor(isoweek(Solarradiation$Datum), levels = 1:53, labels = 1:53 )


today <- Sys.Date()
heute <- format(today, "%Y%m%d")

Solarradiation %>% filter(Energie > 0) %>% ggplot(aes( x = Monate, y = Energie )) + 
  geom_boxplot( aes( fill = Jahre ) ) +
  expand_limits( y = 0 ) +
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 0, vjust = 0.5, hjust=0.5)
  ) +
  labs(  title = paste( 'Sonneneinstahlung Rheinbach - Mittelerde' )
         , subtitle = 'Minutenwerte der dnt WeatherScreen Pro'
         , x = 'Monat'
         , y = 'Energie pro Tag [kWh/m²]'
         , colour = 'Jahre'
         , caption = paste( "Stand:", heute )
  ) -> P3

ggsave(  paste( 
  file = outdir, MyScriptName, '-month.png', sep='')
  , plot = P3
  , device = 'png'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 144
)

Solarradiation %>% filter(Energie > 0) %>% ggplot( aes( x = ISOWeek, y = Energie )) + 
  geom_boxplot( aes( fill = Jahre ) ) +
  expand_limits( y = 0 ) +
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 0, vjust = 0.5, hjust=0.5)
  ) +
  labs(  title = paste( 'Sonneneinstahlung Rheinbach - Mittelerde' )
         , subtitle = 'Minutenwerte der dnt WeatherScreen Pro'
         , x = 'Kalenderwoche'
         , y = 'Energie pro Tag [kWh/m²]'
         , colour = 'Jahre'
         , caption = paste( "Stand:", heute )
  ) -> P3

ggsave(  paste( 
  file = outdir, MyScriptName, '-week.png', sep='')
  , plot = P3
  , device = 'png'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 144
)
