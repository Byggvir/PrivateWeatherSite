#!/usr/bin/env Rscript
#
#
# Script: Weather.r
#
# Stand: 2022-01-21
# (c) 2021 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

MyScriptName <- "RainWeek"

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

source("lib/myfunctions.r")
source("lib/mytheme.r")
source("lib/sql.r")

outdir <- '../png/Rain/'
dir.create( outdir , showWarnings = FALSE, recursive = FALSE, mode = "0777")

MyPos <- list( lat = 50.620941424520026, long = 6.961696767218697)

T_Date <- function( Datum , intercept, slope) {
  
  return (intercept + slope * cospi( as.numeric(Datum - as.Date("2021-07-20"))/182.5))
  
}

SQL <- paste( 'select'
              , '  year(Datum) as Jahr'
              , ', week(Datum, 3) as Kw '
              , ', sum(Regen) as Regen'
              , 'from ( '
              , 'select'
              , 'date(dateutc) as Datum '
              , ', inch_mm(max(dailyrainin)) as Regen'
              , 'from reports '
              , 'group by Datum ) as F'
              , 'group by Jahr, Kw'
              , ';'
)

rain <- RunSQL(SQL)

rain$Kalenderwoche <- factor(rain$Kw, levels = 1:53, labels = paste( 'Kw', 1:53) )
rain$Jahre <- factor(rain$Jahr, levels = unique(rain$Jahr), labels = unique(rain$Jahr) )

today <- Sys.Date()
heute <- format(today, "%Y%m%d")

rain %>% ggplot( aes( x = Kw, y = Regen ) ) + 
  geom_bar( aes( fill = Jahre )
            , position = position_dodge2( width = 0.9)
            , stat = 'identity' ) +
  geom_text( aes(label = round(Regen,1) )
             , position = position_dodge2( width = 0.9 )
             , vjust = -0.5 
             , size = 2  ) +
  
  # scale_x_date() +
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
#  scale_y_break ( c(150,290) ) +
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
  ) +
  labs(  title = paste( 'Niederschlag' )
         , subtitle = 'Wetterstation Mittelerde, Rheinbach'
         , x = "Kalenderwoche"
         , y = "Niederschlag [mm]"
         , caption = paste( "Stand:", heute )
  ) -> P

ggsave(  
  file = paste( outdir, MyScriptName, '.png', sep='')
  , plot = P
  , device = 'png'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 144
)
