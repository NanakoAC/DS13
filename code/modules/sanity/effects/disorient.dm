/*
	Disorient is a simple effect that does the following:

	1. Victim closes their eyes (the user can no longer see what's happening)
	2. Victim's client direction is randomly changed (to any direction except its current)
	3. Victim sprints a few tiles towards a random reachable point
	4. Victim opens their eyes.

	They will likely be pretty confused and take a few seconds to realise where they are
*/
#define EYECLOSE_DURATION	3 SECONDS
/datum/extension/sanity_effect/disorient
	name = "Disorient"
	clinical_name = "Transient Disorientation"
	instant = TRUE
	has_client_effects = TRUE
	trigger_duration_max = (EYECLOSE_DURATION)
	trigger_windup_time = EYECLOSE_TIME_SLOW + 1
	fade_duration = 5 MINUTES

/datum/extension/sanity_effect/disorient/trigger_windup()
	//Close their eyes
	subject.close_eyes_for(EYECLOSE_DURATION, TRUE, EYECLOSE_TIME_SLOW)


/datum/extension/sanity_effect/disorient/trigger_client_effects()
	var/client/C = subject.get_client()
	if (C)
		//Set client direction to any direction other than its current one
		C.dir = pick(GLOB.cardinal - C.dir)




/datum/extension/sanity_effect/disorient/trigger_mob_effects()
	/*
		We are going to move to a random spot we can see
	*/
	var/turf/target = reachable_points_in_view(origin = subject, range = 15, min_range = 6, one_only = TRUE)

	if (target)
		var/delay = subject.movement_delay()
		delay *= 0.6 //Move a bit faster
		walk_to(subject, target, 0, delay)


/datum/extension/sanity_effect/disorient/on_end_trigger()
	//Cancel any walking
	walk(subject, 0)

#undef EYECLOSE_DURATION