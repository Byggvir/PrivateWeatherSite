Wochentage <- c("Mo","Di","Mi","Do","Fr","Sa","So")
WochentageLang <- c("Montag","Dienstag","Mittwoch","Donnerstag","Freitag","Samstag","Sonntag")
Monatsnamen <- c('Januar', 'Februar', 'März','April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November','Dezember')

limbounds <- function (x, zeromin=TRUE) {
  
  if (zeromin == TRUE) {
    range <- c(0,max(x,na.rm = TRUE))
  } else
  { range <- c(min(x, na.rm = TRUE),max(x,na.rm = TRUE))
  }
  if (range[1] != range[2])
  {  f <- 10^(floor(log10(range[2]-range[1])))
  } else {
    f <- 1
  }
  
  return ( c(floor(range[1]/f),ceiling(range[2]/f)) * f) 
}

get_p_value <- function (modelobject) {
  if (class(modelobject) != "lm") stop("Not an object of class 'lm' ")
  f <- summary(modelobject)$fstatistic
  p <- pf(f[1],f[2],f[3],lower.tail=F)
  attributes(p) <- NULL
  return(p)
}

#
# Datum des Donnerstags in einer Kalenderwoche berechnen
#

KwToDate <- function ( Jahr , Kw ) {
  
  R <- as.Date (paste(Jahr,'-01-01',sep = ''))
  
  w <- lubridate::wday(R, week_start = 1)
  
  R[ w > 4 ] <- R[ w > 4 ] + Kw[ w > 4 ] * 7 + 4  - w[ w > 4 ]
  R[ w <= 4 ] <- R[ w <= 4 ] + ( Kw[ w <= 4 ] - 1 ) * 7 + (4 - w [ w <= 4 ]) 
  return (R)
  
}

#
# Umrechnungen
#
#

ToKelvin <- function(TemperatureC) {
  
  return (TemperatureC + 273.15)
  
}

ToCelsius <- function(TemperatureK) {
  
  return (TemperatureK - 273.15)
  
}

#
# Sättigungsdampfdruck in [Pa]
#
# Achtung: Üblich sind [hPa])
#

MagnusFormel <- function (TemperatureK, ice=FALSE) {
  
  if ( ! ice ) {
    K = c( 611.2, 17.62, 273.15, 30.03)
  }
  else {
    K = c( 611.2, 27.46, 273.15, 0.53)
  }
  return ( K[1] * exp( K[2] * ( TemperatureK - K[3] ) / ( TemperatureK - K[4]) ) )
  
}

#
# Sättigung der Luft mit Wasser in [kg/m³] 
#
# Achtung: Üblich sind [g/m³]
#

SaettigungWasser <- function(TemperatureK) {
  
  return(MagnusFormel(TemperatureK)/461.52/TemperatureK)
  
}

#
# Funktion zur Berechung des Taupunktes
#
# Achtung: 
#   Temperatur in °K
#   Luftfeuchte im Intervall [ 0, 1 ]
#

Dewpoint <- function ( TemperatureK, Humidity) {
  
  M = MagnusFormel(TemperatureK) * Humidity
  
  D = log(M/611.2)/17.6200
  
  return((D * 30.03 - 273.15)/(D - 1))

}

#
#
# Funktion zur Berechnung des Hitzeindex
#
# Achtung:
#   Temperaturen in °Celisus
#   Luftfeuchte im Intervall [ 0, 1 ]
#

HeatIndex <- function ( TemperatureK, Humidity) {
  
  #
  # Temperature in °K
  #
  # Humidity im Intervall [ 0, 1 ]
  #
  
  K = c(   -1094.1052437032
           ,     8.3353058622
           , 20726.951290027
           ,  -135.43852416
           ,    -0.012308094
           , -4818.40551395
           ,     0.2211732
           ,    26.823066
           ,    -0.03582
  )
  
  return(   K[1]
            + K[2] * TemperatureK 
            + K[3] * Humidity
            + K[4] * TemperatureK * Humidity
            + K[5] * TemperatureK ^ 2
            + K[6] * Humidity ^ 2 
            + K[7] * TemperatureK ^ 2 * Humidity
            + K[8] * TemperatureK * Humidity ^ 2 
            + K[9] * TemperatureK ^ 2 * Humidity ^ 2 
  )
  
}
