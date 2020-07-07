// boostback.ks

declare local boostbackdelay is 0.

rcs on.
sas on. wait 0.04. set sasmode to "PROGRADE".
unlock steering.
lock throttle to 0.

if eta:periapsis < eta:apoapsis { print "oh no". print 0/0. }

wait until eta:apoapsis < 60.

sas off.
lock steering to heading(270,0).

wait until eta:apoapsis <= 20.

local hvel is ship:groundspeed.

lock throttle to 1.0.

wait until ship:groundspeed <= 5.
wait until ship:groundspeed >= hvel - 100.

unlock throttle.
unlock steering.

sas on. wait 0.1. //set sasmode to "RETROGRADE".