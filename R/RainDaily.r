#!/usr/bin/env Rscript
#
#
# Script: RainDaily.r
#
# Stand: 2022-01-21
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
library(viridis)
library(hrbrthemes)
library(scales)
library(ragg)

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

outdir <- 'png/Rain/'
dir.create( outdir , showWarnings = FALSE, recursive = FALSE, mode = "0777")

MyPos <- list( lat = 50.620941424520026, long = 6.961696767218697)

T_Date <- function( Datum , intercept, slope) {
  
  return (intercept + slope * cospi( as.numeric(Datum - as.Date("2021-07-20"))/182.5))
  
}

SQL <- paste( 'select * from RainDay;'
)


RR <- RunSQL( SQL = SQL) 

#  %>% filter(Datum > "2022-12-31") 

today <- Sys.Date()
heute <- format(today, "%Y%m%d")

d = c(0)
t = c(0)
j = 1

for ( k in 1:nrow(RR)) {
  
  if ( RR$RR[k] == 0 ) {
    d[j] <- d[j] + 1
  }
  else {
    j= j + 1
    d[j] = 0
    t[j] = RR$Datum[k]
  }
}

DaysWithoutRain = data.table(
  Datum = as.Date(t)
  , TageOhneNiederschlag = d
)
print( DaysWithoutRain[ match(  max(DaysWithoutRain$TageOhneNiederschlag)
                                , DaysWithoutRain$TageOhneNiederschlag)
] )


RR %>% filter( Datum > "2022-12-31" ) %>% ggplot( aes( x = Datum, y = RR)) +
  geom_bar( position = position_dodge2( width = 0.9 ), stat = 'identity' ) +
  geom_text( data = RR %>% filter ( RR > 0  & Datum > "2022-12-31"), aes(label = round(RR,1) )
             , position = position_dodge2( width = 0.9 )
             , vjust = -0.5 
             , size = 2  ) +
  scale_x_date( date_breaks = 'month' ) +
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
  ) +
  labs(  title = paste( 'Täglicher Niederschlag' )
         , subtitle = 'Private Wetterstation Mittelerde, Rheinbach'
         , x = "Datum"
         , y = "Niederschlag [mm]"
         , caption = paste( "Stand:", heute )
  ) -> P

ggsave(  
  file = paste( outdir, 'Daily.png', sep='')
  , plot = P
  , device = 'png'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 144
)

setorder(RR,RR)

ggplot_build( ggplot(data = RR %>% filter(RR >0)) + stat_ecdf( aes(RR) ) ) -> d
RR %>% filter( RR > 0 & RR <= 10.0) %>%
    ggplot( aes( x = RR)) +
    # stat_ecdf(geom = 'line' ) +
    geom_density( ) +
    scale_x_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
    scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
    theme_ipsum() +
    theme(  legend.position="right"
            , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
    ) +
    labs(  title = paste( 'Dichte des täglichen Niederschlag' )
           , subtitle = 'Private Wetterstation Mittelerde, Rheinbach'
           , x = "Niederschlag [mm]"
           , y = "Dichte"
           , caption = paste( "Stand:", heute )
    ) -> P

ggsave(  
  file = paste( outdir, 'Daily_Density.png', sep='')
  , plot = P
  , device = 'png'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 144
)

DaysWithoutRain %>% ggplot() +
  geom_bar( aes(x = TageOhneNiederschlag )
            , position = position_dodge2( width = 0.9 )
            , stat = 'count' ) +
  geom_text( aes( x = TageOhneNiederschlag
                  , label = after_stat(count) )
             , position = position_dodge2( width = 0.9 )
             , stat = 'count'
             , vjust = -0.5
             , size = 2  ) +

  # scale_x_date() +
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
  ) +
  labs(  title = paste( 'Zeiträume ohne Niederschlag' )
         , subtitle = 'Private Wetterstation Mittelerde, Rheinbach'
         , x = "Zeitraum in Tagen"
         , y = "Anzahl"
         , caption = paste( "Stand:", heute )
  ) -> P

ggsave(  
  file = paste( outdir, 'Days_without_rain.png', sep='')
  , plot = P
  , device = 'png'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 144
)

SQL = 'select * from RainDayHist;'
RRSum = RunSQL ( SQL = SQL )
S = sum(RRSum$RR)
RRSum$y = S / RRSum$Anzahl

ra = lm ( data = RRSum, formula = y ~ RR )
a = ra$coefficients[1]
b = ra$coefficients[2]

RRSum %>% 
  ggplot( aes( x = RR, y = Anzahl / S ) ) +
  geom_bar( stat = 'identity' ) +
  geom_function( fun = function(x) { 1 / ( a + b * x ) } ) +
  scale_x_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
  ) +
  labs(  title = paste( 'Histogramm des täglichen Niederschlag' )
         , subtitle = 'Private Wetterstation Mittelerde, Rheinbach'
         , x = "Niederschlag [mm]"
         , y = "Dichte"
         , caption = paste( "Stand:", heute )
  ) -> P

ggsave(  
  file = paste( outdir, 'Daily_Hist.png', sep='')
  , plot = P
  , device = 'png'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 144
)

