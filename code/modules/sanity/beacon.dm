/*
	Horror Beacon:
	Horror beacons are used for passive sources of insanity
	An HB is an invisible object which takes into account all the scary things around it, and distributes sanity damage appropriately.
	They are primarily used for a massive optimisation, at a minor cost in accuracy.
	We make the assumption that if someone can see the beacon, then they can see the horrible things nearby

	To calculate sight, the beacon uses a view proximity trigger to track tiles that it can see. Anyone stepping onto one of those
	will do some more advanced visibility calculations
*/