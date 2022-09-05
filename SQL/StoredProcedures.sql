use weatherstations;

delimiter //

-- Berechnen des Kalenderjahres zur Kalenderwoche 
--
create or replace 
function weekyear ( Datum DATE ) returns INT
begin
      return year(adddate(Datum, 3-weekday(Datum)));
end

//

-- Berechnen des Datum des Donnerstages einer Kalenderwoche 
--
create or replace

function KwToDate ( Jahr INT, Kw INT ) returns DATE
begin
    
    set @JBegin = date(concat(Jahr,'-01-01'));
    set @WD = weekday(@JBegin);
    
    if ( @WD > 3 ) 
    then
        set @c = 3 - @WD;
    else
        set @c = - 4 - @WD ;
    end if; 
    return (adddate(@JBegin, @c + 7 * Kw));
    
end

//

create or replace

procedure KeyedTable()
begin

      drop table if exists TimeUntilNextReport;
      drop table if exists dt_dummy;
      
      set @i:=1;
      
      create temporary table if not exists dt_dummy 
        (n int(11), dateutc datetime)
      select 
        @i:=@i+1 as n
        , dateutc as dateutc 
      from reports;
      alter table dt_dummy add primary key(n);
      
      create table if not exists TimeUntilNextReport
        ( n int(11)
        , dateutc datetime
        , delta double
        , primary key(n)
        , index (dateutc))
     
      select
        T1.n as n
        , T1.dateutc as dateutc
        , time_to_sec(timediff(T2.dateutc,T1.dateutc)) as delta
      from dt_dummy as T1
      join dt_dummy as T2
      on T1.n = T2.n - 1;
end
//

delimiter ;
