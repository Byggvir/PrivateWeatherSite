use weatherstations;

delimiter //

drop procedure if exists avgwinddir //

create procedure avgwinddir ()

begin

    select 
        Tag
        , case when d < 90 then 90 - d else 450 - d end as win_dir
        , v as win_v
    from ( 
        select 
            Tag
            , round(sqrt(x*x+y*y),1) as v 
            , round(atan2( y , x ) / pi() * 180,1) as d 
            from ( 
                select 
                    date(dateutc) as Tag
                    , avg(sin(winddir/180*pi())*windspeedmph) as x
                    , avg( cos( winddir / 180 * pi() ) * windspeedmph) as y
                from reports
                group by 
                    date(dateutc)
            ) as xykoord 
    ) as polar;
    
end
//

drop function if exists Barom_in2hPa //

create function Barom_in2hPa ( pressure FLOAT) returns FLOAT

begin

    return round(pressure / 0.0295300586466965,1); 
    
end
//


drop function if exists inch_mm //

create function inch_mm ( inch FLOAT) returns FLOAT

begin

    return round( inch * 25.4, 4 ) ;
    
end
//


drop function if exists Barom_hPa2in //

create function Barom_hPa2in ( pressure FLOAT) returns FLOAT

begin

    return round(pressure * 0.0295300586466965,1); 
    
end
//

drop function if exists Fahrenheit_Celsius //

create function Fahrenheit_Celsius ( Fahrenheit FLOAT ) returns FLOAT

begin

    return round( (Fahrenheit - 32) * 5 / 9 , 1 ) ;

end
//

drop function if exists mph_kmh //

create function mph_kmh ( speed FLOAT ) returns FLOAT

begin
	return round( speed * 1.609344 , 1 )  ;
end
//

drop function if exists mph_ms //

create function mph_ms ( speed FLOAT ) returns FLOAT

begin
	return round( speed * 1609.344 / 3600 , 1 )  ;
end
//

drop function if exists mph_bft //

create function mph_bft ( speed FLOAT ) returns FLOAT

begin
	return round( pow( speed * 1609.344 / 3600/ 0.836, 2/3 ), 0 )  ;
end
//

delimiter ;

create or replace view BaromSpeed as
select 
	dateutc
	, Barom_in2hPa(baromin) as Luftdruck
	, mph_kmh(windgustmph) as Windgeschwindigkeit
from
	reports
where
	baromin is not NULL and windspeedmph is not NULL; 


create or replace view Luftdruck as
select 
	dateutc
	, Barom_in2hPa(baromin)
from
	reports; 
