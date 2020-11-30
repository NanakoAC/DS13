#define SANITY_TIER_MINOR		0
#define SANITY_TIER_MODERATE	100
#define SANITY_TIER_MAJOR		400
#define SANITY_TIER_CRITICAL	1000


#define SANITY_RESERVE_MINOR	40
#define SANITY_RESERVE_MODERATE	160
#define SANITY_RESERVE_MAJOR		250
#define SANITY_RESERVE_CRITICAL	400

//Each point of sanity adds this percentage chance of getting an effect, at each check. 100% at 1000
#define SANITY_PROBABILITY_FACTOR	0.1

//Baseline probability of getting a sanity effect at each check, in addition to calculations
#define SANITY_PROBABILITY_BASE	3

//If you see something spooky but aren't directly facing it, the incoming sanity damage is multiplied by this
//Of course there are other risks to turning your back on horrible things
#define SANITY_VISIBLE_LOOKAWAY_MULT	0.6

//Baseline values on sanity damage
#define SANITY_DAMAGE_SCREAM	5
#define SANITY_DAMAGE_DISMEMBER	75	//Watching others get dismembered
#define SANITY_DAMAGE_SELF_DISMEMBER	200	//Losing your own limb is crazy terrifying
#define SANITY_DAMAGE_DEATH	50	//Death itself is fairly damaging, but its usually accompanied by dismemberment and gore that add more insanity ontop of this
#define SANITY_DAMAGE_MALFUNCTION	3.5	//Light flickering

//Caps on sanity damage
//Cap on sanity damage from active shouts from necromorphs
#define SANITY_CAP_SHOUT	300
#define SANITY_CAP_DISMEMBER	800	//Brutal violence has high limits
#define SANITY_CAP_MALFUNCTION	200	//Malfunctioning machines are only mildly spooky

//Used for creating singleton dummy versions of sanity effects to hold in a global list, for validity checks
#define REFERENCE	"reference"


/*
	Desensitisation values
	The sanity damage from experiencing an effect more than once is multiplied by this to the power of the number of times you've
	seen it. Lower values are stronger

	Generally, the more powerful a sanity effect is, the quicker you become desensitized.
	Big things are only really scary the first few times
*/
#define DESEN_ACTIVE_HIGH	0.75
#define DESEN_ACTIVE_MED	0.85
#define DESEN_ACTIVE_LOW	0.95

//Passive effects tick each second so they have MUCH lower desensitisation rates
#define DESEN_PASSIVE_HIGH	0.99
#define DESEN_PASSIVE_MED	0.995
#define DESEN_PASSIVE_LOW	0.999



/*
	Sanity Tags:
	These are used in various places to group things in a flexible manner, including:

	-Causes of Insanity
		Grouped so that they can be modified by player skills/desensitisation
	-Types of Sanity Effects
		Grouped so they can exclude or influence each other
	-Types of sanity treatment/prevention
		To exclude/suppress sanity effects
*/
#define TAG_GORE	"gore"	//Blood, guts
#define TAG_DISMEMBERMENT	"dismemberment"	//Limbs and heads being severed
#define TAG_DEATH	"death"	//Witnessing sentient beings die
#define TAG_SCREAM	"scream"	//Hearing necromorphs shouting
#define TAG_MALFUNCTION "malfunction"	//Flickering/exploding lights, doors locking themselves. Machinery behaving strangely in general



/*
	Cooldowns:
	Hard minimums after checks or effects, before another sanity check can occur.
	These are not very large because they're not the primary method of pacing out effects.

	That is handled by the probabilities based on your insanity, and the time between effects is usually much longer than this

	Their main purpose is just to prevent oddities of several effects occuring at once, and give you time to read the strings
	before being subjected to something new
*/
#define CHECK_COOLDOWN_CHECK	5 SECONDS	//Minimum after a check in all circumstances
#define CHECK_COOLDOWN_MINOR	20 SECONDS
#define CHECK_COOLDOWN_MODERATE	2 MINUTES
#define CHECK_COOLDOWN_MAJOR	5 MINUTES



/*
	Recovery
	Sanity restored per second
*/
#define SANITY_REGEN_BASE	0.8333	//5 points restored per minute


/*
	How many life ticks (seconds) between each automatic sanity check
	Default 60, once per minute
*/
#define SANITY_CHECK_INTERVAL	60


/*
	When multiple copies of the same kind of passive sanity source (bloodstains, corpses, gore, etc) are in an area, their
	sanity damage per second has falloff for each copy after the first.
	First one has full damage
	Second one has damage multiplied by (1 * (SANITY_PASSIVE_STACK_SOFTCAP ** 1))
	Third one has damage multiplied by (1 * (SANITY_PASSIVE_STACK_SOFTCAP ** 2))

	and so on

	This calculation is done once and precached, whenever a new atom is added or removed to a passive source
*/
#define SANITY_PASSIVE_STACK_FALLOFF_HIGH	0.8
#define SANITY_PASSIVE_STACK_FALLOFF_MID	0.9
#define SANITY_PASSIVE_STACK_FALLOFF_LOW	0.95