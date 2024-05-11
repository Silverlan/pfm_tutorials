--[[
    Copyright (C) 2023 Silverlan

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
]]

include("/pfm/pfm_core_tutorials.lua")

local TUT_HAND_BONE = "J_Bip_L_Hand"
local TUT_HAND_IK_CHAIN_LENGTH = 4



local function get_character_target(tutorialData)
	if tutorialData.characterTarget ~= nil then
		return ents.find_by_uuid(tutorialData.characterTarget)
	end
	local ent, c = ents.citerator(ents.COMPONENT_IK_SOLVER)()
	if ent == nil then
		return
	end
	return ent
end

local function get_target_uuid(tutorialData)
	local entTgt = get_character_target(tutorialData)
	if util.is_valid(entTgt) == false then
		return ""
	end
	return tostring(entTgt:GetUuid())
end

gui.Tutorial.register_tutorial("inverse_kinematics", "tutorials/animating/inverse_kinematics", function(elTut, pm)
	elTut:SetAudioEnabled(false) -- Disabled until audio has been generated for final tutorial version
	elTut:RegisterSlide("intro", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("actor_editor")

			slide:AddGenericMessageBox()
		end,
		nextSlide = "place_character",
	})

	elTut:RegisterSlide("place_character", {
		init = function(tutorialData, slideData, slide)
			local window = slide:GoToWindow("model_catalog")
			local explorer = util.is_valid(window) and window:GetExplorer() or nil
			if util.is_valid(explorer) then
				explorer:SetPath("characters/")
				explorer:Update()
			end

			slide:SetFocusElement(slide:FindElementByPath("contents"))
			slide:AddHighlight(
				pfm.WINDOW_MODEL_CATALOG_UI_ID .. "/models_characters_generic_anime_char_male.pmdl_b",
				true
			)
			slide:AddGenericMessageBox()
		end,
		clearCondition = function(tutorialData, slideData)
			return get_character_target(tutorialData) ~= nil
		end,
		nextSlide = "move_tool",
	})

	elTut:RegisterSlide("move_tool", {
		init = function(tutorialData, slideData, slide)
			local entTgt = get_character_target(tutorialData)
			if entTgt ~= nil then
				tutorialData.characterTarget = tostring(entTgt:GetUuid())
			end
			slide:AddHighlight(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID .. "/manip_controls/manip_move", true)

			slide:AddGenericMessageBox()
		end,
		clearCondition = function(tutorialData, slideData)
			local vp = tool.get_filmmaker():GetViewport()
			if util.is_valid(vp) == false then
				return true
			end
			return vp:GetManipulatorMode() == gui.PFMViewport.MANIPULATOR_MODE_MOVE
		end,
		nextSlide = "ik_controls",
	})

	elTut:RegisterSlide("ik_controls", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddGenericMessageBox()
		end,
		nextSlide = "ik_control_types",
	})

	elTut:RegisterSlide("ik_control_types", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddHighlight(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID .. "/manip_controls/manip_rotate", true)
			slide:AddGenericMessageBox()
		end,
		nextSlide = "elbow_control",
	})

	elTut:RegisterSlide("elbow_control", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("actor_editor")

			local charTarget = get_character_target(tutorialData)
			if util.is_valid(charTarget) then
				local uuidChar = tostring(charTarget:GetUuid())

				slide:SetFocusElement(slide:FindElementByPath("contents"))
				slide:AddHighlight(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/actors/header")
				slide:AddHighlight(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. uuidChar .. "/header")
				slide:AddHighlight(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. uuidChar .. "/ik_solver/header")
				slide:AddHighlight(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. uuidChar .. "/ik_solver/control/header")
				slide:AddHighlight(
					pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. uuidChar .. "/ik_solver/control/J_Bip_L_LowerArm/header"
				)
				slide:AddHighlight(
					pfm.WINDOW_ACTOR_EDITOR_UI_ID
						.. "/"
						.. uuidChar
						.. "/ik_solver/control/J_Bip_L_LowerArm/contents_wrapper/strength/header"
				)
				slide:AddHighlight("property_controls/control_J_Bip_L_LowerArm_strength", true)
			end
			slide:AddGenericMessageBox()
		end,
		nextSlide = "quick_ik",
	})

	elTut:RegisterSlide("quick_ik", {
		init = function(tutorialData, slideData, slide)
			slide:AddGenericMessageBox()
		end,
		nextSlide = "determine_bone",
	})

	elTut:RegisterSlide("determine_bone", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("actor_editor")
			slide:SetFocusElement(slide:FindElementByPath("contents"))

			local vp = tool.get_filmmaker():GetViewport()
			if util.is_valid(vp) then
				vp:SetManipulatorMode(gui.PFMViewport.MANIPULATOR_MODE_SELECT)
			end

			local charTarget = get_character_target(tutorialData)
			if util.is_valid(charTarget) then
				local actorC = charTarget:GetComponent(ents.COMPONENT_PFM_ACTOR)
				local actor = (actorC ~= nil) and actorC:GetActorData() or nil
				if actor ~= nil then
					local cmd = pfm.create_command("delete_component", actor, "ik_solver")
					cmd:Execute()
				end
			end

			local actor = pfm.dereference(get_target_uuid(tutorialData))
			local ent = (actor ~= nil) and actor:FindEntity() or nil
			local mdl = util.is_valid(ent) and ent:GetModel() or nil
			local boneNames = {}
			if mdl ~= nil then
				local skeleton = mdl:GetSkeleton()
				local bone = skeleton:GetBone(mdl:LookupBone(TUT_HAND_BONE))
				while bone ~= nil do
					table.insert(boneNames, 1, bone:GetName())
					bone = bone:GetParent()
				end
			end

			local bonePath = ""
			local itemNames = {
				"actors",
				get_target_uuid(tutorialData),
				"animated",
				"bone",
			}
			itemNames = table.merge(itemNames, boneNames)
			for i, boneName in ipairs(itemNames) do
				local path = bonePath
				if #path > 0 then
					path = path .. "/"
				end
				path = path .. boneName
				slide:AddHighlight(path .. "/header", i == #itemNames)
				bonePath = path
			end

			slide:AddGenericMessageBox({ TUT_HAND_BONE })
		end,
		clearCondition = function(tutorialData, slideData, slide)
			if util.is_valid(slideData.itemHandBone) == false then
				slideData.itemHandBone =
					slide:FindElementByPath(get_target_uuid(tutorialData) .. "/" .. TUT_HAND_BONE, false)
			end
			if util.is_valid(slideData.itemHandBone) == false then
				return false
			end
			return slideData.itemHandBone:IsSelected()
		end,
		nextSlide = "select_chain_length",
	})

	elTut:RegisterSlide("select_chain_length", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("actor_editor")
			slide:SetFocusElement(slide:FindElementByPath("editor_frame/window_actor_editor"))
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR_UI_ID))
			slide:AddHighlight(get_target_uuid(tutorialData) .. "/" .. TUT_HAND_BONE .. "/header")
			slide:AddHighlight("context_menu")
			slide:AddHighlight("context_menu/add_ik_control")
			slide:AddHighlight("context_menu_add_ik_control/ik_control_chain_4", true)

			slide:AddGenericMessageBox({ TUT_HAND_IK_CHAIN_LENGTH })
		end,
		clearCondition = function(tutorialData, slideData, slide)
			return util.is_valid(slide:FindElementByPath(get_target_uuid(tutorialData) .. "/ik_solver/header", false))
		end,
		nextSlide = "controls",
		autoContinue = true,
	})

	elTut:RegisterSlide("controls", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("actor_editor")
			slide:SetFocusElement(slide:FindElementByPath("contents"))
			slide:AddHighlight(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. get_target_uuid(tutorialData) .. "/header")
			slide:AddHighlight(
				pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. get_target_uuid(tutorialData) .. "/ik_solver/header"
			)
			slide:AddHighlight(
				pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. get_target_uuid(tutorialData) .. "/ik_solver/control/header"
			)
			slide:AddHighlight(
				pfm.WINDOW_ACTOR_EDITOR_UI_ID
					.. "/"
					.. get_target_uuid(tutorialData)
					.. "/ik_solver/control/"
					.. TUT_HAND_BONE
					.. "/header",
				true
			)
			slide:AddGenericMessageBox()

			--[[local targetInfo = slide:AddViewportTarget(TUT_IK_HAND_TARGET_LOCATION, function()
				local ent = ents.find_by_uuid(get_target_uuid(tutorialData))
				local ikSolverC = (ent ~= nil) and ent:GetComponent(ents.COMPONENT_IK_SOLVER) or nil
				local idx = (ikSolverC ~= nil) and ikSolverC:GetMemberIndex("control/" .. TUT_HAND_BONE .. "/position")
					or nil
				local posDriven = (idx ~= nil) and ikSolverC:GetTransformMemberPos(idx, math.COORDINATE_SPACE_WORLD)
					or nil
				return posDriven or Vector()
			end, 4.0)
			slideData.targetInfo = targetInfo]]
		end,
		--[[clearCondition = function(tutorialData, slideData, slide)
			return slideData.targetInfo.isInRange()
		end,]]
		nextSlide = "controls2",
	})

	elTut:RegisterSlide("controls2", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("actor_editor")
			slide:SetFocusElement(slide:FindElementByPath("contents"))
			slide:AddHighlight(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. get_target_uuid(tutorialData) .. "/header")
			slide:AddHighlight(
				pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. get_target_uuid(tutorialData) .. "/ik_solver/header"
			)
			slide:AddHighlight(
				pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. get_target_uuid(tutorialData) .. "/ik_solver/control/header"
			)
			slide:AddHighlight(
				pfm.WINDOW_ACTOR_EDITOR_UI_ID
					.. "/"
					.. get_target_uuid(tutorialData)
					.. "/ik_solver/control/"
					.. TUT_HAND_BONE
					.. "/header"
			)
			slide:AddGenericMessageBox()
		end,
		nextSlide = "conclusion",
	})

	elTut:RegisterSlide("conclusion", {
		init = function(tutorialData, slideData, slide)
			slide:SetTutorialCompleted()
			slide:AddGenericMessageBox()
		end,
		nextSlide = "next_tutorial",
	})

	elTut:RegisterSlide("next_tutorial", {
		init = function(tutorialData, slideData, slide)
			-- pm:LoadTutorial("animating/constraints") -- TODO
			time.create_simple_timer(0.0, function()
				gui.Tutorial.close_tutorial()
			end)
		end,
	})

	elTut:StartSlide("intro")
end)
