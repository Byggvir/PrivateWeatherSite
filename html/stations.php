<?php
/**
 * stations.php
 *
 * @package default
 */

define('ABSPATH', 'Weather');

include_once 'weatherdb.php';
include_once 'weathersqllib.php';
include_once 'weatherlib.php';

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

    <h1>Liste der Wetterstationen</h1>

<?php

    StationList();

    $mysqli->close();

?>

</body>
</html>
