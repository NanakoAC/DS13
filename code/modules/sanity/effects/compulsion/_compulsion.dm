/*
	A compulsion is an interactive sanity effect. In addition to simply doing things to you, they also give tasks, objectives.
	Completing the objectives builds progress while ignoring them reduces it.

	When the compulsion ends, you are rewarded or punished based on your progress.
	Most compulsions can end in one of three ways
	1. Bad end. Progress reaches -100, you get the worst possible punishment
	2. Good end, progress reaches 100, you did well
	3. Neutral. The duration expires without progress reaching either extreme

	These rules are not universal, some have infinite duration and cannot expire.
	Some don't gain or don't lose progress, and one of the first two is unavailable
*/
/datum/extension/sanity_effect/compulsion
	ancestor_type = /datum/extension/sanity_effect/compulsion	//Used for startup filtering

	var/progress = 0

	var/min_progress = -100	//Bad end
	var/max_progress = 100	//Good end

	//Default value will take 15 minutes of being ignored to reach min progress
	var/progress_tick = COMPULSION_PROGRESS_SLOW

	apply_duration_max = 20 MINUTES	//Neutral end

	//This can be set false if we dont need a progress tick AND we don't use progress check interval
	process_while_dormant = TRUE


	/*
		Every X ticks, we call progress_check to see if the user has done something towards their goal
	*/
	var/progress_check_interval = 60


	//When giving messages about progress, lets not make it spammy
	var/progress_message_interval = 10 SECONDS
	var/next_progress_message


	/*
		Message vars
	*/
	var/message_progress_negative

	var/message_progress_positive

	var/message_good_end = list("I feel as if a great weight has been lifted off my shoulders", "For the first time in a while, my mind feels clear")

	var/message_bad_end = list("My failures compound within my mind, crushing, oppressive", "I am sliding down a long, dark slope, with no end in sight", "Bit by bit, I feel myself slipping away")

	var/message_neutral_end = list("I feel numb",  "I suppose things could have gone worse")



/datum/extension/sanity_effect/compulsion/can_apply(var/mob/living/carbon/human/victim)
	.=..()
	if (. > CHECK_INVALID)
		var/existing_compulsions = 0
		//To prevent things getting too silly, there is a cap on the number of compulsion effects a mob can suffer from at once
		for (var/datum/extension/sanity_effect/compulsion/C in victim.sanity_effects)

			//Fading effects don't count
			if (C.status == STATUS_FADING)
				continue

			existing_compulsions++
		if (existing_compulsions >= (COMPULSION_LIMIT - 1))
			return CHECK_INVALID

/datum/extension/sanity_effect/compulsion/Process()
	.=..()
	change_progress(progress_tick)
	if (progress_check_interval && ((ticks % progress_check_interval) == 0))
		check_progress()


/datum/extension/sanity_effect/compulsion/can_stop_processing()
	if (progress > min_progress && progress < max_progress)
		return FALSE

	.=..()



/datum/extension/sanity_effect/compulsion/proc/change_progress(var/quantity)
	if (ended)
		return
	progress += quantity


	check_ending()
	if (!ended)
		progress_message((quantity > 0))

/datum/extension/sanity_effect/compulsion/proc/check_ending()
	if (ended)
		return
	if (progress <= min_progress)
		bad_end()
	if (progress >= max_progress)
		good_end()


/*
	Progress Messages
*/
/datum/extension/sanity_effect/compulsion/proc/progress_message(var/positive)
	var/spanclass
	var/list/messages
	if (positive)
		messages = message_progress_positive
		spanclass = "notice"
	else
		messages = message_progress_negative
		spanclass = "warning"


	if (!messages)
		return

	if (world.time < next_progress_message)
		return

	next_progress_message = world.time + progress_message_interval
	var/message = span(spanclass, pick(messages))
	to_chat(subject, message)