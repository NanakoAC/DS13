/*
	Nanako's Sanity System


	Insanity:
	----------
	AKA: Sanity Damage
	AKA: Psychosis

	Insanity represents how insane you are. The normal value for an ordinary sane human is zero, and it cannot go negative.

	Each human has an insanity value which starts at 0 and can rise to over 1000. Various effects trigger from it

	Insanity is only gained from horrible or spooky things. Witnessing violence, blood, gore, hearing screams, having signals mess
	with you, etc.
	Under normal circumstances, insanity will always remain at zero, you won't start going mad because you missed lunch or saw
	some trash.




	Sanity Effects:
	----------------
	An effect is a tangible consequence of your insanity. You may start stumbling around dizzy, or be posessed with an urge to cut
	yourself and bleed everywhere, or lose control and suck on the barrel of your gun.

	Higher insanity primarily affects the severity of these effects. More of it means more and more dangerous effects.


	Sanity effects are divided into four very loose tiers

	Minor:	0-100	Slight annoyances, one-off effects, inconveniences
	Moderate:	0-400	Compulsions. Things which actively get worse if you don't behave in certain ways, encourage participation from users
	Major:	400-1000	Severe dangers, dangerous compulsions, things with a good chance of getting you killed
	Critical:	1000+	Mostly comprised of instant death effects. Things at this tier are only survivable if you are restrained and medicated

	"Getting worse" usually means gaining more insanity as a punishment, and bringing you closer to the critical tier which will kill you

	The tiers are minimums, not limits. Weaker effects can still occur at any time even when you're over 1000 insanity. The selection
	of which effects to apply is randomised, but is weighted towards the most severe things that you meet the requirements for,

	see effect.dm for more details



	Recovery and Mood:
	-------------------
	Insanity heals over time naturally, but very slowly. The rate at which it heals is improved by your mood.

	Mood is a measure of several factors. Your comfort, intoxication, bodily needs being met, pain or injuries, hygiene,
	social contact,  etc.
	The higher your mood, the faster insanity goes away. Lower mood penalises this.

	No matter how low it goes, your mood will never ADD insanity. It still only goes up from traumatic things.
	But extremely low mood can entirely disable recovery and prevent you from getting any better

	The most powerful mood boosters are anti-psychotic drugs. These, combined with the comfort of a therapist's office,
	provide the best environment for recovery


	Courage:
	---------
	Courage is your resistance to insanity. For the purposes of calculating sanity effects, your effective insanity is
	insanity minus courage. If you have 100 courage then you'll experience no ill effects at all until insanity hits 101

	Sources of courage are generally vices, and typically temporary. Take a swig of whisky before charging into horrible places


	Adrenaline:
	------------
	Adrenaline is pumped into the body during combat and stressful situations. While its active in your body, new sanity effects will
	not trigger. So no suddenly going mad in the middle of a fight, mostly. Any existing sanity effects you had before the fight, are unaffected

	Insanity still builds up even during this time, and it will hit you like a tidal wave once you're away from battle and left alone
	with your thoughts.

	In addition, adrenaline completely blocks the recovery of insanity, you need to be away from battle to heal your trauma.

	Adrenaline has a fatigue mechanic. If its constantly in your system for some extended time (10-20 mins?) your body adapts to it and
	it stops working. In this case things behave exactly as if you don't have any adrenaline. So you can't just keep fighting forever#


	Insanity Sources:
	-----------------
	Sources of insanity come in two main types:
		Acute:
			Something happens. A monster screams, you witness someone being killed or dismembered,
			glowing runes appear near you, the lights blow out

			Acute events are the most powerful but they are one off, triggered by explicit actions from the necromorph side.


		Passive:
			Something exists and you see it.
			Blood writing, gore everywhere, a corpse, a severed head, the BPL tanks, etc.
			Passive sources are much weaker and have an upper cap to how high they can raise insanity.
			But their effect is constant. As long as you can see the thing, your insanity will gradually keep rising until the cap.


*/