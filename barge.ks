// barge.ks

local lat is 0.
local long is -63.8.

lock steering to heading(90-arctan2(lat - ship:latitude, (long - ship:longitude)), 0).
lock throttle to sqrt((lat - ship:latitude)^2 + (long - ship:longitude)^2)*3.

wait until abs(lat - ship:latitude) < 0.001 and abs(long - ship:longitude) < 0.001.

brakes on.
unlock throttle.
set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.