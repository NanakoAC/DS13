/*
	Active scan is for mobs, and other things which constantly move around.

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