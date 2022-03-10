<?php
/**
 * update.php
 *
 * @package default
 */


?>
<html>
<head>
<title>WeatherStation</title>
</head>
<body>
<?php

/*

GET parameters

    NOT all fields need to be set, the _required_ elements are:
        ID
        PASSWORD
        dateutc
    IMPORTANT all fields must be url escaped
        reference http://www.w3schools.com/tags/ref_urlencode.asp
    example

  2001-01-01 10:32:35
   becomes
  2000-01-01+10%3A32%3A35

    if the weather station is not capable of producing a timestamp, our system will accept "now". Example:

dateutc=now

    list of fields:

action [action=updateraw] -- always supply this parameter to indicate you are making a weather observation upload
ID [ID as registered by wunderground.com]
PASSWORD [Station Key registered with this PWS ID, case sensitive]
dateutc - [YYYY-MM-DD HH:MM:SS (mysql format)] In Universal Coordinated Time (UTC) Not local time
winddir - [0-360 instantaneous wind direction]
windspeedmph - [mph instantaneous wind speed]
windgustmph - [mph current wind gust, using software specific time period]
windgustdir - [0-360 using software specific time period]
windspdmph_avg2m  - [mph 2 minute average wind speed mph]
winddir_avg2m - [0-360 2 minute average wind direction]
windgustmph_10m - [mph past 10 minutes wind gust mph ]
windgustdir_10m - [0-360 past 10 minutes wind gust direction]
humidity - [% outdoor humidity 0-100%]
dewptf- [F outdoor dewpoint F]
tempf - [F outdoor temperature]
* for extra outdoor sensors use temp2f, temp3f, and so on
rainin - [rain inches over the past hour)] -- the accumulated rainfall in the past 60 min
dailyrainin - [rain inches so far today in local time]
baromin - [barometric pressure inches]
weather - [text] -- metar style (+RA)
clouds - [text] -- SKC, FEW, SCT, BKN, OVC
soiltempf - [F soil temperature]
* for sensors 2,3,4 use soiltemp2f, soiltemp3f, and soiltemp4f
soilmoisture - [%]
* for sensors 2,3,4 use soilmoisture2, soilmoisture3, and soilmoisture4
leafwetness  - [%]
+ for sensor 2 use leafwetness2
solarradiation - [W/m^2]
UV - [index]
visibility - [nm visibility]
indoortempf - [F indoor temperature F]
indoorhumidity - [% indoor humidity 0-100]

    Pollution Fields:

AqNO - [ NO (nitric oxide) ppb ]
AqNO2T - (nitrogen dioxide), true measure ppb
AqNO2 - NO2 computed, NOx-NO ppb
AqNO2Y - NO2 computed, NOy-NO ppb
AqNOX - NOx (nitrogen oxides) - ppb
AqNOY - NOy (total reactive nitrogen) - ppb
AqNO3 -NO3 ion (nitrate, not adjusted for ammonium ion) UG/M3
AqSO4 -SO4 ion (sulfate, not adjusted for ammonium ion) UG/M3
AqSO2 -(sulfur dioxide), conventional ppb
AqSO2T -trace levels ppb
AqCO -CO (carbon monoxide), conventional ppm
AqCOT -CO trace levels ppb
AqEC -EC (elemental carbon) – PM2.5 UG/M3
AqOC -OC (organic carbon, not adjusted for oxygen and hydrogen) – PM2.5 UG/M3
AqBC -BC (black carbon at 880 nm) UG/M3
AqUV-AETH  -UV-AETH (second channel of Aethalometer at 370 nm) UG/M3
AqPM2.5 - PM2.5 mass - UG/M3
AqPM10 - PM10 mass - PM10 mass
AqOZONE - Ozone - ppb
softwaretype - [text] ie: WeatherLink, VWS, WeatherDisplay

*/

define('ABSPATH', 'Weather');

include_once 'weatherdb.php';

$datefields = array (

    'dateutc'
);

$floatsensormap = array (

	'winddir' => 'winddir'
	, 'windspeedmph' => 'windspeedmph'
	, 'windgustmph' => 'windgustmph'
	, 'windgustdir' => 'windgustdir'
	, 'windspdmph_avg2m' => 'windspdmph_avg2m'
	, 'winddir_avg2m' => 'winddir_avg2m'
	, 'windgustmph_10m' => 'windgustmph_10m'
	, 'windgustdir_10m' => 'windgustdir_10m'
	, 'humidity' => 'humidity'
	, 'dewptf' => 'dewptf'
	, 'tempf' => 'tempf'
	, 'rainin' => 'rainin'
	, 'dailyrainin' => 'dailyrainin'
	, 'weeklyrainin' => 'weeklyrainin'
	, 'monthlyrainin' => 'monthlyrainin'
	, 'yearlyrainin' => 'yearlyrainin'
	, 'baromin' => 'baromin'
	, 'absbaromin' => 'absbaromin'
	, 'clouds' => 'clouds'
	, 'soiltempf' => 'soiltempf'
	, 'soilmoisture' => 'soilmoisture'
	, 'leafwetness' => 'leafwetness'
	, 'solarradiation' => 'solarradiation'
	, 'UV' => 'UV'
	, 'visibility' => 'visibility'
	, 'indoortempf' => 'indoortempf'
	, 'indoorhumidity' => 'indoorhumidity'
    , 'qNO' => 'qNO'
    , 'AqNO2T' => 'AqNO2T'
    , 'AqNO2' => 'AqNO2'
    , 'AqNO2Y' => 'AqNO2Y'
    , 'AqNOX' => 'AqNOX'
    , 'AqNOY' => 'AqNOY'
    , 'AqNO3' => 'AqNO3'
    , 'AqSO4' => 'AqSO4'
    , 'AqSO2' => 'AqSO2'
    , 'AqSO2T' => 'AqSO2T'
    , 'AqCO' => 'AqCO'
    , 'AqCOT' => 'AqCOT'
    , 'AqEC' => 'AqEC'
    , 'AqOC' => 'AqOC'
    , 'AqBC' => 'AqBC'
    , 'AqUV-AETH' => 'AqUVAETH'
    , 'AqPM2.5' => 'AqPM25'
    , 'AqPM10' => 'AqPM10'
    , 'AqOZONE' => 'AqOZONE'

) ;

$strsensormap = array (
      'softwaretype' => 'softwaretype'
	, 'weather' => 'weather'
);


$strstationmap = array (
      'softwaretype' => 'softwaretype'
);

/**
 *
 * @param unknown $id
 * @param unknown $token
 * @return unknown
 */

function VerifyAccess($id, $token) {

	global $mysqli;

	$i = $mysqli->real_escape_string($id);
	$t = $mysqli->real_escape_string($token);


	$SQL = 'select name from stations where ID ='. $i . ' and token = "' . $t . '";' ;

	if ($result = $mysqli->query($SQL)
		and $result->num_rows ===1 ) {
		return TRUE;
	} else {
		echo "<p>INVALID PASSWORD/ID</p>";
		return FALSE;
	}

}


/**
 *
 * @param unknown $id
 * @param unknown $sensor
 * @param unknown $dateutc
 */

function InsertReport($id, $sensor, $dateutc ) {

	global $mysqli;

	$i = $mysqli->real_escape_string($id);
	$s = $mysqli->real_escape_string($sensor);
	$d = $mysqli->real_escape_string($dateutc);
	$SQL= 'INSERT INTO reports (ID,sensor,dateutc) values ( ' . $i  . ' , ' . $s . ' , "' . $d . '");';

	if ($mysqli->query($SQL) === TRUE) {
		echo "SUCCESS";
	} else {
		echo "Error: " . $SQL . "<br>" . $mysqli->error;
	}

}


/**
 *
 * @param unknown $id
 * @param unknown $sensor
 * @param unknown $dateutc
 * @param unknown $key
 * @param unknown $value
 */

function UpdateReportStr($id, $sensor, $dateutc, $key, $value) {

	global $mysqli;

	$i = $mysqli->real_escape_string($id);
	$s = $mysqli->real_escape_string($sensor);
	$d = $mysqli->real_escape_string($dateutc);
	$k = $mysqli->real_escape_string($key);
	$v = $mysqli->real_escape_string($value);

	$SQL = 'update reports set ' . $k . '="' . $v . '" where ID='. $i . ' and sensor = ' . $s . ' and dateutc = "' . $d . '";' ;

	if ($mysqli->query($SQL) === TRUE) {

		echo "<p>Record updated successfully: $key => $value </p>";

	} else {

		echo "<p>Error: " . $SQL . "<br>" . $mysqli->error . "</p>";

	}

}

/**
 *
 * @param unknown $id
 * @param unknown $key
 * @param unknown $value
 */

function UpdateStationStr($id, $key, $value) {

	global $mysqli;

	$i = $mysqli->real_escape_string($id);
	$k = $mysqli->real_escape_string($key);
	$v = $mysqli->real_escape_string($value);

	$SQL = 'update stations set ' . $k . '="' . $v . '" where ID='. $i . ';' ;

	if ($mysqli->query($SQL) === TRUE) {

		echo "<p>Station updated successfully: $key => $value </p>";

	} else {

		echo "<p>Error: " . $SQL . "<br>" . $mysqli->error . "</p>";

	}

}

/**
 *
 * @param unknown $id
 * @param unknown $sensor
 * @param unknown $dateutc
 * @param unknown $key
 * @param unknown $value
 */

function UpdateReportFloat($id, $sensor, $dateutc, $key, $value) {

	global $mysqli;

	$i = $mysqli->real_escape_string($id);
	$s = $mysqli->real_escape_string($sensor);
	$d = $mysqli->real_escape_string($dateutc);
	$k = $mysqli->real_escape_string($key);
	$v = $mysqli->real_escape_string($value);

	$SQL = 'update reports set ' . $k . '=' . $v . ' where ID='. $i . ' and sensor = ' . $s . ' and dateutc = "' . $d . '";' ;

	if ($mysqli->query($SQL) === TRUE) {

		echo "<p>Record updated successfully: $key => $value </p>";

	} else {

		echo "<p>Error: " . $SQL . "<br>" . $mysqli->error . "</p>";

	}

}

if (array_key_exists('action', $_GET)) {

	$ACTION = $_GET['action'];  }

else {

	$ACTION = "NO";

}

if (array_key_exists('ID', $_GET)) {

	$ID = $_GET['ID'];  }

else {

	$ID = "1";

}

if (array_key_exists('PASSWORD', $_GET)) {

	$TOKEN = $_GET['PASSWORD'];  }

else {

	$TOKEN = "";

}

if (array_key_exists('dateutc', $_GET)) {

	$DATEUTC = $_GET['dateutc'];  }

else {

	$unixTime = time();
	$timeZone = new \DateTimeZone('UTC');
	$time = new \DateTime();
	$time->setTimestamp($unixTime)->setTimezone($timeZone);

	$formattedTime = $time->format('Y-m-d H:i:s');
	$DATEUTC = $formattedTime;

}

if ( VerifyAccess($ID, $TOKEN) ) {

	InsertReport($ID, 1, $DATEUTC);

	foreach ( $floatsensormap as $key => $value ) {

		if (isset ($_GET[$key])) {

			UpdateReportFloat( $ID, 1, $DATEUTC , $value, $_GET[$key] );

		}

	}	

	foreach ( $strsensormap as $value ) {

		if (isset ($_GET[$value])) {

			UpdateReportStr( $ID, 1, $DATEUTC , $value, $_GET[$value] );

		}

	}

	foreach ( $strstationmap as $value ) {

		if (isset ($_GET[$value])) {

			UpdateStationStr( $ID, $value, $_GET[$value] );

		}

	}

}

$mysqli->close();

?>
</body>
</html>
