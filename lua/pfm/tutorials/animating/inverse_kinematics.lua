--[[
    Copyright (C) 2023 Silverlan

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
]]

include("/pfm/pfm_core_tutorials.lua")

local TUT_HAND_BONE = "L.hand"
local TUT_HAND_IK_CHAIN_LENGTH = 5
local TUT_ACTOR_UUID = "f04525e7-5331-4c15-bc15-59cf10fbf797"

local TUT_FOOT_IK_CHAIN_LENGTH = 4

gui.Tutorial.register_tutorial("inverse_kinematics", "tutorials/animating/inverse_kinematics", function(elTut, pm)
	elTut:RegisterSlide("intro", {
		init = function(tutorialData, slideData, slide)
			slide:OpenWindow("actor_editor")

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
			slide:OpenWindow("actor_editor")
			slide:SetFocusElement(slide:FindElementByPath("contents"))

			local bonePath = ""
			for _, boneName in ipairs({
				"d5aa0397-0bed-4e6b-949d-ba1318afc4b0",
				TUT_ACTOR_UUID,
				"animated",
				"bone",
				"lowerBody",
				"middleBody",
				"Chest",
				"UpperChest",
				"L.shoulder",
				"L.upperArm",
				"L.lowerArm",
				"L.hand",
			}) do
				local path = bonePath
				if #path > 0 then
					path = path .. "/"
				end
				path = path .. boneName
				slide:AddHighlight(path .. "/header")
				bonePath = path
			end

			slide:AddGenericMessageBox({ TUT_HAND_BONE })
		end,
		clearCondition = function(tutorialData, slideData, slide)
			if util.is_valid(slideData.itemHandBone) == false then
				slideData.itemHandBone = slide:FindElementByPath(TUT_ACTOR_UUID .. "/L.hand")
			end
			if util.is_valid(slideData.itemHandBone) == false then
				return true
			end
			return slideData.itemHandBone:IsSelected()
		end,
		nextSlide = "select_chain_length",
	})

	elTut:RegisterSlide("select_chain_length", {
		init = function(tutorialData, slideData, slide)
			slide:OpenWindow("actor_editor")
			slide:SetFocusElement(slide:FindElementByPath("editor_frame/window_actor_editor"))
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR_UI_ID))
			slide:AddHighlight("context_menu")
			slide:AddHighlight("context_menu/add_ik_control")
			slide:AddHighlight("context_menu_add_ik_control/ik_control_chain_4")

			slide:AddGenericMessageBox({ TUT_HAND_IK_CHAIN_LENGTH })
		end,
		clearCondition = function(tutorialData, slideData, slide)
			return util.is_valid(slide:FindElementByPath(TUT_ACTOR_UUID .. "/ik_solver/header", false))
		end,
		nextSlide = "controls",
	})

	elTut:RegisterSlide("controls", {
		init = function(tutorialData, slideData, slide)
			slide:OpenWindow("actor_editor")
			slide:SetFocusElement(slide:FindElementByPath("contents"))
			slide:AddHighlight(
				slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. TUT_ACTOR_UUID .. "/header")
			)
			slide:AddHighlight(
				slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. TUT_ACTOR_UUID .. "/ik_solver/header")
			)
			slide:AddHighlight(
				slide:FindElementByPath(
					pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. TUT_ACTOR_UUID .. "/ik_solver/control/header"
				)
			)
			slide:AddHighlight(
				slide:FindElementByPath(
					pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. TUT_ACTOR_UUID .. "/ik_solver/control/L.hand/header"
				)
			)
			slide:AddGenericMessageBox()

			local targetInfo = slide:AddViewportTarget(Vector(5, 45, 10), function()
				local ent = ents.find_by_uuid(TUT_ACTOR_UUID)
				local ikSolverC = (ent ~= nil) and ent:GetComponent(ents.COMPONENT_IK_SOLVER) or nil
				local idx = (ikSolverC ~= nil) and ikSolverC:GetMemberIndex("control/L.hand/position") or nil
				local posDriven = (idx ~= nil) and ikSolverC:GetTransformMemberPos(idx, math.COORDINATE_SPACE_WORLD)
					or nil
				return posDriven or Vector()
			end, 4.0)
			slideData.targetInfo = targetInfo
		end,
		clearCondition = function(tutorialData, slideData, slide)
			return slideData.targetInfo.isInRange()
		end,
		nextSlide = "elbow_orientation",
	})

	elTut:RegisterSlide("elbow_orientation", {
		init = function(tutorialData, slideData, slide)
			slide:OpenWindow("actor_editor")
			slide:SetFocusElement(slide:FindElementByPath("contents"))
			slide:AddHighlight(slide:FindElementByPath("contents"))
			slide:AddGenericMessageBox()
		end,
		nextSlide = "multi_ik_chain", -- Continue once hand bone is visible
	})

	elTut:RegisterSlide("multi_ik_chain", {
		init = function(tutorialData, slideData, slide)
			slide:OpenWindow("actor_editor")
			slide:SetFocusElement(slide:FindElementByPath("contents"))
			slide:AddHighlight(slide:FindElementByPath("contents"))
			slide:AddGenericMessageBox({ TUT_FOOT_IK_CHAIN_LENGTH })
		end,
		nextSlide = "ik_rig",
	})

	elTut:RegisterSlide("ik_rig", {
		init = function(tutorialData, slideData, slide)
			slide:AddGenericMessageBox()
		end,
		nextSlide = "ik_rig_config_select",
	})

	elTut:RegisterSlide("ik_rig_config_select", {
		init = function(tutorialData, slideData, slide)
			slide:OpenWindow("actor_editor")
			slide:SetFocusElement(slide:FindElementByPath("contents"))

			slide:AddHighlight(
				slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. TUT_ACTOR_UUID .. "/header")
			)
			slide:AddHighlight(
				slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. TUT_ACTOR_UUID .. "/ik_solver/header")
			)
			slide:AddHighlight(
				slide:FindElementByPath(
					pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. TUT_ACTOR_UUID .. "/ik_solver/base_properties/header"
				)
			)
			slide:AddHighlight(
				slide:FindElementByPath(
					pfm.WINDOW_ACTOR_EDITOR_UI_ID
						.. "/"
						.. TUT_ACTOR_UUID
						.. "/ik_solver/base_properties/rigConfigFile/header"
				)
			)
			--[[slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/base_property_controls"))
			slide:AddHighlight(
				slide:FindElementByPath(
					pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/base_property_controls/rigConfigFile/browse_button"
				)
			)]]
			-- pfm_base_properties

			slide:AddMessageBox('TODO: Select property "IK Rig Config File" to continue.')
		end,
		nextSlide = "ik_rig_config",
	})

	elTut:RegisterSlide("ik_rig_config", {
		init = function(tutorialData, slideData, slide)
			slide:OpenWindow("actor_editor")
			slide:SetFocusElement(slide:FindElementByPath("contents"))

			slide:AddHighlight(
				slide:FindElementByPath(
					pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/base_property_controls/rigConfigFile/browse_button"
				)
			)
			-- pfm_base_properties

			slide:AddMessageBox('TODO: Select "..." to browse rigs, then select TODO.')
		end,
		nextSlide = "fb_ik_controls",
	})

	elTut:RegisterSlide("fb_ik_controls", {
		init = function(tutorialData, slideData, slide)
			slide:OpenWindow("actor_editor")
			slide:SetFocusElement(slide:FindElementByPath("contents"))

			slide:AddHighlight(
				slide:FindElementByPath(
					pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/base_property_controls/rigConfigFile/browse_button"
				)
			)

			slide:AddMessageBox("TODO: Go back to IK controls. More controls for head, spline, etc. for full-body IK.")
		end,
		nextSlide = "",
	})
	elTut:StartSlide("intro")
end)
