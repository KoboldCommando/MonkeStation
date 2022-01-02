/obj/item/soup_pot
	name = "\improper Soup Pot"
	desc = "placeholder"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "juicer1"
	resistance_flags = ACID_PROOF
	var/operating = FALSE
	var/obj/item/reagent_containers/beaker = null
	var/obj/item/reagent_containers/soupholder = null
	var/limit = 10
	var/list/holdingitems
	var/static/list/typecache_to_take

	var/static/radial_examine = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_examine")
	var/static/radial_eject = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_eject")
	var/static/radial_mix = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_mix")


/obj/item/soup_pot/Initialize()
	. = ..()
	if(!typecache_to_take)
		typecache_to_take = typecacheof(/obj/item/reagent_containers/food/snacks/grown)
	holdingitems = list()
	beaker = new /obj/item/reagent_containers/glass/beaker/large(src)
	soupholder = new /obj/item/reagent_containers/glass/beaker/bluespace(src)

/obj/item/soup_pot/Destroy()
	beaker = null
	soupholder = null
	drop_all_items()
	return ..()

/obj/item/soup_pot/contents_explosion(severity, target)
	if(beaker)
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += beaker
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += beaker
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += beaker
	if(soupholder)
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += soupholder
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += soupholder
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += soupholder

/obj/item/soup_pot/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !issilicon(user) && !isobserver(user))
		. += "<span class='warning'>You're too far away to examine [src]'s contents and display!</span>"
		return

	if(operating)
		. += "<span class='warning'>\The [src] is boiling!</span>"
		return

	if(beaker || length(holdingitems))
		. += "<span class='notice'>\The [src] contains:</span>"
		for(var/i in holdingitems)
			var/obj/item/O = i
			. += "<span class='notice'>- \A [O.name].</span>"
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			. += "<span class='notice'>- [R.volume] units of [R.name].</span>"
		if(soupholder.reagents.total_volume)
			. += "<span class='notice'>- [soupholder.reagents.total_volume] units of delicious steaming soup!</span>"
		if(!holdingitems.len && !beaker.reagents.total_volume && !soupholder.reagents.total_volume)
			. += "<span class='notice'>- nothing!</span>"

/obj/item/soup_pot/handle_atom_del(atom/A)
	. = ..()
	if(A == beaker)
		beaker = null
		update_icon()
	if(holdingitems[A])
		holdingitems -= A

/obj/item/soup_pot/proc/drop_all_items()
	for(var/i in holdingitems)
		var/atom/movable/AM = i
		AM.forceMove(drop_location())
	holdingitems = list()

/obj/item/soup_pot/update_icon()
	if(beaker)
		icon_state = "juicer1"
	else
		icon_state = "juicer0"

/obj/item/soup_pot/attackby(obj/item/I, mob/user, params)

	if (istype(I, /obj/item/reagent_containers) && !(I.item_flags & ABSTRACT) && I.is_open_container())
		var/obj/item/reagent_containers/J = I
		if(!J.reagents.total_volume)
			to_chat(user, "<span class='warning'>[J] is empty!</span>")
			return

		if(beaker.reagents.holder_full())
			to_chat(user, "<span class='warning'>[src] is full.</span>")
			return

		var/trans = J.reagents.trans_to(src.beaker, J.amount_per_transfer_from_this, transfered_by = user)
		to_chat(user, "<span class='notice'>You fill [src] with [trans] unit\s of the contents of [J].</span>")

	else if(holdingitems.len >= limit)
		to_chat(user, "<span class='warning'>[src] is filled to capacity!</span>")
		return TRUE

	else if(user.transferItemToLoc(I, src))
		to_chat(user, "<span class='notice'>You add [I] to [src].</span>")
		holdingitems[I] = TRUE
		return FALSE

/*
	if(holdingitems.len >= limit)
		to_chat(user, "<span class='warning'>[src] is filled to capacity!</span>")
		return TRUE

	if(!I.grind_results && !I.juice_results)
		if(user.a_intent == INTENT_HARM)
			return ..()
		else
			to_chat(user, "<span class='warning'>You cannot grind [I] into reagents!</span>")
			return TRUE

	if(!I.grind_requirements(src)) //Error messages should be in the objects' definitions
		return

	if(user.transferItemToLoc(I, src))
		to_chat(user, "<span class='notice'>You add [I] to [src].</span>")
		holdingitems[I] = TRUE
		return FALSE
		*/

/obj/item/soup_pot/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/item/soup_pot/attack_self(mob/user)
	var/list/choices = list(
		"Eject" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_eject"),
		"Cook" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_mix")
	)

	var/choice = show_radial_menu(user, src, choices, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user))
		return
	switch(choice)
		if("Eject")
			eject(user)
			return
		if("Cook")
			cook(user)
			return

/obj/item/soup_pot/proc/eject(mob/user)
	for(var/i in holdingitems)
		to_chat(user, "<span class='notice'>The ingredients tumble out of the pot!</span>")
		var/obj/item/O = i
		O.forceMove(drop_location())
		holdingitems -= O
	if(beaker.reagents.total_volume || soupholder.reagents.total_volume)
		to_chat(user, "<span class='notice'>The soup vaporizes into a harmless steam!</span>")
		playsound(src, 'sound/weapons/sear.ogg', 50, 0)
		playsound(src, 'sound/items/cig_snuff.ogg', 50, 0)
		beaker = new /obj/item/reagent_containers/glass/beaker/large(src)
		soupholder = new /obj/item/reagent_containers/glass/beaker/bluespace(src)
		var/datum/effect_system/steam_spread/steam = new /datum/effect_system/steam_spread()
		steam.set_up(10, 0, get_turf(src))
		steam.start()

/obj/item/soup_pot/proc/cook(mob/user)
	if(beaker.reagents.total_volume)
		to_chat(user, "<span class='notice'>The pot begins energetically boiling the contents into soup!</span>")
		operating = TRUE
		icon_state = "juicer0"
		playsound(src, 'sound/machines/terminal_on.ogg', 50, 1)
		playsound(src, 'sound/effects/bubbles2.ogg', 50, 1)
		src.beaker.reagents.trans_to(src.soupholder, 100, transfered_by = user)
		processitems(user)
		addtimer(CALLBACK(src, .proc/stop_operating), 60)
	else if(operating)
		to_chat(user, "<space class='notice'>The soup is still cooking!</span>")
	else
		to_chat(user, "<space class='notice'>You need more broth to cook this into soup!</span>")

/obj/item/soup_pot/proc/stop_operating()
	operating = FALSE
	icon_state = "juicer1"
	playsound(src, 'sound/machines/ding.ogg', 50, 1)

/obj/item/soup_pot/proc/processitems(mob/user)
	for(var/i in holdingitems)
		if(soupholder.reagents.total_volume >= soupholder.reagents.maximum_volume)
			break
		var/obj/item/I = i
		var/souped = FALSE
		check_trash(I)
		if(I.grind_results)
			soupholder.reagents.add_reagent_list(I.grind_results)
			souped = TRUE
		if(I.juice_results)
			soupholder.reagents.add_reagent_list(I.juice_results)
			souped = TRUE
		if(I.reagents)
			I.reagents.trans_to(soupholder, I.reagents.total_volume, transfered_by = user)
			souped = TRUE
		if(souped)
			holdingitems -= I
			qdel(I)
	if(holdingitems.len)
		to_chat(user, "<space class='notice'>Some items refuse to boil down into soup!</span>")

/obj/item/soup_pot/proc/check_trash(obj/item/I)
	if (istype(I, /obj/item/reagent_containers/food/snacks))
		var/obj/item/reagent_containers/food/snacks/R = I
		if (R.trash)
			R.generate_trash(get_turf(src))
