/obj/effect/decal/cleanable
	var/list/random_icon_states
	cleanable = TRUE


/obj/effect/decal/cleanable/Initialize()
	if (random_icon_states && length(src.random_icon_states) > 0)
		src.icon_state = pick(src.random_icon_states)
	. = ..()
