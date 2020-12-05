/*
	This extension attempts to create an object when nobody is looking. It is attached to a turf where the new thing should go
	The turf is periodically checked for nearby viewers

*/

/datum/extension/create_unseen
	name = "create_unseen"
	base_type = /datum/extension/create_unseen
	expected_type = /turf
	flags = EXTENSION_FLAG_IMMEDIATE

	var/interval = 1 SECOND//MINUTE


	var/ongoing_timer

	//Were we being seen when we last checked?
	//Changes to false when nobody is around, back to true when they are
	var/was_seen = TRUE

	//How long have we been unseen? This is reset to zero whenever was_seen becomes true
	var/unseen_time = 0

	//We must remain unseen for this long to finish waiting and spawn the thing
	var/min_time = 0

	var/result_path

	var/obj/result


/datum/extension/create_unseen/New(var/atom/holder, var/typepath, var/_min_time = 10 SECONDS)
	.=..()
	min_time = _min_time
	result_path = typepath
	interval = min(1 MINUTE, min_time / 2)
	if (QDELETED(holder))
		stop()
		return
	start()

/datum/extension/create_unseen/Destroy()
	if (ongoing_timer)
		deltimer(ongoing_timer)
		ongoing_timer = null

	result = null

	.=..()

//Do a single tick immediately
/datum/extension/create_unseen/proc/start()
	tick()


/datum/extension/create_unseen/proc/tick()

	//Alright, lets see if anyone is looking yet
	var/turf/T = holder
	if (!T.is_seen_by_crew())
		//We're not currently seen
		if (was_seen)
			was_seen = FALSE
		else
			unseen_time += interval

		//If we've been unseen for long enough, lets finalise the spawning
		if (unseen_time >= min_time)
			do_spawn()
			stop()
	else
		was_seen = TRUE
		unseen_time = 0

	if (!QDELETED(src) && !QDELETED(T))
		ongoing_timer = addtimer(CALLBACK(src, /datum/extension/create_unseen/proc/tick), interval)


/datum/extension/create_unseen/proc/do_spawn()
	result = new result_path(holder)

/datum/extension/create_unseen/proc/stop()
	if (ongoing_timer)
		deltimer(ongoing_timer)
		ongoing_timer = null

	if (!QDELETED(holder))
		remove_extension(holder, base_type)

