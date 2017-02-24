// Library Utilities


function kNotify {
	parameter mText.
	parameter echo is false.
	hudText ("kOS: " + mText, 3, 2, 45, yellow, echo).
}

// experimental tree walker,
// find decouplers and 'use' them.
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
				} 
				
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