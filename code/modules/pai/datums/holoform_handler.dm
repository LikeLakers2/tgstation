/// A datum handling a pAI mob's holoform functions, from folding out to wabbajacking.
///
/// This is separated out into a handler datum, to ease maintenance - because dear god is pAI's code
/// a mess to go through otherwise.
///
/// When writing code here, make sure any signals that this emits comes from the pAI itself, rather
/// than this datum.

/datum/pai_holoform_handler
	var/mob/living/silicon/pai/pai

	/// If someone has enabled/disabled the pAIs ability to holo
	var/can_holo = TRUE
	/// The skin that will appear when in holoform
	var/datum/pai_holoform_skin/skin
	/// The health of the holochassis
	var/health = 20
	/// Whether we are currently holoformed
	var/in_holoform = FALSE

	COOLDOWN_DECLARE(holo_cooldown)

/datum/pai_holoform_handler/New(mob/living/silicon/pai/handled)
	. = ..()
	pai = handled
	skin = new /datum/pai_holoform_skin(pai)

	RegisterSignal(pai, COMSIG_LIVING_PRE_WABBAJACKED, PROC_REF(on_wabbajack))

/datum/pai_holoform_handler/Destroy(force)
	pai = null
	QDEL_NULL(skin)
	return ..()

/datum/pai_holoform_handler/proc/on_wabbajack()
	var/list/datum/pai_holoform_skin/possible_skins = subtypesof(/datum/pai_holoform_skin) - skin.type
	if(length(possible_skins))
		var/new_holochassis = pick(possible_skins)
		pai.set_holochassis(new_holochassis)
		pai.balloon_alert(pai, "[new_holochassis] composite engaged")
	return STOP_WABBAJACK

/**
 * Toggles the pAI between card mode and mob mode.
 *
 * @param {boolean} force - Passed to `fold_in()` or `fold_out()`.
 *
 * @returns {boolean} - If the mob was successfully toggled between folded modes.
 */
/datum/pai_holoform_handler/proc/toggle_folded(force)
	if(in_holoform)
		return fold_in(force)
	else
		return fold_out(force)

/**
 * Returns the pAI to card mode.
 *
 * @param {boolean} force - If TRUE, the pAI will be forced to card mode.
 *
 * @returns {boolean} - TRUE if the pAI was forced to card mode.
 * 	FALSE otherwise.
 */
/datum/pai_holoform_handler/proc/fold_in(force = FALSE)
	if(!in_holoform)
		return FALSE

	if(!force)
		COOLDOWN_START(src, holo_cooldown, HOLOCHASSIS_COOLDOWN)
	else
		COOLDOWN_START(src, holo_cooldown, HOLOCHASSIS_OVERLOAD_COOLDOWN)

	pai.set_resting(FALSE, silent = TRUE, instant = TRUE)

	if(ispickedupmob(pai.loc))
		var/obj/item/clothing/head/mob_holder/mob_head = pai.loc
		mob_head.release(display_messages = FALSE)

	if(pai.client)
		pai.client.perspective = EYE_PERSPECTIVE
		pai.client.set_eye(pai.card)

	pai.visible_message(span_notice("[pai] dematerialises!"))

	if (isturf(pai.loc))
		new /obj/effect/temp_visual/guardian/phase/out(pai.loc)

	pai.forceMove(pai.card)

	pai.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED, TRAIT_UNDENSE), PAI_FOLDED)
	in_holoform = FALSE
	SEND_SIGNAL(pai, COMSIG_PAI_FOLD_IN)
	return TRUE

/**
 * Engage holochassis form.
 *
 * @param {boolean} force - Force the form to engage.
 *
 * @returns {boolean} - TRUE if the form was successfully engaged.
 * 	FALSE otherwise.
 */
/datum/pai_holoform_handler/proc/fold_out(force = FALSE)
	if(health < 0)
		pai.balloon_alert(pai, "emitter repair incomplete")
		return FALSE
	if(!can_holo && !force)
		pai.balloon_alert(pai, "emitters are disabled")
		return FALSE
	if(in_holoform)
		return FALSE
	if(!COOLDOWN_FINISHED(src, holo_cooldown))
		pai.balloon_alert(pai, "emitters recycling...")
		return FALSE

	COOLDOWN_START(src, holo_cooldown, HOLOCHASSIS_COOLDOWN)

	if(pai.client)
		pai.client.perspective = EYE_PERSPECTIVE
		pai.client.set_eye(pai)

	pai.visible_message(span_boldnotice("[pai] appears in a flash of light!"))

	pai.forceMove(get_turf(pai.card))

	pai.remove_traits(pai, list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED, TRAIT_UNDENSE), PAI_FOLDED)
	pai.update_appearance(UPDATE_ICON_STATE)
	in_holoform = TRUE
	SEND_SIGNAL(pai, COMSIG_PAI_FOLD_OUT)
	return TRUE
