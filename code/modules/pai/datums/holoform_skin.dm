/// Datums describing a holochassis that a pAI can appear as.
///
/// These are implemented as datums that are meant to be instanced. This allows for the currently-
/// -chosen chassis skin to implement functionality specific to it - usually vanity functionality.
/// For example, the cat and kitten chassis' may add an action to hack up a holographic hairball.

/datum/pai_holoform_skin
	// The name to show in the radial menu.
	var/name
	// The name to show when examining the pAI mob. If this is unspecified, it will be
	// `LOWER_TEXT(name)`.
	var/name_in_examine

	// The icons and icon states that are applied to the pAI's mob when this chassis is selected.
	var/icon/icon = 'icons/mob/silicon/pai.dmi'
	var/icon_state
	var/icon/resting_icon = 'icons/mob/silicon/pai.dmi'
	// If unspecified, this will be `"[icon_state]_rest"`.
	var/resting_icon_state
	var/icon/held_lh = 'icons/mob/inhands/pai_item_lh.dmi'
	var/icon/held_rh = 'icons/mob/inhands/pai_item_rh.dmi'
	var/icon/head_icon = 'icons/mob/clothing/head/pai_head.dmi'
	// If unspecified, this will be `"[icon_state]"`.
	var/held_or_worn_icon_state

	// Whether the pAI can be picked up and worn in this holochassis.
	var/can_be_picked_up = FALSE

	/**
	 * Below are variables meant to be defined at runtime. Please do not define them in subtypes.
	 */
	// The pAI mob this is attached to.
	var/mob/living/silicon/pai/pai

/datum/pai_holoform_skin/New(mob/living/silicon/pai/owner)
	. = ..()
	if(isnull(name_in_examine))
		name_in_examine = LOWER_TEXT(name)
	if(isnull(resting_icon_state))
		resting_icon_state = "[icon_state]_rest"
	if(isnull(held_or_worn_icon_state))
		held_or_worn_icon_state = icon_state
	pai = owner

	RegisterSignal(pai, COMSIG_ATOM_UPDATE_ICON_STATE, PROC_REF(update_icon_state))
	RegisterSignal(pai, COMSIG_PAI_FOLD_OUT, PROC_REF(folded_out))
	RegisterSignal(pai, COMSIG_PAI_FOLD_IN, PROC_REF(folded_in))

/datum/pai_holoform_skin/Destroy(force)
	pai = null
	return ..()

/datum/pai_holoform_skin/proc/apply_held_icons()
	pai.held_lh = held_lh
	pai.held_rh = held_rh
	pai.head_icon = head_icon
	pai.held_state = held_or_worn_icon_state

/datum/pai_holoform_skin/proc/update_icon_state()
	SIGNAL_HANDLER
	pai.icon = pai.resting ? resting_icon : icon
	pai.icon_state = pai.resting ? resting_icon_state : icon_state

/datum/pai_holoform_skin/proc/folded_out()
	SIGNAL_HANDLER
	return

/datum/pai_holoform_skin/proc/folded_in()
	SIGNAL_HANDLER
	return

/datum/pai_holoform_skin/bat
	name = "Bat"
	icon_state = "bat"

/datum/pai_holoform_skin/butterfly
	name = "Butterfly"
	icon_state = "butterfly"

/datum/pai_holoform_skin/cat
	name = "Cat"
	icon_state = "cat"
	can_be_picked_up = TRUE

/datum/pai_holoform_skin/chicken
	name = "Chicken"
	icon_state = "chicken"

/datum/pai_holoform_skin/corgi
	name = "Corgi"
	icon_state = "corgi"

/datum/pai_holoform_skin/crow
	name = "Crow"
	icon_state = "crow"
	can_be_picked_up = TRUE

/datum/pai_holoform_skin/duffel_bag
	name = "Duffel Bag"
	icon_state = "duffel"
	can_be_picked_up = TRUE

/datum/pai_holoform_skin/fox
	name = "Fox"
	icon_state = "fox"

/datum/pai_holoform_skin/frog
	name = "Frog"
	icon_state = "frog"
	can_be_picked_up = TRUE

/datum/pai_holoform_skin/hawk
	name = "Hawk"
	icon_state = "hawk"

/datum/pai_holoform_skin/kitten
	name = "Kitten"
	icon_state = "kitten"

/datum/pai_holoform_skin/lizard
	name = "Lizard"
	icon_state = "lizard"

/datum/pai_holoform_skin/monkey
	name = "Monkey"
	icon_state = "monkey"
	can_be_picked_up = TRUE

/datum/pai_holoform_skin/mouse
	name = "Mouse"
	icon_state = "mouse"
	can_be_picked_up = TRUE

/datum/pai_holoform_skin/puppy
	name = "Puppy"
	icon_state = "puppy"

/datum/pai_holoform_skin/rabbit
	name = "Rabbit"
	icon_state = "rabbit"
	can_be_picked_up = TRUE

/datum/pai_holoform_skin/repairbot
	name = "Repairbot"
	icon_state = "repairbot"
	can_be_picked_up = TRUE

/datum/pai_holoform_skin/spider
	name = "Spider"
	icon_state = "spider"
	can_be_picked_up = TRUE
