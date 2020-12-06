/*
	Vars that are attached to and carried around in the mind datum
*/
#define SANITY_LOG_DESCRIPTION_UPDATE_PERIOD	10 MINUTES	//Periodically allow descriptions to be changed
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

	//Last time descriptions in the sanity log were updated
	var/last_sanity_description_update = 0


/*
	Called when the mob gains insanity from passive or active source, this finds and updates the appropriate record in the sanity log
*/
/datum/mind/proc/increment_sanity_log(var/datum/sanity_source/source, var/sanity_damage)
	if (!istype(source))
		source = GLOB.all_sanity_sources[source]

	var/sourcetype = source.type

	var/list/data = sanity_log[sourcetype]
	if (!data)
		data = list("last" = 0, "frequency" = 0, "total" = 0, "desc" = source.get_description())

	data["total"] += sanity_damage
	data["frequency"] += 1
	data["last"] = world.time

	sanity_log[sourcetype] = data

/*
	This is called periodically when the user opens the sanity menu, but no more than once every few minutes

	Replaces all the descriptions of sanity sources with randomly picked new ones
*/
/datum/mind/proc/update_sanity_descriptions()
	for (var/sourcetype in sanity_log)
		var/datum/sanity_source/source = GLOB.all_sanity_sources[sourcetype]
		var/list/data = sanity_log[sourcetype]
		data["desc"] = source.get_description()
		sanity_log[sourcetype] = data

/*
	The Mind Menu

	Offers a UI with various information about the user's mind

	Information shown includes:
	Mental State:
		A display of the user's insanity, courage, and reserved insanity
		Exactly which is shown and how, is highly variable

	Mood:
		A list of all things affecting mood, this is always shown with maximum info level as it is vital info for all players

	Memories: AKA Sanity Log
		List of all sources that have contributed insanity to us.
		At low info levels, these are only shown as vague descriptions
		The exact quantity of insanity gained is always shown, as this is vital info for game balancing feedback


	Effects:
		The current sanity effects on a mob
*/
/datum/mind/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/diagnostic_level = 0)


	diagnostic_level = clamp(diagnostic_level, PSYCH_DIAGNOSTIC_NONE, PSYCH_DIAGNOSTIC_MASTER)

	var/list/data = get_sanity_data(diagnostic_level)



	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "necrospawn_selector.tmpl", "Spawning Menu", 800, 700, state = GLOB.interactive_state)
		ui.set_initial_data(data)
		ui.set_auto_update(0)
		ui.open()



/datum/mind/proc/get_sanity_data(var/diagnostic_level = 0)
	var/list/data = list()
	data += get_mental_state()


//Returns data about the mental state of the user, for UI display
/datum/mind/proc/get_mental_state(var/diagnostic_level = 0)
	switch (diagnostic_level)
		if