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
	flags = EXTENSION_FLAG_IMMEDIATE
	base_type = /datum/extension/eyeclose
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