// Lists actions available to
// all parts of the current craft
// to a text file. EXTREMELY spammy,
// but quick and useful listing.

DECLARE FILE IS "0:/" + SHIPNAME + "-ModList.txt".

FUNCTION kNotify {
	PARAMETER mText.
	HUDTEXT ("kOS: " + mText, 3, 2, 30, YELLOW, TRUE).
}

FOR P IN SHIP:PARTS {
	kNotify("Now polling Part: " + P:NAME).
	LOG ("Suffixes for: " + P:NAME + " Type: " + P:TYPENAME) TO FILE.
	LOG P:SUFFIXNAMES	TO FILE.
	LOG " " TO file.
	LOG ("Modules for part named: " + P:NAME) TO FILE.
	FOR pModules IN P:MODULES {
		SET pModule TO P:GETMODULE(pModules).
		kNotify("Now polling Module: " + pModule:NAME + " Of Part: " + P:NAME).
		LOG " " TO FILE.
		IF pModule:ALLACTIONS:LENGTH > 0 {
			LOG ("DOACTION in: " + pModule:NAME + " Of Part: " + P:NAME + ":") TO FILE.
			LOG pModule:ALLACTIONS TO FILE.
			LOG " " TO FILE.
		}
		IF pModule:ALLEVENTS:LENGTH > 0 {
			LOG ("DOEVENT in " + pModule:NAME + " Of Part: " + P:NAME + ":") TO FILE.
			LOG pModule:ALLEVENTS TO FILE.
			LOG " " TO FILE.
		}
		IF pModule:ALLFIELDS:LENGTH > 0 {
			LOG ("GETFIELD and SETFIELD in " + pModule:NAME + " Of Part: " + P:NAME + ":") TO FILE.
			LOG pModule:ALLFIELDS TO FILE.
			LOG " " TO FILE.
		}
	} kNotify("Done.").
}