// Science Module auto-aggrigator, mostly intended for reusable modules
// while on longer collection missions, like on change of biome.
// Incomplete, May be called from other scripts.
//
// Public Domain -- Written by Jeff Cariveau.

FUNCTION sciTran {
  declare local parameter sPart,sSci.
	IF NOT sSci:INOPERABLE {
		IF NOT sSci:HASDATA {
			sSci:DEPLOY.
			WAIT UNTIL sSci:HASDATA.
		}
		HUDTEXT ("Logging Science for " + sPart:TITLE, 3, 2, 30, YELLOW, TRUE).
		sSci:TRANSMIT.
		sSci:RESET.
	}
}
	
LIST RESOURCES IN resourceList.
//We'll then go over every one..
FOR resource IN resourceList {
	
	//And find the one named "ElectricCharge"
	IF resource:NAME = "ElectricCharge" {
		//We'll only perform the Science if the charge is above 75% of the
		//ship's capacity .
		IF resource:AMOUNT / resource:CAPACITY >= 0.75 {
			
			FOR P IN SHIP:PARTS {
				SET MODS TO P:MODULES.
				IF NOT MODS:EMPTY {
					
					// TODO: Find a way to check for multiple experiments in the same part.
					IF MODS:CONTAINS ("ModuleScienceExperiment") {
						SET SCI TO P:GETMODULE ("ModuleScienceExperiment").
						sciTran(P,SCI).
					} ELSE IF MODS:CONTAINS ("dmmodulescienceanimate") {
						SET SCI TO P:GETMODULE ("dmmodulescienceanimate").
						sciTran(P,SCI).
					}
				}
			} 
		} ELSE { 
			HUDTEXT ("Insufficent EC, please recharge.", 3, 2, 30, RED, TRUE).
		}
	}
}