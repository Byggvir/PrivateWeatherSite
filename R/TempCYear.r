#!/usr/bin/env Rscript
#
#
# Script: TempCYear.r
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
library(ggrepel)
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
# print(WD)

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
              , ', month(dateutc) as Monat'
              , ', Fahrenheit_Celsius(tempf) as Temperatur'
              , 'from reports'
              , 'where id = 1 '
              , ';'
)

TT <- RunSQL(SQL)

# Jahr

TT[,J := year(Datum) ]

# Year of calendarweek

TT[, isoJ := isoyear(Datum) ]

# Factor dateutc

TT[, Jahre := factor( J, levels = unique(J), labels = unique(J) ) ]
TT[, Monate := factor( Monat, levels = 1:12, labels = Monatsnamen ) ]
TT[, KwJahre := factor( isoJ, levels = unique(isoJ), labels = unique(isoJ) ) ]
TT[, Kw := factor( isoweek(Datum), levels = 1:53, labels = paste('Kw', 1:53) ) ]


today <- Sys.Date()
heute <- format(today, "%Y%m%d")

# Avg <- TT %>% filter( Monat == 6 ) %>% group_by( Jahre ) %>% summarise( avg = mean(Temperatur) )
  
TT %>% 
  filter( J > 2021 ) %>%
  ggplot(aes( x = Monate, y = Temperatur )) + 
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
    ) -> P_Bx

ggsave(  
  file = paste( outdir, 'Temp_Boxplot_Monate.png', sep='')
  , plot = P_Bx
  , device = 'png'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 144
)


for ( CurMonth in month(today) ) {
  
  SQL = paste('select * from baseline where Stations_Id = 1 and Monat =', CurMonth, ';')
  BL = RunSQL(SQL = SQL);
  
  TT %>% filter( Monat == CurMonth ) %>% 
    ggplot(aes( x = Jahre, y = Temperatur )) + 
    geom_boxplot( aes( fill = Monate ), show.legend = FALSE ) +
    geom_hline(  aes(yintercept = BL$m[1], colour = paste('Baseline 1961-1990; ', BL$m[1],'° C', sep = '') ) ) +
    stat_summary(fun = "mean", color = "blue", geom = "point", size = 4 ) +
    stat_summary(fun = "mean", color = "blue", geom = "label_repel", aes( label = paste('ø',round(after_stat(y),2) ) ) ) +
    expand_limits( y = 0 ) +
    scale_fill_manual( values = c('cyan')  ) +
    scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
    theme_ipsum() +
    theme(  legend.position="right"
            , axis.text.x = element_text(angle = 0, vjust = 0.5, hjust=0.5)
    ) +
    labs(  title = paste( 'Temperaturen im', Monatsnamen[CurMonth], 'Rheinbach - Mittelerde' )
           , subtitle = 'Minutenwerte der dnt WeatherScreen Pro'
           , x = 'Jahr'
           , y = 'Temperatur [°C]'
           , colour = 'Monate'
           , caption = paste( "Stand:", heute )
    ) -> P4
  
  ggsave(  paste( 
    file = outdir, 'Temp_Boxplot_', CurMonth, '_', Monatsnamen[CurMonth], '.png', sep='')
    , plot = P4
    , device = 'png'
    , bg = "white"
    , width = 1920
    , height = 1080
    , units = "px"
    , dpi = 144
  )

}

TT %>% 
  filter( isoweek(Datum) < 40 & J != 2021 ) %>% 
    ggplot(aes( x = Kw, y = Temperatur )) + 
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
    ) -> P_BxW

ggsave(  file = paste( outdir, 'Temp_Boxplot_Wochen.png', sep='')
  , plot = P_BxW
  , device = 'png'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 144
)

