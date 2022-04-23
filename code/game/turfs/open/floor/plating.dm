/* In this file:
 *
 * Plating
 * Airless
 * Airless plating
 * Engine floor
 * Foam plating
 */

/turf/open/floor/plating
	name = "plating"
	icon_state = "plating"
	intact = FALSE
	baseturfs = /turf/baseturf_bottom
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	FASTDMM_PROP(\
		pipe_astar_cost = 1\
	)

	var/attachment_holes = TRUE

/turf/open/floor/plating/examine(mob/user)
	. = ..()
	if(broken || burnt)
		. += "<span class='notice'>It looks like the dents could be <i>welded</i> smooth.</span>"
		return
	if(attachment_holes)
		. += "<span class='notice'>There are a few attachment holes for a new <i>tile</i>, reinforcement <i>sheets</i> or catwalk <i>rods</i>.</span>"
	else
		. += "<span class='notice'>You might be able to build ontop of it with some <i>tiles</i>...</span>"

/turf/open/floor/plating/Initialize(mapload)
	if (!broken_states)
		broken_states = list("platingdmg1", "platingdmg2", "platingdmg3")
	if (!burnt_states)
		burnt_states = list("panelscorched")
	. = ..()
	if(!attachment_holes || (!broken && !burnt))
		icon_plating = icon_state
	else
		icon_plating = initial(icon_state)

/turf/open/floor/plating/update_icon()
	if(!..())
		return
	if(!broken && !burnt)
		icon_state = icon_plating //Because asteroids are 'platings' too.

/turf/open/floor/plating/attackby(obj/item/C, mob/user, params)
	if(..())
		return
	if(istype(C, /obj/item/stack/rods) && attachment_holes)
		if(broken || burnt)
			to_chat(user, "<span class='warning'>Repair the plating first!</span>")
			return
		if(locate(/obj/structure/lattice/catwalk/over, src))
			return
		if (istype(C, /obj/item/stack/rods))
			var/obj/item/stack/rods/R = C
			if (R.use(2))
				to_chat(user, "<span class='notice'>You lay down the catwalk.</span>")
				playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
				new /obj/structure/lattice/catwalk/over(src)
				return
	if(istype(C, /obj/item/stack/sheet/iron) && attachment_holes)
		if(broken || burnt)
			to_chat(user, "<span class='warning'>Repair the plating first!</span>")
			return
		var/obj/item/stack/sheet/iron/R = C
		if (R.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need one sheet to make a reinforced floor!</span>")
			return
		else
			to_chat(user, "<span class='notice'>You begin reinforcing the floor...</span>")
			if(do_after(user, 30, target = src))
				if (R.get_amount() >= 1 && !istype(src, /turf/open/floor/engine))
					PlaceOnTop(/turf/open/floor/engine, flags = CHANGETURF_INHERIT_AIR)
					playsound(src, 'sound/items/deconstruct.ogg', 80, 1)
					R.use(1)
					to_chat(user, "<span class='notice'>You reinforce the floor.</span>")
				return
	else if(istype(C, /obj/item/stack/tile) && !locate(/obj/structure/lattice/catwalk, src))
		if(!broken && !burnt)
			for(var/obj/O in src)
				if(O.level == 1) //ex. pipes laid underneath a tile
					for(var/M in O.buckled_mobs)
						to_chat(user, "<span class='warning'>Someone is buckled to \the [O]! Unbuckle [M] to move \him out of the way.</span>")
						return
			var/obj/item/stack/tile/W = C
			if(!W.use(1))
				return
			var/turf/open/floor/T = PlaceOnTop(W.turf_type, flags = CHANGETURF_INHERIT_AIR)
			if(istype(W, /obj/item/stack/tile/light)) //TODO: get rid of this ugly check somehow
				var/obj/item/stack/tile/light/L = W
				var/turf/open/floor/light/F = T
				F.state = L.state
			playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
		else
			to_chat(user, "<span class='warning'>This section is too damaged to support a tile! Use a welder to fix the damage.</span>")

/turf/open/floor/plating/welder_act(mob/living/user, obj/item/I)
	if((broken || burnt) && I.use_tool(src, user, 0, volume=80))
		to_chat(user, "<span class='danger'>You fix some dents on the broken plating.</span>")
		icon_state = icon_plating
		burnt = FALSE
		broken = FALSE

	return TRUE

/turf/open/floor/plating/make_plating()
	return

/turf/open/floor/plating/rust_heretic_act()
	if(prob(70))
		new /obj/effect/temp_visual/glowing_rune(src)
	ChangeTurf(/turf/open/floor/plating/rust)

/turf/open/floor/plating/foam
	name = "metal foam plating"
	desc = "Thin, fragile flooring created with metal foam."
	icon_state = "foam_plating"

/turf/open/floor/plating/foam/burn_tile()
	return //jetfuel can't melt steel foam

/turf/open/floor/plating/foam/break_tile()
	return //jetfuel can't break steel foam...

/turf/open/floor/plating/foam/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/tile/plasteel))
		var/obj/item/stack/tile/plasteel/P = I
		if(P.use(1))
			var/obj/L = locate(/obj/structure/lattice) in src
			if(L)
				qdel(L)
			to_chat(user, "<span class='notice'>You reinforce the foamed plating with tiling.</span>")
			playsound(src, 'sound/weapons/Genhit.ogg', 50, TRUE)
			ChangeTurf(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
	else
		playsound(src, 'sound/weapons/tap.ogg', 100, TRUE) //The attack sound is muffled by the foam itself
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(src)
		if(prob(I.force * 20 - 25))
			user.visible_message("<span class='danger'>[user] smashes through [src]!</span>", \
							"<span class='danger'>You smash through [src] with [I]!</span>")
			ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
		else
			to_chat(user, "<span class='danger'>You hit [src], to no effect!</span>")

/turf/open/floor/plating/foam/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_FLOORWALL)
		return list("mode" = RCD_FLOORWALL, "delay" = 0, "cost" = 1)

/turf/open/floor/plating/foam/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	if(passed_mode == RCD_FLOORWALL)
		to_chat(user, "<span class='notice'>You build a floor.</span>")
		ChangeTurf(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
		return TRUE
	return FALSE

/turf/open/floor/plating/foam/ex_act()
	..()
	ScrapeAway(flags = CHANGETURF_INHERIT_AIR)

/turf/open/floor/plating/foam/tool_act(mob/living/user, obj/item/I, tool_type)
	return

/turf/open/floor/plating/can_have_cabling()
	if(locate(/obj/structure/lattice/catwalk, src))
		return 0
	return 1

/turf/open/floor/plating/hinged
var/opened = FALSE
var/is_animating_door = FALSE
var/icon_door = null
var/icon_door_override = FALSE
var/obj/effect/overlay/closet_door/door_obj
var/door_anim_squish = 0.30
var/door_anim_angle = 136
var/door_hinge = -6.5
var/door_anim_time = 2.0
var/open_sound = 'sound/machines/closet_open.ogg'
var/close_sound = 'sound/machines/closet_close.ogg'
var/open_sound_volume = 35
var/close_sound_volume = 50

/turf/open/floor/plating/hinged/update_icon()
	if(istype(src, /obj/structure/closet/supplypod))
		return ..()
	cut_overlays()
	if(!opened)
		layer = OBJ_LAYER
		if(!is_animating_door)
			if(icon_door)
				add_overlay("[icon_door]")
			else
				add_overlay("[icon_state]")

	else
		layer = BELOW_OBJ_LAYER
		if(!is_animating_door)
			if(icon_door_override)
				add_overlay("[icon_door]_open")
			else
				add_overlay("[icon_state]_open")

/turf/open/floor/plating/hinged/proc/animate_door(var/closing = FALSE)
	if(!door_anim_time)
		return
	if(!door_obj) door_obj = new
	vis_contents |= door_obj
	door_obj.icon = icon
	door_obj.icon_state = "[icon_door || icon_state]_door"
	is_animating_door = TRUE
	var/num_steps = door_anim_time / world.tick_lag
	for(var/I in 0 to num_steps)
		var/angle = door_anim_angle * (closing ? 1 - (I/num_steps) : (I/num_steps))
		var/matrix/M = get_door_transform(angle)
		var/door_state = angle >= 90 ? "[icon_door_override ? icon_door : icon_state]_back" : "[icon_door || icon_state]_door"
		var/door_layer = angle >= 90 ? FLOAT_LAYER : ABOVE_MOB_LAYER

		if(I == 0)
			door_obj.transform = M
			door_obj.icon_state = door_state
			door_obj.layer = door_layer
		else if(I == 1)
			animate(door_obj, transform = M, icon_state = door_state, layer = door_layer, time = world.tick_lag, flags = ANIMATION_END_NOW)
		else
			animate(transform = M, icon_state = door_state, layer = door_layer, time = world.tick_lag)
	addtimer(CALLBACK(src,.proc/end_door_animation),door_anim_time,TIMER_UNIQUE|TIMER_OVERRIDE)

/turf/open/floor/plating/hinged/proc/end_door_animation()
	is_animating_door = FALSE
	vis_contents -= door_obj
	update_icon()
	COMPILE_OVERLAYS(src)

/turf/open/floor/plating/hinged/proc/get_door_transform(angle)
	var/matrix/M = matrix()
	M.Translate(-door_hinge, 0)
	M.Multiply(matrix(cos(angle), 0, 0, -sin(angle) * door_anim_squish, 1, 0))
	M.Translate(door_hinge, 0)
	return M

/turf/open/floor/plating/hinged/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!(user.mobility_flags & MOBILITY_STAND) && get_dist(src, user) > 0)
		return
	toggle(user)

/turf/open/floor/plating/hinged/proc/toggle(mob/living/user)
	if(opened)
		return close(user)
	else
		return open(user)

/turf/open/floor/plating/hinged/proc/open(mob/living/user)
	if(opened)
		return
	playsound(loc, open_sound, open_sound_volume, 1, -3)
	opened = TRUE
	animate_door(FALSE)
	update_icon()
	return 1

/turf/open/floor/plating/hinged/proc/close(mob/living/user)
	if(!opened)
		return FALSE
	playsound(loc, close_sound, close_sound_volume, 1, -3)
	opened = FALSE
	animate_door(TRUE)
	update_icon()
	return TRUE
