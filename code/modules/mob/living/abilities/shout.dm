//Simple ability that makes a loud screaming noise, causes screenshake and sanity damage in everyone nearby.
/mob/proc/shout()
	set name = "Shout"
	set category = "Abilities"

	if (incapacitated(INCAPACITATION_KNOCKOUT))
		return

	var/sanity_damage = 5
	var/datum/species/S = get_mental_species_datum()
	if (S)
		sanity_damage = S.shout_sanity_damage

	do_shout(SOUND_SHOUT, sanity_damage = sanity_damage)


//Simple ability that makes a louder screaming noise, causes more screenshake in everyone nearby.
//Causes sanity damage equal to 1.6x what a normal shout does
/mob/proc/shout_long()
	set name = "Scream"
	set category = "Abilities"

	if (incapacitated(INCAPACITATION_KNOCKOUT))
		return

	var/sanity_damage = 8
	var/datum/species/S = get_mental_species_datum()
	if (S)
		sanity_damage = S.shout_sanity_damage * 1.6

	do_shout(SOUND_SHOUT_LONG, sanity_damage = sanity_damage)



/mob/proc/do_shout(var/sound_type, var/do_stun = TRUE, var/sanity_damage = 5)
	if (check_audio_cooldown(sound_type))
		var/file = get_species_audio(sound_type)
		var/list/sound_params = list("source" = src, "soundin" = file, "vol" = VOLUME_HIGH, "vary" = TRUE)

		//We use this proc which will play the sound, meter the heard volume, and deal sanity damage appropriately
		audible_sanity_damage(/datum/sanity_source/scream, sanity_damage, sound_parameters = sound_params)

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