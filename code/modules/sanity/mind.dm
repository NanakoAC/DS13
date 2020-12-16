/*
	Vars that are attached to and carried around in the mind datum
*/
#define SANITY_LOG_DESCRIPTION_UPDATE_PERIOD	10 MINUTES	//Periodically allow descriptions to be changed
/datum/mind
	var/insanity = 0	//How insane we are. Generally in the range 0-1000, but no hard maximum
	var/next_sanity_check	=	0	//Minimum world time before this mob is allowed to do another sanity check
	var/resolve	= 0//subtracted from insanity under most circumstances

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

	//The contents of the sanity log, sorted and compressed into colored strings
	//Must be updated whenever sanity log changes
	var/list/sanity_log_data

	//Last time descriptions in the sanity log were updated
	var/last_sanity_description_update = 0

	//Currently stored strings, cached to prevent rapid changing
	var/mental_state_string
	var/resolve_string



/mob/living/carbon/human/verb/mind_menu()
	set category = "IC"
	set name = "Mind Menu"
	set desc = "Opens your mind menu, allowing you to see what's troubling you."


	open_mind_menu(src)

/mob/living/carbon/human/proc/open_mind_menu(var/mob/user, var/diagnostic_level = PSYCH_DIAGNOSTIC_NONE)
	var/datum/mind/M = get_mind()
	M.ui_interact(user, diagnostic_level = diagnostic_level)


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


	//When we increment an element we want it to be at the top, so we have to execute a slightly complicated process
	//1. Remove from list
	sanity_log -= sourcetype

	//2. Reinsert key at position 1
	sanity_log.Insert(1, sourcetype)

	//3. Reassociate data with key
	sanity_log[sourcetype] = data

	//Thanks to the above process, the list is permanantly kept sorted in descending order of time since last update


	//Null this out so that it will be regenerated on the next refresh
	sanity_log_data = null

/*
	This is called periodically when the user opens the sanity menu, but no more than once every few minutes

	Replaces all the descriptions of sanity sources with randomly picked new ones
*/
/datum/mind/proc/update_sanity_descriptions()
	last_sanity_description_update = world.time

	//Change all the descriptions in the log
	for (var/sourcetype in sanity_log)
		var/datum/sanity_source/source = GLOB.all_sanity_sources[sourcetype]
		var/list/data = sanity_log[sourcetype]
		data["desc"] = source.get_description()
		sanity_log[sourcetype] = data

	//Null out these saved strings, new ones will be fetched in subsequent procs
	mental_state_string = null
	resolve_string = null
	sanity_log_data = null
/*
	The Mind Menu

	Offers a UI with various information about the user's mind

	Information shown includes:
	Mental State:
		A display of the user's insanity, resolve, and reserved insanity
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
/datum/mind/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/diagnostic_level = PSYCH_DIAGNOSTIC_NONE)

	//Make sure this is clamped in sane value range
	diagnostic_level = clamp(diagnostic_level, PSYCH_DIAGNOSTIC_NONE, PSYCH_DIAGNOSTIC_MASTER)

	//var/list/data = list()

	var/list/data = get_sanity_data(diagnostic_level)



	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "mind.tmpl", "Mind: [current.real_name]", 800, 700, state = GLOB.interactive_state)
		ui.set_initial_data(data)
		ui.set_auto_update(0)
		ui.open()



/datum/mind/proc/get_sanity_data(var/diagnostic_level = PSYCH_DIAGNOSTIC_NONE)

	//If its been long enough since the last change, update descriptions
	if ((world.time - last_sanity_description_update) >= SANITY_LOG_DESCRIPTION_UPDATE_PERIOD)
		update_sanity_descriptions()

	var/list/data = list()
	data += get_mental_state(diagnostic_level)
	data += get_sanity_log_data(diagnostic_level)

	return data

	/*
		TODO Here:
		Mood
		Effects
		Sanity Log
	*/


//Returns data about the mental state of the user, for UI display
/datum/mind/proc/get_mental_state(var/diagnostic_level = PSYCH_DIAGNOSTIC_NONE)
	var/list/statelist = list()
	var/effective_insanity
	switch (diagnostic_level)
		//At level 0, they only see a description of the combined sanity - resolve score
		if (PSYCH_DIAGNOSTIC_NONE)
			effective_insanity = current.get_insanity(TRUE, FALSE)
			mental_state_string = insanity_description(effective_insanity, mental_state_string)
			statelist["Mental State:"] = mental_state_string

		//At level 1, you see resolve and sanity seperately
		if (PSYCH_DIAGNOSTIC_AMATEUR)
			effective_insanity = current.get_insanity(FALSE, FALSE)
			var/resolve = current.get_resolve()
			mental_state_string = insanity_description(effective_insanity, mental_state_string)

			statelist["Mental State:"] = mental_state_string

			if (resolve)

				resolve_string = insanity_description(resolve, resolve_string)
				statelist["Resolve"] = resolve_string

		//At level 2, you see precise values
		if (PSYCH_DIAGNOSTIC_AMATEUR)
			effective_insanity = current.get_insanity(FALSE, FALSE)
			var/resolve = current.get_resolve()
			mental_state_string = insanity_description(effective_insanity, mental_state_string)

			statelist["Mental State:"] = "[mental_state_string] ([effective_insanity])"

			if (resolve)

				resolve_string = insanity_description(resolve, resolve_string)
				statelist["Resolve"] = "[resolve_string] ([resolve])"


		//At level 3+, you see the reserved insanity too
		if (PSYCH_DIAGNOSTIC_PROFESSIONAL to PSYCH_DIAGNOSTIC_MASTER)
			effective_insanity = current.get_insanity(FALSE, FALSE)
			var/reserve = current.get_insanity(FALSE, TRUE)
			reserve = (effective_insanity - reserve)

			var/resolve = current.get_resolve()
			mental_state_string = insanity_description(effective_insanity, mental_state_string)

			statelist["Mental State:"] = "[mental_state_string] ([effective_insanity][reserve ? "-[reserve]" : ""])"

			if (resolve)

				resolve_string = insanity_description(resolve, resolve_string)
				statelist["Resolve"] = "[resolve_string] ([resolve])"

	//We're done with this data
	return list("insanity" = statelist)



/datum/mind/proc/get_sanity_log_data(var/diagnostic_level = PSYCH_DIAGNOSTIC_NONE)
	if (!sanity_log_data)
		sanity_log_data = list()
		/*typepath = list("last" = 0, "frequency" = 0, "total" = 0, "desc" = source.get_description())
			The sanity log is laid out like this, and automagically kept in order.
			We will convert each record into a line of coloured text
		*/
		for (var/typepath in sanity_log)
			var/list/data = sanity_log[typepath]

			//Okay what color is the text going to be? This is based on a time delta of how recently a thing happened
			var/last_time = text2num(data["last"])
			var/color = sanity_log_time_color(world.time - last_time)
			//var/text = "<span style=\"color: [color];\">[data["last"]]</span>"

			sanity_log_data += list(list("desc" = data["desc"], "color" = color, "total" = round(data["total"])))


	return list("log" = sanity_log_data)

/*
	Some example code for reference, couldnt put this in the template file
{{for data.parent_list :parent_value:parent_index}}
  {{for parent_value.child_list :child_value:child_index}}
    {{for child_value.grandchild_list :grandchild_value:grandchild_index}}
      etc.



  ChaosAlphaToday at 3:32 PM
that'd be the opacity css property
however I believe it was not well supported on older versions of IE
so it might not work in the byond browser window
depending on the element you try to apply it on
for IE 5-7, apparently you had to use filter: alpha(opacity=50);
for a 0.5 alpha
*/