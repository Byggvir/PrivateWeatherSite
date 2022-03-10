<?php

defined('ABSPATH') or die('No script kiddies please!');

include_once 'weatherdb.php';


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

function GetReport($id, $sensor, $dateutc ) {

	global $mysqli;

	$i = $mysqli->real_escape_string($id);
	$s = $mysqli->real_escape_string($sensor);
	$d = $mysqli->real_escape_string($dateutc);
	$SQL= 'SELECT * FROM reports WHERE ID="' . $i  . '" AND sensor="' . $s . '" ;';

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
 */

function InsertReport($id, $sensor, $dateutc ) {

	global $mysqli;

	$i = $mysqli->real_escape_string($id);
	$s = $mysqli->real_escape_string($sensor);
	$d = $mysqli->real_escape_string($dateutc);
	$SQL= 'INSERT INTO reports (ID,sensor,dateutc) values ( ' . $i  . ' , ' . $s . ' , "' . $d . '");';
    $result = $mysqli->query($SQL);
    if ( $result = $mysqli->query($SQL)) {
        return $esult ;
	} else {
		return "Error: " . $SQL . "<br>" . $mysqli->error;
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

?>
