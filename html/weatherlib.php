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

  $sensor = 1;

  $SQL="SELECT dateutc, format(Fahrenheit_Celsius(tempf),1) as tempc, humidity, format(Barom_in2hPa(baromin),1) as baromhPa, format(Barom_in2hPa(absbaromin),1) as absbaromhPa, round(mph_ms(windspeedmph),1) as Windgeschwindigkeit, winddir as Windrichtung , format(inch_mm(dailyrainin),1) as NiederschlagTag FROM reports where sensor = " . $sensor . " order by dateutc desc limit 60;";
  
  if ($reports = $mysqli->query($SQL)) {
    echo "<table>" ;
    echo "<tr><th>Datum-Zeit [UTC]</th><th>Temperature<br />[°C]</th><th>Humindity<br />[%]</th><th>Air pressure<br />rel. / abs. [hPa]</th><th>Wind<br />[° , m/s]</th><th>Rain<br /> [mm/day]</th></tr>\n" ;
    
    while ($result = $reports->fetch_assoc()) {

      echo '<tr>' . "\n";
      echo '<td>' . $result["dateutc"] . '</td>' . "\n" ;
      echo '<td class="value">' . $result["tempc"] . '</td>' . "\n" ;
      echo '<td class="value">' . $result["humidity"] . '</td>' . "\n" ;
      echo '<td class="value">' . $result["baromhPa"] . ' / ' . $result["absbaromhPa"] . '</td>' . "\n" ;
      echo '<td class="value">' . $result["Windrichtung"] . ' - ' . $result["Windgeschwindigkeit"] . '</td>' . "\n" ;
      echo '<td class="value">' . $result["NiederschlagTag"] . '</td>' . "\n" ;
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
