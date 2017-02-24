// landpid

SAS off.
SET thr TO 0.
lock throttle to thr.
lock steering to retrograde.
SET thrMin TO 0.
SET thrMax TO 1.
SET thrKp TO 0.6.
SET thrKi TO 0.01.
SET thrKd TO 0.05.
SET thrPID TO PIDLoop(thrKp, thrKi, thrKd, thrMin, thrMax).
until SHIP:groundspeed < 5 {
	set thr to min(1,max(ship:groundspeed/10,0)).
}
set thr to 0.
wait until alt:radar < 1500.
until ship:status = "landed" {
	set thrPID:SETPOINT to -max(alt:radar/5, 1).
	SET thr TO thrPID:UPDATE(TIME:SECONDS, SHIP:VERTICALSPEED).
	WAIT 0.01.
	
}
SET thr TO 0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
UNLOCK THROTTLE.
UNLOCK STEERING.
