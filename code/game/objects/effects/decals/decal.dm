/obj/effect/decal
	plane = ABOVE_TURF_PLANE
	layer = DECAL_LAYER
	biomass = 0	//Used for blood and other organic smears
	anchored = TRUE	//Why was this not set true
	can_block_movement = FALSE //On floor
	var/cleanable = FALSE
	var/passive_sanity_type = null	//If set, register this as a source of passive sanity damage when created

/obj/effect/decal/Initialize()
	if (passive_sanity_type)
		register_passive_sanity_source(passive_sanity_type)

/obj/effect/decal/fall_damage()
	return 0

/obj/effect/decal/is_burnable()
	return TRUE

/obj/effect/decal/lava_act()
	. = !throwing ? ..() : FALSE

/obj/effect/decal/clean_blood(var/ignore = 0)
	if(!ignore && cleanable)
		qdel(src)
		return
	..()