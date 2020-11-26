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


/*
	Insanity from an active event.
	These use soft capping, any insanity that would go over the limit is reduced, but not discarded
*/
/mob/living/carbon/human/proc/add_active_insanity(var/datum/sanity_source/source, var/quantity, var/limit, var/source_atom)
	world << "[src] recieving active insanity [quantity]/[limit] from [source_atom]|[source]"
	if (!istype(source))
		source = GLOB.all_sanity_sources[source]

	//Lets find out how much we can wholly add, up to the limit
	var/clear = INFINITY

	//If no limit, all of it is clear
	if (limit)
		clear = limit - get_insanity(FALSE, FALSE)
		if (clear < 0) clear = 0


	//This is the portion that will be softcapped
	if (clear < quantity)
		var/limited_quantity = quantity - clear
		quantity -= limited_quantity

		//The default groupsize settings are probably fine for this
		limited_quantity = soft_cap(limited_quantity)

		//And recombine them now
		quantity += limited_quantity


	//Alrighty, we are clear to modify our insanity
	insanity += quantity

	//TODO Here: Visual effect in the hud indicating insanity was gained
	//Possible future TODO: Trigger an observation indicating sanity was gained
	//TODO Future: Log the source/reason in some kind of ticker

	//We do a sanity check with the quantity as extra prob
	sanity_check(quantity)



/*
	Insanity from a passive tick
	These use hard capping
*/
/mob/living/carbon/human/proc/add_passive_insanity(var/datum/sanity_source/source, var/quantity, var/limit, var/source_atom)
	if (!istype(source))
		source = GLOB.all_sanity_sources[source]

	var/current = get_insanity(FALSE, FALSE)
	if (current >= limit)
		//Hard cap, don't do anything
		return

	insanity = max(current+quantity, limit)


	//TODO: Update the log with source/reason, updating an existing entry if possible before creating anew
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





