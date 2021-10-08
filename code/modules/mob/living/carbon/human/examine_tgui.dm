/datum/examine_panel
	var/mob/living/carbon/human/holder //client of whoever is using this datum
	var/mob/living/carbon/human/dummy/dummy_holder
	var/atom/movable/screen/examine_panel_dummy/examine_panel_screen

/datum/examine_panel/ui_state(mob/user)
	return GLOB.always_state

/datum/examine_panel/ui_close(mob/user)
	user.client.clear_map(examine_panel_screen.assigned_map)

/atom/movable/screen/examine_panel_dummy
	name = "examine panel dummy"

/datum/examine_panel/ui_interact(mob/user, datum/tgui/ui)
	if(!examine_panel_screen)
		dummy_holder = generate_dummy_lookalike(REF(holder), holder)
		var/datum/job/job_ref = SSjob.GetJob(holder.job)
		if(job_ref && job_ref.outfit)
			var/datum/outfit/outfit_ref = new()
			outfit_ref.copy_outfit_from_target(holder)
			outfit_ref.equip(dummy_holder, visualsOnly=TRUE)
		examine_panel_screen = new
		examine_panel_screen.vis_contents += dummy_holder
		examine_panel_screen.name = "screen"
		examine_panel_screen.assigned_map = "examine_panel_[REF(holder)]_map"
		examine_panel_screen.del_on_map_removal = FALSE
		examine_panel_screen.screen_loc = "[examine_panel_screen.assigned_map]:1,1"
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		user.client.register_map_obj(examine_panel_screen)
		ui = new(user, src, "ExaminePanel")
		ui.open()

/datum/examine_panel/ui_data(mob/user)
	var/list/data = list()

	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))
	var/name = skipface ? "Unknown" : holder.name
	var/flavor_text = skipface ? "Obscured" :  holder.dna.features["flavor_text"]
	var/custom_species = skipface ? "Obscured" : holder.dna.features["custom_species"]
	var/custom_species_lore = skipface ? "Obscured" : holder.dna.features["custom_species_lore"]

	data["obscured"] = skipface ? TRUE : FALSE
	data["character_name"] = name
	data["assigned_map"] = examine_panel_screen.assigned_map
	data["flavor_text"] = flavor_text
	data["ooc_notes"] = holder.dna.features["ooc_notes"]
	data["custom_species"] = custom_species
	data["custom_species_lore"] = custom_species_lore
	return data
