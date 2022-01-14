/datum/reagent/alchemy/regia
	name = "Aqua regia"
	description = "One of the foundational reagents of alchemy."
	color = "#914c0b"
	overdose_threshold = 30
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "royal water"
	var/trippy = TRUE

/datum/reagent/alchemy/regia/on_mob_life(mob/living/carbon/M)
	M.set_drugginess(15)
	if(isturf(M.loc) && !isspaceturf(M.loc))
		if(M.mobility_flags & MOBILITY_MOVE)
			if(prob(10))
				step(M, pick(GLOB.cardinals))
	if(prob(7))
		M.emote(pick("twitch","drool","moan","giggle"))
	..()

/datum/reagent/alchemy/regia/overdose_start(mob/living/M)
	to_chat(M, "<span class='userdanger'>You start tripping hard!</span>")
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/overdose, name)

/datum/reagent/alchemy/regia/overdose_process(mob/living/M)
	if(M.hallucination < volume && prob(20))
		M.hallucination += 5
	..()

/datum/reagent/alchemy/regia/on_mob_end_metabolize(mob/living/M)
	if(trippy)
		SEND_SIGNAL(M, COMSIG_CLEAR_MOOD_EVENT, "[type]_high")

/datum/reagent/alchemy/vitae
	name = "Aqua vitae"
	description = "One of the foundational spirits of alchemy."
	color = "#cfcfca"
	taste_description = "ardent spirits"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	random_unrestricted = FALSE
	var/boozepwr = 65

/datum/reagent/alchemy/vitae/on_mob_life(mob/living/carbon/C)
	if(C.drunkenness < volume * boozepwr * ALCOHOL_THRESHOLD_MODIFIER)
		var/booze_power = boozepwr
		if(HAS_TRAIT(C, TRAIT_ALCOHOL_TOLERANCE)) //we're an accomplished drinker
			booze_power *= 0.7
		if(HAS_TRAIT(C, TRAIT_LIGHT_DRINKER))
			if(booze_power < 0)
				booze_power *= -1
			else
				booze_power *= 2
		C.drunkenness = max((C.drunkenness + (sqrt(volume) * booze_power * ALCOHOL_RATE)), 0) //Volume, power, and server alcohol rate effect how quickly one gets drunk
		var/obj/item/organ/liver/L = C.getorganslot(ORGAN_SLOT_LIVER)
		if (istype(L))
			L.applyOrganDamage(((max(sqrt(volume) * (boozepwr ** ALCOHOL_EXPONENT) * L.alcohol_tolerance, 0))/150))
	return ..()

/datum/reagent/alchemy/vitae/reaction_obj(obj/O, reac_volume)
	if(istype(O, /obj/item/paper))
		var/obj/item/paper/paperaffected = O
		paperaffected.clearpaper()
		to_chat(usr, "<span class='notice'>[paperaffected]'s ink washes away.</span>")
	if(istype(O, /obj/item/book))
		if(reac_volume >= 5)
			var/obj/item/book/affectedbook = O
			affectedbook.dat = null
			O.visible_message("<span class='notice'>[O]'s writing is washed away by [name]!</span>")
		else
			O.visible_message("<span class='warning'>[O]'s ink is smeared by [name], but doesn't wash away!</span>")
	return

/datum/reagent/alchemy/vitae/reaction_mob(mob/living/M, method=TOUCH, reac_volume)//Splashing people with ethanol isn't quite as good as fuel.
	if(!isliving(M))
		return

	if(method in list(TOUCH, VAPOR, PATCH))
		M.adjust_fire_stacks(reac_volume / 15)

		if(iscarbon(M))
			var/mob/living/carbon/C = M
			var/power_multiplier = boozepwr / 65 // Weak alcohol has less sterilizing power

			for(var/s in C.surgeries)
				var/datum/surgery/S = s
				S.speed_modifier = max(0.1*power_multiplier, S.speed_modifier)
				// +10% surgery speed on each step, useful while operating in less-than-perfect conditions
	return ..()

/datum/reagent/alchemy/fortis
	name = "Aqua fortis"
	description = "One of the foundational acids of alchemy."
	color = "#ebbc24"
	var/acidpwr = 10 //the amount of protection removed from the armour
	taste_description = "strong water"
	taste_mult = 1.2
	var/toxpwr = 1.5
	var/silent_toxin = FALSE
	self_consuming = TRUE
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/alchemy/fortis/reaction_mob(mob/living/carbon/C, method=TOUCH, reac_volume)
	if(!istype(C))
		return
	reac_volume = round(reac_volume,0.1)
	if(method == INGEST)
		C.adjustBruteLoss(min(6*toxpwr, reac_volume * toxpwr))
		return
	if(method == INJECT)
		C.adjustBruteLoss(1.5 * min(6*toxpwr, reac_volume * toxpwr))
		return
	C.acid_act(acidpwr, reac_volume)

/datum/reagent/alchemy/fortis/reaction_obj(obj/O, reac_volume)
	if(ismob(O.loc)) //handled in human acid_act()
		return
	reac_volume = round(reac_volume,0.1)
	O.acid_act(acidpwr, reac_volume)

/datum/reagent/alchemy/fortis/reaction_turf(turf/T, reac_volume)
	if (!istype(T))
		return
	reac_volume = round(reac_volume,0.1)
	T.acid_act(acidpwr, reac_volume)

/datum/reagent/alchemy/fortis/on_mob_life(mob/living/carbon/M)
	if(toxpwr)
		M.adjustToxLoss(toxpwr*REM, 0)
		. = TRUE
	..()

/datum/reagent/alchemy/hydrophiline
	name = "Hydrophiline"
	description = "An oily wet substance that can cause the body to process water instead of air. Lungs can have difficulty readjusting after extended exposure."
	color = "#9df1fc"
	taste_description = "dry wetness"
	overdose_threshold = 30
	metabolization_rate = 0.25 * REAGENTS_METABOLISM

/datum/reagent/alchemy/hydrophiline/on_mob_life(mob/living/carbon/M)
	if(M.reagents.has_reagent(/datum/reagent/water/))
		M.reagents.remove_reagent(/datum/reagent/water = 2)
		M.adjustOxyLoss(-10*REM, 0)
		if(M.losebreath >= 4)
			M.losebreath -= 2
		M.adjustOrganLoss(ORGAN_SLOT_LUNGS, 2)
	else
		if(!HAS_TRAIT(M, TRAIT_NOBREATH))
			M.adjustOxyLoss(5, 0)
			M.losebreath += 2
			if(prob(20))
				M.emote("gasps like a fish")
	..()
	return TRUE

/datum/reagent/alchemy/snakeoil
	name = "Snake Oil" //alternate name: slugfest
	description = "Allows you to crawl faster on your belly like a snake!  But makes you worse at walking... like a snake."
	reagent_state = LIQUID
	color = "#3f8339"
	overdose_threshold = 20
	metabolization_rate = 0.75 * REAGENTS_METABOLISM

/datum/reagent/alchemy/snakeoil/on_mob_metabolize(mob/living/L)
	RegisterSignal(L, list(COMSIG_MOVABLE_MOVED), .proc/speedchange)

/datum/reagent/alchemy/snakeoil/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(type)
	..()

/datum/reagent/alchemy/snakeoil/on_mob_life(mob/living/carbon/M)
	var/high_message = pick("You feel like being closer to the ground.", "Your belly undulates strangely.", "Your legs feel weak and vestigial.")
	if(prob(5))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.5)
	if(prob(5))
		M.emote(pick("twitch", "slither"))
	..()
	. = 1

/datum/reagent/alchemy/snakeoil/proc/speedchange(mob/living/carbon/M)
	SIGNAL_HANDLER

	if(!(M.mobility_flags & MOBILITY_STAND))
		M.add_movespeed_modifier(type, update=TRUE, priority=100, override=TRUE, multiplicative_slowdown=-4, movetypes = GROUND)
	else
		M.add_movespeed_modifier(type, update=TRUE, priority=100, override=TRUE, multiplicative_slowdown=4, movetypes = GROUND)


/datum/reagent/alchemy/snakeoil/overdose_process(mob/living/M)
	if(prob(33))
		M.visible_message("<span class='danger'>[M]'s legs visibly shirivel and atrophy!</span>")
		M.apply_damage(damage = 2,damagetype = BRUTE, def_zone = BODY_ZONE_L_LEG, blocked = FALSE, forced = FALSE)
		M.apply_damage(damage = 2,damagetype = BRUTE, def_zone = BODY_ZONE_R_LEG, blocked = FALSE, forced = FALSE)
		M.adjustCloneLoss(0.5, updating_health = TRUE, forced = FALSE)
	..()
	. = 1

/datum/reagent/alchemy/recurzine
	name = "Recurzine"
	description = "Shortly after metabolizing, isolates and stores a portion of all other chemicals in the bloodstream. When it exits the system, these stored chemicals return."
	reagent_state = LIQUID
	color = "#8502ff"
	metabolization_rate = 0.4 * REAGENTS_METABOLISM
	var/datum/reagents/storedreagents = new/datum/reagents
	var/storeamount

/datum/reagent/alchemy/recurzine/on_mob_metabolize(mob/living/L)
	storeamount = L.reagents.get_reagent_amount(/datum/reagent/alchemy/recurzine) / 4
	for(var/datum/reagent/R in L.reagents.reagent_list)
		if(R)
			if(R.type != /datum/reagent/alchemy/recurzine) //no actual recursion, sorry
				L.reagents.trans_id_to(src, R.type, storeamount)

/datum/reagent/alchemy/recurzine/on_mob_end_metabolize(mob/living/L)
	if(storedreagents.reagent_list)
		storedreagents.trans_to(L, storedreagents.total_volume)
	..()
