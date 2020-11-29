//Returns the direction from A to B, rounded to the nearest cardinal
//Doing this repeatedly can be used to trace a stair-pattern path towards diagonal objects
/proc/get_cardinal_dir(atom/A, atom/B)
	var/vector2/direction = get_new_vector(B.x - A.x, B.y - A.y)
	if (!direction.NonZero())	//Error!
		return SOUTH	//Default value in case of emergencies
	direction.SelfNormalize()
	var/angle = direction.AngleFrom(Vector2.North)
	angle = round(angle, 90)
	release_vector(direction)
	return turn(NORTH, angle)

//duplicated code for speed
/proc/get_cardinal_step_towards(atom/A, atom/B)
	var/vector2/direction = get_new_vector(B.x - A.x, B.y - A.y)
	if (!direction.NonZero())	//Error!
		return get_step(A, SOUTH)	//Default value in case of emergencies
	direction.SelfNormalize()
	var/angle = direction.AngleFrom(Vector2.North)
	angle = round(angle, 90)
	var/stepdir = turn(NORTH, -angle)	//Minus angle because turn rotates counterclockwise
	release_vector(direction)
	return get_step(A, stepdir)


//Checks if target is within arc degrees either side of user's forward vector.
//Used to make mobs that can only click on stuff infront of them
//The default arc of 210 is approximately accurate to real life, based on the FOV wikipedia article at least
//Code supplied by Kaiochao
	//Note: Rounding included to compensate for a byond bug in 513.1497.
	//Without the rounding, cos(90) returns an erroneous value which breaks this proc

/proc/target_in_frontal_arc(var/mob/user, var/atom/target, var/arc = 210)
	//You are allowed to click yourself and things in your own turf
	if (get_turf(user) == get_turf(target))
		return TRUE

	var/vector2/dirvector = Vector2.NewFromDir(user.dir)
	var/vector2/dotvector = get_new_vector(target.x - user.x, target.y - user.y)
	dotvector.SelfNormalize()
	. = (round(dirvector.Dot(dotvector),0.000001) >= round(cos(arc),0.000001))
	release_vector(dirvector)
	release_vector(dotvector)



//Checks if target is within arc degrees either side of a specified direction vector from user. All parameters are mandatory
//Rounding explained above
/proc/target_in_arc(var/atom/origin, var/atom/target, var/vector2/direction, var/arc)
	origin = get_turf(origin)
	target = get_turf(target)
	if (origin == target)
		return TRUE

	var/vector2/dirvector = direction.Copy()
	var/vector2/dotvector = get_new_vector(target.x - origin.x, target.y - origin.y)
	dotvector.SelfNormalize()
	.= (round(dirvector.Dot(dotvector),0.000001) >= round(cos(arc),0.000001))
	release_vector(dotvector)
	release_vector(dirvector)