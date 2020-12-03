/*
	Active scan is for mobs, and other things which constantly move around.
	The active scan is intended for exactly ONE scary atom, the same thing as the epicentre.

	Proximity triggers cant be used here, they'd just be a waste, regularly remaking objects.

	Instead, we work on a two phase scanning system
		The scanner starts in the slow phase. It will scan the environment periodically (every 5-10 secs)) and it will also scan
		when certain events occur. Like the host mob taking damage, or moving around.
		While in slow phase, there is a hard minimum cooldown (3 secs ish) between scans. If one tries to occur while cooling, antoher is scheduled

		The scanner enters fast phase when it detects any valid victim. In this phase it will scan exactly once per second no matter
		what, just before applying the sanity damage.

		The scanner will remain in fast phase until the following conditions are met:
			-No valid targets remain
			-No valid targets have been detected for some significant time period (30-60 secs)

		When conditions are right, it returns to slow phase

*/
/datum/extension/sanity_scan/active
	last_victim_timeout = 1 MINUTE
	active_scan = TRUE	//Does an active scan for new victims just after each victim recheck

	var/slowmode_active_scan_min_delay = 3 SECONDS	//When in slow scanning mode, this is the minimum time between scans
	var/slowmode_active_scan_max_delay = 30 SECONDS	//When in slow scanning mode, do an active scan at least this often
	var/next_active_scan	//When we're doing the next scan
	var/active_scan_handle	//Timer handle for scheduling




//Here we set observations on our host atom. These will cause a scan to happen whenever certain events occur which might indicate
//activity
/datum/extension/sanity_scan/active/setup_detection()

	GLOB.moved_event.register(epicentre, src, /datum/extension/sanity_scan/active/proc/schedule_scan)

//Called when we start active scanning, we dont need these observations anymore since we'll scan once per second anyway
/datum/extension/sanity_scan/active/proc/unsetup_detection()
	GLOB.moved_event.unregister(epicentre, src, /datum/extension/sanity_scan/active/proc/schedule_scan)
	deltimer(active_scan_handle)
	next_active_scan = null

/*
	This proc attempts to schedule the next active scan with a given delay
*/
/datum/extension/sanity_scan/active/proc/schedule_scan(var/delay = slowmode_active_scan_min_delay)

	//This may be called with garbage data from various observations. Correct the delay if the input isn't something valid
	if (!delay || !isnum(delay))
		delay = slowmode_active_scan_min_delay

	//First of all, we will try to do a scan right now if we can
	var/delta_since_last = world.time - last_active_scan
	if (delta_since_last >= slowmode_active_scan_min_delay)
		//Yes we can!
		do_active_scan()
		return

	//Nope, alright then, next step
	//How long til our next already scheduled, assuming there is any?
	if (next_active_scan)
		var/delta_until_next = next_active_scan - world.time

		//Would the delay we're planning to schedule be worse than that?
		if (delta_until_next < delay)
			//Yup, so we won't bother messing with anything, the next scheduled one can happen on time
			return

		//We're going to do better
		else
			deltimer(active_scan_handle)

	//When we get here, we're either going to scan sooner than originally scheduled, or nothing was already scheduled.
	active_scan_handle = addtimer(CALLBACK(src, /datum/extension/sanity_scan/proc/do_active_scan), delay, TIMER_STOPPABLE)

/*
	Scans for new victims, parent call handles that,
	We're just doing some bookkeeping before and after
*/
/datum/extension/sanity_scan/active/do_active_scan(var/list/viewlist)
	deltimer(active_scan_handle)
	next_active_scan = null
	.=..()

	//Schedule our next san with a long delay
	schedule_scan(slowmode_active_scan_max_delay)


/datum/extension/sanity_scan/active/start_active_processing()
	.=..()
	if (.)
		unsetup_detection()


//When we stop active processing, we switch back to our slow scanning mode, so re-call setup detection
/datum/extension/sanity_scan/active/stop_active_processing()
	.=..()
	if (.)
		setup_detection()




/*
	Active scan doesnt care about sources which differ from the host/epicentre
*/
/datum/extension/sanity_scan/active/add_source(var/atom/thing, var/datum/sanity_source/source, var/recalculate = TRUE)
	if (thing != epicentre)
		return

	.=..()


/datum/extension/sanity_scan/active/remove_source(var/atom/thing, var/recalculate = TRUE)
	if (thing != epicentre)
		return

	.=..()