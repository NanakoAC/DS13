/*
	Sanity scan is an extension which can be added to any object to make it emit an aura of constant sanity damage

	There are two main variants of it.
		The normal one is designed for stationary sources. Things which will move very little, if at all. This is suitable for horror
		beacons which collate gore, bloodstains, etc. Such things should not move more than once every couple minutes

		The Active variant is designed for highly mobile sources, ie mobs. Things that may move several times a second
*/
/datum/extension/sanity_scan
	flags = EXTENSION_FLAG_IMMEDIATE
	var/atom/epicentre	//Where our visibility checks are done from

	//This is an assoc list in the format atom = sanity_source datum
	//It is altered through the add/remove source procs
	var/list/source_atoms = list()

	//A second list reorganising the above, and collapsing many sources
	//This is an assoc list in the format sanity_source datum = list(sanity_damage, sanity_limit, quantity)
	//This list is autocalculated based on source atoms, and should not be directly modified
	var/list/source_data = list()


	//Humans we're currently terrifying
	var/list/victims = list()

	//If true, run an active scan for potential new victims
	var/active_scan = FALSE
	var/last_active_scan	//World time of the last time we scanned



	var/range = 7

	//The last world time we saw a valid victim
	var/last_victim_seen

	//We need to have last seen a victim longer than this time ago, before we're allowed to stop processing
	//0 by default, but 1 minute for the active scan
	var/last_victim_timeout = 0

/*
	Called when we are no longer valid
*/
/datum/extension/sanity_scan/proc/abort_scan()
	qdel(src)


/datum/extension/sanity_scan/New(var/atom/_epicentre)
	.=..()
	epicentre = _epicentre
	setup_detection()

/datum/extension/sanity_scan/Destroy()
	stop_active_processing()
	.=..()

/*
	We only process when we have at least one valid victim
*/
/datum/extension/sanity_scan/Process()
	recheck_victims()

	scare_victims()

	try_stop_processing()


/*
	For the passive variant, this creates the proximity trigger

*/
/datum/extension/sanity_scan/proc/setup_detection()

/*
	Attempts to register a new human as a victim we'll apply sanity to
*/
/datum/extension/sanity_scan/proc/register_victim(var/mob/living/carbon/human/H)
	if (!istype(H))
		return

	if ((H in victims))
		return

	if (!H.has_sanity())
		return

	victims += H
	last_victim_seen = world.time

	//When we have any victims we enter active mode.
	//This contains its own safety checks so we need no more here
	start_active_processing()



/datum/extension/sanity_scan/proc/unregister_victim(var/mob/living/carbon/human/H)

	if (!(H in victims))
		return

	victims -= H

/*
	Adds a new thing as a source to this scanner. Return true if something was added or removed
	Args:
		Atom: The atom which is scary
		Source: The sanity source datum that the atom is associated with
		Recalculate: Set false to suppress automatically recalculating source data. Use it to prevent infinite loops
*/


//just wrappers to be overridden for the active version
/datum/extension/sanity_scan/proc/start_active_processing()
	if (!is_processing)
		START_PROCESSING(SSobj, src)
		return TRUE


/datum/extension/sanity_scan/proc/stop_active_processing()
	if (is_processing)
		STOP_PROCESSING(SSobj, src)
		return TRUE




/datum/extension/sanity_scan/proc/add_source(var/atom/thing, var/datum/sanity_source/source, var/recalculate = TRUE)
	//Already registered
	if ((thing in source_atoms))
		return

	if (!istype(source))
		source = GLOB.all_sanity_sources[source]

	source_atoms[thing] = source
	//Setup an event to remove the thing from our list if it gets deleted
	GLOB.destroyed_event.register(thing, src, /datum/extension/sanity_scan/proc/remove_source)
	.= TRUE
	if (recalculate)
		recalculate_source_data()


/datum/extension/sanity_scan/proc/remove_source(var/atom/thing, var/recalculate = TRUE)
	if (!(thing in source_atoms))
		return

	source_atoms -= thing

	GLOB.destroyed_event.unregister(thing, src, /datum/extension/sanity_scan/proc/remove_source)
	.= TRUE
	if (recalculate)
		recalculate_source_data()



/datum/extension/sanity_scan/proc/validate_source_atoms()
	for (var/thing in source_atoms)
		if (!is_valid_source_atom(thing))
			remove_source(thing, FALSE) //Pass false to prevent looping

//This proc recalculates the sanity damage we'll apply per tick, per sourcetype.
//All sources of the same type are combined in here
/datum/extension/sanity_scan/proc/recalculate_source_data()

	//Cleanse the list of any bad data
	validate_source_atoms()

	source_data = list()
	for (var/thing in source_atoms)
		var/datum/sanity_source/source = source_atoms[thing]
		var/list/data = source_data[source]
		if (!data)
			//Not filled yet, lets make it
			data = list("sanity_damage" = 0, "sanity_limit" = 0, "quantity" = 0)

		//The damage suffers falloff depending on the number of sources of this type already registered
		var/base_damage = source.sanity_damage
		var/quantity = data["quantity"]
		if (quantity)
			base_damage *= (1 * (source.falloff ** quantity))

		data["sanity_limit"] = source.sanity_limit
		data["sanity_damage"] += base_damage
		data["quantity"] += 1
		source_data[source] = data



//Is it really okay to use this thing as an insanity source?
/datum/extension/sanity_scan/proc/is_valid_source_atom(var/atom/thing)
	.=TRUE

	//If it doesnt exist, then no
	if (QDELETED(thing))
		return FALSE






/*
	Here we recheck all existing victims.
	The active scan will also scan for new victims
*/
/datum/extension/sanity_scan/proc/recheck_victims()
	var/list/viewlist//We'll only make this when we need it

	for (var/mob/living/carbon/human/H as anything in victims)
		var/fail = FALSE
		if (!is_valid_victim(H))
			fail = TRUE

		if (!fail)
			if (!viewlist)
				viewlist = view(range, epicentre)

			var/turf/T = get_turf(H)
			if (!(T in viewlist))
				fail = TRUE

		//If validity failed, remove from the list
		if (fail)
			unregister_victim(H)

	if (active_scan)
		do_active_scan(viewlist)

	//If theres any victims left, update this
	if (LAZYLEN(victims))
		last_victim_seen = world.time


//Checks if this person is valid to be a victim right now.
//Does not check location/distance, that is handled elsewhere
/datum/extension/sanity_scan/proc/is_valid_victim(var/mob/living/carbon/human/H)
	if (!istype(H))
		return FALSE

	//This proc contains checks for being connected, conscious, alive, etc
	if (!H.has_sanity())
		return FALSE

	return TRUE



/*
	This proc scans the area around the epicentre and registers any new victims it can see
	Only the active subtype does this

	A viewlist can optionally be passed in to save on doing another view call
*/
/datum/extension/sanity_scan/proc/do_active_scan(var/list/viewlist)
	last_active_scan = world.time
	if (!viewlist)
		viewlist = view(range, epicentre)

	for (var/mob/living/carbon/human/H in viewlist)
		if (H == epicentre)
			continue
		if (!is_valid_victim(H))
			continue
		register_victim(H)



/*
	This is run after validating the victim list
	Here we apply insanity to all victims who are still valid

	All safety checks are done so we can proceed immediately
*/
/datum/extension/sanity_scan/proc/scare_victims()
	for (var/mob/living/carbon/human/H as anything in victims)
		for (var/datum/sanity_source/source as anything in source_data)
			var/list/data = source_data[source]
			H.add_passive_insanity(source, data["sanity_damage"], data["sanity_limit"], epicentre)


/*
	Called each process step
*/
/datum/extension/sanity_scan/proc/try_stop_processing()
	if (is_processing && can_stop_processing())
		stop_active_processing()



/*
	Can we stop processing?

*/
/datum/extension/sanity_scan/can_stop_processing()
	//If our host atom is gone, screw the other checks and stop immediately
	if (QDELETED(epicentre))
		return TRUE

	//Not if there are any valid victims left
	if (LAZYLEN(victims))
		return FALSE


	//How long has it been since we last saw a valid victim?
	var/last_seen_delta = world.time - last_victim_seen
	//If it hasn't been long enough, we can't rest yet
	if (last_seen_delta < last_victim_timeout)
		return FALSE


	return TRUE