/*
	Claustrophobia is a simple compulsion which makes the user afraid of enclosed spaces

	Periodically it evaluates the surroundings:
	To start, the subject has a set negative number of space points. Then we add points based on the turfs that are visible
		1 point for every clear floor turf
		0.5 points for every not-clear floor (contains a dense object)
		2 points for every open space
		3 points for every space/void tile

	If the user is currently in an outdoor area (space, aegis VII surface) each of these scores are doubled

	If the resulting total is a positive number, the compulsion gains progress. Vice Versa if negative


*/

/datum/extension/sanity_effect/compulsion/claustrophobia
	name = "Claustrophobia"
	clinical_name = "Claustrophobia"
	/*
		This is roughly half of 169, which is the number of tiles onscreen with a 6 view range
	*/
	var/starting_score = -85

	//Wearing a helmet that covers your face is pretty claustrophobic
	var/helmet_penalty = -15

	//Hiding inside a locker, or similar object, causes a huge penalty
	var/contained_penalty = -40

	//We gain or lose this many points of progress, per point of space, per check
	var/progress_per_point = 0.05

	//Your vision radius is reduced
	statmods = list(STATMOD_VIEW_RANGE = -1)

	progress_message_interval = 50 SECONDS

	message_progress_negative = list("The walls are closing in!",
	 "This place is so dark and oppressive.",
	 "I feel like I can't breathe in here, I need to get some space",
	 "Gotta get out. Gotta get out. GOTTA GET OUT!",
	 "Will I ever see the stars again?",
	 "Will I ever stand under an open sky again?",
	 "Am I doomed to die in this cramped iron box?",
	 "It's too cramped around here.",
	 "I should find a window, I want to see the stars",
	 "I need room to breathe.")

	message_progress_positive = list("Finally, room to stretch, and breathe!",
	 "It's so light and airy here, I never want to leave!",
	 "Deep breaths, I'm okay now...",
	 "The stars are so pretty tonight",
	 "This is good, just got to stay in an open area.")




/datum/extension/sanity_effect/compulsion/claustrophobia/check_progress()
	var/score = starting_score

	//If the face is covered, things feel worse
	var/obj/item/clothing/facecovering = subject.get_covering_equipped_item(FACE)
	if (facecovering)

		//Lets make this message less spammy
		if (prob(40))
			to_chat(subject, "This [facecovering] is stifling, I should really take it off")
		score += helmet_penalty


	if (!istype(subject.loc, /turf))
		score += contained_penalty


	//We will batch all positive gains, to multiply them later
	var/positive_subtotal = 0
	var/list/turfs = subject.turfs_in_view()
	var/seen_external = FALSE
	for (var/turf/T as anything in turfs)
		if (iswall(T))
			continue

		else if (isfloor(T))
			if (turf_clear(T))
				positive_subtotal += 1
			else
				positive_subtotal += 0.5

			//Corruption makes it less spacious
			if (turf_corrupted(T))
				positive_subtotal -= 0.25

		else if (istype(T, /turf/space))
			positive_subtotal += 3	//Space is good
		else if (istype(T, /turf/simulated/open))
			positive_subtotal += 2

		if (!seen_external && turf_is_external(T))
			seen_external = TRUE


	//Alright now, are we outside
	var/external = turf_is_external(get_turf(subject))
	if (external)
		//Being outside doubles the positive score
		positive_subtotal *= 2


	//Here we have the final score, now
	score += positive_subtotal
	world << "Score is [score]"
	var/progress_change = score * progress_per_point

	change_progress(progress_change)

	//Darken the screen edges if you're in a claustrophobic area
	subject.set_fullscreen((progress_change < 0),"vignette", /obj/screen/fullscreen/fishbed)


	//If we are not currently outside, but we can see an outside turf, we are filled with a longing to go out there
	if (!external && seen_external)
		to_chat(subject, pick(list("It looks so beautiful and spacious outside", "I'm sick of being cooped up in here. I should go out...", "I'm suffocating in here, I need to be out there")))