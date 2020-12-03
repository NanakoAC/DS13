/*
	Insanity from a passive tick
	These use hard capping
*/
/mob/living/carbon/human/proc/add_passive_insanity(var/datum/sanity_source/source, var/sanity_damage, var/sanity_limit, var/origin_atom)
	var/datum/mind/M = get_mind()
	if (!M)
		return FALSE

	if (!istype(source))
		source = GLOB.all_sanity_sources[source]

	sanity_damage = (!isnull(sanity_damage)) ? sanity_damage : source.sanity_damage
	sanity_limit = (!isnull(sanity_limit)) ? sanity_limit : source.sanity_limit
	origin_atom = (!isnull(origin_atom)) ? origin_atom : src



	var/current = get_insanity(FALSE, FALSE)
	if (current >= sanity_limit)
		//Hard cap, don't do anything
		return

	//Handle repeat things
	sanity_damage *= get_desensitisation_factor(source)

	M.insanity = min(current+sanity_damage, sanity_limit)


	M.increment_sanity_log(source, sanity_damage)
	//Possible future TODO: Trigger an observation indicating sanity was gained



/*
	This is just a wrapper for a proc in SSsanity, the sanity controller
	Called by an object to register itself as a scary thing, and get assigned to a beacon

	Use only for things which won't move much, and which come in large quantities, like bloodstains
*/
/atom/proc/register_passive_sanity_source(var/sourcetype)
	SSsanity.register_passive_sanity_source(src, sourcetype)


/*
	This is used for specific things which are scary, and relatively unique. there will only be one or few of them,
	In this case the object does not use horror beacons, and it is itself the epicentre.

	Use only for things which won't move much, and which come in simular or very small quantities, like the marker, and harvester nodes
*/
/atom/proc/register_standalone_passive_sanity_source(var/sourcetype)
	var/datum/extension/sanity_scan/passive/scan_extension = set_extension(src, /datum/extension/sanity_scan/passive)
	scan_extension.add_source(src, sourcetype)

/*
	This registers a sanity source which is highly mobile. It has multilayered scanning systems to minimise performance cost

	Best used for objects which might change position frequently
*/
/atom/proc/register_mobile_passive_sanity_source(var/sourcetype)
	var/datum/extension/sanity_scan/active/A = set_extension(src, /datum/extension/sanity_scan/active)
	A.add_source(src, sourcetype)

/*
	This override creates a subtype used for livingmobs specifically.
	Note that this effect will end, and the extension will delete itself, when that mob dies. If you want it to still emit
	scariness after death, you'll need to re-register it as an immobile passive source
*/
/mob/living/register_mobile_passive_sanity_source(var/sourcetype)
	var/datum/extension/sanity_scan/active/mob/A = set_extension(src, /datum/extension/sanity_scan/active/mob)
	A.add_source(src, sourcetype)