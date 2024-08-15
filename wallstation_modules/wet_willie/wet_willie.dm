// Mood event
/datum/mood_event/willie
	description = "Ewwww, My ear is all wet!"
	mood_change = -2
	timeout = 60 SECONDS

// Abstract item
/obj/item/hand_item/willie
	name = "willie"
	desc = "Get someone in an aggressive grab then use this on them to give them a wet willie"
	inhand_icon_state = "nothing"

/obj/item/hand_item/willie/attack(mob/living/carbon/target, mob/living/carbon/human/user)
	if(!istype(target))
		to_chat(user, span_warning("You don't think you can give this a wet willie"))
		return


	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_warning("You can't bring yourself to give [target] a wt willie! You don't want to risk harming anyone..."))
		return

	if(!(target?.get_bodypart(BODY_ZONE_HEAD)) || user.pulling != target || user.grab_state < GRAB_AGGRESSIVE || user.getStaminaLoss() > 80)
		return FALSE

	var/obj/item/bodypart/head/the_head = target.get_bodypart(BODY_ZONE_HEAD)
	if(!(the_head.biological_state & BIO_FLESH))
		to_chat(user, span_warning("You can't give [target] a wet willie, [target.p_they()] [target.p_have()] no skin on [target.p_their()] ears!"))
		return

	user.visible_message(span_danger("[user] begins giving [target] a wet willie!"), span_warning("You start giving [target] a wet willie!"), vision_distance=COMBAT_MESSAGE_RANGE, ignored_mobs=target)
	to_chat(target, span_userdanger("[user] starts giving you a wet willie!"))

	if(!do_after(user, 1 SECONDS, target))
		to_chat(user, span_warning("You fail to give [target] a wet willie!"))
		to_chat(target, span_danger("[user] fails to give you a wet willie!"))
		return

	target.add_mood_event("willie", /datum/mood_event/willie)

	willie_loop(user, target, 0)

/// The actual meat and bones of the willy'ing
/obj/item/hand_item/willie/proc/willie_loop(mob/living/carbon/human/user, mob/living/carbon/target, iteration)
	if(!(target?.get_bodypart(BODY_ZONE_HEAD)) || user.pulling != target)
		return FALSE

	if(user.getStaminaLoss() > 80)
		to_chat(user, span_warning("You're too tired to continue giving [target] a wet willie!"))
		to_chat(target, span_danger("[user] is too tired to continue giving you a wet willie!"))
		return

	var/damage = rand(1, 2)
	var/ear_damage = 1
	var/obj/item/organ/internal/ears/ears = target.get_organ_slot(ORGAN_SLOT_EARS)
	if(istype(ears, /obj/item/organ/internal/ears/cat))
		damage += rand(2,4)
		ear_damage += rand(1,3)
	if(damage >= 5)
		target.emote("scream")

	log_combat(user, target, "given a wet willie to", addition = "([damage] brute before armor)")
	target.apply_damage(damage, BRUTE, BODY_ZONE_HEAD)
	target.adjustOrganLoss(ORGAN_SLOT_EARS, ear_damage)
	user.adjustStaminaLoss(iteration + 5)
	// playsound() - :mistake:

	if(prob(33))
		user.visible_message(span_danger("[user] continues giving [target] a wet willie!"), span_warning("You continue giving [target] a wet willie!"), vision_distance=COMBAT_MESSAGE_RANGE, ignored_mobs=target)
		to_chat(target, span_userdanger("[user] continues giving you a wet willie!"))

	if(!do_after(user, 1 SECONDS + (iteration * 2), target))
		to_chat(user, span_warning("You fail to give [target] a wet willie!"))
		to_chat(target, span_danger("[user] fails to give you a wet willie!"))
		return

	iteration++
	willie_loop(user, target, iteration)

// Emote
/datum/emote/living/carbon/willie
	key = "willie"
	key_third_person = "willies"
	hands_use_check = TRUE

/datum/emote/living/carbon/willie/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	var/obj/item/hand_item/willie/willie = new(user)
	if(user.put_in_hands(willie))
		to_chat(user, span_notice("You ready your willy'ing hand."))
	else
		qdel(willie)
		to_chat(user, span_warning("You're incapable of willy'ing in your current state."))
