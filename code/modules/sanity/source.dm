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
	var/name = "spooky thing"
	var/base_type = /datum/sanity_source	//Used to prevent abstract base classes from appearing in global lists

	//Descriptions shown to most users, one is picked at random. Add as many to this list as you can imagine

	var/list/descriptions = list()
	var/list/sanity_tags = list()

	//These two values are both fallback/defaults. They can, and often will be overridden by the caller
	var/sanity_damage	=	5	//How much insanity this source causes by default, if no value is specified.
	var/sanity_limit = 1000	//How high this can raise insanity before either being hardcapped or suffering falloff, depending on whether its passive or active


	//Seeing the same spooky thing repeatedly scares you less.
	//The sanity damage from a source is multiplied by this to the power of the number of times its already been seen
	var/desensitisation = DESEN_ACTIVE_LOW

	//Used to taper off the stacking effects from many passive sources of the same type, like lots of bloodstains
	//Only used in passive sources, irrelevant for active ones
	var/falloff	=	SANITY_PASSIVE_STACK_FALLOFF_LOW


/*
	Some common ones
*/

//Necromorph Shouts
/datum/sanity_source/scream
	name = "screams"
	descriptions = list("I can still hear their screams",
	"The monstrous wailing haunts my mind",
	"It screamed like a dying pig",
	"It echoed like whalesong")

	sanity_tags = list(TAG_SCREAM)
	sanity_damage = SANITY_DAMAGE_SCREAM
	sanity_limit = SANITY_CAP_SHOUT


//Repressed memories, only used by admins dealing sanity damage
/datum/sanity_source/memory
	descriptions = list("Something horrible happened, and i can't remember what",
	"There's a hole in my memories",
	"Why am I like this?",
	"What have I done?")

//Witnessing dismemberment
/datum/sanity_source/dismember
	name = "dismemberment"
	descriptions = list("They just...tore him apart",
	"He was butchered like an animal",
	"They cut off his head, and he kept moving, twitching",
	"They sliced him apart like meat",
	"Limbs aren't supposed to come off like that")

	sanity_tags = list(TAG_DISMEMBERMENT)
	sanity_damage = SANITY_DAMAGE_DISMEMBER
	sanity_limit = SANITY_CAP_DISMEMBER

	desensitisation = DESEN_ACTIVE_MED

//Experiencing dismemberment
/datum/sanity_source/self_dismember
	name = "self dismemberment"
	descriptions = list("Will I ever be whole again?",
	"A part of me is just...gone",
	"It still itches, but it's not there.",
	"I am a broken shell")

	sanity_tags = list(TAG_DISMEMBERMENT)
	sanity_damage = SANITY_DAMAGE_SELF_DISMEMBER
	sanity_limit = SANITY_CAP_DISMEMBER

	desensitisation = DESEN_ACTIVE_HIGH


//Witnessing people die
/datum/sanity_source/death
	name = "death"
	descriptions = list("Snuffed out like a candle",
	"I watched a man die",
	"I saw the spark fade from his eyes",
	"So much death",
	"Crumpled like a puppet without strings",
	"Such a senseless waste of life")

	sanity_tags = list(TAG_DEATH)
	sanity_damage = SANITY_DAMAGE_DEATH

	desensitisation = DESEN_ACTIVE_MED

/datum/sanity_source/malfunction
	name = "malfunction"
	descriptions = list("I swear this ship is haunted",
	"What's wrong with the lights around here?",
	"This ship is falling apart",
	"This ship is a floating coffin",
	"Why do the doors keep malfunctioning?",
	"What if an airlock opens itself and kills us all?",
	"Can't trust anything on this ship, its all buggy",
	"Does anything work right around here?",
	"This old vessel is really showing its age")

	sanity_tags = list(TAG_MALFUNCTION)
	sanity_damage = SANITY_DAMAGE_MALFUNCTION

	sanity_limit = SANITY_CAP_MALFUNCTION

	desensitisation = DESEN_ACTIVE_LOW



/*
	Passive sources below here
	!! Do not mix active and passive sources !!
*/
/datum/sanity_source/blood
	name = "blood"
	descriptions = list("So much blood",
	"The walls are painted red",
	"The deck runs crimson",
	"Vital pigment stains this canvas",
	"This vessel is a rich vermillion work of art",
	"The tang of iron in the air",
	"Red really livens up the dull industrial aesthetic")

	sanity_tags = list(TAG_BLOOD)
	sanity_damage = SANITY_DAMAGE_PASSIVE_LOW

	sanity_limit = SANITY_CAP_BLOOD

	desensitisation = DESEN_PASSIVE_LOW


/*
	Seeing live necromorphs in person. And possibly other horrible non-necromorph monsters
	May include illusory creatures

	Make subtypes to vary the sanity damage
*/
/datum/sanity_source/monster
	name = "monster"
	descriptions = list("Oh god its horrible",
	"What the fuck was that thing?",
	"Is it still chasing me?",
	"Monstrous creatures stalk the halls",
	"How did that monster get aboard?",
	"It looked vaguely human...")

	sanity_tags = list(TAG_MONSTER)
	sanity_damage = SANITY_DAMAGE_PASSIVE_MOB_LOW

	//No limit on sanity damage, it can drive you all the way to suicide just by standing infront of you
	//Honestly quite a reasonable alternative to being torn apart

	//Even though its a powerful source, you don't easily get used to them because monsters are mobile, intelligent and adaptive
	desensitisation = DESEN_PASSIVE_LOW

//Subtype used only for Tier IV monsters like ubermorph
/datum/sanity_source/monster/mid
	sanity_damage = SANITY_DAMAGE_PASSIVE_MOB_MID

/datum/sanity_source/monster/high
	sanity_damage = SANITY_DAMAGE_PASSIVE_MOB_HIGH


/*
	TODO:
	Gore
	gibbing
	psychic pulses
	corruption nodes
	gaze
	whispers
	Runes/graffiti
*/