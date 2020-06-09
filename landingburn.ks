// landingburn.ks
// By tuckyia / NoRePercussions
// File last updated 8 June 2020
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

// Set up a trigger to extend gear beforehand in case burn is shorter than 4 seconds.
// Runs asynchronously when the condition is triggered
when addons:tr:timetillimpact <= 4 and -v0/acceleration <= 5 then { gear on. }


wait until alt:radar <= heighttoburn and ship:verticalspeed < -1.

print "Landing burn started at " + v0 + " m/s". // Debug: prints velocity at burn start.
lock throttle to 1.


wait until ship:verticalspeed > -1.
if alt:radar > shipheight + 2 { // Make sure ship isn't already on the ground
	print "Missed target landing height by " + round(alt:radar-shipheight) + " meters". // Debug: prints altitude when velocity hits 0 to find offset from ground

	// Accelerate slowly down until 5 m/s is reached
	lock throttle to ((-M*gravity_calculator())/F) - 0.05.


	wait until v0 <= -5.0 or alt:radar < shipheight + 2.
	lock throttle to ((-M*gravity_calculator())/F). // Does not account for drag atm.
}.

wait until alt:radar < shipheight + 3. // Need to account for engines preventing full compression of landing gear

// Shutdown sequence
rcs off.
sas off.
unlock throttle.



// Function library

function gravity_calculator {
	// Solve for local gravity and average over the fall, assuming altitude is quadratic
	declare local GM to ship:body:mu.
	declare local R to (body:radius + ship:altitude - 2*alt:radar/3).
	declare local g to GM/(R^2).
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
	global dragcoef is 0.000152. // Hard-coded, later will try to implement a function to approximate irt.
}

function initvariables {
	global lock v0 to ship:verticalspeed. // Instantaneous vertical velocity.
	global lock M to ship:mass.
	global lock F to ship:availablethrust.
	global lock h0 to alt:radar. // Instantaneous height above ground	
}

function initburnheight {
	// Find acceleration info that is not a function of mass:
	// g_c solves for gravitational pull, the second part averages drag
	// Drag equation assumes that acceleration is linear and uses an average of atm. pressure from 0-1 km
	global lock averagethrust to (F + 2 * ship:availablethrustat(1)) / 3.

	global lock drag to (abs(v0)^2 * dragcoef / 3).
	global lock accconst to gravity_calculator() + drag. // Will update to account for pressure
	global lock fuelcoef to -1 * v0 * getfuelflow() / (2*200). // One unit of fuel is 5 kg. 200 units is 1 ton. Solving for half of mass in tons

	global lock acceleration to findgreatestroot(M, -1*(fuelcoef + averagethrust + M*accconst), accconst * fuelcoef).
	global lock averagemass to M - (fuelcoef / acceleration).

	global lock heighttoburn to (v0^2)/(2*acceleration) + shipheight + 2.
}

function findgreatestroot {
	parameter a, b, c.
	return (-b + sqrt(b^2-(4*a*c)))/(2*a).
}