--[[
    Copyright (C) 2023 Silverlan

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
]]

include("/pfm/pfm_core_tutorials.lua")

local uuidCat = "0657005c-16f1-4ee0-a6ea-5be960267a32"
local catTargetLocation = Vector(-133, 14, -168)
local nextTutorial = "tutorials/interface/02_actor_editor"

-- lua_exec_cl pfm/tutorials/interface/viewport.lua

time.create_simple_timer(0.1, function()
	gui.Tutorial.start_tutorial("viewport")
end)

gui.Tutorial.register_tutorial("viewport", function(elTut, pm)
	elTut:RegisterSlide("viewport", {
		init = function(slideData, slide)
			tool.get_filmmaker():GoToWindow("primary_viewport")
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddMessageBox(
				"Welcome to the viewport tutorial. This tutorial will introduce you to the viewport, "
					.. "where you can preview your scene and animation, move actors around, etc."
			)
		end,
		clear = function(slideData) end,
		nextSlide = "viewport_interaction1",
	})

	--[[elTut:RegisterSlide("viewport", {
		init = function(slideData, slide)
			tool.get_filmmaker():GoToWindow("primary_viewport")
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddMessageBox(
				'This is the viewport, where you can preview your scene/animation, select and transform actors, etc.\nYou can also create additional viewports from the "Windows" sub-menu in the menu bar.',
				"pfm/tutorials/intro/viewport_test.mp3"
			)
		end,
		clear = function(slideData) end,
		nextSlide = "viewport_interaction1",
	})]]

	elTut:RegisterSlide("viewport_interaction1", {
		init = function(slideData, slide)
			slide:AddHighlight(slide:FindElementByPath("pfm_primary_viewport/viewport"))
			slide:AddMessageBox(
				"We'll start with the camera controls. To control the viewport camera, press and hold the right mouse button, which will enable FPS controls. "
					.. "As long as you hold down the button, "
					.. "you can rotate the camera by moving the mouse, and move the camera using WASD. You can also change the field of view using the scroll wheel.\n\n"
					.. "Try moving around in the scene until you find the origami cat in the dining room."
			)

			slideData.targetEntity = ents.find_by_uuid(uuidCat)
			if util.is_valid(slideData.targetEntity) == false then
				return
			end
			local el = gui.create("WIGameObjectSelectionOutline")
			el:SetTarget(slide:FindElementByPath("pfm_primary_viewport/viewport"), slideData.targetEntity)
			slideData.gameObjectOutline = el
		end,
		clear = function(slideData)
			util.remove(slideData.gameObjectOutline)
		end,
		clearCondition = function(slideData)
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
		nextSlide = "viewport_interaction2",
	})

	elTut:RegisterSlide("viewport_interaction2", {
		init = function(slideData, slide)
			slide:AddHighlight(slide:FindElementByPath("pfm_primary_viewport/viewport"))
			slide:AddMessageBox(
				"Now click the cat with your left mouse button to select it. Selected objects have a yellow outline around them.\n"
					.. "You can only select objects that are part the project, map-objects, like the chairs in this scene, cannot be selected."
			)
			slideData.targetEntity = ents.find_by_uuid(uuidCat)
			pm:DeselectAllActors()
		end,
		clearCondition = function(slideData)
			if util.is_valid(slideData.targetEntity) == false then
				return true
			end
			local selC = slideData.targetEntity:GetComponent("pfm_selection_wireframe")
			return (selC ~= nil and selC:IsPersistent())
		end,
		nextSlide = "viewport_manip_controls",
	})

	elTut:RegisterSlide("viewport_manip_controls", {
		init = function(slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddHighlight(slide:FindElementByPath("pfm_primary_viewport/manip_controls"))
			slide:AddMessageBox(
				"These are the manipulator controls, which can be used to manipulate selected actors, bones, etc. in the scene. From left to right:\n- Select ("
					.. pfm.get_key_binding("pfm_action transform select")
					.. ")\n- Move ("
					.. pfm.get_key_binding("pfm_action transform translate")
					.. ")\n- Rotate ("
					.. pfm.get_key_binding("pfm_action transform rotate")
					.. ")\n- Scale ("
					.. pfm.get_key_binding("pfm_action transform scale")
					.. ')\n\nClick on the "Move" manipulator to continue.'
			)

			local vp = tool.get_filmmaker():GetViewport()
			if util.is_valid(vp) then
				vp:SetManipulatorMode(gui.PFMViewport.MANIPULATOR_MODE_SELECT)
			end
		end,
		clearCondition = function(slideData)
			local vp = tool.get_filmmaker():GetViewport()
			if util.is_valid(vp) == false then
				return true
			end
			return vp:GetManipulatorMode() == gui.PFMViewport.MANIPULATOR_MODE_MOVE
		end,
		nextSlide = "viewport_move_actor",
	})

	elTut:RegisterSlide("viewport_move_actor", {
		init = function(slideData, slide)
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddMessageBox(
				"Now try moving the actor into the marked spot on the table in the living room using the transform gizmo."
			)

			slideData.targetEntity = ents.find_by_uuid(uuidCat)
			if util.is_valid(slideData.targetEntity) == false then
				return
			end
			slideData.locationMarker = slide:AddLocationMarker(catTargetLocation)
		end,
		clearCondition = function(slideData)
			if util.is_valid(slideData.targetEntity) == false or util.is_valid(slideData.locationMarker) == false then
				return true
			end
			local posMarker = slideData.locationMarker:GetPos()
			local posEnt = slideData.targetEntity:GetPos()
			local yDist = math.abs(posMarker.y - posEnt.y)
			posMarker.y = 0.0
			posEnt.y = 0.0
			local xzDist = posMarker:Distance(posEnt)

			return yDist < 2.0 and xzDist < 8.0
		end,
		clear = function(slideData)
			util.remove(slideData.locationMarker)
		end,
		nextSlide = "viewport_manip_controls_fin",
	})

	elTut:RegisterSlide("viewport_manip_controls_fin", {
		init = function(slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddHighlight(slide:FindElementByPath("pfm_primary_viewport/manip_controls"))
			slide:AddMessageBox(
				"You can toggle the transform space between world, local and screen space by pressing the transform button multiple times."
			)
		end,
		nextSlide = "viewport_transform_space",
	})

	elTut:RegisterSlide("viewport_transform_space", {
		init = function(slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddHighlight(slide:FindElementByPath("pfm_primary_viewport/vp_settings/transform_space"))
			slide:AddMessageBox("Alternatively you can also change the transform space over here.")
		end,
		nextSlide = "snap_to_grid",
	})

	elTut:RegisterSlide("snap_to_grid", {
		init = function(slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddHighlight({
				slide:FindElementByPath("pfm_primary_viewport/vp_settings/snap_to_grid_spacing"),
				slide:FindElementByPath("pfm_primary_viewport/vp_settings/angular_spacing"),
			})
			slide:AddMessageBox("You can also enable snap-to-grid to make it easier to align objects.")
		end,
		nextSlide = "viewport_live_render",
	})

	elTut:RegisterSlide("viewport_live_render", {
		init = function(slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddHighlight(slide:FindElementByPath("pfm_primary_viewport/vp_settings/rt_enabled"))
			slide:AddMessageBox(
				'The "Live Render" setting toggles the viewport to a real-time raytraced preview of the scene, rendered using the Cycles renderer. This can be useful to get a quick preview of what your scene will look like with baked lightmaps, or when using the Cycles renderer to render the final image.\nYou can still move around the scene with the "Live Render" mode active, but some actions (like adding or removing actors) will not be visible until the mode is deactivated.'
			)
		end,
		nextSlide = "cc_controls",
	})

	elTut:RegisterSlide("cc_controls", {
		init = function(slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddHighlight(slide:FindElementByPath("pfm_primary_viewport/cc_controls"))
			slide:AddMessageBox(
				"These are the camera controls. Here you toggle between the work and scene camera, or change the scene camera to a different one.\n\nSwitch to the scene camera to continue."
			)
		end,
		clearCondition = function(slideData)
			local vp = tool.get_filmmaker():GetViewport()
			if util.is_valid(vp) == false then
				return true
			end
			return vp:IsSceneCamera()
		end,
		nextSlide = "viewport_playback_controls",
	})

	elTut:RegisterSlide("viewport_playback_controls", {
		init = function(slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddHighlight(slide:FindElementByPath("pfm_primary_viewport/playback_controls"))
			slide:AddMessageBox(
				"These are the playback controls. Here you can view your animation frame-by-frame, or in real-time by pressing the play-button. Some keybindings are also available:\n"
					.. pfm.get_key_binding("pfm_action toggle_play")
					.. ": Toggle Play\n"
					.. pfm.get_key_binding("pfm_action previous_frame")
					.. ": Previous Frame\n"
					.. pfm.get_key_binding("pfm_action next_frame")
					.. ": Next Frame\n"
					.. pfm.get_key_binding("pfm_action previous_bookmark")
					.. ": Previous Bookmark\n"
					.. pfm.get_key_binding("pfm_action next_bookmark")
					.. ": Next Bookmark\n"
					.. pfm.get_key_binding("pfm_action create_bookmark")
					.. ": Create Bookmark\n\n"
					.. "Press the play button to continue."
			)
		end,
		clearCondition = function(slideData)
			local vp = pm:GetViewport()
			if util.is_valid(vp) == false then
				return true
			end
			return vp:GetPlayState() == gui.PFMPlayButton.STATE_PLAYING
		end,
		nextSlide = "viewport_fin",
	})

	elTut:RegisterSlide("viewport_fin", {
		init = function(slideData, slide)
			slide:AddMessageBox(
				"This concludes the tutorial on the viewport.\n\n"
					.. "You can now end the tutorial, or press the continue-button to start the next tutorial in this series."
			)
		end,
		nextSlide = "viewport_next_tutorial",
	})

	elTut:RegisterSlide("viewport_next_tutorial", {
		init = function(slideData, slide)
			pm:LoadTutorial("interface/render")
		end,
	})

	elTut:StartSlide("viewport_transform_space")
	--elTut:StartSlide("viewport_fin")
end)
