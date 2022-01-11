/obj/machinery/chem_dispenser/alchemy
	name = "alchemaestro"
	desc = "For ill-advised experiments with the very nature of chemistry itself."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "soda_dispenser"
	has_panel_overlay = FALSE
	amount = 10
	pixel_y = 6
	layer = WALL_OBJ_LAYER
	working_state = null
	nopower_state = null
	pass_flags = PASSTABLE
	dispensable_reagents = list(
		/datum/reagent/alchemy/regia,
		/datum/reagent/alchemy/fortis,
		/datum/reagent/alchemy/vitae
	)
	upgrade_reagents = list(
		/datum/reagent/drug/crank,
		/datum/reagent/drug/krokodil,
		/datum/reagent/drug/bath_salts,
		/datum/reagent/drug/happiness
	)
	emagged_reagents = list(
	)

/obj/machinery/chem_dispenser/alchemy/update_icon()
	. = ..()
	add_overlay(image('icons/effects/atmospherics.dmi', "miasma_old", WALL_OBJ_LAYER + 0.5))
