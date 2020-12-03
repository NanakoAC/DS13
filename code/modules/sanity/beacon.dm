/*
	Horror Beacon:
	Horror beacons are used for passive sources of insanity
	An HB is an invisible object which acts as an atomic holder for a passive scan extension.
	We make the assumption that if someone can see the beacon, then they can see the horrible things nearby


*/
/obj/horror_beacon
	var/area/registered_area
	var/datum/extension/sanity_scan/passive/scan_extension
	density = FALSE
	opacity = FALSE

	//TODO: Remove this icon. Visuals are temporary and only for debugging
	icon = 'icons/obj/objects.dmi'
	icon_state = "shieldon"

/obj/horror_beacon/Initialize()
	.=..()
	var/area/A = get_area(src)
	if (A)
		LAZYADD(A.horror_beacons, src)
		registered_area = A

		//This extension will setup scanning and prox triggers
		scan_extension = set_extension(src, /datum/extension/sanity_scan/passive)
	else
		//If we somehow have no area, something has gone horribly wrong
		return INITIALIZE_HINT_QDEL


/obj/horror_beacon/Destroy()
	scan_extension = null	//Parent destroy behaviour will remove and delete it, we just remove this reference so we dont interfere
	.=..()
	if (registered_area)
		LAZYREMOVE(registered_area.horror_beacons, src)


/*
	Wrapper for registering a source on the scan extension
*/
/obj/horror_beacon/proc/register(var/atom/thing, var/datum/sanity_source/source)
	scan_extension.add_source(thing, source)