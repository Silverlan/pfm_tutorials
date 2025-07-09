-- SPDX-FileCopyrightText: (c) 2023 Silverlan <opensource@pragma-engine.com>
-- SPDX-License-Identifier: MIT

include("/pfm/pfm_core_tutorials.lua")

gui.Tutorial.register_tutorial("dof", function(elTut, pm)
	elTut:RegisterSlide("intro", {
		init = function(tutorialData, slideData, slide)
			slide:AddMessageBox(
				"In this tutorial you will learn how to add a depth of field effect (DOF) "
					.. "to your scene. Depth of field refers to the range of distance in a photograph "
					.. "where objects appear in sharp focus, while the background and foreground may "
					.. "appear blurry or out of focus.\n\n"
					.. "This tutorial assumes that you have already set up a scene with a camera. If you have not "
					.. "done so yet, please end the tutorial now and restart it once you have."
			)
		end,
		nextSlide = "select_camera_actor",
	})
	elTut:RegisterSlide("select_camera_actor", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("actor_editor")
			slide:SetFocusElement(slide:FindElementByPath("window_actor_editor"))
			slide:AddHighlight(slide:FindElementByPath("window_actor_editor/actor_tree"))
			slide:AddMessageBox(
				"DOF works on a per-camera basis, which means you have to add the effect to "
					.. "a specific camera. Please select the camera in the actor editor that you wish to "
					.. 'add depth-of-field to and press "Continue".'
			)
		end,
		clear = function(tutorialData, slideData) end,
		clearCondition = function(tutorialData, slideData)
			local actorEditor = pm:GetActorEditor()
			local actors = actorEditor:GetSelectedActors()
			if #actors == 1 then
				local actor = actors[1]
				tutorialData.cameraActor = actor
				return actor:HasComponent("pfm_camera")
			end
			return false
		end,
		nextSlide = "optical_camera_component",
	})
	elTut:RegisterSlide("optical_camera_component", {
		init = function(tutorialData, slideData, slide)
			local actorEditor = slide:GoToWindow("actor_editor")
			local item = (util.is_valid(actorEditor) and tutorialData.cameraActor ~= nil)
					and actorEditor:GetActorItem(tutorialData.cameraActor)
				or nil
			item:Expand(true)
			slide:SetFocusElement(slide:FindElementByPath("window_actor_editor"))
			slide:AddHighlight(item)
			slide:AddMessageBox(
				'To enable DOF for this camera, you will have to add the "Optical Camera" '
					.. "component to it. You can do so by right-clicking the camera, and selecting "
					.. '"Optical Camera" from the "Create new Component" list.'
			)
		end,
		clear = function(tutorialData, slideData) end,
		clearCondition = function(tutorialData, slideData)
			if util.is_valid(tutorialData.cameraActor) == false then
				return true
			end
			return tutorialData.cameraActor:HasComponent("optical_camera")
		end,
		nextSlide = "set_active_camera",
	})
	elTut:RegisterSlide("set_active_camera", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("primary_viewport", 0.6)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID .. "/cc_camera"))
			slide:AddMessageBox(
				"Before we continue, you need to make sure that the camera is set as the active camera in the viewport, otherwise you "
					.. "will not be able to see the DOF effect."
			)
		end,
		clear = function(tutorialData, slideData) end,
		clearCondition = function(tutorialData, slideData, slide)
			local window = slide:GetWindow("primary_viewport")
			local cam = util.is_valid(window) and window:GetCamera() or nil
			local pfmActorC = util.is_valid(cam) and cam:GetEntity():GetComponent(ents.COMPONENT_PFM_ACTOR) or nil
			local actorData = util.is_valid(pfmActorC) and pfmActorC:GetActorData() or nil
			return actorData == tutorialData.cameraActor
		end,
		nextSlide = "show_debug_focus",
	})
	elTut:RegisterSlide("show_debug_focus", {
		init = function(tutorialData, slideData, slide)
			local actorEditor = slide:GoToWindow("actor_editor")
			local item = util.is_valid(actorEditor)
					and actorEditor:GetPropertyEntry(
						tostring(tutorialData.cameraActor:GetUniqueId()),
						"optical_camera",
						"ec/optical_camera/showDebugFocus"
					)
				or nil
			item:Expand(true)
			slide:SetFocusElement(slide:FindElementByPath("window_actor_editor"))
			slide:AddHighlight(item)
			slide:AddMessageBox(
				"The optical camera component has various properties you can use to change the DOF effect. However, "
					.. 'before you do so, it is recommended that you enable the "Show Debug Focus" property. '
					.. "This will enable a scene overlay guide in the viewport, which will make it easier "
					.. "to fine-tune the DOF values."
			)
		end,
		clear = function(tutorialData, slideData) end,
		clearCondition = function(tutorialData, slideData)
			if util.is_valid(tutorialData.cameraActor) == false then
				return true
			end
			return tutorialData.cameraActor:GetMemberValue("ec/optical_camera/showDebugFocus")
		end,
		nextSlide = "scene_overlay_guide",
	})
	elTut:RegisterSlide("scene_overlay_guide", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("primary_viewport", 0.6)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID .. "/viewport"))
			slide:AddMessageBox(
				"The scene overlay guide is shown as a thick blue stripe, which indicates "
					.. "the range of distance where objects are in focus. The stripe itself is only a visual aid "
					.. 'and will not appear in the final render. Remember to disable the "Show Debug Focus" property '
					.. "after you are done editing the DOF values."
			)
		end,
		nextSlide = "focal_distance",
	})
	elTut:RegisterSlide("focal_distance", {
		init = function(tutorialData, slideData, slide)
			local actorEditor = slide:GoToWindow("actor_editor")
			local item = util.is_valid(actorEditor)
					and actorEditor:GetComponentEntry(
						tostring(tutorialData.cameraActor:GetUniqueId()),
						"optical_camera"
					)
				or nil
			item:Expand(true)
			slide:SetFocusElement(slide:FindElementByPath("contents"))
			slide:AddHighlight(item)
			slide:AddMessageBox(
				'The most important property is the "Focal Distance", which represents the '
					.. "distance from the camera at which objects are in focus. The other properties can be used "
					.. "to further change the appearance of the DOF effect. You can hover over each property to get a "
					.. "short tooltip description of its purpose."
			)
		end,
		nextSlide = "final",
	})
	elTut:RegisterSlide("final", {
		init = function(tutorialData, slideData, slide)
			slide:AddMessageBox(
				"That completes this tutorial. Please note that DOF may not work, or exhibit "
					.. "different behavior, depending on the renderer you are using."
			)
		end,
	})

	elTut:StartSlide("intro")
end)
