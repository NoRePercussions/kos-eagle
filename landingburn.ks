// landingburn.ks
// By tuckyia / NoRePercussions
// File last updated 9 June 2020
// Goal: Land a booster, SpaceX style, as precisely as possible.
// This script: Landing retroburn to cancel out vertical velocity at the ground
// Test script: optimized for experimentation, not production

wait 10. // Give the pilot (or test program) time to start flying

// Coast until past apoapsis
wait until eta:apoapsis > eta:periapsis.
ag3 on.
print "Descent started".

// Pull calculation functions and variables into namespace
// Yeah, I don't like globals much but locks create functions in kOS. Might change later.
initconstants().
initvariables().
initburnheight().
initburnangle().

sas off.
lock steering to heading(90, 90 - burnangle*1.4).

// Set up a trigger to extend gear beforehand in case burn is shorter than 4 seconds.
// Runs asynchronously when the condition is triggered
when -v0/acceleration <= 5 and alt:radar < 300 then { gear on. } //addons:tr:timetillimpact <= 4 and 


wait until alt:radar <= heighttoburn and ship:verticalspeed < -1.
set timer to time:seconds.

print burnangle.
print acceleration.
print vaccel.
print hvel.
print "Landing burn started at " + v0 + " m/s". // Debug: prints velocity at burn start.
lock throttle to heighttoburn / alt:radar.


wait until ship:verticalspeed > -1.
print "Burn time: " + (time:seconds - timer) + " seconds".
if alt:radar > shipmaxheight + 1 { // Make sure ship isn't already on the ground
	print "Missed target landing height by " + round(alt:radar-shipheight) + " meters". // Debug: prints altitude when velocity hits 0 to find offset from ground

	// Accelerate slowly down until 5 m/s is reached
	lock throttle to ((-M*gravity_calculator())/F) - 0.05.


	wait until v0 <= -5.0 or alt:radar < shipheight + 2.
	lock throttle to ((-M*gravity_calculator())/F). // Does not account for drag atm.
}.

wait until alt:radar < shipmaxheight + 0.5. // Need to account for engines preventing full compression of landing gear

// Shutdown sequence
rcs off.
sas off.
unlock throttle.



// Function library

function gravity_calculator {
	// Solve for local gravity and average over the fall, assuming altitude is quadratic
	declare local GM to ship:body:mu.
	declare local R to (body:radius + ship:altitude - h0).
	declare local g to GM/(R * (R+h0)).
	return -g.
}.

function getfuelflow {
	local fuelflow is 0.
	list engines in elist.
	for engine in elist {
		if engine:ignition {
			set fuelflow to fuelflow + 64.7438888549805. // Accumulate fuel consumption
			// engine:fuelflow exists but returns values only for current throttle
		}.
	}.
	return fuelflow.
}

function initconstants {
	set config:ipu to 2000. // Set processor speed as fast as possible for testing

	global shipheight is 14.38. // Hard-coded for now
	global shipmaxheight is 18.78. // When at top of gear
	global dragcoef is 0.000152. // Hard-coded
}

function initvariables {
	global lock v0 to ship:verticalspeed. // Instantaneous vertical velocity.
	global lock hvel to ship:groundspeed. // Instantaneous vertical velocity.
	global lock M to ship:mass.
	global lock F to ship:availablethrust.
	global lock Fp to ship:availablethrustat(1).
	global lock h0 to alt:radar. // Instantaneous height above ground
	global lock p to ship:sensors:pres/101.325.
}

function initburnheight {
	// Find acceleration info that is not a function of mass:
	// g_c solves for gravitational pull, the second part averages drag
	// Drag equation assumes that acceleration is linear and uses an average of atm. pressure from 0-1 km
	global lock averagethrust to (F + 2*Fp) / 3.

	global lock drag to ((p + 2) * v0^2 * dragcoef / 9).
	global lock accconst to drag. // Will update to account for pressure. no longer takes grav.
	global lock fuelcoef to -1 * v0 * getfuelflow() / (2*200). // One unit of fuel is 5 kg. 200 units is 1 ton. Solving for half of mass in tons

	global lock acceleration to findgreatestroot(M, -1*(fuelcoef + averagethrust + M*accconst), accconst * fuelcoef).
	global lock averagemass to M - (fuelcoef / acceleration).
}

function initburnangle {
	global lock burnangle to (arccos(-(hvel * gravity_calculator()) / (acceleration * pyth(-v0, hvel)))
	    - arctan(-v0/hvel)).
	global lock vaccel to acceleration*cos(burnangle/1.4) + gravity_calculator().

	global lock heighttoburn to (v0^2)/(2*vaccel) + shipheight + 4.
}

function findgreatestroot {
	parameter a, b, c.
	return (-b + sqrt(b^2-(4*a*c)))/(2*a).
}

function pyth {
	parameter x, y.
	return sqrt(x^2 + y^2).
}