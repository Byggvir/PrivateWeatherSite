#!/usr/bin/env Rscript
#
#
# Script: Weather.r
#
# Stand: 2024-09-09
# (c) 2024 by Thomas Arend, Rheinbach
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
library(xml2)
library(jsonlite)
# 
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
# print(WD)

source("lib/myfunctions.r")
source("lib/sql.r")


outdir <- '../png/Wetter/'

dir.create( outdir , showWarnings = FALSE, recursive = FALSE, mode = "0777")
T_Date <- function( Datum , intercept, slope) {
  
  return (intercept + slope * cospi( as.numeric(Datum - as.Date("2021-07-20"))/182.5))
  
}

today <- Sys.Date()
heute <- format(today, "%Y%m%d")

cityId = 56
WMO <- jsonlite::read_json( paste0( 'http://worldweather.wmo.int/de/json/', cityId, '_de.xml' ) )

issueDate = WMO$city$forecast$issueDate

n = length(WMO$city$forecast$forecastDay)

for ( i in 1:n) {
  
  wf = unlist( WMO$city$forecast$forecastDay[[i]])

  SQL <- paste ('insert into wmoforecast values('
                , cityId, ','
                , paste0( '"', issueDate, '"' ), ',' 
                , paste0( '"', wf[1], '"' ), ','
                , as.numeric( wf[4]), ','
                , as.numeric( wf[5]), ','
                , paste0('"', wf[3] , '"')
                , ');' )   
 ExecSQL( SQL  = SQL )
}
