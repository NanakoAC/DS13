/*
	A sanity "check" is an event which occurs periodically, or under certain circumstances, to see if someone should have new sanity
	effects added to them.

	Overview:
	-----------
	By default, sanity checks occur once every certain time period, approximately once a minute.
	In addition, sanity checks occur instantly whenever someone is subjected to an acute source of sanity damage.
	IE, witnessing something awful

	There is a small cooldown on this instant occurrence (5 seconds?) to prevent spam


	When a sanity check happens, a random probability is rolled to see if a new effect should be applied right now.
	This probability is affected by several factors


	If the probability succeeds, then a new effect is chosen from a huge list of all possible effects, minus those that we don't
	have enough insanity for. The selection of which effect is weighted based on the minimum sanity requirements for each, so it's
	generally more likely that the most severe available effects will be picked, but this is far from guaranteed.

	Once an effect is picked, we check can_apply on it, and can_trigger too if its instant. If these checks return an invalid result,
	then we remove that effect from the list and pick again. Repeat until we find one that can be applied


	Cooldown:
	----------
	First of all, the last sanity effect applied will add a hard minimum cooldown, by setting a minimum world-time until the next
	check is allowed to happen. if that time hasn't arrived yet, we just don't do a check


	Probability:
	------------
	The probability that an effect will be applied at each check is primarily based on the victim's insanity value.
	1% chance per 10 points, ish

	However, we don't use insanity as is, we use a modified value of it. Equal to
	Insanity - Reserved Insanity - Courage

	Some insanity is reserved by existing applied effects, so generally the more effects you already have,
	the lower the odds that new ones will be added


	Thresholds and Picking:
	------------------------
	To get a list of things to pick, we first make a copy of the entire global list of all possible sanity effects. #
	This is an assoc list in the format list(effect_datum = minimum_insanity)
	This is sorted by the minimum insanity in ascending order

	To figure out which ones we meet the minimum for, we use a value equal to insanity - courage.
	Reserved insanity is NOT factored into this calculation, intentionally.

	Then we chop off the bottom of the list, excluding all those which have a minimum value higher than what we just calculated.

	With what's left, we do pickweight to grab one, this weights towards the higher value
*/