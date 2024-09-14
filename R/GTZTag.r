#!/usr/bin/env Rscript
#
#
# Script: GTZMonat.r
#
# Stand: 2024-03-28
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
library(ggrepel)
library(viridis)
library(hrbrthemes)
library(scales)
library(ragg)

library(pracma)

# Set Working directory to git root

if (rstudioapi::isAvailable()){
  
  DSO <-  rstudioapi::getSourceEditorContext( id = NULL )
  
  # When called in RStudio
  SD <- unlist(
    str_split(
      dirname(
        DSO$path)
      , '/'
    )
  )
  
} else {
  
  #  When called from command line 
  SD = (function() return( if(length(sys.parents())==1) getwd() else dirname(sys.frame(1)$ofile) ))()
  SD <- unlist(str_split(SD,'/'))
  
}

WD <- paste(SD[1:(length(SD)-1)],collapse='/')
setwd(WD)
# print(WD)

source("R/lib/myfunctions.r")
source("R/lib/sql.r")

outdir <- 'png/GTZ/'
dir.create( outdir , showWarnings = FALSE, recursive = FALSE, mode = "0777")

MyPos <- list( lat = 50.620941424520026, long = 6.961696767218697)

T_Date <- function( Datum , intercept, slope) {
  
  return (intercept + slope * cospi( as.numeric(Datum - as.Date("2021-07-20"))/182.5))
  
}


today <- Sys.Date()
heute <- format(today, "%Y%m%d")

SQL <- paste( 'select * from GTZTag  where not ( Jahr = 2021 and Monat = 3 );')

GTZ <- RunSQL( SQL = SQL) 
GTZ$AvgGTZ = movavg(GTZ$GTZ, 30, 'e')

GTZ %>% ggplot( aes( x = Datum, y = GTZ ) ) +
  geom_bar( aes (), position = position_dodge2( width = 0.9 ), stat = 'identity' ) +
  scale_x_date( date_breaks = 'month' ) +
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
  ) +
  labs(  title = paste( 'Gradtagzahl eines Tages' )
         , subtitle = 'Private Wetterstation Mittelerde, Rheinbach'
         , x = "Datum"
         , y = "Gradtagzahl GZT [K]"
         , caption = paste( "Stand:", heute )
  ) -> P

ggsave(  
  file = paste( outdir, 'GTZTag.png', sep='')
  , plot = P
  , device = 'png'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 144
)
