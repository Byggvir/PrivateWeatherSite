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

outdir <- '../png/Temperatur/'
dir.create( outdir , showWarnings = FALSE, recursive = TRUE, mode = "0777" )

Stations = RunSQL( SQL = ' select distinct Stations_Id from baseline6190;')

options( OutDec = '.')

# for ( S in Stations[, Stations_Id] ) {
# # for ( S in c(2667, 2968) ) {
#     
#   SQL <- paste(   'select Stations_Id, D.Datum, D.TMK as TT, W.AvgT as TT_Rhb from dwd.daily as D'
#                 , 'join AvgTemp as W on D.Datum = W.Datum where Stations_Id = ', S, ' and D.TMK > -999 and W.Datum > "2021-03-11" ;'
#                 )
#   daten <- RunSQL(SQL)
#   
#   if (nrow(daten) > 1000 ) {
#     
#     ra = lm ( data = daten , formula = TT_Rhb ~ TT )
#     ci = confint(ra)
#     r_2 = summary(ra)$r.squared
# 
#     if ( r_2 > 0.95) {
# 
#       cat ( S , '\n')
#       print(ra$coefficients)
#       print(ci)
#       cat ( '\n\n')
#       
#       # daten %>% ggplot() +
#       #   geom_point( aes( x = TT_Rhb, y = TT, colour = S ) ) +
#       # 
#       #   scale_x_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
#       #   scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
#       # 
#       #   theme_ipsum() +
#       #   theme(  legend.position="right"
#       #           , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
#       #           , strip.text.x = element_text (
#       #               color = "black"
#       #             , face = "bold.italic"
#       #           ) ) +
#       #   labs(  title = paste( S, ' vs Rheinbach' )
#       #          , subtitle = paste( min(daten$Datum), 'bis', max(daten$Datum))
#       #          , x = "Temperatur Rheinbach [°C]"
#       #          , y = "Temperatur [° C]"
#       #          , colour = 'Legende'
#       #          , caption = paste( "Stand:", heute )
#       #   ) -> P
#       # 
#       # ggsave(  file = paste0( outdir, 'Scatter_',S,'_Rhb.png', sep='')
#       #   , plot = P
#       #   , device = 'png'
#       #   , bg = "white"
#       #   , width = 1920
#       #   , height = 1080
#       #   , units = "px"
#       #   , dpi = 144
#       # )
#       
#       SQL = paste( 'insert into RA_RHB values ( ', S,
#                    ','
#                     , gsub(",",".", ra$coefficients[1] )
#                     , ','
#                     , gsub(",",".", ra$coefficients[2] )
#                     , ','
#                     , gsub(",",".", ci[1,1] )
#                     , ','
#                     , gsub(",",".", ci[2,1] )
#                      , ','
#                      , gsub(",",".", ci[1,2] )
#                      , ','
#                      , gsub(",",".", ci[2,2] )
#                      , ','
#                      , gsub(",",".", r_2 )
#                      , ','
#                      , gsub(",",".", nrow(daten) )
#                    , ');'
#                     )
#       ExecSQL(SQL)
#     
#     }
#   }
# 
# }

SQL ='select A.Stations_Id, A.Monat, A.avgTMK * B.slope + B.intercept as TT from baseline6190 as A join RA_RHB as B on A.Stations_Id = B.Stations_Id;'
BL = RunSQL( SQL = SQL )
BL[, Monate := factor(Monat, levels= 0:12, labels = c('Jahr', Monatsnamen) ) ]
      BL %>% ggplot() +
        geom_density( aes( x = TT ) ) +

        scale_x_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
        scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
        facet_wrap(vars(Monate), scales = 'free_x' ) +
        theme_ipsum() +
        theme(  legend.position="right"
                , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
                , strip.text.x = element_text (
                    color = "black"
                  , face = "bold.italic"
                ) ) +
        labs(  title = paste( 'Dichte Basistemperatur Rheinbach 1961-1990' )
               , subtitle = ''
               , x = "Temperatur Rheinbach [°C]"
               , y = "Dichte"
               , colour = 'Legende'
               , caption = paste( "Stand:", heute )
        ) -> P

      ggsave(  file = paste0( outdir, 'Density_BL_Rhb.png', sep='')
        , plot = P
        , device = 'png'
        , bg = "white"
        , width = 1920
        , height = 1080
        , units = "px"
        , dpi = 144
      )

