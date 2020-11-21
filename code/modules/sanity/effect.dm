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
#define REFERENCE	"reference"
/datum/extension/sanity_effect
	expected_type = /mob/living/carbon/human
	base_type = /datum/extension/sanity_effect //Used for startup filtering
	flags = EXTENSION_FLAG_IMMEDIATE

	var/required_insanity = SANITY_TIER_MINOR
	var/reserve = SANITY_RESERVE_MINOR

	var/reference = FALSE	//If true, this doesnt have a holder and exists in a list for checking
	var/currently_active = FALSE	//Is this currently applied to a mob and doing things?

	var/instant = FALSE		//Will apply and trigger in the same frame

	var/max_duration = 20 MINUTES
	var/min_duration = null


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



/*
	Safety Checks. Both of these must return one of the following
	CHECK_NEVER
	CHECK_INVALID
	CHECK_NOT_IDEAL
	CHECK_IDEAL
*/
/*
	Can this be applied to the target mob?
	If this returns
	CHECK_NEVER
	CHECK_INVALID

	Then the affect will not be applied, no distinction between them

	If this returns CHECK_NOT_IDEAL, it may not be applied, depending on whether other effects are more ideal
*/
/datum/extension/sanity_effect/proc/can_apply(var/mob/living/carbon/human/victim)
	return CHECK_IDEAL



/*
	Once applied, can this effect start doing its thing?
	In the case of instant effects, this is called at the same time as can_apply, and has the same consequences as described above

	If this returns
	CHECK_NEVER after already being applied, the effect will be removed

	If this returns
	CHECK_INVALID after already being applied, it will not trigger right now, but try again later

	If this returns
	CHECK_NOT_IDEAL
	CHECK_IDEAL
	After already being applied, then it will trigger, theres no distinction between them

*/
/datum/extension/sanity_effect/proc/can_trigger(var/mob/living/carbon/human/victim)
	return CHECK_IDEAL