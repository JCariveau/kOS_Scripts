// executes the next node for the current vessel

function kNotify {
	parameter mText.
	hudText ("kOS: " + mText, 2, 2, 30, yellow, true).
}

set nd to nextnode.
//print out node's basic parameters - ETA and deltaV
kNotify("Node in: " + round(nd:eta) + " seconds, rough DeltaV: " + round(nd:deltav:mag,1) + " m/s.").

//calculate ship's max acceleration
set max_acc to ship:maxthrust/ship:mass.

// Now we just need to divide deltav:mag by our ship's max acceleration
// to get the estimated time of the burn.
//
// Please note, this is not exactly correct.  The real calculation
// needs to take into account the fact that the mass will decrease
// as you lose fuel during the burn.  In fact throwing the fuel out
// the back of the engine very fast is the entire reason you're able
// to thrust at all in space.  The proper calculation for this
// can be found easily enough online by searching for the phrase
//   "Tsiolkovsky rocket equation".
// This example here will keep it simple for demonstration purposes,
// but if you're going to build a serious node execution script, you
// need to look into the Tsiolkovsky rocket equation to account for
// the change in mass over time as you burn.
set burn_duration to nd:deltav:mag/max_acc.
kNotify("Crude Estimated burn duration: " + round(burn_duration,1) + " seconds.").
wait until nd:eta <= (burn_duration/2 + 60).
set warp to 0.
sas off. // SAS fights the 'cooked' controls.
set np to nd:deltav. //points to node, don't care about the roll direction.
kNotify("Turning the vessel into the node.").
// TODO: now we need to wait until the burn vector and ship's facing are aligned
lock steering to np.

//the ship is facing the right direction, let's wait for our burn time
kNotify("Waiting to burn.").
wait until nd:eta <= (burn_duration/2).

//we only need to lock throttle once to a certain variable in the 
//beginning of the loop, and adjust only the variable itself inside it
set tset to 0.
lock throttle to tset.

set done to False.
set dv0 to nd:deltav. //initial deltav
kNotify("Firing engines.").
until done
{
    //recalculate current max_acceleration, as it changes while we burn through fuel
    set max_acc to ship:maxthrust/ship:mass.

    //throttle is 100% until there is less than 1 second of time left to burn
    //when there is less than 1 second - decrease the throttle linearly
    set tset to min(nd:deltav:mag/max_acc, 1).

    //here's the tricky part, we need to cut the throttle as soon as our 
	//nd:deltav and initial deltav start facing opposite directions
    //this check is done via checking the dot product of those 2 vectors
    if vdot(dv0, nd:deltav) < 0
    {
        kNotify("End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1)).
        set tset to 0.
        break.
    }

    //we have very little left to burn, less then 0.1m/s
    if nd:deltav:mag < 0.1
    {
        kNotify("Finalizing burn, remaining dv: " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1)).
        
		//we burn slowly until our node vector starts to drift significantly from initial vector
        //this usually means we are on point
        wait until vdot(dv0, nd:deltav) < 0.5.

        set tset to 0.
        kNotify("End burn, remaining dv: " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1)).
        set done to true.
    }
}
wait 1.
//set throttle to 0 just in case.
set ship:control:pilotmainthrottle to 0.
unlock steering.
unlock throttle.
wait 1.

//we no longer need the maneuver node
remove nd.

