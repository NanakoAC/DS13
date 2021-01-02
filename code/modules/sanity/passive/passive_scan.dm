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

	trigger = new(holder = epicentre, on_turf_entered = /datum/extension/sanity_scan/proc/register_victim, on_turfs_changed = null, range = src.range, proc_owner = src)
	trigger.register_turfs()

	//We do an active scan once only on initial setup, because the prox trigger won't detect things which are already in range but not moving
	do_active_scan()


/datum/extension/sanity_scan/passive/Destroy()
	if (trigger)
		QDEL_NULL(trigger)
	.=..()