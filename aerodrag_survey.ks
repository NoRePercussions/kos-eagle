// aerodrag_survey.ks

set config:ipu to 2000.

global datalist is lexicon("v", list(), "a", list(), "p", list()).

until alt:radar < 50 {
	if ship:verticalspeed < 0 and ship:altitude <= 1000 and ship:altitude >= 100 {
		recorddata().
	}
}

writejson(datalist, "aerodrag.json").

function recorddata {
	datalist:v:add(ship:verticalspeed).
	datalist:a:add(ship:sensors:acc:mag).
	datalist:p:add(ship:sensors:pres/101.325).
}