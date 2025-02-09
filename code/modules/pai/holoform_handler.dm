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
	var/current_skin = "repairbot"
	/// The health of the holochassis
	var/health = 20
	/// Whether we are currently holoformed
	var/in_holoform = FALSE

	/// How long we have until we can fold out.
	COOLDOWN_DECLARE(holo_cooldown)

	/// List of all possible chassis skins. TRUE means the pAI can be picked up in this chassis.
	var/static/list/possible_skins = list(
		"bat" = FALSE,
		"butterfly" = FALSE,
		"cat" = TRUE,
		"chicken" = FALSE,
		"corgi" = FALSE,
		"crow" = TRUE,
		"duffel" = TRUE,
		"fox" = FALSE,
		"frog" = TRUE,
		"hawk" = FALSE,
		"lizard" = FALSE,
		"monkey" = TRUE,
		"mouse" = TRUE,
		"rabbit" = TRUE,
		"repairbot" = TRUE,
		"kitten" = TRUE,
		"puppy" = TRUE,
		"spider" = TRUE,
	)

/datum/pai_holoform_handler/New(mob/living/silicon/pai/handled)
	. = ..()
	pai = handled

	// Signals, organized alphabetically by signal name.
	RegisterSignals(pai, list(COMSIG_LIVING_ADJUST_BRUTE_DAMAGE, COMSIG_LIVING_ADJUST_BURN_DAMAGE), PROC_REF(on_shell_damaged))
	RegisterSignal(pai, COMSIG_LIVING_ADJUST_STAMINA_DAMAGE, PROC_REF(on_shell_weakened))
	RegisterSignal(pai, COMSIG_LIVING_PRE_WABBAJACKED, PROC_REF(on_wabbajack))
	RegisterSignal(pai, COMSIG_LIVING_TRY_PICKUP, PROC_REF(on_mob_try_pickup))
	RegisterSignal(pai, COMSIG_LIVING_TRY_PULL, PROC_REF(on_try_pull))

	COOLDOWN_START(src, holo_cooldown, HOLOCHASSIS_INIT_TIME)

/datum/pai_holoform_handler/Destroy(force)
	pai = null
	QDEL_NULL(skin)
	return ..()

/datum/pai_holoform_handler/proc/take_holo_damage(amount)
	health = clamp((health - amount), -50, HOLOCHASSIS_MAX_HEALTH)
	if(health < 0)
		fold_in(force = TRUE)
	if(amount > 0)
		to_chat(pai, span_userdanger("The impact degrades your holochassis!"))
	return amount

/datum/pai_holoform_handler/proc/on_mob_try_pickup(mob/living/user, instant)
	SIGNAL_HANDLER
	if(!possible_skins[skin])
		to_chat(user, span_warning("[pai]'s current form isn't able to be carried!"))
		return COMSIG_LIVING_PREVENT_PICKUP

/// Called when we take burn or brute damage, pass it to the shell instead
/datum/pai_holoform_handler/proc/on_shell_damaged(datum/hurt, type, amount, forced)
	SIGNAL_HANDLER
	take_holo_damage(amount)
	return COMPONENT_IGNORE_CHANGE

/// Called when we take stamina damage, pass it to the shell instead
/datum/pai_holoform_handler/proc/on_shell_weakened(datum/hurt, type, amount, forced)
	SIGNAL_HANDLER
	take_holo_damage(amount * ((forced) ? 1 : 0.25))
	return COMPONENT_IGNORE_CHANGE

/datum/pai_holoform_handler/proc/on_try_pull(atom/movable/thing, force)
	return COMSIG_LIVING_CANCEL_PULL

/datum/pai_holoform_handler/proc/on_wabbajack()
	SIGNAL_HANDLER

	var/list/other_skins = possible_skins - skin
	if(length(other_skins))
		var/new_holochassis = pick(other_skins)
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
