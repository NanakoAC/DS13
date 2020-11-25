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

//Cap on sanity damage from active shouts from necromorphs
#define SANITY_CAP_SHOUT	300