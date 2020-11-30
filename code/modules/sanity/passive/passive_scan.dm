/*
	Passive scan is for horror beacons, which are sort of elected representatives for bloodstains, corpses, gore.
	Things which sit on the ground and do nothing, rarely or never move
*/
/datum/extension/sanity_scan/passive
	var/datum/proximity_trigger/view/trigger


/*
	Creates the proximity trigger.
	This may be called again if the epicentre moves
*/
/datum/extension/sanity_scan/passive/setup_detection()
	if (trigger)
		QDEL_NULL(trigger)

	var/datum/proximity_trigger/view/trigger = new(holder = epicentre, on_turf_entered = /datum/extension/sanity_scan/proc/register_victim, on_turfs_changed = null, range = src.range)

