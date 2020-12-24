/*
	Wrong door causes you to end up in the wrong place when you walk through a door
	The name is an oblique Cultist Simulator Reference

	How it works:
	1. We detect when the victim is about to walk through a door, by them bumping into it
	2. We loop through the doors in the world, until we find one with a matching direction
*/

/datum/extension/sanity_effect/wrong_door
	name = "Wrong Door"
	clinical_name = "Sleepwalking"
	required_insanity = SANITY_TIER_MODERATE
	reserve = SANITY_RESERVE_MODERATE

	cooldown = SANITY_COOLDOWN_MODERATE
	fade_duration = 5 MINUTES

	messages_trigger_end = list("How the hell did I get here?", "I just came through a door", "WRONG DOOR", "Wait, what?")
	var/obj/machinery/door/entry_door
	var/obj/machinery/door/exit_door

	//If the subject bumps into a door but doesn't immediately go into it, we allow them to take this many steps before we give up
	var/allowed_moves = 10

/datum/extension/sanity_effect/wrong_door/Destroy()
	GLOB.bump_event.unregister(subject, src, /datum/extension/sanity_effect/wrong_door/proc/subject_bump)
	GLOB.moved_event.unregister(subject, src, /datum/extension/sanity_effect/wrong_door/proc/subject_move)
	.=..()

/datum/extension/sanity_effect/wrong_door/applied()
	.=..()
	GLOB.bump_event.register(subject, src, /datum/extension/sanity_effect/wrong_door/proc/subject_bump)


/datum/extension/sanity_effect/wrong_door/proc/subject_bump(var/atom/movable/mover, var/atom/obstacle)
	if (istype(obstacle, /obj/machinery/door))
		var/obj/machinery/door/candidate = obstacle
		//Lets make sure this door is viable

		//If the door is closed at this second, we need to check that it will open
		if (candidate.density)
			//Is it able to operate
			if (!candidate.can_open())
				return

			//Can their ID open it?
			if (!candidate.allowed(mover))
				return

		//Alright this door is viable
		entry_door = candidate

		stop_tracking()
		GLOB.moved_event.register(subject, src, /datum/extension/sanity_effect/wrong_door/proc/subject_move)

/datum/extension/sanity_effect/wrong_door/proc/subject_move(var/atom/movable/mover, var/oldloc, var/newloc)
	allowed_moves--
	if (entry_door)
		//If they have walked through the door, we're clear to start
		if (newloc == get_turf(entry_door))
			attempt_trigger()

	if (!allowed_moves || !entry_door)
		stop_tracking()

/datum/extension/sanity_effect/wrong_door/proc/stop_tracking()
	GLOB.moved_event.unregister(subject, src, /datum/extension/sanity_effect/wrong_door/proc/subject_move)
	allowed_moves = initial(allowed_moves)

/*
	Visibility checking.
	Call parent first, and we only care to overrule if it returned a possibly valid result
*/
/datum/extension/sanity_effect/wrong_door/can_trigger(var/mob/living/carbon/human/H)

	.=..()
	if (. > CHECK_INVALID)
		//Alright, lets see if anyone is looking
		if (H.is_seen())
			return CHECK_INVALID


/datum/extension/sanity_effect/wrong_door/trigger_mob_effects()
	//Alright, we are going
	find_exit_door()
	if (exit_door)
		exit_door.open()
		sleep(2)
		subject.forceMove(get_turf(exit_door))



/datum/extension/sanity_effect/wrong_door/proc/find_exit_door()
	exit_door = null

	//This is expensive
	var/list/doors = list()
	for (var/obj/machinery/door/candidate in world)
		doors += candidate

	var/viable_directions
	switch (entry_door.dir)
		if (NORTH, SOUTH)
			viable_directions = NORTH | SOUTH
		if (EAST, WEST)
			viable_directions = EAST | WEST


	//Lets test random doors until we find a viable one
	while (!exit_door && length(doors))
		var/obj/machinery/door/candidate = pick_n_take(doors)

		//Lets not drop into space
		if (is_turf_atmos_unsafe(get_turf(candidate)))
			continue

		//It must face the same way as our origin, or opposite
		if (!(candidate.dir & viable_directions))
			continue


		var/turf/T = get_turf(candidate)

		//Lets not teleport to admin areas
		if (!isOnShipLevel(T))
			continue

		//It must be the only dense thing in its turf, so we dont emerge from window shutters
		var/clear = TRUE
		for (var/atom/A in T)
			if (A == candidate)
				continue

			if (A.density)
				clear = FALSE
				break
		if (!clear)
			continue

		//It must not currently be seen
		if (candidate.is_seen())
			continue

		exit_door = candidate