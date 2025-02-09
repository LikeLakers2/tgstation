
/mob/living/silicon/pai/blob_act(obj/structure/blob/B)
	return FALSE

/mob/living/silicon/pai/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	take_holo_damage(50 / severity)
	Stun(400 / severity)
	if(holoform_handler.in_holoform)
		holoform_handler.fold_in(force = TRUE)
	//Need more effects that aren't instadeath or permanent law corruption.
	//Ask and you shall receive
	switch(rand(1, 3))
		if(1)
			adjust_stutter(1 MINUTES / severity)
			to_chat(src, span_danger("Warning: Feedback loop detected in speech module."))
		if(2)
			adjust_slurring(INFINITY)
			to_chat(src, span_danger("Warning: Audio synthesizer CPU stuck."))
		if(3)
			set_derpspeech(INFINITY)
			to_chat(src, span_danger("Warning: Vocabulary databank corrupted."))
	if(prob(40))
		set_active_language(get_random_spoken_language())

/mob/living/silicon/pai/ex_act(severity, target)
	take_holo_damage(50 * severity)
	switch(severity)
		if(EXPLODE_DEVASTATE) //RIP
			qdel(card)
			qdel(src)
		if(EXPLODE_HEAVY)
			holoform_handler.fold_in(force = TRUE)
			Paralyze(400)
		if(EXPLODE_LIGHT)
			holoform_handler.fold_in(force = TRUE)
			Paralyze(200)

	return TRUE

/mob/living/silicon/pai/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(!user.combat_mode)
		visible_message(span_notice("[user] gently pats [src] on the head, eliciting an off-putting buzzing from its holographic field."))
		return
	user.do_attack_animation(src)
	if(user.name != master_name)
		visible_message(span_danger("[user] stomps on [src]!."))
		take_holo_damage(2)
		return
	visible_message(span_notice("Responding to its master's touch, [src] disengages its holochassis emitter, rapidly losing coherence."))
	if(!do_after(user, 1 SECONDS, src))
		return
	fold_in()
	if(user.put_in_hands(card))
		user.visible_message(span_notice("[user] promptly scoops up [user.p_their()] pAI's card."))

/mob/living/silicon/pai/bullet_act(obj/projectile/hitting_projectile, def_zone, piercing_hit = FALSE)
	. = ..()
	if(. == BULLET_ACT_HIT && (hitting_projectile.stun || hitting_projectile.paralyze))
		fold_in(force = TRUE)
		visible_message(span_warning("The electrically-charged projectile disrupts [src]'s holomatrix, forcing [p_them()] to fold in!"))

/mob/living/silicon/pai/ignite_mob(silent)
	return FALSE

/mob/living/silicon/pai/getBruteLoss()
	return HOLOCHASSIS_MAX_HEALTH - holochassis_health

/mob/living/silicon/pai/getFireLoss()
	return HOLOCHASSIS_MAX_HEALTH - holochassis_health
