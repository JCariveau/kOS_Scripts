// Library Utilities


function kNotify {
	parameter mText.
	parameter echo is false.
	hudText ("kOS: " + mText, 3, 2, 45, yellow, echo).
}

// experimental tree walker, find decouplers and 'use' them.
// doesn't (yet) look for flingatron children and the like.
function autoStage { 
	list engines in engs.
	if not engs:empty {
		for eng in engs {
			if eng:flameOut {
				until eng:modules:contains("ModuleDecouple") or eng:modules:contains("ModuleAnchoredDecoupler") {
					if eng:hasParent set eng to eng:parent.
				}
				kNotify("Staging").
				if eng:modules:contains("ModuleEngines") {
					set en to eng:getModule("ModuleEngines").
					en:doAction("activate engine",true).
				} // TODO: add the above to a 'child' walker.
				
				if eng:modules:contains("ModuleDecouple") {
					set dc to eng:getModule("ModuleDecouple").
					dc:doEvent("decouple").
				}
				else if eng:modules:contains("ModuleAnchoredDecoupler") {
					set dc to eng:getModule("ModuleAnchoredDecoupler").
					dc:doEvent("decouple").
				}
			}
		}
	}
}

// Eccentricity based circularizer, still under development.
// Multiplier is for balancing TWR to realistic levels.
function cirE {
	parameter iMultiplier is 1.
	parameter iTarget is .005.
	
	// Throttle PIDLoop
	set throttleMin to 0.
	set throttleMax to 1.
	set throttleKp to 0.5.
	set throttleKi to 0.01.
	set throttleKd to 0.1.
	set throttlePID to PIDLoop(throttleKp, throttleKi, throttleKd, throttleMin, throttleMax).
	set throttlePID:setPOINT to 15. 
	
	set iThrottle to 0.
	sas off.
	lock steering to prograde. 
	lock throttle to iThrottle.
	
	wait until eta:apoapsis < 30.
	set warp to 0.
	wait until eta:apoapsis < 15.
	kNotify("Circularizing").

	// TODO: basic hill climber for eccentricity
	// if we're going back up, we need to stop
	until obt:eccentricity < iTarget {
		set iThrottle to min(throttlePID:update(time:seconds, eta:apoapsis), obt:eccentricity * iMultiplier).
		if eta:apoapsis > 30 break.
		wait 0.001.
	}
	
	set iThrottle to 0.
	set ship:control:pilotMainThrottle to 0.
	unlock throttle.
	unlock steering.
	sas on.
}