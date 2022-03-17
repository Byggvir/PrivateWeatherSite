#!/usr/bin/env Rscript
#
#
# Script: Weather.r
#
# Stand: 2022-01-21
# (c) 2021 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

MyScriptName <- "Weather"

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
  SD = (function() return( if(length(sys.parents())==1) getwd() else dirname(sys.frame(1)$ofile) ))()
  SD <- unlist(str_split(SD,'/'))
  
}

WD <- paste(SD[1:(length(SD))],collapse='/')
setwd(WD)

source("lib/myfunctions.r")
source("lib/mytheme.r")
source("lib/sql.r")

T_Date <- function( Datum , intercept, slope) {
  
  return (intercept + slope * cospi( as.numeric(Datum - as.Date("2021-07-20"))/182.5))
  
}

today <- Sys.Date()
heute <- format(today, "%Y%m%d")

SQL <- 'select date(dateutc) as Datum, Fahrenheit_Celsius(max(tempf)) as maxT, Fahrenheit_Celsius(min(tempf)) as minT from reports group by Datum;'
daten <- RunSQL(SQL)

ra1 <- lm( maxT ~ cospi( as.numeric(Datum - as.Date("2021-07-20"))/182.5), data = daten)

ci1 <- confint(ra1, CI=0.95)

ra2 <- lm( minT ~ cospi( as.numeric(Datum - as.Date("2021-07-20"))/182.5), data = daten)

ci2 <- confint(ra2, CI=0.95)


daten %>% ggplot() + 

  geom_smooth( aes( x = Datum, y = maxT, colour = 'Max' ) ) +
  geom_smooth( aes( x = Datum, y = minT, colour = 'Min' ) ) +
  
  geom_point( aes( x = Datum, y = maxT, colour = 'Max' ) ) +
  geom_point( aes( x = Datum, y = minT, colour = 'Min' ) ) +
  
  geom_function( fun = T_Date, args = list (intercept = ra1$coefficients[1], slope = ra1$coefficients[2])) +
  geom_function( fun = T_Date, args = list (intercept = ra2$coefficients[1], slope = ra2$coefficients[2])) +
  scale_x_date( breaks = '1 month' ) + 
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_fill_viridis(discrete = TRUE) +
  theme_ta() +
  theme(  plot.title = element_text( size = 24 )
          , legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
          , strip.text.x = element_text (
            size = 12
            , color = "black"
            , face = "bold.italic"
          ) ) +
  labs(  title = paste( 'Temperaturen Rheinbach' )
         , subtitle = 'Minimale / Maximale Temperatur des Tages'
         , x = "Datum"
         , y = "Temperatur [°C]"
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
  geom_point( aes( x = minT, y = maxT ) ) +
  geom_smooth( aes( x = minT, y = maxT ), method = 'lm') +
  scale_x_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_fill_viridis(discrete = TRUE) +
  theme_ta() +
  theme(  plot.title = element_text( size = 24 )
          , legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
          , strip.text.x = element_text (
            size = 12
            , color = "black"
            , face = "bold.italic"
          ) ) +
  labs(  title = paste( 'Temperaturen Rheinbach' )
         , subtitle = 'Maximale ~ Minimale Temperatur des Tages'
         , x = "minimale Temperatur [°C]"
         , y = "maximale Temperatur [°C]"
  ) -> P2

ggsave(  paste( 
  file = '../png/', MyScriptName, '_S.svg', sep='')
  , plot = P2
  , device = 'svg'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 72
)

ra <- lm( maxT ~ minT, data = daten)
ci <- confint(ra, CI=0.95)

print(ra)
print(ci)

daten %>% ggplot() + 
  geom_point( aes( x = cospi( as.numeric(Datum - as.Date("2021-07-15"))/182.5), y = maxT ) ) +
  geom_smooth( aes( x = cospi( as.numeric(Datum - as.Date("2021-07-15"))/182.5), y = maxT ), method = 'lm') +
  scale_x_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_fill_viridis(discrete = TRUE) +
  theme_ta() +
  theme(  plot.title = element_text( size = 24 )
          , legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
          , strip.text.x = element_text (
            size = 12
            , color = "black"
            , face = "bold.italic"
          ) ) +
  labs(  title = paste( 'Temperaturen Rheinbach' )
         , subtitle = 'Maximale Temperatur des Tages nach Jahreszeit'
         , x = "cos(t)"
         , y = "maximale Temperatur [°C]"
  ) -> P3

ggsave(  paste( 
  file = '../png/', MyScriptName, '_Sin.svg', sep='')
  , plot = P3
  , device = 'svg'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 72
)
