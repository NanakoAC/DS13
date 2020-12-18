/*
	This is only for folder specific defines, most of the real values are in _defines/sanity.dm
*/

//Sanity effect safety check results
#define CHECK_NEVER	0	//This effect will never be applied to this mob during this round
#define CHECK_INVALID	1	//This effect can't be applied right now, try again later

//This effect could have been triggered, but some user action has been taken to block it. For example:
//strait jacket, restraints, antipsychotic drugs, etc
//We will allow it to be applied anyway even if instant, but it can't trigger.
//For purposes of applying, treated as identical to CHECK_IDEAL, because we don't want to punish players for preventative action
#define CHECK_PREVENTED 2

#define CHECK_NOT_IDEAL	3	//This effect can be applied, but is not great. Move it into a Plan B shortlist, but keep looking
#define CHECK_IDEAL	4	//This effect is perfect, accept it right now


#define REFERENCE	"reference"


/*
	Status flags for sanity effects
*/
#define STATUS_DORMANT	1	//Applied but not currently active
#define STATUS_ACTIVE	2	//Currently active and doing stuff
#define STATUS_FADING	3
/* A fading effect is still applied, but not for long. It can never trigger again, can't be treated, and will be removed on its own
	after some time. The purpose of fading effects is just to hang onto some reserved insanity for a few minutes.

	They will only show in the mind menu for really high psych skill
 */