/*
	Disorient is a simple effect that does the following:

	1. Victim closes their eyes (the user can no longer see what's happening)
	2. Victim's client direction is randomly changed (to any direction except its current)
	3. Victim sprints a few tiles towards a random reachable point
	4. Victim opens their eyes.

	They will likely be pretty confused and take a few seconds to realise where they are
*/
/datum/extension/sanity_effect/disorient
	max_duration = 3 SECONDS

/datum/extension/sanity_effect/disorient/apply_client_effects()

	//Close their eyes
	subject.close_eyes_for(max_duration, TRUE, EYECLOSE_TIME_SLOW)
	spawn(EYECLOSE_TIME_SLOW+1)
		//Wait for that to be done
		if (subject)
			var/client/C = subject.get_client()
			if (C)
				//Set client direction to any direction other than its current one
				C.dir = pick(GLOB.cardinal - C.dir)