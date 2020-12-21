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
	The hard minimum insanity (calculated after subtracting resolve) that is required to qualify for this effect.
	If you have less than this, it is not valid
*/

/datum/extension/sanity_effect
	expected_type = /mob/living/carbon/human
	base_type = /datum/extension/sanity_effect //Used for startup filtering
	flags = EXTENSION_FLAG_IMMEDIATE



//Data
//----------------------
	var/clinical_name	//Optional, used when viewed by advanced psychiatrists.

	var/mob/living/carbon/human/subject

	var/required_insanity = SANITY_TIER_MINOR
	var/reserve = SANITY_RESERVE_MINOR

	var/reference = FALSE	//If true, this doesnt have a holder and exists in a list for checking

	var/status = STATUS_DORMANT	//Must be one of STATUS_DORMANT, STATUS_ACTIVE, STATUS_FADING

	var/instant = FALSE		//Will apply and trigger in the same frame


//Applying Variables
//---------------------------
	//If this has been applied to this mob at least once already in this round, we return this instead of ideal.
	//Recommended values:
		//CHECK_NOT_IDEAL: Will not apply a second time unless nothing else is ideal, so the user will almost never see it twice in a round
		//CHECK_NEVER: Once only per round, never allow a second time
		//CHECK_IDEAL:	Can repeat endlessly, no limiting. Useful for things that don't grate with repetition
	var/previously_applied_behaviour = CHECK_NOT_IDEAL //TODO: Not implemented


	//How long this effect remains applied, before being unapplied
	//Note that even after this ends, if trigger is active, we will wait for that to finish before terminating
	//Setting this to zero and setting instant to true, will create an effect that triggers once then removes as soon as its done triggering
	var/apply_duration_max = 0

	//If set, duration is randomised between min and max
	var/apply_duration_min = null

	//If true, this effect has reached the end of its duration and should now be either unapplied or faded
	//This is only set when it can't end due to an ongoing trigger, so it will end as soon as it becomes inactive
	var/ended = FALSE

	//Just tracks a timer handle so it can be stopped manually in case of early termination
	var/apply_timer_handle


//Triggering Variables
//---------------------
	//How long trigger lasts. If zero, it will end immediately
	var/trigger_duration_max = 0

	//If set, duration is randomised between min and max
	var/trigger_duration_min

	//If set, this much time is allotted to windup stuff before the duration starts
	var/trigger_windup_time

	//Just tracks a timer handle so it can be stopped manually in case of early termination
	var/trigger_timer_handle

	//Triggering Variables
	//TODO: Not implemented
	var/max_trigger_instances = 1	//How many times can this trigger per application? 0 = no limit

	//If true, this calls apply_client_effects when triggered, and also when the victim logs in
	var/has_client_effects = FALSE

	//If true, this calls apply_mob_effects when triggered
	var/has_mob_effects = TRUE


//Fading Variables
//---------------------
	//If set, this effect will go into fading status when duration runs out.
	//While fading it is mostly invisible and can't trigger, but will still hang onto reserved insanity
	//After the fade duration it will finally unapply
	//TODO: Unimplemented
	var/fade_duration = null

	//Applying Variables








//String Variables
//---------------------
	/*
		Auto messages

		These are all lists of strings. random things are picked from them and shown to users at the appropriate events

		nothing happens for each event if the appropriate list is left null
	*/

	//Shown once when first applied
	//TODO: Not implemented
	var/list/messages_apply

	//Shown each time the effect triggers
	//TODO: Not implemented
	var/list/messages_trigger_start

	//Shown when the effect finishes triggering, and changes to any non active state
	//TODO: Not implemented
	var/list/messages_trigger_end

	//Shown once when the effect ends, either by immediately unapplying, or by switching to fading state
	//Note, nothing is shown when fading ends and its unapplied at that point
	//TODO: Not implemented
	var/list/messages_end

	//Shown each time the message is prevented from triggering, via medication, restraints, etc.
	//TODO: Not implemented
	var/list/messages_prevented = list("You feel strange for a moment, but it passes without incident.",
	"You feel uncomfortable, but hold it together",
	"You feel like you just dodged a bullet",
	"The seconds tick by, uneventfully",
	"You twitch in anticipation, but nothing happens.",
	"A still moment passes by",
	"You feel a brief restlessness, vanishing as quickly as it comes.",
	"The stillness within grounds you",
	"You feel muted, neutral.")

	//These are shown periodically while the effect is in a dormant state
	//TODO: Not implemented
	var/list/messages_periodic_dormant

	//These are shown periodically while the effect is in an active state
	//TODO: Not implemented
	var/list/messages_periodic_active




/datum/extension/sanity_effect/New(var/datum/holder)
	//Pass this special parameter in to tell the sanity effect that its not getting a holder and should not initialize
	if (holder == REFERENCE)
		reference = TRUE
		return

	..()

	Initialize(arglist(args))




//This isnt the same as atom initialize, it could have any mixture of input parameters, override it and set what's expected
/datum/extension/sanity_effect/proc/Initialize()
	.=..()
	subject = holder

	applied()

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
	Called when we are applied
*/
/datum/extension/sanity_effect/proc/applied()
	var/apply_duration = apply_duration_max
	if (!isnull(apply_duration_min))
		apply_duration = rand_between(apply_duration_min, apply_duration_max)

	apply_timer_handle = addtimer(CALLBACK(src, /datum/extension/sanity_effect/proc/end_apply), apply_duration, TIMER_STOPPABLE)



/*
	Called when our overarching duration runs out, attempts to end.

*/
/datum/extension/sanity_effect/proc/end_apply()
	/*
		If triggering is still active, we can't end yet
	*/
	if (status == STATUS_ACTIVE)
		//Set this flag so that this proc will be called again when trigger ends
		ended = TRUE
		return







/*
	Triggering
*/

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

/datum/extension/sanity_effect/proc/attempt_trigger()
	var/safety = can_trigger(holder)
	if (safety == CHECK_NOT_IDEAL || safety == CHECK_IDEAL)
		trigger()

//Actually do things!
//don't override this directly if possible, override the procs it calls instead.
//Add more of them as needed
/datum/extension/sanity_effect/proc/trigger()
	status = STATUS_ACTIVE

	trigger_windup()

	if (trigger_windup_time)
		sleep(trigger_windup_time)

	if (has_client_effects)
		//Apply client effects and setup a call to reapply them later
		if (!GLOB.logged_in_event.is_listening(holder, src, /datum/extension/sanity_effect/proc/trigger_client_effects))
			GLOB.logged_in_event.register(holder, src, /datum/extension/sanity_effect/proc/trigger_client_effects)
		trigger_client_effects()


	if (has_mob_effects)
		trigger_mob_effects()


	var/trigger_duration = trigger_duration_max
	if (!isnull(trigger_duration_min))
		trigger_duration = rand_between(trigger_duration_min, trigger_duration_max)

	trigger_timer_handle = addtimer(CALLBACK(src, /datum/extension/sanity_effect/proc/end_trigger), trigger_duration, TIMER_STOPPABLE)




/*
	Called when triggering ends
*/
/datum/extension/sanity_effect/proc/end_trigger()
	deltimer(trigger_timer_handle)

	status = STATUS_DORMANT

	on_end_trigger()

	if (ended)
		end_apply()


/*
	Overrideable procs
	Override these instead of touching other things
*/
/datum/extension/sanity_effect/proc/trigger_windup()

/datum/extension/sanity_effect/proc/on_end_trigger()


/datum/extension/sanity_effect/proc/trigger_client_effects()


/datum/extension/sanity_effect/proc/trigger_mob_effects()
