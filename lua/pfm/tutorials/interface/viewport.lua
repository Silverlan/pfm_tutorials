--[[
    Copyright (C) 2023 Silverlan

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
]]

include("/pfm/pfm_core_tutorials.lua")

local uuidChar = "fde723dd-1ba0-4d3e-8536-e576fc161f80"
local charTargetLocation = Vector(-80.3301, 22.377, -164.07)
local charChairToleranceDistance = 7.0

gui.Tutorial.register_tutorial("viewport", "tutorials/interface/viewport", function(elTut, pm)
	elTut:RegisterSlide("intro", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("primary_viewport")
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "interaction1",
	})

	--[[elTut:RegisterSlide("viewport", {
		init = function(tutorialData,slideData, slide)
			slide:GoToWindow("primary_viewport")
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddMessageBox(
				'This is the viewport, where you can preview your scene/animation, select and transform actors, etc.\nYou can also create additional viewports from the "Windows" sub-menu in the menu bar.',
				"pfm/tutorials/intro/viewport_test.mp3"
			)
		end,
		clear = function(tutorialData,slideData) end,
		nextSlide = "viewport_interaction1",
	})]]
	-- TODO: Secondary viewport?

	elTut:RegisterSlide("interaction1", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight(slide:FindElementByPath("window_primary_viewport/viewport"))
			slide:AddGenericMessageBox()

			slideData.targetEntity = ents.find_by_uuid(uuidChar)
			if util.is_valid(slideData.targetEntity) == false then
				return
			end
			local el = gui.create("WIGameObjectSelectionOutline")
			local elTgt = slide:FindElementByPath("window_primary_viewport/viewport", false)
			if elTgt ~= nil then
				el:SetTarget(elTgt, slideData.targetEntity)
			end
			slideData.gameObjectOutline = el
		end,
		clear = function(tutorialData, slideData)
			util.remove(slideData.gameObjectOutline)
		end,
		clearCondition = function(tutorialData, slideData)
			if util.is_valid(slideData.gameObjectOutline) == false then
				return true
			end
			if slideData.gameObjectOutline:IsTargetInFullView() == false then
				return false
			end
			local cam = game.get_render_scene_camera()
			if util.is_valid(cam) == false or util.is_valid(slideData.targetEntity) == false then
				return true
			end
			local trC = cam:GetEntity():GetComponent(ents.COMPONENT_TRANSFORM)
			if trC == nil then
				return true
			end
			return trC:GetDistance(slideData.targetEntity) < 100
		end,
		nextSlide = "interaction2",
	})

	elTut:RegisterSlide("interaction2", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight(slide:FindElementByPath("window_primary_viewport/viewport"))
			slide:AddGenericMessageBox()
			slideData.targetEntity = ents.find_by_uuid(uuidChar)
			pm:DeselectAllActors()
		end,
		clearCondition = function(tutorialData, slideData)
			if util.is_valid(slideData.targetEntity) == false then
				return true
			end
			local selC = slideData.targetEntity:GetComponent("pfm_selection_wireframe")
			return (selC ~= nil and selC:IsPersistent())
		end,
		nextSlide = "interaction3",
	})

	elTut:RegisterSlide("interaction3", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight(slide:FindElementByPath("window_primary_viewport/viewport"))
			slide:AddGenericMessageBox()
		end,
		nextSlide = "manip_controls",
	})

	elTut:RegisterSlide("manip_controls", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddHighlight("window_primary_viewport/manip_controls", true)
			slide:AddGenericMessageBox( --[[{
				pfm.get_key_binding("pfm_action transform select"),
				pfm.get_key_binding("pfm_action transform translate"),
				pfm.get_key_binding("pfm_action transform rotate"),
				pfm.get_key_binding("pfm_action transform scale"),
			}]])

			local vp = tool.get_filmmaker():GetViewport()
			if util.is_valid(vp) then
				vp:SetManipulatorMode(gui.PFMViewport.MANIPULATOR_MODE_SELECT)
			end

			local actor = ents.find_by_uuid(uuidChar)
			local actorC = (actor ~= nil) and actor:GetComponent(ents.COMPONENT_PFM_ACTOR) or nil
			local actorData = (actorC ~= nil) and actorC:GetActorData() or nil
			pm:DeselectAllActors()
			if actorData ~= nil then
				pm:SelectActor(actorData, true)
			end
		end,
		clearCondition = function(tutorialData, slideData)
			local vp = tool.get_filmmaker():GetViewport()
			if util.is_valid(vp) == false then
				return true
			end
			return vp:GetManipulatorMode() == gui.PFMViewport.MANIPULATOR_MODE_MOVE
		end,
		nextSlide = "move_actor",
	})

	elTut:RegisterSlide("move_actor", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddGenericMessageBox()

			slideData.targetEntity = ents.find_by_uuid(uuidChar)
			if util.is_valid(slideData.targetEntity) == false then
				return
			end
			slideData.locationMarker = slide:AddLocationMarker(charTargetLocation)

			local targetInfo = slide:AddViewportTarget(charTargetLocation, function()
				local ent = ents.find_by_uuid(uuidChar)
				local animC = (ent ~= nil) and ent:GetComponent(ents.COMPONENT_ANIMATED) or nil
				if animC == nil then
					return Vector()
				end
				local pose = animC:GetBonePose("lowerBody", math.COORDINATE_SPACE_WORLD)
				return (pose ~= nil) and pose:GetOrigin() or Vector()
			end, charChairToleranceDistance)
			if util.is_valid(targetInfo.lineEntity) then
				targetInfo.lineEntity:SetColor(Color.Red)
			end
			slideData.targetInfo = targetInfo
		end,
		clearCondition = function(tutorialData, slideData, slide)
			return slideData.targetInfo.isInRange()
		end,
		clear = function(tutorialData, slideData)
			util.remove(slideData.locationMarker)
		end,
		nextSlide = "rotate_actor",
	})

	elTut:RegisterSlide("rotate_actor", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddGenericMessageBox()

			slideData.targetEntity = ents.find_by_uuid(uuidChar)
			if util.is_valid(slideData.targetEntity) == false then
				return
			end
		end,
		clearCondition = function(tutorialData, slideData, slide)
			if util.is_valid(slideData.targetEntity) == false then
				return true
			end
			local ang = slideData.targetEntity:GetAngles()
			return ang.y >= -105 and ang.y <= -75
		end,
		nextSlide = "manip_controls_fin",
	})

	-- TODO: This should include a short explanation of what "transform space" actually is
	elTut:RegisterSlide("manip_controls_fin", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddHighlight("window_primary_viewport/manip_controls", true)
			slide:AddGenericMessageBox()
		end,
		nextSlide = "transform_space",
	})

	elTut:RegisterSlide("transform_space", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddHighlight("window_primary_viewport/vp_settings/transform_space", true)
			slide:AddGenericMessageBox()
		end,
		nextSlide = "snap_to_grid",
	})

	elTut:RegisterSlide("snap_to_grid", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddHighlight({
				slide:FindElementByPath("window_primary_viewport/vp_settings/snap_to_grid_spacing"),
				slide:FindElementByPath("window_primary_viewport/vp_settings/angular_spacing"),
			})
			slide:SetArrowTarget("window_primary_viewport/vp_settings/snap_to_grid_spacing")
			slide:AddGenericMessageBox()
		end,
		nextSlide = "live_render",
	})

	elTut:RegisterSlide("live_render", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddHighlight("window_primary_viewport/vp_settings/rt_enabled", true)
			slide:AddGenericMessageBox()
		end,
		clearCondition = function(tutorialData, slideData, slide)
			local el = slide:FindElementByPath("window_primary_viewport/vp_settings/rt_enabled", false)
			local tgt = util.is_valid(el) and el:GetTarget() or nil
			if util.is_valid(tgt) == false then
				return true
			end
			return toboolean(tgt:GetValue())
		end,
		autoContinue = true,
		nextSlide = "live_render_active",
	})

	elTut:RegisterSlide("live_render_active", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddGenericMessageBox()
		end,
		nextSlide = "cc_controls",
	})

	elTut:RegisterSlide("cc_controls", {
		init = function(tutorialData, slideData, slide)
			local el = slide:FindElementByPath("window_primary_viewport/vp_settings/rt_enabled", false)
			local tgt = util.is_valid(el) and el:GetTarget() or nil
			if util.is_valid(tgt) then
				tgt:SelectOption(0)
			end

			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddHighlight("window_primary_viewport/cc_controls", true)
			slide:AddGenericMessageBox()
		end,
		clearCondition = function(tutorialData, slideData)
			local vp = tool.get_filmmaker():GetViewport()
			if util.is_valid(vp) == false then
				return true
			end
			return vp:IsSceneCamera()
		end,
		nextSlide = "playback_controls",
	})

	elTut:RegisterSlide("playback_controls", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddHighlight("window_primary_viewport/playback_controls", true)
			slide:AddGenericMessageBox({
				pfm.get_key_binding("pfm_action toggle_play"),
				pfm.get_key_binding("pfm_action previous_frame"),
				pfm.get_key_binding("pfm_action next_frame"),
				pfm.get_key_binding("pfm_action previous_bookmark"),
				pfm.get_key_binding("pfm_action next_bookmark"),
				pfm.get_key_binding("pfm_action create_bookmark"),
			})
		end,
		clearCondition = function(tutorialData, slideData)
			local vp = pm:GetViewport()
			if util.is_valid(vp) == false then
				return true
			end
			return vp:GetPlayState() == pfm.util.PlaybackState.STATE_PLAYING
		end,
		nextSlide = "fin",
	})

	elTut:RegisterSlide("fin", {
		init = function(tutorialData, slideData, slide)
			slide:SetTutorialCompleted()
			slide:AddGenericMessageBox()
		end,
		nextSlide = "next_tutorial",
	})

	elTut:RegisterSlide("next_tutorial", {
		init = function(tutorialData, slideData, slide)
			time.create_simple_timer(0.0, function()
				pm:LoadTutorial("interface/asset_catalogues")
			end)
		end,
	})
	elTut:StartSlide("intro")
end)
