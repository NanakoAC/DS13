// BYOND lower-cases color values, and thus we do so as well to ensure atom.color == COLOR_X will work correctly
#define COLOR_BLACK            "#000000"
#define COLOR_NAVY_BLUE        "#000080"
#define COLOR_GREEN            "#008000"
#define COLOR_DARK_GRAY        "#404040"
#define COLOR_MAROON           "#800000"
#define COLOR_PURPLE           "#800080"
#define COLOR_VIOLET           "#9933ff"
#define COLOR_OLIVE            "#808000"
#define COLOR_BROWN_ORANGE     "#824b28"
#define COLOR_DARK_ORANGE      "#b95a00"
#define COLOR_GRAY40           "#666666"
#define COLOR_SEDONA           "#cc6600"
#define COLOR_DARK_BROWN       "#917448"
#define COLOR_BLUE             "#0000ff"
#define COLOR_DEEP_SKY_BLUE    "#00e1ff"
#define COLOR_LIME             "#00ff00"
#define COLOR_CYAN             "#00ffff"
#define COLOR_TEAL             "#33cccc"
#define COLOR_RED              "#ff0000"
#define COLOR_PINK             "#ff00ff"
#define COLOR_ORANGE           "#ff9900"
#define COLOR_YELLOW           "#ffff00"
#define COLOR_GRAY             "#808080"
#define COLOR_RED_GRAY         "#aa5f61"
#define COLOR_BROWN            "#b19664"
#define COLOR_GREEN_GRAY       "#8daf6a"
#define COLOR_BLUE_GRAY        "#6a97b0"
#define COLOR_SUN              "#ec8b2f"
#define COLOR_PURPLE_GRAY      "#a2819e"
#define COLOR_BLUE_LIGHT       "#33ccff"
#define COLOR_RED_LIGHT        "#ff3333"
#define COLOR_BEIGE            "#ceb689"
#define COLOR_PALE_GREEN_GRAY  "#aed18b"
#define COLOR_PALE_RED_GRAY    "#cc9090"
#define COLOR_PALE_PURPLE_GRAY "#bda2ba"
#define COLOR_PALE_BLUE_GRAY   "#8bbbd5"
#define COLOR_LUMINOL          "#66ffff"
#define COLOR_SILVER           "#c0c0c0"
#define COLOR_GRAY80           "#cccccc"
#define COLOR_OFF_WHITE        "#eeeeee"
#define COLOR_WHITE            "#ffffff"
#define COLOR_NT_RED           "#9d2300"
#define COLOR_GUNMETAL         "#545c68"
#define COLOR_MUZZLE_FLASH     "#ffffb2"
#define COLOR_CHESTNUT         "#996633"
#define COLOR_BEASTY_BROWN     "#663300"
#define COLOR_WHEAT            "#ffff99"
#define COLOR_CYAN_BLUE        "#3366cc"
#define COLOR_LIGHT_CYAN       "#66ccff"
#define COLOR_PAKISTAN_GREEN   "#006600"
#define COLOR_HULL             "#436b8e"
#define COLOR_AMBER            "#ffbf00"
#define COLOR_COMMAND_BLUE     "#46698c"
#define COLOR_SKY_BLUE         "#5ca1cc"
#define COLOR_PALE_ORANGE      "#b88a3b"
#define COLOR_CIVIE_GREEN      "#b7f27d"
#define COLOR_TITANIUM         "#d1e6e3"
#define COLOR_DARK_GUNMETAL    "#4c535b"
#define COLOR_GOLD				"#d4af37"

#define	PIPE_COLOR_GREY        "#ffffff"	//yes white is grey
#define	PIPE_COLOR_RED         "#ff0000"
#define	PIPE_COLOR_BLUE        "#0000ff"
#define	PIPE_COLOR_CYAN        "#00ffff"
#define	PIPE_COLOR_GREEN       "#00ff00"
#define	PIPE_COLOR_YELLOW      "#ffcc00"
#define	PIPE_COLOR_BLACK       "#444444"
#define	PIPE_COLOR_ORANGE      "#b95a00"

#define	COMMS_COLOR_DEFAULT    "#ff00ff"
#define	COMMS_COLOR_ENTERTAIN  "#666666"
#define	COMMS_COLOR_AI         "#ff00ff"
#define	COMMS_COLOR_COMMON     "#408010"
#define	COMMS_COLOR_SERVICE    "#709b00"
#define	COMMS_COLOR_SUPPLY     "#7f6539"
#define	COMMS_COLOR_SCIENCE    "#993399"
#define	COMMS_COLOR_MEDICAL    "#009190"
#define	COMMS_COLOR_MINING     "#929820"
#define	COMMS_COLOR_ENGINEER   "#a66300"
#define	COMMS_COLOR_SECURITY   "#930000"
#define	COMMS_COLOR_COMMAND    "#204090"
#define	COMMS_COLOR_CENTCOMM   "#5c5c7c"
#define	COMMS_COLOR_SYNDICATE  "#6d3f40"

#define GLASS_COLOR            "#74b1ee"
#define GLASS_COLOR_PHORON     "#7c3a9a"
#define GLASS_COLOR_TINTED     "#222222"
#define GLASS_COLOR_FROSTED    "#ffffff"

#define COLOR_BLOOD_HUMAN      "#a10808"
#define COLOR_BLOOD_NECRO      "#583001"

#define COLOR_KINESIS_INDIGO	"#4d59db"
#define COLOR_KINESIS_INDIGO_PALE	"#9fa6f5"

#define COLOR_NECRO_YELLOW		"#FFFF00"
#define COLOR_MARKER_RED		"#FF4444"
#define COLOR_BIOMASS_GREEN		"#53761d"
#define COLOR_BIOLUMINESCENT_ORANGE "#ffb347"

// Codex category colours.
#define CODEX_COLOR_LORE      "#abdb9b"
#define CODEX_COLOR_MECHANICS "#9ebcd8"
#define CODEX_COLOR_ANTAG     "#e5a2a2"

#define COLOR_OOC	"#960018"

//These three are components of the luminance vector, a thing used in color matrices
//I don't honestly know what they actually stand for, other than that the first letters are red, green, blue
#define RWGT	0.3086
#define GWGT	0.6094
#define BWGT	0.0820

#define RANDOM_RGB rgb(rand(0,255), rand(0,255), rand(0,255))

/obj/colorscrew
	plane = OBJ_PLANE
	screen_loc = "1,1"
	appearance_flags = PLANE_MASTER | NO_CLIENT_COLOR
	blend_mode = BLEND_OVERLAY

/obj/colorscrew/Initialize()
	set waitfor = FALSE
	.=..()

	while (TRUE)
		//This raises brightness i guess
		var/saturation = rand_between(0, 4)
		filters = filter(type="blur", size=saturation)
		world << "Set saturation to [saturation]"
		sleep(20)

/obj/colorscrew_two
	plane = ABOVE_HUD_PLANE
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "grey"
	appearance_flags = NO_CLIENT_COLOR
	blend_mode = BLEND_OVERLAY
	var/client/C

/obj/colorscrew_two/New(var/thing)
	world << "New screenthing [thing]"
	C = thing
	.=..()

/obj/colorscrew_two/Initialize()
	set waitfor = FALSE
	.=..()

	alpha = 128
	while (TRUE)
		//This raises brightness i guess
		var/saturation = rand_between(0, 4)
		filters = filter(type="blur", size=saturation)
		world << "Set saturation to [saturation]"
		sleep(20)




/obj/colorscrew_three
	plane = ABOVE_HUD_PLANE
	//icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	//icon_state = "grey"
	//appearance_flags = NO_CLIENT_COLOR
	blend_mode = BLEND_OVERLAY
	var/client/C

/obj/colorscrew_three/New(var/thing)
	world << "New screenthing [thing]"
	C = thing
	.=..()

/obj/colorscrew_three/Initialize()
	set waitfor = FALSE
	.=..()

	while (TRUE)
		//This raises brightness i guess
		var/saturation = rand_between(-4, 4)
		C.color = get_saturation_matrix(saturation)
		sleep(20)



/client/verb/colorscrew()
	set name = "colorscrew"

	screen += new /obj/colorscrew(src)


/client/verb/colorscrew_two()
	set name = "colorscrew 2"

	screen += new /obj/colorscrew_two(src)

/client/verb/colorscrew_three()
	set name = "colorscrew 3"

	screen += new /obj/colorscrew_three(src)