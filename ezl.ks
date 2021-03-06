// easy launcher.
PARAMETER com IS 90.
// Throttle PIDLoop :: Elsewhere this becomes time to apoapsis.
SET thrMin TO 0.
SET thrMax TO 1.
SET thrKp TO 0.5.
SET thrKi TO 0.01.
SET thrKd TO 0.1.
SET thrPID TO PIDLoop(thrKp, thrKi, thrKd, thrMin, thrMax).
SET thrPID:SETPOINT TO 45.

SET thr TO 1.
LOCK THROTTLE TO thr.
LOCK STEERING TO HEADING(com, 90).
SAS OFF. // SAS fights the 'cooked' controls.
RCS OFF.
LIGHTS ON.

WHEN SHIP:VERTICALSPEED > 375 THEN LOCK STEERING TO HEADING(com, 80).
WHEN SHIP:GROUNDSPEED > 100 THEN LOCK STEERING TO SRFPROGRADE.
WHEN SHIP:APOAPSIS > BODY:ATM:HEIGHT THEN LOCK STEERING TO PROGRADE.
IF BODY:ATM:EXISTS WHEN ALTITUDE > BODY:ATM:HEIGHT THEN PANELS ON.

WAIT 1.
STAGE.
WAIT 4.
GEAR OFF.

// WHEN STAGE:LIQUIDFUEL < 0.1 THEN {
//   STAGE.
//   PRESERVE.
// }

UNTIL OBT:ECCENTRICITY < .003 {
  SET thr TO MIN(1, MAX(thrPID:UPDATE(TIME:SECONDS, ETA:APOAPSIS), 0)).
  LIST ENGINES IN engs.
  FOR eng IN engs {
      SET eng:thrustLimit TO MAX(MIN((OBT:ECCENTRICITY * 1000), 100), 10).
  }
}

SET thr TO 0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
UNLOCK THROTTLE.
UNLOCK STEERING.
SAS ON.
