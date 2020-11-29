/mob/living/carbon/human



/mob/living/carbon/human/proc/get_insanity(var/include_courage, var/include_reserve)
	var/datum/mind/M = get_mind()
	if (!M)
		return FALSE
	. = M.insanity

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
	var/datum/mind/M = get_mind()
	if (!M)
		return FALSE
	return M.courage






/*
	Insanity from a passive tick
	These use hard capping
*/
/mob/living/carbon/human/proc/add_passive_insanity(var/datum/sanity_source/source, var/sanity_damage, var/sanity_limit, var/origin_atom)
	var/datum/mind/M = get_mind()
	if (!M)
		return FALSE
	if (!istype(source))
		source = GLOB.all_sanity_sources[source]



	var/current = get_insanity(FALSE, FALSE)
	if (current >= sanity_limit)
		//Hard cap, don't do anything
		return

	//Handle repeat things
	sanity_damage *= get_desensitisation_factor(source)

	M.insanity = max(current+sanity_damage, sanity_limit)


	M.increment_sanity_log(source, sanity_damage)
	//Possible future TODO: Trigger an observation indicating sanity was gained



/*
	Can this mob recieve insanity and be subjected to sanity effects?
*/
/mob/proc/has_sanity()
	return FALSE	//human only


/mob/living/carbon/human/has_sanity()
	//Must be connected, cant scare SSD people
	if (!client)
		return FALSE

	//Need a mind
	var/datum/mind/M = get_mind()
	if (!M)
		return FALSE

	//Must be alive and conscious, cant scare the dead or sleepers
	if (incapacitated(INCAPACITATION_KNOCKOUT))
		return FALSE

	//Check the species, only normal humans allowed, no necromorphs or lunatics
	var/datum/species/S = get_mental_species_datum()
	if (!S || !S.has_sanity)
		return FALSE

	return TRUE


/*
	Dummies can always recieve sanity damage, for testing purposes
*/
/mob/living/carbon/human/dummy/has_sanity()
	return TRUE






/*

*/
/mob/living/carbon/human/proc/get_sanity_recovery()

	//TODO: Check for adrenaline and return 0 if there is any

	. = SANITY_REGEN_BASE

	//TODO: Calculate and factor in mood


/*
	Gets a multiplier to modify incoming psych damage based on how many times we've seen this source before
*/
/mob/living/carbon/human/proc/get_desensitisation_factor(var/datum/sanity_source/source)
	. = 1 //Incase something fails, we just return one, no change to the damage

	var/datum/mind/M = get_mind()
	if (!M)
		return

	var/list/data = M.sanity_log[source]
	if (!LAZYLEN(data))
		return

	var/frequency = data["frequency"]
	if (!isnum(frequency))
		return

	//Future TODO here: Adjust the effective frequency based on a player skill to be added in future

	//We return 1x the desensitisation multiplier to the power of the frequency
	return 1 * (source.desensitisation ** frequency)



/*
	Sanity dummy is intended for testing insanity effects, it gets an empty mind datum
*/
/mob/living/carbon/human/dummy/sanity/Initialize()
	.=..()
	mind = new()




