/*
	Handles global variables and asynchronous procs related to sanity
*/
SUBSYSTEM_DEF(sanity)
	name = "Sanity"
	init_order = SS_INIT_DEFAULT
	flags = SS_NO_FIRE

	/*
		This is a list of atoms which want to register themselves to a horror beacon as insanity sources
	*/
	var/list/atoms_awaiting_beacon = list()

	var/processing_passive_atoms = FALSE


/*
	Procs attached to generic atoms

	This is called by any atom to register itself as a passive insanity source. Such as a bloodstain or a corpse
	Atoms are not allowed to specify anything other than a source. If they want to have unique values for damage or limit
	they must make a new subtype of sanity source

	Make sure the atom is in the correct location before calling this, and try not to move it afterwards
	If the atom is likely to move around a lot, use register_mobile_passive_sanity_source instead. This version is optimised for
	things which rarely move

	It will search for a nearby horror beacon and register itself to that. if one does not exist, one will be created
*/
/datum/controller/subsystem/sanity/proc/register_passive_sanity_source(var/atom/thing, var/sourcetype)
	atoms_awaiting_beacon[thing] = sourcetype
	if (!processing_passive_atoms)
		process_passive_sanity_sources()

/datum/controller/subsystem/sanity/proc/process_passive_sanity_sources()
	set waitfor = FALSE

	if (processing_passive_atoms)
		return
	processing_passive_atoms = TRUE
	while (LAZYLEN(atoms_awaiting_beacon))
		//Grab the first thing in the list
		var/atom/thing = atoms_awaiting_beacon[1]
		//It's gone? Skip it then
		if (QDELETED(thing))
			atoms_awaiting_beacon -= thing
			continue

		var/sourcetype = atoms_awaiting_beacon[thing]
		atoms_awaiting_beacon -= thing




		var/area/A = get_area(thing)
		//We must be in nullspace
		if (!A)
			continue


		var/obj/horror_beacon/selected_beacon

		//Lets get a viewlist
		var/viewlist = dview(world.view, get_turf(thing))
		//And loop through all the existing beacons
		for (var/obj/horror_beacon/HB as anything in A.horror_beacons)
			var/turf/T = get_turf(HB)
			if ((T in viewlist))
				selected_beacon = HB
				break


		/*
			Okay now HERE is where the really expensive work happens,
			this is why we're using a subsystem with async processing in the first place

			We're going to make a new beacon, and we'll find the turf with the best vantage point to place it in
		*/
		if (!selected_beacon)
			var/turf/T = find_best_viewpoint(get_turf(thing))
			if (T)
				selected_beacon = new(T)

		//We should now have a beacon to work with
		if (selected_beacon)
			selected_beacon.register(thing, sourcetype)

	processing_passive_atoms = FALSE