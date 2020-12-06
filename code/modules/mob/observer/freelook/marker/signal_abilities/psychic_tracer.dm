/*
	Bugs a target crewmember, allowing you to see things around them

	When initially cast, it reveals a wide area around the victim. The radius gradually shrinks as the duration depletes.
	The duration depletes faster for each other visible crewmember around the host, so it is less effective for spying on large groups, but good for tracking loners

	Future Plans:
	Once the system is available, make duration based on psych damage instead. Lasting longer on people who are less sane
*/
#define TRACER_MAX_RANGE	10

/datum/signal_ability/psychic_tracer
	name = "Psychic Tracer"
	id = "psychic_tracer"
	desc = "Plants a psychic tracer on a target mob, causing them to act as a visual relay for necrovision. This allows signals to see in a radius around them. <br>\
	This lasts 5 minutes as a baseline, but it wears off more slowly depending on the target's sanity (minus courage). As long as the target has over 300 insanity, this effect is permanant<br>\
	<br>\
	Casting it again on a target who already has a tracer will refresh the duration and range"
	target_string = "any living mob or crewmember"
	energy_cost = 110
	require_corruption = FALSE
	require_necrovision = TRUE
	autotarget_range = 1
	target_types = list(/mob/living)

	targeting_method	=	TARGET_CLICK




/datum/signal_ability/psychic_tracer/on_cast(var/mob/user, var/atom/target, var/list/data)
	var/datum/extension/psychic_tracer/MW = get_extension(target, /datum/extension/psychic_tracer)
	if (istype(MW))
		MW.refresh_duration()
		link_necromorphs_to(SPAN_NOTICE("Refreshed duration on Psychic Tracer attached to [target] at LINK"), target)
	else
		MW = set_extension(target, /datum/extension/psychic_tracer)
		link_necromorphs_to(SPAN_NOTICE("[user] planted a psychic tracer on [target] at LINK"), target)




/*
	Atom
	This is just a placeholder because visualnet and moved observation code requires a movable atom as a point of reference
*/
/obj/effect/psychic_tracer
	var/datum/extension/psychic_tracer/EM
	visualnet_range = TRACER_MAX_RANGE


/obj/effect/psychic_tracer/get_visualnet_tiles(var/datum/visualnet/network)
	return EM.get_visualnet_tiles(network)



/*
	Extension: Added to the infected mob
*/
/datum/extension/psychic_tracer
	name = "Psychic Tracer"
	expected_type = /mob/living
	flags = EXTENSION_FLAG_IMMEDIATE
	base_type = /datum/extension/psychic_tracer

	var/mob/living/carbon/human/H
	var/mob/living/L
	var/tick_interval_seconds = 4	//This serves a dual purpose
	var/initial_duration = 5 MINUTES
	var/initial_radius = TRACER_MAX_RANGE
	var/radius

	var/duration
	var/obj/effect/psychic_tracer/object

	//Crew
	var/crew_multiplier = 0.5	//50% faster for each visible crewmember

	var/permanant_threshold = 300



/datum/extension/psychic_tracer/New(var/datum/holder)
	.=..()
	L = holder
	if (ishuman(holder))
		H = holder
		//Deals a bit of sanity damage on application, but not on refreshing
		H.add_active_insanity(/datum/sanity_source/gaze, SANITY_DAMAGE_ACTIVE_MID)
	duration = initial_duration
	addtimer(CALLBACK(src, /datum/extension/psychic_tracer/proc/tick), tick_interval_seconds SECONDS)
	object = new /obj/effect/psychic_tracer(holder)
	object.EM = src

	GLOB.necrovision.add_source(object, TRUE, TRUE)


/datum/extension/psychic_tracer/proc/tick()
	if (QDELETED(L) || L.stat == DEAD)
		stop()
		return

	var/subtract_multiplier
	var/insanity = L.get_insanity(TRUE)
	if (insanity >= permanant_threshold)
		subtract_multiplier = 1
	else if (!insanity || insanity < 0)
		subtract_multiplier = 0
	else
		subtract_multiplier = insanity / permanant_threshold

	change_duration(-((tick_interval_seconds SECONDS) * (1 - subtract_multiplier)))
	if (duration > 0)
		addtimer(CALLBACK(src, /datum/extension/psychic_tracer/proc/tick), tick_interval_seconds SECONDS)



/datum/extension/psychic_tracer/proc/refresh_duration()
	change_duration(initial_duration - duration)



/datum/extension/psychic_tracer/proc/change_duration(var/change)
	duration += change

	if (duration <= 0)
		stop()
		return

	//Lets calculate the radius after this change
	var/percent = duration / initial_duration
	var/newradius = Ceiling(initial_radius * percent)
	set_radius(newradius)

/datum/extension/psychic_tracer/proc/set_radius(var/newradius)
	//Only update things if the radius has changed
	if (radius == newradius)
		return

	radius = newradius

	//Remove and re-add ourselves to update the necrovision
	GLOB.necrovision.remove_source(object, TRUE, TRUE)
	object.visualnet_range = radius
	GLOB.necrovision.add_source(object, TRUE, TRUE)

/datum/extension/psychic_tracer/get_visualnet_tiles(var/datum/visualnet/network)
	return L.turfs_in_view(radius)


/datum/extension/psychic_tracer/proc/stop()
	remove_extension(holder, base_type)

/datum/extension/psychic_tracer/Destroy()
	QDEL_NULL(object)
	GLOB.necrovision.remove_source(src, TRUE, TRUE)
	.=..()



#undef TRACER_MAX_RANGE