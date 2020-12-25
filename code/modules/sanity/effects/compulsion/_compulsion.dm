/*
	A compulsion is an interactive sanity effect. In addition to simply doing things to you, they also give tasks, objectives.
	Completing the objectives builds progress while ignoring them reduces it.

	When the compulsion ends, you are rewarded or punished based on your progress.
	Most compulsions can end in one of three ways
	1. Bad end. Progress reaches -100, you get the worst possible punishment
	2. Good end, progress reaches 100, you did well
	3. Neutral. The duration expires without progress reaching either extreme

	These are not universal, some have infinite duration and cannot expire.
	Some don't gain or lose progress, and one of the first two is unavailable
*/
/datum/extension/sanity_effect/compulsion
	ancestor_type = /datum/extension/sanity_effect/compulsion	//Used for startup filtering

	var/progress = 0

	var/min_progress = -100
	var/max_progress = 100

	apply_duration_max = 20 MINUTES