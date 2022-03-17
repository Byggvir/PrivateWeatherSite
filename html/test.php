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
include_once 'graphics.php';

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
	
    <title>Weather-Station List</title>

</head>

<body>

    <h1>PHP-Test</h1>

<?php

  thermometer(0);    
  thermometer(20);    
  thermometer(30);    
?>

</body>
</html>
