// kOS Launch script
// Jeff Cariveau
runoncepath("0:/lib_utils.ks").

PARAMETER Comp IS 90. // Compass direction, defaults East.
PARAMETER tarAlt IS 15000. // Starting altitude.
CLEARSCREEN.

// Check for atmosphere, get well above it.
IF BODY:ATM:EXISTS AND tarAlt < BODY:ATM:HEIGHT {
	SET tarAlt TO BODY:ATM:HEIGHT + tarAlt.
} 

// Throttle PIDLoop :: Elsewhere this becomes time to apoapsis.
SET thrMin TO 0.
SET thrMax TO 1.
SET thrKp TO 0.5.
SET thrKi TO 0.01.
SET thrKd TO 0.1.
SET thrPID TO PIDLoop(thrKp, thrKi, thrKd, thrMin, thrMax).
SET thrPID:SETPOINT TO 45. 
// Q PIDLoop :: Keeps pressure from ripping up / cooking rocket.
SET qMin TO 0.
SET qMax TO 1.
SET qKp TO 0.5.
SET qKi TO 0.01.
SET qKd TO 0.1.
SET qPID TO PIDLoop(qKp, qKi, qKd, qMin, qMax).
SET qPID:SETPOINT TO 35. 

// Make sure we go fast enough not to tip over.
WHEN SHIP:VELOCITY:SURFACE:MAG > 150 THEN {
	kNotify("Begin Gravity Turn").
	IF BODY:ATM:EXISTS {
		// Cosine Gravity Turn based on altitude.
		LOCK STEERING TO HEADING(Comp, MAX(5,ARCCOS(SHIP:ALTITUDE / BODY:ATM:HEIGHT))). 
		WHEN SHIP:ALTITUDE > (BODY:ATM:HEIGHT * .525) THEN LOCK STEERING TO PROGRADE.
	} ELSE LOCK STEERING TO HEADING(Comp, 5). 
}	

SET thr TO 1.
LOCK THROTTLE TO thr.
LOCK STEERING TO HEADING(Comp, 90).
SAS OFF. // SAS fights the 'cooked' controls.

kNotify ("Target altitude is " + (tarAlt / 1000) + " Km").
WAIT 1.
kNotify ("Launching").
STAGE.
WAIT 5.
GEAR OFF.
IF BODY:ATM:EXISTS WHEN ALTITUDE > BODY:ATM:HEIGHT THEN PANELS ON.

// Throttle PIDLoop, time to apoapsis.
UNTIL SHIP:APOAPSIS > tarAlt {
	SET thr TO MIN(thrPID:UPDATE(TIME:SECONDS, ETA:APOAPSIS), qPID:UPDATE(TIME:SECONDS, SHIP:Q * 100)).
	autostage().
	WAIT 0.1.
}
SET thr TO 0.

cirE(1, 0.003).

kNotify("Done").
