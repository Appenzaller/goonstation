/*========================*/
/*----------Eyes----------*/
/*========================*/

/obj/item/organ/eye
	name = "eyeball"
	organ_name = "eye"
	desc = "Here's lookin' at you! Er, maybe not so much, anymore."
	organ_holder_location = "head"
	icon = 'icons/obj/items/organs/eye.dmi'
	icon_state = "eye"
	var/change_iris = 1
	var/iris_color = "#0D84A8"
	var/iris_state_override = null
	var/color_r = 1 // same as glasses/helmets/masks/etc, used for vision color modifications, see human/handle_regular_hud_updates()
	var/color_g = 1
	var/color_b = 1
	var/show_on_examine = FALSE // do we get mentioned when our donor is examined?

	New()
		..()
		SPAWN(0)
			src.UpdateIcon()

	disposing()
		if (holder)
			if (holder.left_eye == src)
				holder.left_eye = null
			if (holder.right_eye == src)
				holder.right_eye = null
		..()

	on_transplant(mob/M)
		. = ..()
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.update_face()

	on_removal()
		if(ishuman(donor))
			var/mob/living/carbon/human/H = donor
			SPAWN(0) //need to delay until after the eye is actually removed from the organholder
				H.update_face()
		. = ..()

	proc/update_color(datum/appearanceHolder/AH, side)
		if(src.change_iris)
			if (AH.customization_first.id == "hetcro[side]")
				src.iris_color = AH.customization_first_color
			else if (AH.customization_second.id == "hetcro[side]")
				src.iris_color = AH.customization_second_color
			else if (AH.customization_third.id == "hetcro[side]")
				src.iris_color = AH.customization_third_color
			else
				src.iris_color = AH.e_color
			var/image/iris_image = image(src.icon, src, "[iris_state_override || icon_state]-iris")
			iris_image.color = iris_color
			src.UpdateOverlays(iris_image, "iris")


	attach_organ(var/mob/living/carbon/M, var/mob/user)
		/* Overrides parent function to handle special case for attaching eyes.
		Note that eyes don't appear to track op_stage on the head container, like chest organs do. */
		var/mob/living/carbon/human/H = M
		if (!src.can_attach_organ(H, user))
			return 0

		if (!headSurgeryCheck(H))
			user.show_text("You're going to need to remove that mask/helmet/glasses first.", "blue")
			return null

		var/fluff = pick("insert", "shove", "place", "drop", "smoosh", "squish")
		var/target_organ_location = null

		if (user.find_in_hand(src, "right"))
			target_organ_location = "right"
		else if (user.find_in_hand(src, "left"))
			target_organ_location = "left"
		else if (!user.find_in_hand(src))
			// Organ is not in the attackers hand. This was likely a drag and drop. If you're just tossing an organ at a body, where it lands will be imprecise
			target_organ_location = pick("right", "left")

		if (target_organ_location == "right" && !H.organHolder.right_eye)
			user.tri_message(H, "<span class='alert'><b>[user]</b> [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into [H == user ? "[his_or_her(H)]" : "[H]'s"] right eye socket!</span>",\
				"<span class='alert'>You [fluff] [src] into [user == H ? "your" : "[H]'s"] right eye socket!</span>",\
				"<span class='alert'>[H == user ? "You" : "<b>[user]</b>"] [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into your right eye socket!</span>")

			if (user.find_in_hand(src))
				user.u_equip(src)
			H.organHolder.receive_organ(src, "right_eye", 2)
			H.update_body()
		else if (target_organ_location == "left" && !H.organHolder.left_eye)
			user.tri_message(H, "<span class='alert'><b>[user]</b> [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into [H == user ? "[his_or_her(H)]" : "[H]'s"] left eye socket!</span>",\
				"<span class='alert'>You [fluff] [src] into [user == H ? "your" : "[H]'s"] left eye socket!</span>",\
				"<span class='alert'>[H == user ? "You" : "<b>[user]</b>"] [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into your left eye socket!</span>")

			if (user.find_in_hand(src))
				user.u_equip(src)
			H.organHolder.receive_organ(src, "left_eye", 2)
			H.update_body()
		else
			user.tri_message(H, "<span class='alert'><b>[user]</b> tries to [fluff] the [src] into [H == user ? "[his_or_her(H)]" : "[H]'s"] right eye socket!<br>But there's something already there!</span>",\
				"<span class='alert'>You try to [fluff] the [src] into [user == H ? "your" : "[H]'s"] right eye socket!<br>But there's something already there!</span>",\
				"<span class='alert'>[H == user ? "You" : "<b>[user]</b>"] [H == user ? "try" : "tries"] to [fluff] the [src] into your right eye socket!<br>But there's something already there!</span>")
			return 0

		return 1

/obj/item/organ/eye/left
	name = "left eye"
	body_side = L_ORGAN

/obj/item/organ/eye/right
	name = "right eye"
	body_side = R_ORGAN

/obj/item/organ/eye/synth
	name = "syntheye"
	organ_name = "syntheye"
	desc = "An eye what done grew out of a plant."
	icon_state = "eye-synth"
	item_state = "plant"
	synthetic = 1
	iris_state_override = "eye"
	iris_color = "#2dca2d"

TYPEINFO(/obj/item/organ/eye/cyber)
	mats = 6

/obj/item/organ/eye/cyber
	name = "cybereye"
	organ_name = "cybereye"
	desc = "A fancy electronic eye to replace one that someone's lost. Kinda fragile, but better than nothing!"
	icon_state = "eye-cyber"
	item_state = "heart_robo1"
	robotic = 1
	created_decal = /obj/decal/cleanable/oil
	edible = 0
	default_material = "pharosium"
	show_on_examine = TRUE
	change_iris = FALSE

	emp_act()
		..()
		if (!src.broken)
			src.take_damage(20, 20, 0)
			if (src.holder && src.holder.donor)
				src.holder.donor.show_text("<b>Your [src.organ_name] [pick("crackles and sparks", "makes a weird crunchy noise", "buzzes strangely")]!</b>", "red")

/obj/item/organ/eye/cyber/configurable
	iris_state_override = "eye"
	change_iris = TRUE

	attackby(obj/item/W, mob/user)
		if(ispulsingtool(W)) //TODO kyle's robotics configuration console/machine/thing
			var/new_color = tgui_color_picker(usr, "Choose a color", "Cybereye", "#0D84A8")
			if (!isnull(new_color))
				iris_color = new_color
			var/image/iris_image = image(src.icon, src, "eye-iris")
			iris_image.color = iris_color
			src.UpdateOverlays(iris_image, "iris")
		else
			. = ..()

TYPEINFO(/obj/item/organ/eye/cyber/sunglass)
	mats = 7

/obj/item/organ/eye/cyber/sunglass
	name = "polarized cybereye"
	organ_name = "polarized cybereye"
	desc = "A fancy electronic eye. It has a polarized filter on the lens for built-in protection from the sun and other harsh lightsources. Your night vision is fucked, though."
	icon_state = "eye-sunglass"
	default_material = "pharosium"
	color_r = 0.95 // darken a little
	color_g = 0.95
	color_b = 0.975 // kinda blue
	iris_color = "#202020"

	on_transplant(mob/M)
		. = ..()
		APPLY_ATOM_PROPERTY(M, PROP_MOB_DISORIENT_RESIST_EYE, src, 100)
		APPLY_ATOM_PROPERTY(M, PROP_MOB_DISORIENT_RESIST_EYE_MAX, src, 100)

	on_removal()
		REMOVE_ATOM_PROPERTY(donor, PROP_MOB_DISORIENT_RESIST_EYE, src)
		REMOVE_ATOM_PROPERTY(donor, PROP_MOB_DISORIENT_RESIST_EYE_MAX, src)
		. = ..()

TYPEINFO(/obj/item/organ/eye/cyber/sechud)
	mats = 7

/obj/item/organ/eye/cyber/sechud
	name = "\improper Security HUD cybereye"
	organ_name = "\improper Security HUD cybereye"
	desc = "A fancy electronic eye. It has a Security HUD system installed."
	icon_state = "eye-sec"
	default_material = "pharosium"
	color_r = 0.975 // darken a little, kinda red
	color_g = 0.95
	color_b = 0.95
	iris_color = "#3a0404"

	process()
		if (src.broken)
			processing_items.Remove(src)
			get_image_group(CLIENT_IMAGE_GROUP_ARREST_ICONS).remove_mob(donor)

	on_transplant(var/mob/M)
		..()
		if (src.broken)
			return
		processing_items |= src
		get_image_group(CLIENT_IMAGE_GROUP_ARREST_ICONS).add_mob(donor)

	on_removal()
		processing_items.Remove(src)
		get_image_group(CLIENT_IMAGE_GROUP_ARREST_ICONS).remove_mob(donor)
		..()

TYPEINFO(/obj/item/organ/eye/cyber/thermal)
	mats = 7

/obj/item/organ/eye/cyber/thermal
	name = "thermal imager cybereye"
	organ_name = "thermal imager cybereye"
	desc = "A fancy electronic eye. It lets you see through cloaks and enhances your night vision. Use caution around bright lights."
	icon_state = "eye-thermal"
	default_material = "pharosium"
	color_r = 1
	color_g = 0.9 // red tint
	color_b = 0.9
	iris_color = "#a01f1f"

	on_transplant(mob/M)
		. = ..()
		APPLY_ATOM_PROPERTY(M, PROP_MOB_THERMALVISION, src)

	on_removal()
		REMOVE_ATOM_PROPERTY(donor, PROP_MOB_THERMALVISION, src)
		. = ..()

TYPEINFO(/obj/item/organ/eye/cyber/meson)
	mats = 7

/obj/item/organ/eye/cyber/meson
	name = "mesonic imager cybereye"
	organ_name = "mesonic imager cybereye"
	desc = "A fancy electronic eye. It lets you see the structure of the station through walls. Trippy!"
	icon_state = "eye-meson"
	default_material = "pharosium"
	color_r = 0.925
	color_g = 1
	color_b = 0.9
	organ_abilities = list(/datum/targetable/organAbility/meson)
	var/on = 1
	var/mob/living/carbon/human/assigned = null
	iris_color = "#45bb00"

	on_transplant(var/mob/M)
		..()
		if (src.broken)
			return
		if (ishuman(M))
			src.assigned = M
			if (src.on)
				src.assigned.vision.set_scan(1)
				APPLY_ATOM_PROPERTY(M, PROP_MOB_MESONVISION, src)

	on_removal()
		REMOVE_ATOM_PROPERTY(donor, PROP_MOB_MESONVISION, src)
		if (istype(assigned.glasses, /obj/item/clothing/glasses/visor))
			return
		else
			src.assigned.vision.set_scan(0)
		..()

	proc/toggle()
		src.on = !src.on
		playsound(assigned, 'sound/items/mesonactivate.ogg', 30, TRUE)
		if (src.on)
			assigned.vision.set_scan(1)
			APPLY_ATOM_PROPERTY(donor, PROP_MOB_MESONVISION, src)
		else
			assigned.vision.set_scan(0)
			REMOVE_ATOM_PROPERTY(donor, PROP_MOB_MESONVISION, src)

TYPEINFO(/obj/item/organ/eye/cyber/spectro)
	mats = 7

/obj/item/organ/eye/cyber/spectro
	name = "spectroscopic imager cybereye"
	organ_name = "spectroscopic imager cybereye"
	desc = "A fancy electronic eye. It has an integrated minature Raman spectroscope for easy qualitative and quantitative analysis of chemical samples."
	icon_state = "eye-spectro"
	default_material = "pharosium"
	color_r = 1 // pink tint?
	color_g = 0.9
	color_b = 0.95
	iris_color = "#d12ab5"

	on_transplant(mob/M)
		. = ..()
		APPLY_ATOM_PROPERTY(M, PROP_MOB_SPECTRO, src)

	on_removal()
		REMOVE_ATOM_PROPERTY(donor, PROP_MOB_SPECTRO, src)
		. = ..()

TYPEINFO(/obj/item/organ/eye/cyber/prodoc)
	mats = 7

/obj/item/organ/eye/cyber/prodoc
	name = "\improper ProDoc Healthview cybereye"
	organ_name = "\improper ProDoc Healthview cybereye"
	desc = "A fancy electronic eye. It's fitted with an advanced miniature sensor array that allows you to quickly determine the physical condition of others."
	icon_state = "eye-prodoc"
	default_material = "pharosium"
	color_r = 0.925
	color_g = 1
	color_b = 0.925
	iris_color = "#1dd144"

	// stolen from original prodocs
	process()
		if (src.broken)
			processing_items.Remove(src)
			get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).remove_mob(donor)

	on_transplant(var/mob/M)
		..()
		if (src.broken)
			return
		processing_items |= src
		APPLY_ATOM_PROPERTY(M,PROP_MOB_EXAMINE_HEALTH,src)
		get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).add_mob(M)
		return

	on_removal(var/mob/M)
		processing_items.Remove(src)
		REMOVE_ATOM_PROPERTY(M,PROP_MOB_EXAMINE_HEALTH,src)
		get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).remove_mob(donor)
		..()
		return

TYPEINFO(/obj/item/organ/eye/cyber/ecto)
	mats = 7

/obj/item/organ/eye/cyber/ecto
	name = "ectosensor cybereye"
	organ_name = "ectosensor cybereye"
	desc = "A fancy electronic eye. It lets you see spooky stuff."
	icon_state = "eye-ecto"
	default_material = "pharosium"
	color_r = 0.925
	color_g = 1
	color_b = 0.925
	iris_color = "#65e681"

	on_transplant(mob/M)
		. = ..()
		APPLY_ATOM_PROPERTY(M, PROP_MOB_GHOSTVISION, src)

	on_removal()
		REMOVE_ATOM_PROPERTY(donor, PROP_MOB_GHOSTVISION, src)
		. = ..()

TYPEINFO(/obj/item/organ/eye/cyber/camera)
	mats = 7

/obj/item/organ/eye/cyber/camera
	name = "camera cybereye"
	organ_name = "camera cybereye"
	desc = "A fancy electronic eye. It has a camera in it connected to the station's security camera network."
	icon_state = "eye-camera"
	var/obj/machinery/camera/camera = null
	var/camera_tag = "Eye Cam"
	var/camera_network = "Zeta"
	default_material = "pharosium"
	iris_color = "#0d0558"

	New()
		..()
		src.camera = new /obj/machinery/camera(src)
		src.camera.c_tag = src.camera_tag
		src.camera.network = src.camera_network

	on_transplant(var/mob/M)
		..()
		src.camera.c_tag = "[M]'s Eye"
		return ..()

TYPEINFO(/obj/item/organ/eye/cyber/nightvision)
	mats = 7

/obj/item/organ/eye/cyber/nightvision
	name = "night vision cybereye"
	organ_name = "night vision cybereye"
	desc = "A fancy electronic eye. It has built-in image-intensifier tubes to allow vision in the dark. Keep away from bright lights."
	icon_state = "eye-night"
	default_material = "pharosium"
	color_r = 0.7
	color_g = 1
	color_b = 0.7
	iris_color = "#027e17"

	on_transplant(mob/M)
		. = ..()
		APPLY_ATOM_PROPERTY(M, PROP_MOB_NIGHTVISION, src)

	on_removal()
		REMOVE_ATOM_PROPERTY(donor, PROP_MOB_NIGHTVISION, src)
		. = ..()

TYPEINFO(/obj/item/organ/eye/cyber/laser)
	mats = 7

/obj/item/organ/eye/cyber/laser
	name = "laser cybereye"
	organ_name = "laser cybereye"
	desc = "A fancy electronic eye. It can fire a small laser."
	icon_state = "eye-laser"
	default_material = "pharosium"
	color_r = 1
	color_g = 0.85
	color_b = 0.85
	organ_abilities = list(/datum/targetable/organAbility/eyebeam)
	iris_color = "#ff0000"
	var/eye_proj_override = null

	add_ability(var/datum/abilityHolder/aholder, var/abil)
		if (!ispath(abil, /datum/targetable/organAbility/eyebeam) || !aholder)
			return ..()
		var/datum/targetable/organAbility/eyebeam/OA = aholder.getAbility(abil)//addAbility(abil)
		if (istype(OA)) // already has a laser eye, apparently!  let's DOUBLE IT
			OA.linked_organ = list(OA.linked_organ, src)
			OA.cooldown = 80
			OA.eye_proj = ispath(src.eye_proj_override) ? eye_proj_override : /datum/projectile/laser/eyebeams
		else
			OA = aholder.addAbility(abil)
			if (istype(OA))
				OA.linked_organ = src
				OA.cooldown = 40
				if (ispath(src.eye_proj_override))
					OA.eye_proj = src.eye_proj_override
					OA.cooldown = 80
				else if (src.body_side == L_ORGAN)
					OA.eye_proj = /datum/projectile/laser/eyebeams/left
				else
					OA.eye_proj = /datum/projectile/laser/eyebeams/right

	remove_ability(var/datum/abilityHolder/aholder, var/abil)
		if (!ispath(abil, /datum/targetable/organAbility/eyebeam) || !aholder)
			return ..()
		var/datum/targetable/organAbility/eyebeam/OA = aholder.getAbility(abil)
		if (!OA) // what??
			return
		if (islist(OA.linked_organ)) // two laser eyes, just remove our half of the projectile and whatnot
			var/list/lorgans = OA.linked_organ
			lorgans -= src // remove us from the list so only the other eye is left and thus will be lorgans[1]
			OA.linked_organ = lorgans[1]
			OA.cooldown = 40
			if (istype(OA.linked_organ, /obj/item/organ/eye/cyber/laser)) // I mean uhh it really really ought to be but we gotta be careful I guess
				var/obj/item/organ/eye/cyber/laser/other_eye = OA.linked_organ
				if (ispath(other_eye.eye_proj_override))
					OA.eye_proj = other_eye.eye_proj_override
					OA.cooldown = 80
					return
			if (src.body_side == L_ORGAN)
				OA.eye_proj = /datum/projectile/laser/eyebeams/right
			else
				OA.eye_proj = /datum/projectile/laser/eyebeams/left
		else // just us!
			aholder.removeAbility(abil)

/obj/item/organ/eye/lizard
	name = "slit eye"
	desc = "I guess its owner is just a lzard now. Ugh that pun was terrible. Not worth losing an eye over."
	icon_state = "eye-lizard"

obj/item/organ/eye/skeleton
	name = "boney eye"
	desc = "Yes it also has eye sockets. How this works is unknown."
	icon_state = "eye-bone"
	default_material = "bone" //duh
	blood_reagent = "calcium"
	change_iris = 0

/obj/item/organ/eye/cow
	name = "cow eye"
	desc = "This takes 'hitting the bullseye' to another level."
	icon_state = "eye-cow"
	blood_reagent = "milk"

/obj/item/organ/eye/pug
	name = "pug eye"
	desc = "Poor guy."
