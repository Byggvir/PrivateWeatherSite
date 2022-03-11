<?php
/**
 * index.php
 *
 * @package default
 */

define('ABSPATH', 'Weather');

include_once 'weatherdb.php';
include_once 'weathersqllib.php';
include_once 'weatherlib.php';

$datefields = array (

    'dateutc'
);

$floatsensormap = array (

  'absbaromin'
, 'baromin'
, 'dailyrainin'
, 'dateutc'
, 'dewptf'
, 'humidity'
, 'indoorhumidity'
, 'indoortempf'
, 'monthlyrainin'
, 'rainin'
, 'solarradiation'
, 'tempf'
, 'weeklyrainin'
, 'windchillf'
, 'winddir'
, 'windgustmph'
, 'windspeedmph'
, 'yearlyrainin'
, 'UV'
) ;

$strsensormap = array (
      'softwaretype' => 'softwaretype'
	, 'weather' => 'weather'
);


$strstationmap = array (
      'softwaretype' => 'softwaretype'
);

?>
<html>
<head>

	<meta charset="UTF-8" />
	<meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta http-equiv="expires" content="0" /> 
	<meta http-equiv="refresh" content="60" />
	<meta http-equiv="cache-control" content="no-cache" />
	<meta http-equiv="pragma" content="no-cache" />
	<link rel="stylesheet" type="text/css" href="css/style.css" />
	
    <title>Weather-Station</title>

</head>

<body>

    <h1>Wetterstation</h1>

<?php

    WeatherReport();

    $mysqli->close();

    // Execute the R script within PHP code
    // Generates output as test.png image.
    // Moved to cron job
    // exec("R/Weather72h.r");
    
    
?>
    <div id="r-output" style="width: 100%; padding: 25px;">
    <img style="width: 960px; padding: 25px;" src="png/temperature_72h.svg" alt="R Graph" />
    </div>
    <div id="r-output" style="width: 100%; padding: 25px;">
    <img style="width: 960px; padding: 25px;" src="png/air_pressure_72h.svg" alt="R Graph" />
    </div>
    <div id="r-output" style="width: 100%; padding: 25px;">
    <img style="width: 960px; padding: 25px;" src="png/winddir_72h.svg" alt="R Graph" />
    </div>
    <div id="r-output" style="width: 100%; padding: 25px;">
    <img style="width: 960px; padding: 25px;" src="png/windspeed_72h.svg" alt="R Graph" />
    </div>
    <div id="r-output" style="width: 100%; padding: 25px;">
    <img style="width: 960px; padding: 25px;" src="png/solarradiation_72h.svg" alt="R Graph" />
    </div>

</body>
</html>
