--[[
    Copyright (C) 2023 Silverlan

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
]]

include("/pfm/pfm_core_tutorials.lua")

local TUT_HAND_BONE = "J_Bip_L_Hand"
local TUT_HAND_IK_CHAIN_LENGTH = 4
local TUT_ACTOR_UUID = "180f36ee-f747-4b85-80df-290ad4afc2ef"
local TUT_IK_RIG = "tut_demo_ik_rig"
local TUT_IK_HAND_TARGET_LOCATION = Vector(-112.117, 55.6728, -88.7924)


gui.Tutorial.register_tutorial("inverse_kinematics", "tutorials/animating/inverse_kinematics", function(elTut, pm)
	elTut:RegisterSlide("intro", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("actor_editor")

			slide:AddGenericMessageBox()
		end,
		nextSlide = "options",
	})

	elTut:RegisterSlide("options", {
		init = function(tutorialData, slideData, slide)
			slide:AddGenericMessageBox()
		end,
		nextSlide = "determine_bone",
	})

	elTut:RegisterSlide("determine_bone", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("actor_editor")
			slide:SetFocusElement(slide:FindElementByPath("contents"))

			local actor = pfm.dereference(TUT_ACTOR_UUID)
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
				TUT_ACTOR_UUID,
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
				slideData.itemHandBone = slide:FindElementByPath(TUT_ACTOR_UUID .. "/" .. TUT_HAND_BONE, false)
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
			slide:AddHighlight(TUT_ACTOR_UUID .. "/" .. TUT_HAND_BONE .. "/header")
			slide:AddHighlight("context_menu")
			slide:AddHighlight("context_menu/add_ik_control")
			slide:AddHighlight("context_menu_add_ik_control/ik_control_chain_4", true)

			slide:AddGenericMessageBox({ TUT_HAND_IK_CHAIN_LENGTH })
		end,
		clearCondition = function(tutorialData, slideData, slide)
			return util.is_valid(slide:FindElementByPath(TUT_ACTOR_UUID .. "/ik_solver/header", false))
		end,
		nextSlide = "controls",
		--autoContinue = true
	})

	elTut:RegisterSlide("controls", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("actor_editor")
			slide:SetFocusElement(slide:FindElementByPath("contents"))
			slide:AddHighlight(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. TUT_ACTOR_UUID .. "/header")
			slide:AddHighlight(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. TUT_ACTOR_UUID .. "/ik_solver/header")
			slide:AddHighlight(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. TUT_ACTOR_UUID .. "/ik_solver/control/header")
			slide:AddHighlight(
				pfm.WINDOW_ACTOR_EDITOR_UI_ID
					.. "/"
					.. TUT_ACTOR_UUID
					.. "/ik_solver/control/"
					.. TUT_HAND_BONE
					.. "/header",
				true
			)
			slide:AddGenericMessageBox()

			local targetInfo = slide:AddViewportTarget(TUT_IK_HAND_TARGET_LOCATION, function()
				local ent = ents.find_by_uuid(TUT_ACTOR_UUID)
				local ikSolverC = (ent ~= nil) and ent:GetComponent(ents.COMPONENT_IK_SOLVER) or nil
				local idx = (ikSolverC ~= nil) and ikSolverC:GetMemberIndex("control/" .. TUT_HAND_BONE .. "/position")
					or nil
				local posDriven = (idx ~= nil) and ikSolverC:GetTransformMemberPos(idx, math.COORDINATE_SPACE_WORLD)
					or nil
				return posDriven or Vector()
			end, 4.0)
			slideData.targetInfo = targetInfo
		end,
		clearCondition = function(tutorialData, slideData, slide)
			return slideData.targetInfo.isInRange()
		end,
		nextSlide = "controls2",
	})

	elTut:RegisterSlide("controls2", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("actor_editor")
			slide:SetFocusElement(slide:FindElementByPath("contents"))
			slide:AddHighlight(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. TUT_ACTOR_UUID .. "/header")
			slide:AddHighlight(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. TUT_ACTOR_UUID .. "/ik_solver/header")
			slide:AddHighlight(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. TUT_ACTOR_UUID .. "/ik_solver/control/header")
			slide:AddHighlight(
				pfm.WINDOW_ACTOR_EDITOR_UI_ID
					.. "/"
					.. TUT_ACTOR_UUID
					.. "/ik_solver/control/"
					.. TUT_HAND_BONE
					.. "/header"
			)
			slide:AddGenericMessageBox()

			local targetInfo = slide:AddViewportTarget(Vector(), function()
				local ent = ents.find_by_uuid(TUT_ACTOR_UUID)
				local ikSolverC = (ent ~= nil) and ent:GetComponent(ents.COMPONENT_IK_SOLVER) or nil
				local idx = (ikSolverC ~= nil) and ikSolverC:GetMemberIndex("control/" .. TUT_HAND_BONE .. "/position")
					or nil
				local posDriven = (idx ~= nil) and ikSolverC:GetTransformMemberPos(idx, math.COORDINATE_SPACE_WORLD)
					or nil
				return posDriven or Vector()
			end, 4.0)
			slideData.targetInfo = targetInfo
		end,
		nextSlide = "ik_rig",
	})

	elTut:RegisterSlide("ik_rig", {
		init = function(tutorialData, slideData, slide)
			slide:AddGenericMessageBox()
		end,
		nextSlide = "ik_rig_property",
	})

	elTut:RegisterSlide("ik_rig_property", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("actor_editor")
			slide:SetFocusElement(slide:FindElementByPath("contents"))

			slide:AddHighlight(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. TUT_ACTOR_UUID .. "/header")
			slide:AddHighlight(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. TUT_ACTOR_UUID .. "/ik_solver/header")
			slide:AddHighlight(
				pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. TUT_ACTOR_UUID .. "/ik_solver/base_properties/header"
			)
			slide:AddHighlight(
				pfm.WINDOW_ACTOR_EDITOR_UI_ID
					.. "/"
					.. TUT_ACTOR_UUID
					.. "/ik_solver/base_properties/rigConfigFile/header"
			)
			slide:AddHighlight(

				pfm.WINDOW_ACTOR_EDITOR_UI_ID
					.. "/"
					.. TUT_ACTOR_UUID
					.. "/ik_solver/base_properties/rigConfigFile/header",
				true
			)

			slide:AddGenericMessageBox()
		end,
		clearCondition = function(tutorialData, slideData, slide)
			if util.is_valid(slideData.itemRigConfigFile) == false then
				slideData.itemRigConfigFile =
					slide:FindElementByPath(TUT_ACTOR_UUID .. "/ik_solver/base_properties/rigConfigFile", false)
			end
			if util.is_valid(slideData.itemRigConfigFile) == false then
				return false
			end
			return slideData.itemRigConfigFile:IsSelected()
		end,
		nextSlide = "ik_rig_file",
	})

	elTut:RegisterSlide("ik_rig_file", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("actor_editor")
			slide:SetFocusElement(slide:FindElementByPath("contents"))

			slide:AddHighlight(
				pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/base_property_controls/rigConfigFile/browse_button",
				true
			)

			slide:AddGenericMessageBox({ TUT_IK_RIG })
		end,
		clearCondition = function(tutorialData, slideData, slide)
			local actor = pfm.dereference(TUT_ACTOR_UUID)
			if actor == nil then
				return true
			end
			local val = actor:GetMemberValue("ec/ik_solver/rigConfigFile")
			return val ~= nil and #val > 0
		end,
		nextSlide = "ik_rig_hand_control",
	})

	elTut:RegisterSlide("ik_rig_hand_control", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("actor_editor")
			slide:SetFocusElement(slide:FindElementByPath("contents"))
			slide:AddHighlight(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. TUT_ACTOR_UUID .. "/header")
			slide:AddHighlight(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. TUT_ACTOR_UUID .. "/ik_solver/header")
			slide:AddHighlight(
				pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. TUT_ACTOR_UUID .. "/ik_solver/control/header",
				true
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
