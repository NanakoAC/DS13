//Simple ability that makes a loud screaming noise, causes screenshake in everyone nearby.
/mob/proc/shout()
	set name = "Shout"
	set category = "Abilities"

	if (incapacitated(INCAPACITATION_KNOCKOUT))
		return

	do_shout(SOUND_SHOUT, sanity_damage = 5)


//Simple ability that makes a louder screaming noise, causes more screenshake in everyone nearby.
/mob/proc/shout_long()
	set name = "Scream"
	set category = "Abilities"

	if (incapacitated(INCAPACITATION_KNOCKOUT))
		return

	do_shout(SOUND_SHOUT_LONG, sanity_damage = 8)



/mob/proc/do_shout(var/sound_type, var/do_stun = TRUE, var/sanity_damage = 5)
	if (check_audio_cooldown(sound_type))
		var/file = get_species_audio(sound_type)
		audible_sanity_damage(quantity = sanity_damage, var/limit = 0, var/override_source = null,  var/reason = "spooky things", var/list/sound_parameters)

		if (play_species_audio(src, sound_type, VOLUME_HIGH, 1, 2))
			if (do_stun)
				src.Stun(1)
			src.shake_animation(40)
			set_audio_cooldown(sound_type, 8 SECONDS)
			new /obj/effect/effect/expanding_circle(loc, 2, 3 SECOND)	//Visual effect
			for (var/mob/M in range(8, src))
				var/distance = get_dist(src, M)
				var/intensity = 5 - (distance * 0.3)
				var/duration = (7 - (distance * 0.5)) SECONDS
				shake_camera(M, duration, intensity)
				//TODO in future: Add psychosis damage here for non-necros who hear the scream