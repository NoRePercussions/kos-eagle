// ascent.ks

global initialpitch is 22.
global targetheading is 90.
global targetapo is 2_863.
global targetperi is 1_222.

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

lock throttle to 0.

runoncepath("kos-eagle/maneuverlib.ks").

executemaneuver(node(time:seconds + eta:apoapsis, 0, 0, visviva())).


function lower {
	parameter x, y.
	if x > y {return y.}. return x.
}

function visviva {
  local gravity to constant:G * ship:body:mass.
  local r_apo to ship:apoapsis + 600000.
  local target_sma to (targetapo*1000 + ship:apoapsis)/2 + 600_000.
  
  //Vis-viva equation to give speed we'll have at apoapsis.
  local apovelocity to SQRT(gravity * ((2 / r_apo) - (1 / ship:orbit:semimajoraxis))).
  
  //Vis-viva equation to calculate speed we want at apoapsis for a circular orbit. 
  //For a circular orbit, desired SMA = radius of apoapsis.
  local vexpected to SQRT(gravity * ((2 / r_apo) - (1 / target_sma))). 
  
  local dv to vexpected - apovelocity.
  return dv.
}.