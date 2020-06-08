// landingburn.ks
// Burn time v0 * F / M
// Burn height v0 8 t - M * t^2
set config:ipu to 2000.

global datalist is lexicon("v", list(), "a", list()).

set offset to 14.38.

set dragcoef to 0.000152.

lock g to 9.80665. //Update to local gravity later
lock v0 to ship:verticalspeed.
lock M to ship:mass.
lock F to ship:availablethrust.
lock h0 to alt:radar.
lock a to ((F/M) + gravity_calculator() + (abs(v0)^2 * dragcoef / 3)).

//lock t to v0 * M / F.
//lock h to (v0 * t) + (g * t / 2) - ((M * t^2) / (2 * F)).
wait 10.

lock burntime to -v0/a.
lock fuelconsumption to burntime * getfuelflow().
lock burntfuelweight to fuelconsumption / 200.
lock avgmass to M - burntfuelweight/2.
lock h to (v0^2)/(2*a) + offset.

wait until eta:apoapsis > eta:periapsis.
ag3 on.
print "Descent".

when -v0/a <= 4 and addons:tr:timetillimpact <= 4 then { gear on. }

wait until alt:radar <= iterativeburn(15).// - 1*v0/25.// {print iterativeburn(7). wait 0.}
//print verboseiterativeburn(1) + "/" + h0.
print "Trying to burn".
//print avgmass + "/" + mass.
print getfuelflow().
lock throttle to 1.


wait until ship:verticalspeed > -1.
if alt:radar > 15 {
	print alt:radar-offset.
	lock throttle to ((M*g)/F) - 0.05.


	wait until ship:verticalspeed <= -5.0 or alt:radar < 16.
	lock throttle to ((M*g)/F).
}.

//print ((M*g)/F).

wait until alt:radar < 16.
rcs off.
sas off.
unlock throttle.

//writejson(datalist, "aerodrag.json").


function gravity_calculator {
	declare local GM to ship:body:mu.
	declare local R to (body:radius + ship:altitude - alt:radar/3).
	declare local g to GM/(R^2).
	return -g.
}.

function recorddata {
	datalist:v:add(ship:verticalspeed).
	datalist:a:add(ship:sensors:acc:mag).
}

function getfuelflow {
	local fuelflow is 0.
	list engines in elist.
	for engine in elist {
		if engine:ignition {
			set fuelflow to fuelflow + 64.7438888549805. //engine:fuelflow. need at max thrust, not current
		}.
	}.
	return fuelflow.
}

function iterativeburn {
	parameter iterations.
	local mass is ship:mass.
	local acc is 0.

	for i in range(iterations) {
		set acc to ((F/mass) + gravity_calculator() + (abs(v0)^2 * dragcoef / 3)).
		set burntime to -v0/acc.
		set avgmass to M - (burntime * getfuelflow() / 200)/2.
		set mass to avgmass + 0.
	}

	local h is (v0^2)/(2*a) + offset.
	print h+"/"+alt:radar.
	return h.
}