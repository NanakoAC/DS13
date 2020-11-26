/*
	Sanity effects are applied to mobs to do things with them. they are the puppeteers that control actions.

	On a technical level, they exist in one of two states
		Reference: Singletons stored in global lists, these are only used for validity and cost checking.
		These sit in limbo with no holder datum

		Active:	Attached to a holder, work as normal extensions


	Apply:
	Applying just means putting the extension on a mob. It may do something immediately, or it may sit there and wait for
	the right conditions. When an effect does something, this is "triggering". The safety check can_apply is called before this,
	if it fails, the effect will not be applied, and something else will be applied in its place


	Trigger:
	The effect does its thing right now. An effect might trigger multiple times while it remains applied, or just once.
	The safety check can_trigger is called before this, if it fails, the effect will continue waiting and try to trigger again later


	Instant
	Instant effects will trigger in the same frame that they're applied. Because of this, both can_apply and can_trigger
	are checked before applying, and both must pass.


	Max Duration:
	An upper limit on how long the effect will continue to exist. It might trigger once and maintain whatever it did for that period
	Or it might remain applied for that period, occasionally triggering. Everything should have a max duration unless it is intended
	to be permanant. Even if the effect can terminate early, duration is a fallback.


	Min Duration: (Optional, default null)
	If set, the actual duration will be randomised between min and max.
	If unset, max is used without any random factor


	Reserve:
	While this effect is applied, a portion of the victim's insanity is "reserved".
	This just means that quantity is not used in checks to calculate the odds of applying more effects.
	It does not affect which effects the victim is eligible for, and the total quantity of reserved insanity can become higher than
	the actual amount of insanity.
	See check.dm for more detail


	required_insanity:
	The hard minimum insanity (calculated after subtracting courage) that is required to qualify for this effect.
	If you have less than this, it is not valid
*/

/datum/extension/sanity_effect
	expected_type = /mob/living/carbon/human
	base_type = /datum/extension/sanity_effect //Used for startup filtering
	flags = EXTENSION_FLAG_IMMEDIATE

	var/mob/living/carbon/human/subject

	var/required_insanity = SANITY_TIER_MINOR
	var/reserve = SANITY_RESERVE_MINOR

	var/reference = FALSE	//If true, this doesnt have a holder and exists in a list for checking
	var/currently_active = FALSE	//Is this currently applied to a mob and doing things?

	var/instant = FALSE		//Will apply and trigger in the same frame

	var/max_duration = 20 MINUTES
	var/min_duration = null

	//Applying Variables

	//If this has been applied to this mob at least once already in this round, we return this instead of ideal.
	//Recommended values:
		//CHECK_NOT_IDEAL: Will not apply a second time unless nothing else is ideal, so the user will almost never see it twice in a round
		//CHECK_NEVER: Once only per round, never allow a second time
		//CHECK_IDEAL:	Can repeat endlessly, no limiting. Useful for things that don't grate with repetition
	var/previously_applied_behaviour = CHECK_NOT_IDEAL //TODO: Not implemented

	//Triggering Variables
	//TODO: Not implemented
	var/max_trigger_instances = 1	//How many times can this trigger per application? 0 = no limit

	//If true, this calls apply_client_effects when triggered, and also when the victim logs in
	var/has_client_effects = FALSE

	//If true, this calls apply_mob_effects when triggered
	var/has_mob_effects = TRUE


/datum/extension/sanity_effect/New(var/datum/holder)
	//Pass this special parameter in to tell the sanity effect that its not getting a holder amd should not initialize
	if (holder == REFERENCE)
		reference = TRUE
		return

	..()




	Initialize(arglist(args))


//This isnt the same as atom initialize, it could have any mixture of input parameters, override it and set what's expected
/datum/extension/sanity_effect/proc/Initialize()
	.=..()

	//Even though safety checks were done, we redo them anyways in the case of CHECK_PREVENTED
	if (instant)
		attempt_trigger()



/*
	Safety Checks. Both of these must return one of the following
	CHECK_NEVER
	CHECK_INVALID
	CHECK_NOT_IDEAL
	CHECK_PREVENTED
	CHECK_IDEAL
*/
/*
	Can this be applied to the target mob?
	If this returns
	CHECK_NEVER
	CHECK_INVALID

	Then the affect will not be applied, no distinction between them

	If this returns CHECK_NOT_IDEAL, it may not be applied, depending on whether other effects are more ideal

	If it returns
	CHECK_PREVENTED
	CHECK_IDEAL
	Then it applies just fine
*/
/datum/extension/sanity_effect/proc/can_apply(var/mob/living/carbon/human/victim)
	return CHECK_IDEAL



/*
	Once applied, can this effect start doing its thing?
	In the case of instant effects, this is called at the same time as can_apply,
	and has the same consequences as described above

	If this returns
	CHECK_NEVER after already being applied, the effect will be removed from the mob

	If this returns
	CHECK_INVALID
	CHECK_PREVENTED
	after already being applied, it will not trigger right now, but try again later

	If this returns
	CHECK_NOT_IDEAL
	CHECK_IDEAL
	After already being applied, then it will trigger, theres no distinction between them

*/
/datum/extension/sanity_effect/proc/can_trigger(var/mob/living/carbon/human/victim)
	return CHECK_IDEAL


/*
	Triggering
*/
/datum/extension/sanity_effect/proc/attempt_trigger()
	var/safety = can_trigger(holder)
	if (safety == CHECK_NOT_IDEAL || safety == CHECK_IDEAL)
		trigger()

//Actually do things!
//don't override this directly if possible, override the procs it calls instead.
//Add more of them as needed
/datum/extension/sanity_effect/proc/trigger()
	if (has_client_effects)
		//Apply client effects and setup a call to reapply them later
		if (!GLOB.logged_in_event.is_listening(holder, src, /datum/extension/sanity_effect/proc/apply_client_effects))
			GLOB.logged_in_event.register(holder, src, /datum/extension/sanity_effect/proc/apply_client_effects)
		apply_client_effects()


	if (has_mob_effects)
		apply_mob_effects()



/datum/extension/sanity_effect/proc/apply_client_effects()


/datum/extension/sanity_effect/proc/apply_mob_effects()