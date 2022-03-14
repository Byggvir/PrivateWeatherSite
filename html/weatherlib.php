<?php
/**
 * weatherlib.php
 *
 * @package default
 */


defined('ABSPATH') or die('No script kiddies please!');


/**
 *
 * @param float   $Fahrenheit
 * @return unknown
 */
function FahrenheitToCelsius(float $Fahrenheit ) : float {
	return ($Fahrenheit - 32) * 5/9 ;
}


/**
 *
 * @param float   $Celsius
 * @return unknown
 */
function CelsiusToFahrenheit( float $Celsius) : float {
	return $Celsius * 9 / 5 + 32;
}

function WeatherReport () {
   
  global $mysqli;
 
  $SQL="SELECT dateutc, Fahrenheit_Celsius(tempf) as tempc, Barom_in2hPa(baromin) as baromhPa, Barom_in2hPa(absbaromin) as absbaromhPa FROM reports order by dateutc desc limit 10;";
  
  if ($reports = $mysqli->query($SQL)) {
    echo "<table>" ;
    echo "<tr><th>Zeit</th><th>Temperatur [°C]</th><th>Luftdruck [hPa]</th><th>Abs. Luftdruck [hPa]</th></tr>\n" ;
    
    while ($result = $reports->fetch_assoc()) {

      echo "<tr>\n";
      echo "<td>" . $result["dateutc"] . "</td>\n" ;
      echo "<td>" . $result["tempc"] . "</td>\n" ;
      echo "<td>" . $result["baromhPa"] . "</td>\n" ;
      echo "<td>" . $result["absbaromhPa"] . "</td>\n" ;
      echo "</tr>\n";
 
        
    }/* end while */
    echo "</table>\n" ;

    $reports->close();
    
  } /* end if */

} /* End of WeaterReport */

function StationList () {
   
  global $mysqli;
 
  $SQL="SELECT * FROM stations;";
  
  if ($reports = $mysqli->query($SQL)) {
    echo "<table>" ;
    echo "<tr><th>Id</th><th>Name</th><th>Software</th><th>Latitude</th><th>Longitude</th></tr>\n" ;
    
    while ($result = $reports->fetch_assoc()) {

      echo "<tr>\n";
      echo "<td>" . $result["id"] . "</td>\n" ;
      echo "<td>" . $result["name"] . "</td>\n" ;
      echo "<td>" . $result["softwaretype"] . "</td>\n" ;
      echo "<td>" . $result["location_lat"] . "</td>\n" ;
      echo "<td>" . $result["location_long"] . "</td>\n" ;
      echo "</tr>\n";
 
        
    }/* end while */
    echo "</table>\n" ;

    $reports->close();
    
  } /* end if */

} /* End of StationList */



?>
