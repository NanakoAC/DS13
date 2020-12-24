/client/proc/admin_add_sanity_effect(var/mob/living/carbon/human/H)
	set name = "Add Sanity Effect"
	set desc = "Adds a sanity effect of your choice to the victim"
	set category = "Fun"


	var/mob/M = usr
	if (!istype(H) || QDELETED(H)|| QDELETED(M))
		return


	var/choice_name = input(M,"Choose which sanity effect to add" ,"Sanity Effects") as null|anything in GLOB.sanity_effects_by_name

	if (!choice_name)
		return

	var/datum/extension/sanity_effect/SE = GLOB.sanity_effects_by_name[choice_name]

	//First we will try to apply it safely
	var/success = H.apply_sanity_effect(SE.type, TRUE)


	//If that fails we can force it to apply, bypassing safety checks
	if (!success)
		var/a = alert(M, "ERROR: Failed to safely apply [SE.name], would you like to force it anyway? This may cause buggy behaviour or runtime errors",
		"Sanity error", "Force", "Choose Again")

		if (a == "Force")
			H.apply_sanity_effect(SE.type, FALSE)


	//Lastly now that we're done, call this function again recursively so the menu pops up again.
	//We'll keep doing this until user manually cancels
	spawn(1)
		admin_add_sanity_effect(H)