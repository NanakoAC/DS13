
/mob
	var/list/screens = list()

/mob/proc/set_fullscreen(condition, screen_name, screen_type, arg)
	condition ? overlay_fullscreen(screen_name, screen_type, arg) : clear_fullscreen(screen_name)

/mob/proc/overlay_fullscreen(category, type, severity)

	var/rescale = FALSE
	var/obj/screen/fullscreen/screen = screens[category]

	if(!client) //The mob needs to be player-controlled to modify the screen

		return

	if (client.temp_view != world.view)
		rescale = TRUE



	if(screen)
		if(screen.type != type)
			clear_fullscreen(category, FALSE)
			screen = null
		else if(!severity || severity == screen.severity)
			return null


	if(!screen)
		screen = new type()
		screen.owner = src


	screen.icon_state = "[initial(screen.icon_state)][severity]"
	screen.severity = severity

	if (rescale)
		screen.set_size(client)

	screens[category] = screen
	if(client && (stat != DEAD || screen.allstate))

		client.screen += screen
	return screen

/mob/proc/clear_fullscreen(category, animated = 10)

	var/obj/screen/fullscreen/screen = screens[category]

	if(!screen)
		return

	screens -= category

	if(animated)
		spawn(0)
			animate(screen, alpha = 0, time = animated)
			sleep(animated)
			if(client)
				client.screen -= screen
			qdel(screen)
	else
		if(client)
			client.screen -= screen
		qdel(screen)

/mob/proc/clear_fullscreens()
	for(var/category in screens)
		clear_fullscreen(category, 0)

/mob/proc/hide_fullscreens()
	if(client)
		for(var/category in screens)
			client.screen -= screens[category]

/mob/proc/reload_fullscreen()
	if(client)
		for(var/category in screens)
			var/obj/screen/fullscreen/F = screens[category]
			var/newtype
			if (F)
				newtype = F.type
			clear_fullscreen(category, 0)
			//client.screen -= screens[category]
			overlay_fullscreen(category, newtype, INFINITY)


/proc/get_or_create_fullscreen(var/view_radius)
	var/pixels = ((view_radius*2)+1)*world.icon_size
	var/entry_name = "[pixels]x[pixels]"
	if (!GLOB.fullscreen_icons[entry_name])
		//If the icons isn't made yet, make it and set it in the global list
		GLOB.fullscreen_icons[entry_name] = rescale_icon('icons/mob/screen_full.dmi', pixels, pixels)
	return GLOB.fullscreen_icons[entry_name] //Then return it


/obj/screen/fullscreen
	icon = 'icons/mob/screen_full.dmi'
	icon_state = "default"
	screen_loc = "BOTTOMLEFT"
	plane = FULLSCREEN_PLANE
	mouse_opacity = 0
	var/small_icon = FALSE	//True on any that don't use screen_full.dmi
	var/severity = 0
	var/allstate = 0 //shows if it should show up for dead people too
	var/mob/owner

/obj/screen/fullscreen/proc/set_size(var/client/C)
	//Here we select (and if needed, generate) the icon for the right size
	if (C.temp_view == world.view)
		return	//No special sizing needed

	icon = get_or_create_fullscreen(C.temp_view)



/obj/screen/fullscreen/Destroy()
	severity = 0
	owner = null
	return ..()

/obj/screen/fullscreen/brute
	icon_state = "brutedamageoverlay"
	layer = DAMAGE_LAYER

/obj/screen/fullscreen/oxy
	icon_state = "oxydamageoverlay"
	layer = DAMAGE_LAYER

/obj/screen/fullscreen/crit
	icon_state = "passage"
	layer = CRIT_LAYER

/obj/screen/fullscreen/blind
	icon_state = "blackimageoverlay"
	layer = DAMAGE_LAYER

/obj/screen/fullscreen/impaired
	icon_state = "impairedoverlay"
	layer = IMPAIRED_LAYER

/obj/screen/fullscreen/flash/noise
	icon_state = "noise"

/obj/screen/fullscreen/fishbed
	icon_state = "fishbed"
	allstate = 1

/obj/screen/fullscreen/pain
	icon_state = "brutedamageoverlay6"
	alpha = 0

/obj/screen/fullscreen/pain/Destroy()
	if (owner && owner.pain == src)
		owner.pain = null
	.= ..()


//Small icons
//-------------------------
/obj/screen/fullscreen/blackout
	icon = 'icons/mob/screen1.dmi'
	icon_state = "blackout"
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	layer = DAMAGE_LAYER
	small_icon = TRUE



/obj/screen/fullscreen/blurry
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "blurry"
	small_icon = TRUE

/obj/screen/fullscreen/flash
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "flash"



/obj/screen/fullscreen/high
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "druggy"
	small_icon = TRUE

/obj/screen/fullscreen/noise
	icon = 'icons/effects/static.dmi'
	icon_state = "1 light"
	screen_loc = ui_entire_screen
	layer = FULLSCREEN_LAYER
	alpha = 127
	small_icon = TRUE

/obj/screen/fullscreen/fadeout
	icon = 'icons/mob/screen1.dmi'
	icon_state = "black"
	screen_loc = ui_entire_screen
	layer = FULLSCREEN_LAYER
	alpha = 0
	allstate = 1
	small_icon = TRUE

/obj/screen/fullscreen/fadeout/Initialize()
	. = ..()
	animate(src, alpha = 255, time = 10)

/obj/screen/fullscreen/scanline
	icon = 'icons/effects/static.dmi'
	icon_state = "scanlines"
	screen_loc = ui_entire_screen
	alpha = 50
	layer = FULLSCREEN_LAYER
	small_icon = TRUE


