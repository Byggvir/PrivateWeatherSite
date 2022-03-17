# PrivateWeatherSite
Collect data from weatherstations (in the local net) on a Raspberry Pi

**Achtung:** Dies ist keine ausgereifte Anwendung, sondern ein *quick and dirty* Beispiel, wie ein eigenes Wetterprotal funktionieren kann.

## Einleitung

Private Wetterstationen können Daten an Wetterportale im Internet übertragen: Neben den Protalen

  * [Ecowitt weather](https://www.ecowitt.net)
  * [Weather Underground](https://WeatherUnderground.com)
  * [WeatherCloud](https://weathercloud.net/)
  * [WOW - Weather Observation Website](www.WeatherObservationWebsite.com)

können die Daten an ein eingenes Portal gesendet werden.

Dieses Git stellt eine Website (nicht nur für das heimische Netz) bereit, das die Daten über http entgegennimmt, in eine MariaDB / MySQL Datenbank speichert und anzeigt.

Meine *dnt WeatherScreen Pro* unterstütz dazu zwei Protokolle:

  * Ecowitt
  * Wunderground

Mein privates Wetterprotal im Heimnatz ist über DynDNS unter [weather.dyn.byggvir.de](https://weather.dyn.byggvir.de) erreichbar.

In diesem Git wird das Protokoll von Wunderground verwendet.

Die Meldungen der Wetterstation nimmt die Website über das Script update.php entgegen. Meine dnt Weatherstation Pro berichtet nicht alle im Protokoll möglichen Parameter. Ich habe dennoch alle Parameter in der  Tabelle *reports* definiert, so dass eine anderer Wetterstation, die mehr Daten berichtet, bebenso genutzt werden kann.

## Requirements

  * Apache2 als Web-Server
  * MySQL / MariaDB zum Speichern der Reports
  * PHP für die Seiten
  * R zum Generieren der Karten

## Test

Entwickelt und getestet wurden die Scripte unter Debian 11 Bullseye und Raspbian OS Bullseye.

## Installation Website

Es reicht das Verzeichnis *html* in das Root Verzeichnis eines virtuellen Host zu kopieren.

Die Zugriffsdaten auf die MySQL-Datenbank müssen für R unter */etc/R/sql.conf.de/weatherstations.cnf* abgelegt werden.

## Installation Datenbank *weatherstations*

Auf dem Host muss unter MariaDB eine Datenbank *weatherstations* mit zwei Tabellen *stations* und *reports* angelegt werden. Dies geschieht mit dem Script *init-db* im Ordner *SQL*.

Die Tabelle *stations* hat fünf Spalten:

```
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
```

Die Tabelle *reports* hat sehr viele Felder, die hier nicht erläutert werden.

***id*** ist eine eindeutige Nummer der Station.

Mit dem geheimen ***token*** (Variable PASSWORD im Report) authentifiziert sich die Wetterstation. So richtig geheim ist dieses Token nicht, da die Reports unverschlüsselt über ***http*** übertragen werden.

***name*** ist ein beliebiger Name der Staion, der nicht eindeutig sein muss.

***softwaretype*** gibt an, welche Software die Wetterstation verwendet. Das Feld wird anhand des letzten Reports überschrieben. Das Feld wird ebenfalls in den einzelen Reports gespeichert.

***location_lat*** und ***location_log*** geben die Position der Wetterstation an.

Die Stationen müssen manuell in die Tabelle *stations* eingetragen werden. Z.B mit dem SQL Statement:

    insert into stations
    values (1,"<geheimer token>","<Name der Station>","Software",50.62094487,6.9616949);

**Anmerkung:** Im Moment erscheint auf der Startseite nur die Station 1.

## Installation R

Die Installation von R ist etwas umfangreicher es werden zahlreiche Packages benötig. Wenn es kein ***nackter*** Host kann es eine Weile dauern, bis alle Vorausetzungen für die Installation der R-Packete gegeben sind.

Die Liste der Debian-Packete, die ich im Laufe der Zeit auf einem Raspberry Pi mit Desktop installieren musste, findet sich in [Debian-Packages](Debian-Packages.md).

Die erforderlichen R-Packete sind in [R-Packages](R-Packages.md) aufgelistet.

TBC
