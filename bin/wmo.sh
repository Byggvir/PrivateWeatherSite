#!/bin/bash

pushd ../data
    wget -O full_city_list.csv https://worldweather.wmo.int/de/json/full_city_list.txt
    wget -O - http://worldweather.wmo.int/de/json/56_de.xml \
    | python3 -m json.tool > 56_$(date +%4Y%m%d).json
    
popd
