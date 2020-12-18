//Causes a mob to step one tile in a direction, and their camera goes with them
/mob/proc/lurch(var/direction, var/camera_shift = 64, var/skip_cooldown = TRUE)
	if (!direction)
		direction = pick(GLOB.cardinal)

	if (skip_cooldown)
		reset_move_cooldown()

	if (!SelfMove(direction))
		return
	if (client)
		var/vector2/delta = Vector2.NewFromDir(direction)
		delta.SelfMultiply(camera_shift)
		animate(client, pixel_x = delta.x, pixel_y = delta.y, time = 3)
		animate(pixel_x = 0, pixel_y = 0, time = 10)


//Makes a mob unable to move under its own power. either for a limited duration or until the handler is removed
/mob/proc/root(var/duration = 0)
	return AddMovementHandler(/datum/movement_handler/root, null, duration)


/*
	Resurrection
	Brings a dead mob back to life.

	In the case of humans, this will require all vital organs (brain, heart, etc) to be present and in working condition,
	otherwise it will either instafail, or die shortly after
*/
/mob/proc/resurrect(var/external_healing = 100)
	if (stat != DEAD)
		return FALSE

	stat = CONSCIOUS
	return TRUE

/mob/living/resurrect(var/external_healing = 100)
	.=..()
	if (!.)
		return
	if (external_healing)
		heal_overall_damage(external_healing)
	adjustOxyLoss(-9999999)//Remove oxyloss


/mob/living/carbon/human/resurrect(var/external_healing = 100)
	.=..()
	if (!.)
		return

	for (var/obj/item/organ/O in internal_organs)
		O.rejuvenate()

	shock_stage = 0




/*
	Closing Eyes
	Does a fullscreen effect and then blacks out the screen for some time

	The animation is premade in animated sprites and can't be dynamically adjusted, so three speed settings are here
*/
#define EYECLOSE_TIME_FAST	0.54 SECONDS
#define EYECLOSE_TIME_NORMAL	0.92 SECONDS
#define EYECLOSE_TIME_SLOW	1.975 SECONDS
#define EYEOPEN_TIME	0.55 SECONDS
/mob/proc/close_eyes_for(var/duration, var/over_hud, var/speed)
	if (get_extension(src, /datum/extension/eyeclose))
		//TODO: Extend duration of existing if possible
		return
	set_extension(src, /datum/extension/eyeclose, duration, over_hud, speed)


/datum/extension/eyeclose
	var/status = 0	//0: Closing, 1: Closed, 2: opening

	var/client/C
	var/speed
	var/over_hud
	var/duration

/datum/extension/eyeclose/New(var/mob/user, var/duration, var/over_hud, var/speed)
	.=..()

	if(!user || !user.client)
		end()
		return

	C = user.client
	src.speed = speed
	src.over_hud = over_hud
	src.duration = duration

	addtimer(CALLBACK(src, /datum/extension/eyeclose/proc/close),0, TIMER_STOPPABLE)

/datum/extension/eyeclose/proc/close()
	var/screentype = /obj/screen/fullscreen/eyeclose
	switch (speed)
		if (EYECLOSE_TIME_FAST)
			screentype = /obj/screen/fullscreen/eyeclose/fast
		if (EYECLOSE_TIME_SLOW)
			screentype = /obj/screen/fullscreen/eyeclose/slow

	var/obj/screen/fullscreen/eyeclose/EC = new screentype()
	if(over_hud)
		EC.plane = ABOVE_HUD_PLANE
	C.screen += EC

	//And now we wait
	sleep(speed)

	status = 1

	//We are done waiting, the eyes are now fully closed
	//TODO Here: Safety checks. Still logged in?

	//Assume its safe to proceed for now

	//We gotta create the blackout overlay
	if(over_hud)
		C.mob.overlay_fullscreen("total_blackout", /obj/screen/fullscreen/total_blackout)
	else
		C.mob.overlay_fullscreen("blackout", /obj/screen/fullscreen/blackout)


	//And now lets remove the eyeclose thing
	C.screen -= EC
	qdel(EC)


	//Lets setup our opening time
	addtimer(CALLBACK(src, /datum/extension/eyeclose/proc/open),duration,  TIMER_STOPPABLE)

/datum/extension/eyeclose/proc/open()

	//TODO here: Safety checks

	status = 2
	//Alright lets open those eyes
	var/obj/screen/fullscreen/eyeclose/EC = new /obj/screen/fullscreen/eyeclose/open()
	if(over_hud)
		EC.plane = ABOVE_HUD_PLANE
	C.screen += EC


	//We gotta remove the blackout overlay
	if(over_hud)
		C.mob.clear_fullscreen("total_blackout")
	else
		C.mob.clear_fullscreen("blackout")


	//Wait for the animation to finish
	sleep(EYEOPEN_TIME)

	//And now lets fade out over one second
	animate(EC, alpha = 0, time = 1 SECOND)

	//Wait for that
	sleep(1 SECOND)

	//And we're done
	end()


/datum/extension/eyeclose/proc/end()
	C = null
	remove_self()