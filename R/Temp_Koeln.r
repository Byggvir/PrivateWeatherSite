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

SQL <- paste(   'select Stations_Id, D.Datum, D.TMK as TT_Koe, W.AvgT as TT_Rhb from dwd.daily as D'
              , 'join AvgTemp as W on D.Datum = W.Datum where (Stations_Id = 2667 or Stations_Id = 2968) and D.TMK > -999 and W.Datum > "2024-03-11" ;'
              )
daten <- RunSQL(SQL)
daten[, S := factor(Stations_Id)]


daten %>% ggplot() +
  geom_point( aes( x = TT_Rhb, y = TT_Koe, colour = S ) ) +

  scale_x_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +

  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
          , strip.text.x = element_text (
              color = "black"
            , face = "bold.italic"
          ) ) +
  labs(  title = paste( 'Köln-Stammheim vs Rheinbach' )
         , subtitle = paste( min(daten$Datum), 'bis', max(daten$Datum))
         , x = "Temperatur Rheinbach [°C]"
         , y = "Temperatur Köln-Stammheim [° C]"
         , colour = 'Legende'
         , caption = paste( "Stand:", heute )
  ) -> P

ggsave(  file = paste0( outdir, 'ScatterKoeRhb.png', sep='')
  , plot = P
  , device = 'png'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 144
)

ra = lm ( data = daten , formula = TT_Rhb ~ TT_Koe)
ci = confint(ra)

SQL <- paste( 'select D.Datum, avg(D.TMK) as m, stddev(D.TMK) as s from dwd.daily as D where D.Mess_Datum > 19610000 and D.Mess_Datum < 19910000 and D.Stations_Id = 2968 and D.TMK > -999;' )
Baseline = RunSQL (SQL = SQL)

print(ra$coefficients)
print(ci)


# SQL = 'delete from baseline where Stations_Id <= 4;'
# ExecSQL(SQL)

options( OutDec = '.')

#for (m in 1:12) {
S=4
SQL = paste( 'insert into baseline select ', 4, ', Monat, m *'
              , gsub(",",".", ra$coefficients[2] )
              , '+'
              , gsub(",",".", ra$coefficients[1] )
              , ', s * '
              , gsub(",",".", ra$coefficients[2] )
              , ' from baseline where Stations_Id = 2968;' 
              )
ExecSQL(SQL)

SQL = paste( 'insert into baseline select 5, Monat, m *'
             , gsub(",",".", ci[2,1] )
             , '+'
             , gsub(",",".", ci[1,1] )
             , ', s * '
             , gsub(",",".", ci[2,1] )
             , ' from baseline where Stations_Id = 2968;' 
)
ExecSQL(SQL)

SQL = paste( 'insert into baseline select 6, Monat, m *'
             , gsub(",",".", ci[2,2] )
             , '+'
             , gsub(",",".", ci[1,2] )
             , ', s * '
             , gsub(",",".", ci[2,2] )
             , ' from baseline where Stations_Id = 2968;' 
)
ExecSQL(SQL)
