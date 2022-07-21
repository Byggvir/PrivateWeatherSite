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
 
  $SQL="SELECT dateutc, Fahrenheit_Celsius(tempf) as tempc, humidity, Barom_in2hPa(baromin) as baromhPa, Barom_in2hPa(absbaromin) as absbaromhPa, mph_ms(windspeedmph) as Windgeschwindigkeit, winddir as Windrichtung FROM reports order by dateutc desc limit 12;";
  
  if ($reports = $mysqli->query($SQL)) {
    echo "<table>" ;
    echo "<tr><th>Datum-Zeit [UTC]</th><th>Temperatur [°C]</th><th>Luftfeuchte [%]</th><th>Luftdruck [hPa]</th><th>Abs. Luftdruck [hPa]</th><th>Windrichtung</th><th>Windgeschwindigkeit [m/s]</th></tr>\n" ;
    
    while ($result = $reports->fetch_assoc()) {

      echo '<tr>' . "\n";
      echo '<td>' . $result["dateutc"] . '</td>' . "\n" ;
      echo '<td class="value">' . $result["tempc"] . '</td>' . "\n" ;
      echo '<td class="value">' . $result["humidity"] . '</td>' . "\n" ;
      echo '<td class="value">' . $result["baromhPa"] . '</td>' . "\n" ;
      echo '<td class="value">' . $result["absbaromhPa"] . '</td>' . "\n" ;
      echo '<td class="value">' . $result["Windrichtung"] . '</td>' . "\n" ;
      echo '<td class="value">' . $result["Windgeschwindigkeit"] . '</td>' . "\n" ;
      echo '</tr>' . "\n";
 
        
    }/* end while */
    echo '</table>' . "\n" ;

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
