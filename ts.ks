// Engine Cruse Control
// Throttle PIDLoop
PARAMETER thrSP IS 5.
SET thrMin TO 01.
SET thrMax TO 1.
SET thrKp TO 0.5.
SET thrKi TO 0.01.
SET thrKd TO 0.1.
SET thrPID TO PIDLoop(thrKp, thrKi, thrKd, thrMin, thrMax).
SET thrPID:SETPOINT TO thrSP.

SET thr TO 0.
LOCK THROTTLE TO thr.

UNTIL BRAKES { SET thr TO MAX(MIN(1, thrPID:UPDATE(TIME:SECONDS, SHIP:GROUNDSPEED)), 0). }

SET thr TO 0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
UNLOCK THROTTLE.
