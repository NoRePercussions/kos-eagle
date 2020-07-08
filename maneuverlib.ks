// maneuverlib.ks

function executemaneuver {
	parameter node, addnode is true, rcsstate is true.

	print "Abort (backspace) to stop node execution".

	when abort then { lock throttle to 0. return. }

	if addnode {add node.}.

	if node:eta < 0 { print "Error - node is in past". return. }.

	sas on. wait 0. set sasmode to "PROGRADE".

	lock dv to node:deltav:mag.

	if currentdv() < dv { print "Needs to stage". }.

	local acceleration is ship:availablethrust / (ship:mass - (stage:liquidfuel + stage:oxidizer)/(2*200)).
	local burntime is dv / acceleration.

	if node:eta < burntime/2 { print "Burn should have already occured!". }
	else { wait 1. kuniverse:timewarp:warpto(time:seconds + node:eta - burntime/2 - 30). }

	wait until node:eta - burntime/2 <= 30.
	set rcs to rcsstate. sas on. wait 0. set sasmode to "MANEUVER".


	wait until node:eta - burntime/2 <= 0.

	lock throttle to 1.0.

	wait until dv <= 10.0.

	lock throttle to 0.1.

	wait until dv <= 1.0.

	lock throttle to 0.01.

	wait until dv <= 0.1.

	lock throttle to 0.
	remove node.
}

function currentdv { // zero-indexed
	list engines in elist.
	local accisp is 0. local ispn is 0.
	for engine in elist {
		if engine:ignition {
			set ispn to ispn + 1.
			set accisp to accisp + 1/engine:isp.
		}
	}

	local stageisp is ispn / accisp.
	print stageisp.

	return stageisp*ln(ship:mass / (ship:mass - (stage:liquidfuel + stage:oxidizer)/200))*9.81.

}

//executemaneuver(nextnode, false, true).