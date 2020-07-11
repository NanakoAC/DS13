/*
	Sanity effects are applied to mobs to do things with them. they are the puppeteers that control actions.

	On a technical level, they exist in one of two states
		Reference: Singletons stored in global lists, these are only used for validity and cost checking.
		These sit in limbo with no holder datum

		Active:	Attached to a holder, work as normal extensions
*/
#define REFERENCE	"reference"
/datum/extension/sanity_effect
	var/reference = FALSE	//If true, this doesnt have a holder and exists in a list for checking


/datum/extension/sanity_effect/New(var/datum/holder)
	//Pass this special parameter in to tell the sanity effect that its not getting a holder
	if (holder == REFERENCE)
		reference = TRUE
		return


	Initialize(arglist(args))