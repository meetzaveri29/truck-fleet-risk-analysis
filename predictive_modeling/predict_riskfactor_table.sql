CREATE TABLE predict_riskfactor AS
SELECT
    gs.driverid,
    tm.truckid,
    rs.riskfactor,
    rs.events,
    rs.totmiles,
    ts.model,
    MAX(gs.velocity) AS max_speed,
    AVG(tm.mpg) AS avg_mileage
FROM
    truck_mileage tm
JOIN geolocation gs ON gs.truckid = tm.truckid
JOIN riskfactor rs ON rs.driverid = gs.driverid
JOIN trucks ts ON ts.truckid = gs.truckid
GROUP BY
    gs.driverid,
    tm.truckid,
    rs.riskfactor,
    rs.events,
    rs.totmiles,
    ts.model;
