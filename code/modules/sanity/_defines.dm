/*
	This is only for folder specific defines, most of the real values are in _defines/sanity.dm
*/

//Sanity effect safety check results
#define CHECK_NEVER	0	//This effect will never be applied to this mob during this round
#define CHECK_INVALID	1	//This effect can't be applied right now, try again later
#define CHECK_NOT_IDEAL	2	//This effect can be applied, but is not great. Move it into a Plan B shortlist, but keep looking
#define CHECK_IDEAL	3	//This effect is perfect, accept it right now


#define REFERENCE	"reference"