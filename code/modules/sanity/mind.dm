/*
	Vars that are attached to and carried around in the mind datum
*/
/datum/mind
	var/insanity = 0	//How insane we are. Generally in the range 0-1000, but no hard maximum
	var/next_sanity_check	=	0	//Minimum world time before this mob is allowed to do another sanity check
	var/courage	= 0//subtracted from insanity under most circumstances

	/*
		The sanity log is quite complex. This is an associative list in the format
		source = list(last, ocurrences, total)

		Source: A datum reference to a /datum/sanity_source singleton
		Last: The last world time that any sanity changes attributable to that source were made
		Frequency: How many times this round we've been affected by that source. Used to calculate desensitisation
			This increases once per discrete event for active sources, and once per second for passive sources.
			The passive ones will generally end up with MUCH higher ocurrence numbers, and this is accounted in the desensitisation values
		Total: How much total insanity we've gained or lost because of this source throughout the round

		Some of the data in the sanity log will be shown to users in their mind menu. not all of it though
	*/
	var/list/sanity_log = list()


/*
	Called when the mob gains insanity from passive or active source, this finds and updates the appropriate record in the sanity log
*/
/datum/mind/proc/increment_sanity_log(var/datum/sanity_source/source, var/sanity_damage)
	var/list/data = sanity_log[source]
	if (!data)
		data = list("last" = 0, "frequency" = 0, "total" = 0)

	data["total"] += sanity_damage
	data["frequency"] += 1
	data["last"] = world.time

	sanity_log[source] = data