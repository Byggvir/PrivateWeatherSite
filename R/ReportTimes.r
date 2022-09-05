#!/usr/bin/env Rscript
#
#
# Script: Weather.r
#
# Stand: 2022-01-21
# (c) 2021 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

MyScriptName <- "TempCYear"

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

outdir <- '../png/Temperatur/'
dir.create( outdir , showWarnings = FALSE, recursive = TRUE, mode = "0777" )

MyPos <- list( lat = 50.620941424520026, long = 6.961696767218697)

T_Date <- function( Datum , intercept, slope) {
  
  return (intercept + slope * cospi( as.numeric(Datum - as.Date("2021-07-20"))/182.5))
  
}

SQL <- paste( 'select year(t1.dateutc) as Jahr, month(t1.dateutc) as Monat, time_to_sec(timediff(t1.dateutc,t2.dateutc)) as delta from times as t1 join times as t2 on t1.n = t2.n+1;')

RT <- RunSQL(SQL)
RT$Jahre <- factor(RT$Jahr, levels = unique(RT$Jahr), labels = unique(RT$Jahr)) 
RT$Monate <- factor(RT$Monat, levels = 1:12, labels = Monatsnamen) 
  
today <- Sys.Date()
heute <- format(today, "%Y%m%d")

RT %>% filter (delta < 1000 ) %>% ggplot(aes( x = delta, groupe = Monate)) + 
  geom_histogram( aes( fill = Monate), binwidth = 1, position = position_stack()) +
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 0, vjust = 0.5, hjust=1)
  ) +
  labs(  title = paste( 'Abstand zwischen zwei Meldungen' )
         , subtitle = 'Minutenwerte der DNT Weatherscreen Pro'
         , x = 'Anzahl'
         , y = 'Sekunden'
         , colour = 'Jahre'
         , caption = paste( "Stand:", heute )
  ) -> P3

ggsave(  paste( 
  file = outdir, 'ReportZeiten.png', sep='')
  , plot = P3
  , device = 'png'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 144
)
