/mob/living/carbon/human
	var/insanity = 0	//How insane we are. Generally in the range 0-1000, but no hard maximum
	var/next_sanity_check	=	0	//Minimum world time before this mob is allowed to do another sanity check
	var/courage	= 0//subtracted from insanity under most circumstances

/mob/living/carbon/human/proc/get_insanity(var/include_courage, var/include_reserve)
	. = insanity

	//Sanity reserved by active effects is calculated first, this does not go below zero
	if (include_reserve)
		//TODO: Have a sublist for sanity effects
		for (var/datum/extension/sanity_effect/S in extensions)
			if (!S.currently_active)
				continue

			. -= S.reserve
			//If we drop to zero don't bother to continue counting
			if (. <= 0)
				. = 0
				break

	//Next subtract courage, this CAN go negative
	if (include_courage)
		. -= get_courage()

/mob/living/carbon/human/proc/get_courage()
	return courage