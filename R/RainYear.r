#!/usr/bin/env Rscript
#
#
# Script:RainYear.r
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
library(dplyr)

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
source("lib/mytheme.r")
source("lib/sql.r")

today <- Sys.Date()
heute <- format(today, "%Y%m%d")

outdir <- '../png/Rain/'
dir.create( outdir , showWarnings = FALSE, recursive = FALSE, mode = "0777")

MyPos <- list( lat = 50.620941424520026, long = 6.961696767218697)

SQL <- paste( 'select date(convert_tz(dateutc,"GMT","Europe/Berlin")) as Datum, year(convert_tz(dateutc,"GMT","Europe/Berlin")) as Jahr, dayofyear(convert_tz(dateutc,"GMT","Europe/Berlin")) as Tag, inch_mm(max(dailyrainin)) as Regen from reports as R group by Datum;' )

rain <- RunSQL(SQL)
rain[, Jahre := factor(Jahr, levels = unique(Jahr), labels = unique(Jahr) ) ]
rain[, KumRegen := cumsum(Regen), by =Jahre ]

#rain %>% group_by(Jahre) %>% mutate( KumRegen = cumsum(Regen) ) -> rain

ra = lm ( data = rain, formula = KumRegen ~ Tag + 0 )
print(ra)

maxRain <- as.data.table(rain %>% group_by( Jahr ) %>% summarize(MaxJahr = max(KumRegen)))
maxRain[, Jahre := factor(Jahr, levels = unique(Jahr), labels = unique(Jahr) ) ]

rain %>% filter( Jahr > 2021 ) %>% ggplot( 
    aes( x = Tag, y = KumRegen , colour = Jahre ) 
    ) + 
  #geom_smooth( method = 'glm', formula = y ~ x + 0 , alpha = 0.5, linetype = 'dotted' ) +  
  
  geom_line( linewidth = 1, alpha = 0.8 ) + 
  geom_hline( data = maxRain %>% filter( Jahr > 2021 ) 
              , aes(yintercept = MaxJahr, colour = Jahre )  
              , linetype = 'dotted'
              ) +
  
  geom_label_repel( data = maxRain %>% filter( Jahr > 2021 ) 
              , aes( x = 0, y = MaxJahr, label = round(MaxJahr,1), colour = Jahre )
              , show.legend = FALSE
              , hjust = 1 ) +
  
  # scale_x_date() + 
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
  ) +
  labs(  title = paste( 'Niederschlag (kumuliert)' )
         , subtitle = 'Wetterstation Mittelerde, Rheinbach'
         , x = "Tag"
         , y = "kumulierter Niederschlag [mm]"
         , caption = paste( "Stand:", heute )
  ) -> P

ggsave(  
  file = paste( outdir, 'RainYear.png', sep='')
  , plot = P
  , device = 'png'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 144
)
