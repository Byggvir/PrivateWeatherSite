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

today <- Sys.Date()
heute <- format(today, "%Y%m%d")

T_Date <- function( Datum , intercept, slope) {
  
  return (intercept + slope * cospi( as.numeric(Datum - as.Date("2021-07-20"))/182.5))
  
}

SQL <- paste( 
    'select dateutc as Datum, "Mittelerde" as Quelle, Fahrenheit_Celsius(tempf) as Temperature'
  , ' from reports where dateutc > date(SUBDATE(now(), INTERVAL 60 DAY)) group by Datum'
  , 'union'
  ,  'select dateutc as Datum, "EL51H" as Quelle, Temperature as Temperature'
  , ' from datalogger where dateutc > date(SUBDATE(now(), INTERVAL 60 DAY)); '
)

datalogger <- RunSQL(SQL)

# Jahr

J <- year(datalogger$Datum)
JJ <- unique(J)

# Year of calendarweek

isoJ <- isoyear(datalogger$Datum)
isoJJ <- unique(isoJ)

# Factor dateutc

datalogger$Jahre <- factor( J, levels = JJ, labels = JJ)
datalogger$Monate <- factor( month(datalogger$Datum), levels = 1:12, labels = Monatsnamen)

datalogger$KwJahre <- factor( isoJ, levels = isoJJ, labels = isoJJ)
datalogger$Kw <- factor( isoweek(datalogger$Datum), levels = 1:53, labels = paste('Kw', 1:53))


datalogger %>% ggplot() + 
  geom_boxplot( aes( x = Kw, y = Temperature, fill = Quelle ) ) +

  # scale_x_date( breaks = '1 week' ) + 
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_fill_viridis(discrete = TRUE) +

  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
          , strip.text.x = element_text (
              color = "black"
            , face = "bold.italic"
          ) ) +
  labs(  title = paste( 'Vergleich Mittelerde - Wintergarten' )
         , subtitle = 'Temperatur'
         , x = "Datum/Zeit"
         , y = "Temperatur [°C]"
         , colour = 'Quelle'
         , caption = paste( "Stand:", heute )
  ) -> P

ggsave(  
  file = paste( outdir,'datalogger_maxT.png', sep='')
  , plot = P
  , device = 'png'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 144
)
