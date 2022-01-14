/datum/chemical_reaction/regia
	name = "Aqua regia"
	id = /datum/reagent/alchemy/regia
	results = list(/datum/reagent/alchemy/regia = 5)
	required_reagents = list(/datum/reagent/drug/crank = 5, /datum/reagent/drug/happiness = 5)
	mix_message = "The mixture bubbles and clarifies."

/datum/chemical_reaction/fortis
	name = "Aqua fortis"
	id = /datum/reagent/alchemy/fortis
	results = list(/datum/reagent/alchemy/fortis = 5)
	required_reagents = list(/datum/reagent/drug/crank = 5, /datum/reagent/drug/krokodil = 5)
	mix_message = "The mixture steams with an acrid smell."

/datum/chemical_reaction/vitae
	name = "Aqua vitae"
	id = /datum/reagent/alchemy/vitae
	results = list(/datum/reagent/alchemy/vitae = 5)
	required_reagents = list(/datum/reagent/drug/crank = 5, /datum/reagent/drug/bath_salts = 5)
	mix_message = "The mixture swirls and becomes crystal clear."

/datum/chemical_reaction/hydrophiline
	name = "Hydrophiline"
	id = /datum/reagent/alchemy/hydrophiline
	results = list(/datum/reagent/alchemy/hydrophiline = 10)
	required_reagents = list(/datum/reagent/alchemy/vitae = 5, /datum/reagent/water = 5)

/datum/chemical_reaction/snakeoil
	name = "Snake oil"
	id = /datum/reagent/alchemy/snakeoil
	results = list(/datum/reagent/alchemy/snakeoil = 10)
	required_reagents = list(/datum/reagent/alchemy/fortis = 5, /datum/reagent/water = 5)

/datum/chemical_reaction/recurzine
	name = "Recurzine"
	id = /datum/reagent/alchemy/recurzine
	results = list(/datum/reagent/alchemy/recurzine = 10)
	required_reagents = list(/datum/reagent/alchemy/regia = 5, /datum/reagent/water = 5)
