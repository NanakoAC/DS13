/*
	Sanity Sources

	Singleton datums held in a global list, these are used to refer to a specific category of thing which caused some insanity.
	Things like: Screams, dismemberment, death, looking at the marker.

	The main purpose for their existence is to hold strings which are randomly selected and shown to users.

	but they can also have functional code which varies the sanity damage based on certain factors.
	For example, someone with surgical experience might be less horrified by seeing dismemberment

	Lastly, they hold reasonable baseline values for sanity damage/limit so there's no need to specify them. But overriding them is
	always an option in the sanity functions
*/
/datum/sanity_source
	name = "spooky thing"
	var/list/descriptions = list()	//Descriptions shown to most users, one is picked at random. Add as many to this list as you can imagine
	var/list/sanity_tags = list()

	//These two values are both fallback/defaults. They can, and often will be overridden by the caller
	var/sanity_damage	=	5	//How much insanity this source causes by default, if no value is specified.
	var/sanity_limit = 1000	//How high this can raise insanity before either being hardcapped or suffering falloff, depending on whether its passive or active






/*
	Some common ones
*/

//Necromorph Shouts
/datum/sanity_source/scream
	descriptions = list("I can still hear their screams",
	"The monstrous wailing haunts my mind",
	"It screamed like a dying pig, but it wouldn't die",
	"It echoed like whalesong, but darker")

	sanity_tags = list(TAG_SCREAM)