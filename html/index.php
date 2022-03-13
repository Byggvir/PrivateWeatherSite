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
	<meta http-equiv="refresh" content="300" />
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
    <div id="r-output1" style="width: 100%; padding: 25px;">
    <img style="width: 960px; padding: 25px;" src="png/temperature_72h.svg" alt="R Graph" />
    </div>
    <div id="r-output2" style="width: 100%; padding: 25px;">
    <img style="width: 960px; padding: 25px;" src="png/air_pressure_72h.svg" alt="R Graph" />
    </div>
    <div id="r-output3" style="width: 100%; padding: 25px;">
    <img style="width: 960px; padding: 25px;" src="png/winddir_72h.svg" alt="R Graph" />
    </div>
    <div id="r-output4" style="width: 100%; padding: 25px;">
    <img style="width: 960px; padding: 25px;" src="png/windspeed_72h.svg" alt="R Graph" />
    </div>
    <div id="r-output5" style="width: 100%; padding: 25px;">
    <img style="width: 960px; padding: 25px;" src="png/solarradiation_72h.svg" alt="R Graph" />
    </div>
    
    <script>        
        // Use an off-screen image to load the next frame.
        var img = new Image();

        // When it is loaded...
        img.addEventListener("load", function() {

            // Set the on-screen image to the same source. This should be instant because
            // it is already loaded.
            document.getElementById("r-output1").src = img.src;

            // Schedule loading the next frame.
            setTimeout(function() {
                img.src = "png/temperature_72h.svg?"+ (new Date).getTime()
            }, 1000/15); // 15 FPS (more or less)
        })

        // Start the loading process.
        img.src = "png/temperature_72h.svg?"+ (new Date).getTime();
    </script>

</body>
</html>
