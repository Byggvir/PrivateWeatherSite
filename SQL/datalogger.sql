use weatherstations;

create table if not exists 
datalogger ( 
      logger int
    , id bigint(20)
    , dateutc datetime
    , Temperature double
    , Humidity double
    , primary key (logger, dateutc)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOAD DATA LOCAL 
INFILE '/tmp/EFG217104173.csv'      
INTO TABLE datalogger
FIELDS TERMINATED BY ','
IGNORE 0 ROWS;

LOAD DATA LOCAL 
INFILE '/tmp/EL2005001039.csv'      
INTO TABLE datalogger
FIELDS TERMINATED BY ','
IGNORE 0 ROWS;

LOAD DATA LOCAL 
INFILE '/tmp/EL2104003867.csv'      
INTO TABLE datalogger
FIELDS TERMINATED BY ','
IGNORE 0 ROWS;
