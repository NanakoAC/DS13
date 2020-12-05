/datum/signal_ability/runes
	name = "Bloody Rune"
	id = "rune"
	desc = "Creates a spooky rune in blood, which deals sanity damage to those who look at it. \
	This spell can be cast in visible areas, but the creation of the rune is delayed until nobody has seen the location for ten seconds.\
	It will only appear when no humans are looking"
	target_string = "a wall or floor"
	energy_cost = 16
	require_corruption = FALSE
	autotarget_range = 0
	LOS_block = FALSE	//This is for spooking people, we want them to see it happen
	target_types = list(/turf/simulated)

/datum/signal_ability/runes/on_cast(var/mob/user, var/atom/target, var/list/data)
	GLOB.cult.powerless = TRUE //Just in case. This makes sure the runes don't do anything
	var/turf/T = get_turf(target)

	//This will create the rune only when nobody is looking
	set_extension(T, /datum/extension/create_unseen, /obj/random/rune, 10 SECONDS)




/obj/random/rune
	name = "random rune"
	desc = "This is some random loot."
	icon = 'icons/obj/items.dmi'
	icon_state = "gift3"

/obj/random/rune/item_to_spawn()
	return pickweight(list(/obj/effect/decal/rune/convert,
				/obj/effect/decal/rune/teleport,
				/obj/effect/decal/rune/tome,
				/obj/effect/decal/rune/wall,
				/obj/effect/decal/rune/ajorney,
				/obj/effect/decal/rune/defile,
				/obj/effect/decal/rune/offering,
				/obj/effect/decal/rune/drain,
				/obj/effect/decal/rune/emp,
				/obj/effect/decal/rune/massdefile,
				/obj/effect/decal/rune/weapon,
				/obj/effect/decal/rune/shell,
				/obj/effect/decal/rune/confuse,
				/obj/effect/decal/rune/revive,
				/obj/effect/decal/rune/blood_boil,
				/obj/effect/decal/rune/tearreality))