/mob/living/silicon/pai/update_resting()
	. = ..()
	update_appearance(UPDATE_ICON_STATE)
	if(loc != card)
		visible_message(span_notice("[src] [resting? "lays down for a moment..." : "perks up from the ground."]"))

/**
 * Checks if we are allowed to interact with a radial menu
 *
 * @param {atom} anchor - The atom that is anchoring the menu.
 *
 * @returns {boolean} - TRUE if we are allowed to interact with the menu,
 * 	FALSE otherwise.
 */
/mob/living/silicon/pai/proc/check_menu(atom/anchor)
	if(incapacitated)
		return FALSE
	if(get_turf(src) != get_turf(anchor))
		return FALSE
	if(!isturf(loc) && loc != card)
		balloon_alert(src, "can't do that here")
		return FALSE
	return TRUE

/**
 * Sets a new holochassis skin based on a pAI's choice.
 *
 * @returns {boolean} - True if the skin was successfully set.
 * 	FALSE otherwise.
 */
/mob/living/silicon/pai/proc/choose_chassis()
	var/list/skins = list()
	for(var/holochassis_option in possible_chassis)
		var/image/item_image = image(icon = src.icon, icon_state = holochassis_option)
		skins += list("[holochassis_option]" = item_image)
	sort_list(skins)
	var/atom/anchor = get_atom_on_turf(src)
	var/choice = show_radial_menu(src, anchor, skins, custom_check = CALLBACK(src, PROC_REF(check_menu), anchor), radius = 40, require_near = TRUE)
	if(!choice)
		return FALSE
	set_holochassis(choice)
	balloon_alert(src, "[choice] composite engaged")
	update_resting()
	return TRUE

/**
 * Sets the holochassis skin and updates the icons
 *
 * @param {string} choice - The skin that will be used for the pAI holoform
 *
 * @returns {boolean} - TRUE if the skin was successfully set. FALSE otherwise.
 */
/mob/living/silicon/pai/proc/set_holochassis(choice)
	if(!choice)
		return FALSE
	chassis = choice
	update_appearance(UPDATE_DESC | UPDATE_ICON_STATE)
	return TRUE

/**
 * Toggles the onboard light
 *
 * @returns {boolean} - TRUE if the light was toggled.
 */
/mob/living/silicon/pai/proc/toggle_integrated_light()
	set_light_on(!light_on)
	return TRUE
