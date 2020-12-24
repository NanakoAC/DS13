/*
	Travelling Blackout is a simple but highly impactful Tier II instant effect
	It can only trigger when the victim is alone,from both humans and necromorphs. No witnesses are allowed

	1. Victim closes their eyes (the user can no longer see what's happening)
	2. Victim is teleported somewhere else on the ship.
	ICly, this is not actually teleporting, its more like sleepwalking.
	The victim is going on a long walk, but they don't remember the journey

	It would look like teleporting to an outside observer, hence why witnesses are not allowed

	3. Once a destination is chosen, the victim awakes in a lying down position, similar to spawning in maintenance
*/
#define EYECLOSE_DURATION	8 SECONDS
/datum/extension/sanity_effect/travelling_blackout
	name = "Travelling Blackout"
	clinical_name = "Sleepwalking"
	instant = TRUE
	required_insanity = SANITY_TIER_MODERATE
	reserve = SANITY_RESERVE_MODERATE

	trigger_duration_max = (EYECLOSE_DURATION)
	trigger_windup_time = EYECLOSE_TIME_SLOW + 1
	cooldown = SANITY_COOLDOWN_MODERATE
	fade_duration = 5 MINUTES

	messages_periodic_active = list("I feel like I'm moving", "Where am I going?", "What's happening?")
	messages_trigger_end = list("Ugh my head hurts,where am I?", "How the hell did I get here?", "I don't remember walking here, where was I before?")
/*
	Visibility checking.
	Call parent first, and we only care to overrule if it returned a possibly valid result
*/
/datum/extension/sanity_effect/travelling_blackout/can_trigger(var/mob/living/carbon/human/H)

	.=..()
	if (. > CHECK_INVALID)
		//Alright, lets see if anyone is looking
		if (H.is_seen())
			return CHECK_INVALID

		//They must also be aboard the main scene for now. This limitation can be removed in future with a better level/scene system
		var/area/A = get_area(H)
		if (!A || !is_station_area(A))
			return CHECK_INVALID


/datum/extension/sanity_effect/travelling_blackout/trigger_windup()
	//Close their eyes
	subject.close_eyes_for(EYECLOSE_DURATION, TRUE, EYECLOSE_TIME_SLOW)


/datum/extension/sanity_effect/travelling_blackout/trigger_mob_effects()

	var/turf/landing_point = find_landing_point()
	//This should never happen
	if (!landing_point)
		return

	//Alright we've found a place to land, lets move the player there
	subject.forceMove(landing_point)

	//And you are now sleepingw
	subject.Paralyse((EYECLOSE_DURATION  / 10)+1)


/datum/extension/sanity_effect/travelling_blackout/proc/find_landing_point()
	/*
		First of all, lets create a buffer list of possible areas
	*/
	var/list/candidates = GLOB.ship_areas.Copy()



	//Right lets loop through them
	while (candidates.len)
		var/area/A = pick_n_take(candidates)


		//We don't want to spawn on corruption
		if (area_corrupted(A, FALSE))
			continue

		//Lets make sure we have breathable air
		if (is_area_atmos_unsafe(A))
			continue

		//How many attempts will we make at testing turfs within this area?
		var/turfs_to_check = 5

		//Get the list of clear floor tiles
		var/list/spaces = A.get_spaces()
		while (turfs_to_check && spaces.len)
			turfs_to_check--
			var/turf/T = pick_n_take(spaces)
			var/list/viewers = T.get_viewers()

			//Don't spawn if the tile is visible to anyone
			if (viewers.len)
				continue


			//TODO: More safety checks?

			//If we get here, we have found a suitable turf
			return T


#undef EYECLOSE_DURATION