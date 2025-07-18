-- Pig script to populate riskfactor table
-- Calculates driver risk factor based on non-normal events per million miles

-- Load geolocation data from Hive table
a = LOAD 'myproject.geolocation' USING org.apache.hive.hcatalog.pig.HCatLoader();

-- Filter out normal events (keep only risky events)
b = FILTER a BY event != 'normal';

-- Generate driver ID, event, and occurrence count for each risky event
c = FOREACH b GENERATE driverid, event, (int) '1' AS occurance;

-- Group by driver ID to aggregate events per driver
d = GROUP c BY driverid;

-- Calculate total occurrences of risky events per driver
e = FOREACH d GENERATE group AS driverid, SUM(c.occurance) AS t_occ;

-- Load driver mileage data from Hive table
g = LOAD 'myproject.drivermileage' USING org.apache.hive.hcatalog.pig.HCatLoader();

-- Join events data with mileage data by driver ID
h = JOIN e BY driverid, g BY driverid;

-- Calculate final risk factor: (events / total_miles) * 1,000,000
-- This gives us risky events per million miles driven
final_data = FOREACH h GENERATE 
    $0 AS driverid, 
    $1 AS events, 
    $3 AS totmiles,
    (float)$1/$3*1000000 AS riskfactor;

-- Store results into riskfactor Hive table
STORE final_data INTO 'myproject.riskfactor' USING org.apache.hive.hcatalog.pig.HCatStorer();
