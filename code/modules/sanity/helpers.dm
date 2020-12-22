/*
	This list contains descriptions for various sanity damage levels
	The ones used are those assigned to the smallest number which is >= our current insanity

	Negative values are used when factoring in resolve too
*/

GLOBAL_LIST_INIT(sanity_descriptions, list("-200" = list("heroic", "fearless", "indomitable", "on top of the world"),
"-100" = list("gutsy", "gallant", "resolute", "high_spirited", "stalwart"),
"-50" = list("fired up", "cheering", "resolveous", "tenacious"),
"-20" = list("confident", "ready", "motivated", "energetic"),
"-5" = list("comfortable", "relaxed", "cheerful"),
"0" = list("fine", "ordinary", "normal", "bored"),
"50" = list("annoyed", "irritable", "on edge", "uneasy", "restless"),
"100" = list("anxious", "irrational", "distressed", "nervous", "spooked"),
"200" = list("trembling", "worried", "fearful", "shaken", "melancholy"),
"350" = list("scared", "incoherent", "panicking", "traumatised"),
"500" = list("cracking", "unhinged", "terrified", "haunted", "crying"),
"800" = list("gibbering", "screaming", "broken", "sobbing", "suffering"),
"1000" = list("............", "kill me....please", "make it stop"),
"1200" = list("f i n e", "smiling.", "wouldn't you like to know?", "none of your business", "The Higher I Rise the More I SEE")))


/*
	Works with the above menu to get a description for an insanity value
	if an existing string is passed, and the list we select contains that string, then we will return that same string unaltered
*/
/proc/insanity_description(var/value, var/existing)
	var/list/strings
	for (var/numstring in GLOB.sanity_descriptions)
		var/num = text2num(numstring)
		if (num >= value)
			strings = GLOB.sanity_descriptions[numstring]
			break

	if (strings)
		if ((existing in strings))
			return existing
		return pick(strings)

	return existing




/*
	When looking at the sanity log, entries are color coded depending on how recently they happened.
	Bright and red when new, grey when ages ago
*/
GLOBAL_LIST_INIT(sanity_log_time_colors, list(
"[10 SECONDS]" = "#FF0000",
"[30 SECONDS]" = "#EE2222",
"[1 MINUTES]" = "#DD4444",
"[2 MINUTES]" = "#CC6666",
"[5 MINUTES]" = "#BB8888",
"[10 MINUTES]" = "#AAAAAA",
"[15 MINUTES]" = "#999999",
"[30 MINUTES]" = "#888888",
"[1 HOUR]" = "#777777",
"[INFINITY]" = "#666666"))

//Go down the list until we find a number higher than the delta
/proc/sanity_log_time_color(var/value)
	for (var/numstring in GLOB.sanity_log_time_colors)
		var/num = text2num(numstring)
		if (num >= value)
			return GLOB.sanity_log_time_colors[numstring]



	return "#FFFFFF"