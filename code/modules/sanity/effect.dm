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
*/
#define REFERENCE	"reference"
/datum/extension/sanity_effect
	expected_type = /mob/living/carbon/human
	flags = EXTENSION_FLAG_IMMEDIATE

	var/reference = FALSE	//If true, this doesnt have a holder and exists in a list for checking

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
/datum/extension/sanity_effect/Initialize()
	.=..()