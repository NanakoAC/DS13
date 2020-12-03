/*
	Mental things
*/
/datum/species/proc/handle_sanity(var/mob/living/carbon/human/H, var/datum/mind/M)
	//Sanity recovers each tick
	M.insanity = clamp(M.insanity - H.get_sanity_recovery(), 0, INFINITY)

	//Once per minute, a sanity check, if we have any insanity left
	if (M.insanity && H.life_tick % SANITY_CHECK_INTERVAL == 0)
		H.sanity_check()


//Insanity effects are only for humans
/datum/species/necromorph/handle_sanity(var/mob/living/carbon/human/H)
	return