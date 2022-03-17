<?php
/**
 * grafics.php
 *
 * @package default
 */


/*
 * Autor: Thomas Arend
 * Stand: 15.03.2021
 *
 * Better quick and dirty than perfect but never!
 *
 * Security token to detect direct calls of included libraries. */

defined( 'ABSPATH' ) or die( 'No script kiddies please!' );

/*
 * The user weather needs insert, update and read access to the database
 */

function thermometer ($T) {
    
?>

<div class="svg">
    <svg width="30" height="280" viewBox="0 0 30 280">

<?php

    echo '<rect x="0" y="0" width="30" height="280" rx="5" ry="5" fill="gray"/>';
    echo '<rect x="5" y="'. (50 - $T) * 4 . '" width="20" height="' . 280 - (50 - $T) * 4 . '" rx="5" ry="5"/>';
    echo '<line x1="0" y1="200" x2="30" y2="200" stroke="blue" />' ;
    echo '<line x1="0" y1="120" x2="30" y2="120" stroke="red" />' ;
    
?>

    </svg>
</div> 

<?php






}
?> 
