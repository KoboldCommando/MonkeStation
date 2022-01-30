/obj/item/soup_pot
	name = "soup Pot"
	desc = "placeholder"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "juicer1"
	resistance_flags = ACID_PROOF
	var/operating = FALSE
	var/datum/reagents/soupholder = new/datum/reagents(300)
	var/maxbroth = 100 //maximum amount of precooked broth
	var/list/holdingitems
	var/limit = 10
	var/readytoserve = FALSE
	var/static/list/typecache_to_take
	var/static/radial_serve = image(icon = 'monkestation/icons/mob/soup.dmi', icon_state = "serve")
	var/static/radial_cook = image(icon = 'monkestation/icons/mob/soup.dmi', icon_state = "cook")
	var/static/radial_empty = image(icon = 'monkestation/icons/mob/soup.dmi', icon_state = "empty")


/obj/item/soup_pot/Initialize()
	. = ..()
	holdingitems = list()

/obj/item/soup_pot/Destroy()
	soupholder = null
	drop_all_items()
	return ..()

/obj/item/soup_pot/contents_explosion(severity, target)
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

	if(readytoserve)
		if(soupholder.total_volume)
			. += "<span class='notice'>- [soupholder.total_volume] units of delicious steaming soup!</span>"

	if(soupholder || length(holdingitems))
		. += "<span class='notice'>\The [src] contains:</span>"
		for(var/i in holdingitems)
			var/obj/item/O = i
			. += "<span class='notice'>- \A [O.name].</span>"
		for(var/datum/reagent/R in soupholder.reagent_list)
			. += "<span class='notice'>- [R.volume] units of [R.name].</span>"
		if(!holdingitems.len && !soupholder.total_volume && !soupholder.total_volume)
			. += "<span class='notice'>- nothing!</span>"

/obj/item/soup_pot/handle_atom_del(atom/A)
	. = ..()
	if(A == soupholder)
		soupholder = null
		update_icon()
	if(holdingitems[A])
		holdingitems -= A

/obj/item/soup_pot/proc/drop_all_items()
	for(var/i in holdingitems)
		var/atom/movable/AM = i
		AM.forceMove(drop_location())
	holdingitems = list()

/obj/item/soup_pot/update_icon()
	if(soupholder)
		icon_state = "juicer1"
	else
		icon_state = "juicer0"

/obj/item/soup_pot/attackby(obj/item/I, mob/user, params)

	if (istype(I, /obj/item/reagent_containers) && !(I.item_flags & ABSTRACT) && I.is_open_container())
		var/obj/item/reagent_containers/J = I
		if(!J.reagents.total_volume)
			to_chat(user, "<span class='warning'>[J] is empty!</span>")
			return

		if(soupholder.total_volume >= src.maxbroth)
			to_chat(user, "<span class='warning'>[src] is full.</span>")
			return

		var/trans = J.reagents.trans_to(src.soupholder, J.amount_per_transfer_from_this, transfered_by = user)
		to_chat(user, "<span class='notice'>You fill [src] with [trans] unit\s of the contents of [J].</span>")

	else if(holdingitems.len >= limit)
		to_chat(user, "<span class='warning'>[src] is filled to capacity!</span>")
		return TRUE

	else if(user.transferItemToLoc(I, src))
		to_chat(user, "<span class='notice'>You add [I] to [src].</span>")
		holdingitems[I] = TRUE
		return FALSE

/obj/item/soup_pot/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/item/soup_pot/attack_self(mob/user)
	var/list/choices = list("Empty" = image(icon = 'monkestation/icons/mob/soup.dmi', icon_state = "empty"))

	if(readytoserve)
		choices.Add("Serve" = image(icon = 'monkestation/icons/mob/soup.dmi', icon_state = "serve"))
	else
		choices.Add("Cook" = image(icon = 'monkestation/icons/mob/soup.dmi', icon_state = "cook"))

	var/choice = show_radial_menu(user, src, choices, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user))
		return
	switch(choice)
		if("Empty")
			empty(user)
			return
		if("Cook")
			cook(user)
			return
		if("Serve")
			serve(user)
			return

/obj/item/soup_pot/proc/empty(mob/user)
	for(var/i in holdingitems)
		to_chat(user, "<span class='notice'>The ingredients tumble out of the pot!</span>")
		var/obj/item/O = i
		O.forceMove(drop_location())
		holdingitems -= O
	if(soupholder.total_volume)
		to_chat(user, "<span class='notice'>The soup vaporizes into a harmless steam!</span>")
		playsound(src, 'sound/weapons/sear.ogg', 50, 0)
		playsound(src, 'sound/items/cig_snuff.ogg', 50, 0)
		soupholder = new/datum/reagents
		var/datum/effect_system/steam_spread/steam = new /datum/effect_system/steam_spread()
		steam.set_up(10, 0, get_turf(src))
		steam.start()
	readytoserve = FALSE

/obj/item/soup_pot/proc/cook(mob/user)
	if(soupholder.total_volume)
		to_chat(user, "<span class='notice'>The pot begins energetically boiling the contents into soup!</span>")
		operating = TRUE
		icon_state = "juicer0"
		playsound(src, 'sound/machines/terminal_on.ogg', 50, 1)
		playsound(src, 'sound/effects/bubbles2.ogg', 50, 1)
		processitems(user)
		addtimer(CALLBACK(src, .proc/stop_operating), 60)
	else if(operating)
		to_chat(user, "<space class='notice'>The soup is still cooking!</span>")
	else
		to_chat(user, "<space class='notice'>You need more broth to cook this into soup!</span>")

/obj/item/soup_pot/proc/stop_operating()
	operating = FALSE
	readytoserve = TRUE
	icon_state = "juicer1"
	playsound(src, 'sound/machines/ding.ogg', 50, 1)

/obj/item/soup_pot/proc/serve(mob/user)
	//create a bowl of soup containing 30u of the soup
	//put it in the user's hands or on the ground
	//if we're empty then make us no longer ready to serve

/obj/item/soup_pot/proc/processitems(mob/user)
	for(var/i in holdingitems)
		if(soupholder.total_volume >= soupholder.maximum_volume)
			break
		var/obj/item/I = i
		var/souped = FALSE
		check_trash(I)
		if(I.grind_results)
			soupholder.add_reagent_list(I.grind_results)
			souped = TRUE
		if(I.juice_results)
			soupholder.add_reagent_list(I.juice_results)
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
