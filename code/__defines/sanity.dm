#define SANITY_TIER_MINOR		0
#define SANITY_TIER_MODERATE	100
#define SANITY_TIER_MAJOR		400
#define SANITY_TIER_CRITICAL	1000


#define SANITY_RESERVE_MINOR	40
#define SANITY_RESERVE_MODERATE	160
#define SANITY_RESERVE_MAJOR		250
#define SANITY_RESERVE_CRITICAL	400

//Compulsion progress ticks. How fast they decay towards failure when ignored
//These values are based on the assumption of a common 20 minute duration
#define COMPULSION_PROGRESS_SLOW	-0.111	//15 minutes to reach -100
#define COMPULSION_PROGRESS_MED		-0.222	//10 minutes to reach -100
#define COMPULSION_PROGRESS_FAST	-0.333	//5 minutes to reach -100

//Each point of sanity adds this percentage chance of getting an effect, at each check. 100% at 1000
#define SANITY_PROBABILITY_FACTOR	0.1

//Baseline probability of getting a sanity effect at each check, in addition to calculations
#define SANITY_PROBABILITY_BASE	3

/*
	Higher tier effects are more likely to be picked when we meet their requirement.
	The weight of each effect is equal to its minimum insanity multiplied by this value
	Plus one
*/
#define SANITY_MINIMUM_PROBABILITY_WEIGHT	0.015

//If you see something spooky but aren't directly facing it, the incoming sanity damage is multiplied by this
//Of course there are other risks to turning your back on horrible things
#define SANITY_VISIBLE_LOOKAWAY_MULT	0.6


#define SANITY_COOLDOWN_MINOR		30 SECONDS
#define SANITY_COOLDOWN_MODERATE	2 MINUTES
#define SANITY_COOLDOWN_MAJOR		4 MINUTES
#define SANITY_COOLDOWN_CRITICAL	6 MINUTES



//Baseline values on sanity damage
#define SANITY_DAMAGE_SCREAM	5
#define SANITY_DAMAGE_DISMEMBER	75	//Watching others get dismembered
#define SANITY_DAMAGE_SELF_DISMEMBER	200	//Losing your own limb is crazy terrifying
#define SANITY_DAMAGE_DEATH	50	//Death itself is fairly damaging, but its usually accompanied by dismemberment and gore that add more insanity ontop of this
#define SANITY_DAMAGE_MALFUNCTION	3.5	//Light flickering
#define SANITY_DAMAGE_GAZE	50	//Being spotted by an eye node
#define SANITY_DAMAGE_WHISPER	5	//Being spotted by an eye node


//Generic active sanity damage values
#define SANITY_DAMAGE_ACTIVE_LOW	5
#define SANITY_DAMAGE_ACTIVE_MID	20
#define SANITY_DAMAGE_ACTIVE_HIGH	50

//Passive Sanity Damage: These use standardised values, it all blends together
//All passive sanity damage values are per-second
#define SANITY_DAMAGE_PASSIVE_LOW	0.03	//Bloodstains
#define SANITY_DAMAGE_PASSIVE_MID	0.1		//Corpses
#define SANITY_DAMAGE_PASSIVE_HIGH	0.4
#define SANITY_DAMAGE_PASSIVE_EXTREME	1	//Marker and shards, inactive
#define SANITY_DAMAGE_PASSIVE_MARKER	5	//Marker and shards, active

//Passive sanity damage from mobs. They only inflict this damage aura while alive, killing them stops it.
//So to counterbalance that risk, they are far more powerful than immobile sources
#define SANITY_DAMAGE_PASSIVE_MOB_LOW	1
#define SANITY_DAMAGE_PASSIVE_MOB_MID	3
#define SANITY_DAMAGE_PASSIVE_MOB_HIGH	6








//Caps on sanity damage
//Cap on sanity damage from active shouts from necromorphs
#define SANITY_CAP_SHOUT	350
#define SANITY_CAP_DISMEMBER	800	//Brutal violence has high limits
#define SANITY_CAP_MALFUNCTION	250	//Malfunctioning machines are only mildly spooky
#define SANITY_CAP_GAZE	350
#define SANITY_CAP_GRAFFITI	150	//Nothing supernatural about graffiti, fairly low
/*
	Sanity caps for passive things
*/
#define SANITY_CAP_BLOOD	300
#define SANITY_CAP_MARKER_INACTIVE	200	//Hanging around near an inert marker makes you a bit uneasy

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

//Alternate spelling
#define DESEN_ACTIVE_MID	DESEN_ACTIVE_MED

//An event that you cannot become used to
#define DESEN_NONE	1

//Passive effects tick each second so they have MUCH lower desensitisation rates
#define DESEN_PASSIVE_HIGH	0.99
#define DESEN_PASSIVE_MED	0.995
#define DESEN_PASSIVE_LOW	0.999

//Alternate spelling
#define DESEN_PASSIVE_MID	DESEN_PASSIVE_MED



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
#define TAG_BLOOD	"blood"	//Bloodstains on floor, walls, and people
#define TAG_MONSTER	"monster"	//Live necromorphs, scary illusions. Generally witnessing horrible creatures face to face
#define TAG_ALIEN	"alien"	//Marker, shards and other alien artefacts
#define TAG_GRAFFITI	"graffiti"	//Runes and writing
#define TAG_WHISPER	"whisper"

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
#define SANITY_REGEN_BASE	0.08333	//5 points restored per minute


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



#define PSYCH_DIAGNOSTIC_NONE	0
#define PSYCH_DIAGNOSTIC_AMATEUR	1
#define PSYCH_DIAGNOSTIC_PROFESSIONAL	2
#define PSYCH_DIAGNOSTIC_EXPERT	3
#define PSYCH_DIAGNOSTIC_MASTER	4