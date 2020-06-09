// hoverslam.ks

clearscreen.

set launchpad to Kerbin:GEOPOSITIONLATLNG(-0.0972074984824922,-74.5576753390154).

addons:tr:settarget(launchpad).

if addons:tr:hasimpact = false {
	print 0/0.
}

wait until eta:apoapsis > eta:periapsis.
sas off.
rcs on.
ag1 on.

wait 0.5.
global stcontrol is ship:retrograde:vector.
lock steering to stcontrol.

set ewpid to pidloop(1300,40,20,-15,30).
set nspid to pidloop(1500,30,20,-35,35).
set ewpid:setpoint to launchpad:lng.
set nspid:setpoint to launchpad:lat.

when ship:altitude < 30_000 then {
	rcs off.
}

when alt:radar < 50 then {
	print addons:tr:impactpos.
}

lock throttle to 0.
set last to stcontrol.

until addons:tr:hasimpact = False {
	iterate().
	wait 0.02.
}

unlock throttle.

function iterate {
	local ew is 15 + ewpid:update(time:seconds, addons:tr:impactpos:lng).
	local ns is nspid:update(time:seconds, addons:tr:impactpos:lat).

	local pitch is max(abs(ew), abs(ns)).

	local bearing is norm(arctan2(-ew, -ns)).

	if vang(last, heading(bearing, 90-pitch):forevector) > 0.1 {
		//print last + "," + heading(bearing, 90-pitch):forevector.
		set last to heading(bearing, 90-pitch):forevector.
		print ew + "," + ns.
	
		set stcontrol to heading(bearing, 90-pitch).
		//set stcontrol to heading(270 - bearing, 45-pitch, constant:pi/4).
		//set stcontrol to yawcorrection * (pitchcorrection * heading(270, 45)).
		//set stcontrol to heading(bearing, 45 - pitch, constant:pi/4).
	}
}

function norm {
	parameter x.
	if x < 0 {
		return x + 360.
	}
	return x.
}

// set pitchup30 to angleaxis(-30, ship:starvector).  // Learn this control so you can properly pitch / yaw / roll 
// set yawright30 to angleaxis(-30, ship:topvector).
// set roll30 to angleaxis(-30, ship:forevector).