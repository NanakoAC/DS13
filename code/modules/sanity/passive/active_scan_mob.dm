/datum/extension/sanity_scan/active/mob
	//Subtype of the active scan specifically for mob/living
	var/death_registered = FALSE

//Here we set observations on our host atom. These will cause a scan to happen whenever certain events occur which might indicate
//activity
/datum/extension/sanity_scan/active/mob/setup_detection()
	.=..()
	GLOB.damage_hit_event.register(epicentre, src, /datum/extension/sanity_scan/active/proc/schedule_scan)

	//Make sure we only do this once
	if (!death_registered)
		//Scary mobs cease to be so when they are dead
		GLOB.death_event.register(epicentre, src, /datum/extension/sanity_scan/proc/abort_scan)

//Called when we start active scanning, we dont need these observations anymore since we'll scan once per second anyway
/datum/extension/sanity_scan/active/mob/unsetup_detection()
	GLOB.damage_hit_event.unregister(epicentre, src, /datum/extension/sanity_scan/active/proc/schedule_scan)
	.=..()