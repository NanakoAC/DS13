/*
	A sanity "check" is an event which occurs periodically, or under certain circumstances, to see if someone should have new sanity
	effects added to them.

	Overview:
	-----------
	By default, sanity checks occur once every certain time period, approximately once a minute.
	In addition, sanity checks occur instantly whenever someone is subjected to an acute source of sanity damage.
	IE, witnessing something awful

	There is a small cooldown on this instant occurrence (5 seconds?) to prevent spam


	When a sanity check happens, a random probability is rolled to see if a new effect should be applied right now.
	This probability is affected by several factors


	If the probability succeeds, then a new effect is chosen from a huge list of all possible effects, minus those that we don't
	have enough insanity for. The selection of which effect is weighted based on the minimum sanity requirements for each, so it's
	generally more likely that the most severe available effects will be picked, but this is far from guaranteed.

	Once an effect is picked, we check can_apply on it, and can_trigger too if its instant. If these checks return an invalid result,
	then we remove that effect from the list and pick again. Repeat until we find one that can be applied


	Cooldown:
	----------
	First of all, the last sanity effect applied will add a hard minimum cooldown, by setting a minimum world-time until the next
	check is allowed to happen. if that time hasn't arrived yet, we just don't do a check


	Probability:
	------------
	The probability that an effect will be applied at each check is primarily based on the victim's insanity value.
	1% chance per 10 points, ish

	However, we don't use insanity as is, we use a modified value of it. Equal to
	Insanity - Reserved Insanity - Courage

	Some insanity is reserved by existing applied effects, so generally the more effects you already have,
	the lower the odds that new ones will be added


	Thresholds and Picking:
	------------------------
	To get a list of things to pick, we first make a copy of the entire global list of all possible sanity effects. #
	This is an assoc list in the format list(effect_datum = minimum_insanity)
	This is sorted by the minimum insanity in ascending order

	To figure out which ones we meet the minimum for, we use a value equal to insanity - courage.
	Reserved insanity is NOT factored into this calculation, intentionally.

	Then we chop off the bottom of the list, excluding all those which have a minimum value higher than what we just calculated.

	With what's left, we do pickweight to grab one, this weights towards the higher value


	Extra Prob:
	-----------
	Passing in a number here adds it to the probability of the sanity check, making it more or less likely that an effect will be chosen
*/
/mob/living/carbon/human/proc/sanity_check(var/extra_prob = 0)

	//Cooldown
	if (world.time < next_sanity_check)
		return

	//Alright, now lets get the sanity we use for probability calculations
	var/prob_sanity = get_insanity(TRUE, TRUE) * SANITY_PROBABILITY_FACTOR	//True to calculate both courage and reserve

	prob_sanity += SANITY_PROBABILITY_BASE
	prob_sanity += extra_prob

	//Now the check
	if (!prob(prob_sanity))
		return


	//Alright, we are going to add an effect.Now lets get our threshold
	var/sanity_threshold = get_insanity(TRUE, FALSE)	//This value does NOT count reserve, but does count courage


	//And lets get the list of all the possible effects
	var/list/possible_effects = get_threshold_sanity_effect_list(src, sanity_threshold)


	//Now we have a list of the effects we meet the threshold for, we're going to find one
	var/datum/extension/sanity_effect/chosen = null	//The final selection, only set once we're certain
	var/list/backup_possible_effects = list()	//This temporary list holds effects that are valid but not ideal.
	var/done = FALSE	//Used to get out of the loop
	while (!done)
		//Safety checks first

		//If we ran out of options, we have failed
		if (!length(possible_effects))
			done = TRUE
			continue

		//The selection is weighted by the minimum sanity, so more severe effects are more common
		var/datum/extension/sanity_effect/candidate = pickweight(possible_effects)

		var/failed = FALSE
		//First of all, can it be applied, we do this for all of them
		var/apply_check = candidate.can_apply(src)

		//If any check returns not ideal, and none of them are invalid/never, this is set true
		var/not_ideal = FALSE

		switch(apply_check)
			if (CHECK_NEVER, CHECK_INVALID)
				failed = TRUE
			if (CHECK_NOT_IDEAL)
				not_ideal = TRUE


		//Secondly, if its instant we need to also check can_trigger
		if (candidate.instant && !failed)
			var/trigger_check = candidate.can_trigger(src)
			switch(trigger_check)
				if (CHECK_NEVER, CHECK_INVALID)
					failed = TRUE
				if (CHECK_NOT_IDEAL)
					not_ideal = TRUE


		//Now lets check the compiled results
		if (failed)
			//Remove from possible options
			possible_effects -= candidate
		else if (not_ideal)
			possible_effects -= candidate
			//Plan B
			backup_possible_effects.[candidate] = possible_effects[candidate]

		else
			//If we get here, we found an ideal effect
			chosen = candidate
			done = TRUE



	//If nothing is chosen yet, its time for plan B
	//We have already validity checked these and know for sure they are valid to apply
	if (!chosen && length(backup_possible_effects))
		chosen = pickweight(backup_possible_effects)

	//If we still somehow got none, then its a failure
	if (!chosen)
		return

	apply_sanity_effect(chosen, FALSE)



/*
	Actually puts a specific effect on a mob.
	The effect var can either be a typepath, or a sanity effect extension
*/
/mob/living/carbon/human/proc/apply_sanity_effect(var/effect, var/safety = TRUE)
	//If we've been given an extension, assign it appropriately
	var/datum/extension/sanity_effect/example
	var/typepath
	if(istype(effect, /datum/extension/sanity_effect))
		example = effect
		typepath = example.type
	else
		typepath = effect
		//In the case that we've been passed a typepath, do we need to go fetch an example reference?
		//Only if we're gonna use it for safety checks
		if (safety)
			for (var/datum/extension/sanity_effect/E as anything in GLOB.all_sanity_effects)
				if (E.type == typepath)
					example = E
					break


	//Alright, safety checking, if its necessary
	if (safety)
		if (!example)
			return FALSE

		switch(example.can_apply(src))
			if (CHECK_NEVER, CHECK_INVALID)
				return FALSE

		if (example.instant)
			switch(example.can_trigger(src))
				if (CHECK_NEVER, CHECK_INVALID)
					return FALSE

	//If we are here, we've passed the safety checks, lets do this!
	set_extension(src, typepath)	//Boom, done
	return TRUE



/*
	Returns a list of all sanity effects that we meet the minimum insanity requirement for.
	Does not do any additional validity or checking on them, that comes later
*/
/proc/get_threshold_sanity_effect_list(var/mob/living/carbon/human/subject, var/sanity_threshold)
	var/first_affordable = 1
	var/list/possible = list()

	//Possible future todo:
	//Make a preliminary copy and modify it based on the subject

	for (first_affordable in 1 to length(GLOB.all_sanity_effects))
		var/requirement = GLOB.all_sanity_effects[first_affordable]


		if (requirement < sanity_threshold)
			//We've found one we can afford! Since they're in descending order, it means we can afford the rest of the list too
			possible = GLOB.all_sanity_effects.Copy(first_affordable)


	//Possible todo: Farther modifications here

	return possible