#!/usr/bin/env Rscript

options(OutDec=',')

MyScriptName <- "GetWU"

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
library(XML)
library(RCurl)
library(rlist)
library(stringr)
library(argparser)
library(jsonlite)

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

source("R/lib/sql.r")

CSVOUT1 <- '/tmp/wunderground.csv'

if (file.exists(CSVOUT1)) {

  unlink(CSVOUT1)

}

headURL = 'https://api.weather.com/v2/pws/dailysummary/7day?format=json&numericPrecision=decimal&units=m'

apiKey = '&apiKey=e93074e6ed4147b9b074e6ed4117b9f3'
StationID = '&stationId=IRHEIN137' 

  HTML <- getURL( paste0( headURL, apiKey , StationID )
                  , .opts = list( ssl.verifypeer = FALSE )
                  , .encoding = 'UTF-8' )

  dt <- fromJSON(HTML)
  print(dt$summaries$metric)

#  dt <- tables[[1]]
