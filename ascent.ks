// ascent.ks

global initialpitch is 22.
global targetheading is 90.
global targetapo is 100.
global targetperi is 100.

stage.

lock steering to heading(targetheading,90).
lock throttle to 2*((ship:mass*9.81)/ship:availablethrust).
gear off.

wait until ship:verticalspeed >= 100.

lock steering to heading(targetheading, 90 - lower((ship:verticalspeed-100)/4, initialpitch)).

wait until ship:verticalspeed >= 100 + 4*initialpitch or vang(ship:srfprograde:vector, heading(targetheading, 90-initialpitch):vector) < 0.5.

lock steering to heading(targetheading, 90-initialpitch).

wait until vang(ship:srfprograde:vector, heading(targetheading, 90-initialpitch):vector) < 0.5.

unlock steering.
sas on. wait 0.04. set sasmode to "PROGRADE".

wait until ship:apoapsis > 40_000.
lock throttle to 0. unlock throttle. sas off.
set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
stage.
sas on. wait 0.04. set sasmode to "PROGRADE".
lock throttle to 2*((ship:mass*9.81)/ship:availablethrust).

//core
wait until ship:apoapsis > targetperi*1000.



function lower {
	parameter x, y.
	if x > y {return y.}. return x.
}