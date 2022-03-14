DROP DATABASE IF EXISTS `weatherstations`;
CREATE DATABASE IF NOT EXISTS weatherstations;

GRANT ALL ON weatherstations.* to 'weather'@'localhost' IDENTIFIED BY 'weather';

FLUSH PRIVILEGES;

USE `weatherstations`;

--
-- Table structure for table `stations`
--

DROP TABLE IF EXISTS `stations`;

CREATE TABLE `stations` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `token` char(64) DEFAULT NULL,
  `name` char(64) DEFAULT NULL,
  `softwaretype` char(64) DEFAULT NULL,
  `location_lat` double DEFAULT NULL,
  `location_long` double DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `reports`
--

DROP TABLE IF EXISTS `reports`;

CREATE TABLE `reports` (
  `id` bigint(20) NOT NULL,
  `sensor` int(11) NOT NULL,
  `dateutc` datetime NOT NULL,
  `winddir` double DEFAULT NULL,
  `windspeedmph` double DEFAULT NULL,
  `windgustmph` double DEFAULT NULL,
  `windgustdir` double DEFAULT NULL,
  `windspdmph_avg2m` double DEFAULT NULL,
  `winddir_avg2m` double DEFAULT NULL,
  `windgustmph_10m` double DEFAULT NULL,
  `windgustdir_10m` double DEFAULT NULL,
  `humidity` double DEFAULT NULL,
  `dewptf` double DEFAULT NULL,
  `tempf` double DEFAULT NULL,
  `rainin` double DEFAULT NULL,
  `dailyrainin` double DEFAULT NULL,
  `baromin` double DEFAULT NULL,
  `weather` varchar(1024) DEFAULT NULL,
  `clouds` double DEFAULT NULL,
  `soiltempf` double DEFAULT NULL,
  `soilmoisture` double DEFAULT NULL,
  `leafwetness` double DEFAULT NULL,
  `solarradiation` double DEFAULT NULL,
  `UV` double DEFAULT NULL,
  `visibility` double DEFAULT NULL,
  `indoortempf` double DEFAULT NULL,
  `indoorhumidity` double DEFAULT NULL,
  `softwaretype` varchar(64) DEFAULT NULL,
  `qNO` double DEFAULT NULL,
  `AqNO2T` double DEFAULT NULL,
  `AqNO2` double DEFAULT NULL,
  `AqNO2Y` double DEFAULT NULL,
  `AqNOX` double DEFAULT NULL,
  `AqNOY` double DEFAULT NULL,
  `AqNO3` double DEFAULT NULL,
  `AqSO4` double DEFAULT NULL,
  `AqSO2` double DEFAULT NULL,
  `AqSO2T` double DEFAULT NULL,
  `AqCO` double DEFAULT NULL,
  `AqCOT` double DEFAULT NULL,
  `AqEC` double DEFAULT NULL,
  `AqOC` double DEFAULT NULL,
  `AqBC` double DEFAULT NULL,
  `AqUVAETH` double DEFAULT NULL,
  `AqPM25` double DEFAULT NULL,
  `AqPM10` double DEFAULT NULL,
  `AqOZONE` double DEFAULT NULL,
  `absbaromin` double DEFAULT NULL,
  `weeklyrainin` double DEFAULT NULL,
  `monthlyrainin` double DEFAULT 0,
  `yearlyrainin` double DEFAULT 0,
  `windchillf` double DEFAULT NULL,
  PRIMARY KEY (`id`,`sensor`,`dateutc`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
