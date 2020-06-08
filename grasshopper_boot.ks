// grasshopper_boot.ks

//runpath("0:/boot/boot_term.ks").

set targetalt to makelaunchgui().

set maxvel to 80.

stage.
lock throttle to 0.3.
gear off.
rcs on.
sas on.
set sasmode to "radialout".

wait until ship:verticalspeed >= maxvel.

lock throttle to ((ship:mass*9.806)/ship:availablethrust).

wait until ship:apoapsis >= targetalt + 100.

lock throttle to 0.

wait until eta:apoapsis <= 4.
AG1 on. AG2 on.

unlock throttle.

runpath("0:/kos-eagle/landingburn.ks").




function makelaunchgui {
  local launchb is false.
  
  local launchgui is gui(200).
  local launchlabel is launchgui:addlabel("Launch Data").

  set launchlabel:style:align to "CENTER".
  set launchlabel:style:hstretch to true.


  local altlabel is launchgui:addlabel("Target Orbit Altitude (1 km)").

  set altlabel:style:align to "CENTER".
  
  local alts is launchgui:addhslider(2, 1, 40).
  
  set alts:onchange to { parameter x. set altlabel:text to "Target Orbit Altitude (" + round(x)/2 + " km)". }.
  
  
  local launchbutton is launchgui:addbutton("LAUNCH").
  
  set launchbutton:onclick to { launchb on. }.
  
  
  launchgui:show().
  
  wait until launchb.
  local altc is round(alts:value)*500.
  
  launchgui:hide().
  launchgui:dispose.

  return altc.
}.