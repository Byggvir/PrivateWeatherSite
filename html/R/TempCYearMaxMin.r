#!/usr/bin/env Rscript
#
#
# Script: Weather.r
#
# Stand: 2022-01-21
# (c) 2021 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

MyScriptName <- "TempCYearMaxMin"

options(OutDec=',')

require(data.table)
library(tidyverse)
library(REST)
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

MyPos <- list( lat = 50.620941424520026, long = 6.961696767218697)

T_Date <- function( Datum , intercept, slope) {
  
  return (intercept + slope * cospi( as.numeric(Datum - as.Date("2021-07-20"))/182.5))
  
}

SQL <- paste( 'select'
              , 'date(dateutc) as Datum '
              , ', Fahrenheit_Celsius(max(tempf)) as maxT'
              , ', Fahrenheit_Celsius(min(tempf)) as minT'
              , 'from reports'
              , 'where id = 1 '
              , 'and dateutc > date(SUBDATE(now(), INTERVAL 1 YEAR))'
              , 'group by Datum ;'
)
daten <- RunSQL(SQL)

today <- Sys.Date()
heute <- format(today, "%Y%m%d")

ra1 <- lm( maxT ~ cospi( as.numeric(Datum - as.Date("2021-07-20"))/182.5), data = daten)
ci1 <- confint(ra1, CI=0.95)

ra2 <- lm( minT ~ cospi( as.numeric(Datum - as.Date("2021-07-20"))/182.5), data = daten)
ci2 <- confint(ra2, CI=0.95)

daten %>% ggplot() + 
  geom_smooth( aes( x = Datum, y = maxT, colour = 'Max' ), size = 1 ) +
  geom_smooth( aes( x = Datum, y = minT, colour = 'Min' ), size = 1 ) +
  
  geom_point( aes( x = Datum, y = maxT, colour = 'Max' ), size = 5 ) +
  geom_point( aes( x = Datum, y = minT, colour = 'Min' ), size = 5 ) +
  
  geom_function( fun = T_Date, args = list (intercept = ra1$coefficients[1], slope = ra1$coefficients[2]), size = 2) +
  geom_function( fun = T_Date, args = list (intercept = ra2$coefficients[1], slope = ra2$coefficients[2]), size = 2) +

  scale_x_date( breaks = '1 month', date_labels = "%b %Y" ) + 
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_fill_viridis(discrete = TRUE) +
  theme_ta() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
  ) +
  labs(  title = paste( 'Temperaturen Rheinbach' )
         , subtitle = 'Minimale / Maximale Temperatur des Tages'
         , x = "Datum"
         , y = "Temperatur [°C]"
         , colour = 'Tagestemperatur'
         , caption = paste( "Stand:", heute )
  ) -> P

ggsave(  paste( 
  file = '../png/', MyScriptName, '_T.svg', sep='')
  , plot = P
  , device = 'svg'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 72
)

daten %>% ggplot() + 
  geom_point( aes( x = cospi( as.numeric(Datum - as.Date("2021-07-20"))/182.5), y = maxT, colour = 'Max' ), size = 5 ) +
  geom_abline(intercept = ci1[1,1], slope = ci1[2,1]) +
  geom_abline(intercept = ci1[1,2], slope = ci1[2,2]) +
  scale_x_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_fill_viridis(discrete = TRUE) +
  theme_ta() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
  ) +
  labs(  title = paste( 'Temperaturen Rheinbach' )
         , subtitle = 'Minimale / Maximale Temperatur des Tages'
         , x = "Datum"
         , y = "Temperatur [°C]"
         , colour = 'Tagestemperatur'
         , caption = paste( "Stand:", heute )
  ) -> P

ggsave(  paste( 
  file = '../png/', MyScriptName, '_S.svg', sep='')
  , plot = P
  , device = 'svg'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 72
)
