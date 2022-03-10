<?php
/**
 * weatherdb.php
 *
 * @package default
 */


/*
 * Autor: Thomas Arend
 * Stand: 10.03.2021
 *
 * Better quick and dirty than perfect but never!
 *
 * Security token to detect direct calls of included libraries. */

defined( 'ABSPATH' ) or die( 'No script kiddies please!' );

/*
 * The user weather needs insert, update and read access to the database
 */

$dbhost = "localhost";          /* Change here when you don't use a locol server */
$dbname = "weatherstations";    /* Change database name here; Maybe your provider assigns a dbname */
$dbuser = "weather";            /* Change user here */
$dbpass = "weather";            /* Change password !!! */

$mysqli = new mysqli($dbhost, $dbuser, $dbpass, $dbname) or die();

?>
