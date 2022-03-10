library(bit64)
library(RMariaDB)
library(data.table)

RunSQL <- function (
  SQL = 'select * from Faelle;'
  , prepare= c("set @i := 1;")) {
  
  rmariadb.settingsfile <- "/etc/R/sql.conf.d/weatherstations.cnf"
  
  rmariadb.db <- "weatherstations"
  
  DB <- dbConnect(
    RMariaDB::MariaDB()
    , default.file=rmariadb.settingsfile
    , group=rmariadb.db
    , bigint="numeric"
  )
  for ( P in prepare ){
    dbExecute(DB, P)
  }
  rsQuery <- dbSendQuery(DB, SQL)
  dbRows<-dbFetch(rsQuery)

  # Clear the result.
  
  dbClearResult(rsQuery)
  
  dbDisconnect(DB)
  
  return(dbRows)
}

ExecSQL <- function (
  SQL 
) {
  
  rmariadb.settingsfile <- "/etc/R/sql.conf.d/weatherstations.cnf"
  
  rmariadb.db <- "weatherstations"
  
  DB <- dbConnect(
    RMariaDB::MariaDB()
    , default.file=rmariadb.settingsfile
    , group=rmariadb.db
    , bigint="numeric"
  )
  
  count <- dbExecute(DB, SQL)

  dbDisconnect(DB)
  
  return (count)
  
}
