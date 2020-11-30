/*
	Horror Beacon:
	Horror beacons are used for passive sources of insanity
	An HB is an invisible object which acts as an atomic holder for a passive scan extension.
	We make the assumption that if someone can see the beacon, then they can see the horrible things nearby


*/
/obj/horror_beacon
	var/area/registered_area

/obj/horror_beacon/Initialize()
	.=..()

	var/area/A = get_area()
	if (A)
		A.horror_beacons.LAZYADD(src)
		registered_area = A



/obj/horror_beacon/Destroy()
	.=..()
	if (registered_area)
		registered_area.horror_beacons.LAZYREMOVE(src)