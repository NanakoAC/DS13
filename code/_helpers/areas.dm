/*
	List generation helpers
*/
/proc/get_filtered_areas(var/list/predicates = list(/proc/is_area_with_turf))
	. = list()
	if(!predicates)
		return
	if(!islist(predicates))
		predicates = list(predicates)
	for(var/area/A)
		if(all_predicates_true(list(A), predicates))
			. += A

/proc/get_area_turfs(var/area/A, var/list/predicates)
	. = new/list()
	A = istype(A) ? A : locate(A)
	if(!A)
		return
	for(var/turf/T in A.contents)
		if(!predicates || all_predicates_true(list(T), predicates))
			. += T

/proc/get_subarea_turfs(var/area/A, var/list/predicates)
	. = new/list()
	A = istype(A) ? A.type : A
	if(!A)
		return
	for(var/sub_area_type in typesof(A))
		var/area/sub_area = locate(sub_area_type)
		for(var/turf/T in sub_area.contents)
			if(!predicates || all_predicates_true(list(T), predicates))
				. += T

/proc/group_areas_by_name(var/list/predicates)
	. = list()
	for(var/area/A in get_filtered_areas(predicates))
		group_by(., A.name, A)

/proc/group_areas_by_z_level(var/list/predicates)
	. = list()
	for(var/area/A in get_filtered_areas(predicates))
		group_by(., num2text(A.z), A)

/*
	Pick helpers
*/
/proc/pick_subarea_turf(var/areatype, var/list/predicates)
	var/list/turfs = get_subarea_turfs(areatype, predicates)
	if(turfs && turfs.len)
		return pick(turfs)

/proc/pick_area_turf(var/areatype, var/list/predicates)
	var/list/turfs = get_area_turfs(areatype, predicates)
	if(turfs && turfs.len)
		return pick(turfs)

/proc/pick_area(var/list/predicates)
	var/list/areas = get_filtered_areas(predicates)
	if(areas && areas.len)
		. = pick(areas)

/proc/pick_area_and_turf(var/list/area_predicates, var/list/turf_predicates)
	var/area/A = pick_area(area_predicates)
	if(!A)
		return
	return pick_area_turf(A, turf_predicates)

/*
	Predicate Helpers
*/
/proc/is_station_area(var/area/A)
	. = isStationLevel(A.z)

/proc/is_contact_area(var/area/A)
	. = isContactLevel(A.z)

/proc/is_player_area(var/area/A)
	. = isPlayerLevel(A.z)

/proc/is_not_space_area(var/area/A)
	. = !istype(A,/area/space)

/proc/is_not_shuttle_area(var/area/A)
	. = !istype(A,/area/shuttle)

/proc/is_area_with_turf(var/area/A)
	. = isnum(A.x)

/proc/is_area_without_turf(var/area/A)
	. = !is_area_with_turf(A)

/proc/is_maint_area(var/area/A)
	. = istype(A,/area/maintenance)

/proc/is_coherent_area(var/area/A)
	return !is_type_in_list(A, GLOB.using_map.area_coherency_test_exempt_areas)

/proc/area_corrupted(var/atom/A, var/require_support = TRUE)
	var/area/T = get_area(A)
	for (var/obj/effect/vine/corruption/C in T)
		if (!require_support || C.is_supported())
			return TRUE


	return FALSE

/proc/area_contains_necromorphs(var/atom/A)
	var/area/T = get_area(A)
	for (var/mob/living/L in T)
		if (L.stat != DEAD && L.is_necromorph())
			return TRUE

	return FALSE


//A useful proc for events.
//This returns a random area of the station which is meaningful. Ie, a room somewhere
//If filter_players is true, it will only pick an area that has no human players in it
	//This is useful for spawning, you dont want people to see things pop into existence
//If filter_maintenance is true, maintenance areas won't be chosen
/proc/random_ship_area(var/filter_players = FALSE, var/filter_maintenance = FALSE, var/filter_critical = FALSE)
	var/list/possible = list()
	for(var/Y in GLOB.ship_areas)
		var/area/A = Y
		if (istype(A, /area/shuttle))
			continue

		if (filter_maintenance && A.is_maintenance)
			continue
		/*
		if (filter_critical && (A.flags & AREA_FLAG_CRITICAL))
			continue

		if (istype(A, /area/turret_protected))
			continue
		*/

		if(filter_players)
			var/should_continue = FALSE
			for(var/mob/living/carbon/human/H in GLOB.human_mob_list)
				if(!H.client)
					continue
				if(A == get_area(H))
					should_continue = TRUE
					break

			if(should_continue)
				continue

		possible += A

	return pick(possible)

/area/proc/random_space()
	var/list/turfs = list()
	for(var/turf/simulated/floor/F in src.contents)
		if(turf_clear(F))
			turfs += F
	if (turfs.len)
		return pick(turfs)
	else return null


/area/proc/get_spaces()
	var/list/turfs = list()
	for(var/turf/simulated/floor/F in src.contents)
		if(turf_clear(F))
			turfs += F

	return turfs


/*
	Simple area version of atmos unsafe that just tests the first floor tile
	This makes the assumption that atmosphere is uniform across an area. Which is true 99% of the time.
	If those edge cases are important, this may not be suitable
*/
/proc/is_area_atmos_unsafe(var/area/A)
	for (var/turf/simulated/floor/F in A)
		return is_turf_atmos_unsafe(F)
	return TRUE

GLOBAL_LIST_INIT(is_station_but_not_space_or_shuttle_area, list(/proc/is_station_area, /proc/is_not_space_area, /proc/is_not_shuttle_area))

GLOBAL_LIST_INIT(is_contact_but_not_space_or_shuttle_area, list(/proc/is_contact_area, /proc/is_not_space_area, /proc/is_not_shuttle_area))

GLOBAL_LIST_INIT(is_player_but_not_space_or_shuttle_area, list(/proc/is_player_area, /proc/is_not_space_area, /proc/is_not_shuttle_area))

GLOBAL_LIST_INIT(is_station_area, list(/proc/is_station_area))

GLOBAL_LIST_INIT(is_station_and_maint_area, list(/proc/is_station_area, /proc/is_maint_area))



/*
	Misc Helpers
*/
#define teleportlocs area_repository.get_areas_by_name_and_coords(GLOB.is_player_but_not_space_or_shuttle_area)
#define stationlocs area_repository.get_areas_by_name(GLOB.is_player_but_not_space_or_shuttle_area)
#define wizteleportlocs area_repository.get_areas_by_name(GLOB.is_station_area)
#define maintlocs area_repository.get_areas_by_name(GLOB.is_station_and_maint_area)
#define wizportallocs area_repository.get_areas_by_name(GLOB.is_station_but_not_space_or_shuttle_area)
