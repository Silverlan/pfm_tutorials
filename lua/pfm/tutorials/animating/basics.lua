--[[
    Copyright (C) 2023 Silverlan

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
]]

include("/pfm/pfm_core_tutorials.lua")

local uuidCamera = "e95c48a2-ab47-47db-8681-b62acdcf2a8f"

-- lua_exec_cl pfm/tutorials/animating/basics.lua

time.create_simple_timer(0.1, function()
	gui.Tutorial.start_tutorial("basic_animating")
end)

gui.Tutorial.register_tutorial("basic_animating", "tutorials/animating/basics", function(elTut, pm)
	elTut:RegisterSlide("intro", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("actor_editor")
			slide:SetMinWindowFrameDividerFraction(pfm.WINDOW_ACTOR_EDITOR, 0.4)

			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "animation_mode",
	})

	elTut:RegisterSlide("animation_mode", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))
			slide:AddHighlight(
				slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID .. "/timeline_toolbar_left/graph_editor")
			)
			slide:AddGenericMessageBox()
			--
		end,
		clearCondition = function(tutorialData, slideData)
			local timeline = pm:GetTimeline()
			if util.is_valid(timeline) == false then
				return true
			end
			return timeline:GetEditor() == gui.PFMTimeline.EDITOR_GRAPH
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "animation_mode_indicator",
	})

	elTut:RegisterSlide("animation_mode_indicator", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID .. "/viewport"))
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "dolly_zoom_intro",
	})

	elTut:RegisterSlide("dolly_zoom_intro", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR_UI_ID))
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR_UI_ID))
			slide:AddHighlight(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. uuidCamera .. "/header")
			slide:AddHighlight(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. uuidCamera .. "/camera/header")
			slide:AddHighlight(
				pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. uuidCamera .. "/camera/contents_wrapper/fov/header"
			)

			slide:AddGenericMessageBox()
		end,
		clearCondition = function(tutorialData, slideData)
			local actorEditor = tool.get_filmmaker():GetActorEditor()
			local item = actorEditor:GetPropertyEntry(uuidCamera, "camera", "ec/camera/fov")
			return util.is_valid(item) == false or item:IsSelected()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "dolly_zoom_fov",
	})

	elTut:RegisterSlide("dolly_zoom_fov", {
		init = function(tutorialData, slideData, slide)
			local actorEditor = pm:GetActorEditor()
			local item = actorEditor.m_activeControls[uuidCamera]["ec/camera/fov"].control
			slideData.fovSlider = item

			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR_UI_ID))
			slide:AddHighlight(item)

			slide:AddGenericMessageBox()
		end,
		clearCondition = function(tutorialData, slideData)
			if util.is_valid(slideData.fovSlider) == false then
				return true
			end
			local val = slideData.fovSlider:GetValue()
			return val >= 40.0 and val <= 50.0
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "animated_property",
	})

	elTut:RegisterSlide("animated_property", {
		init = function(tutorialData, slideData, slide)
			local actorEditor = pm:GetActorEditor()
			local item = actorEditor.m_activeControls[uuidCamera]["ec/camera/fov"].control
			slideData.fovSlider = item

			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR_UI_ID))
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR_UI_ID))
			slide:SetArrowTarget(item)

			slide:AddGenericMessageBox()
		end,
		nextSlide = "animated_property_icon",
	})

	elTut:RegisterSlide("animated_property_icon", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(
				slide:FindElementByPath(
					pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. uuidCamera .. "/camera/contents_wrapper/fov/header"
				)
			)
			slide:AddHighlight(
				slide:FindElementByPath(
					pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. uuidCamera .. "/camera/contents_wrapper/fov/header"
				)
			)

			local el = slide:FindElementByPath(
				pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. uuidCamera .. "/camera/contents_wrapper/fov/header/animated"
			)
			if util.is_valid(el) then
				slideData.animatedIcon = el
				slideData.onClick = el:AddCallback("OnMouseEvent", function(el, button, state, mods)
					if button == input.MOUSE_BUTTON_LEFT and state == input.STATE_PRESS then
						slideData.clicked = true
					end
				end)
			end

			slide:AddGenericMessageBox()
		end,
		autoContinue = true,
		clearCondition = function(tutorialData, slideData)
			if util.is_valid(slideData.animatedIcon) == false then
				return true
			end
			return slideData.clicked or false
		end,
		clear = function(tutorialData, slideData)
			util.remove(slideData.onClick)
		end,
		nextSlide = "graph_editor",
	})

	elTut:RegisterSlide("graph_editor", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))

			local timeline = pm:GetTimeline()
			local graphEditor = util.is_valid(timeline) and timeline:GetGraphEditor() or nil
			local graphCurve = util.is_valid(graphEditor) and graphEditor:GetGraphCurve(1) or nil
			local dp = (graphCurve ~= nil and util.is_valid(graphCurve.curve)) and graphCurve.curve:GetDataPoint(0)
				or nil
			if util.is_valid(dp) then
				slide:SetArrowTarget(dp)
			end

			slide:AddGenericMessageBox()
		end,
		nextSlide = "graph_editor_playhead",
	})

	elTut:RegisterSlide("graph_editor_playhead", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))

			local t = 2.0
			local bm = pm:AddBookmark(t, true)
			slideData.bookmark = bm

			local timeline = pm:GetTimeline()
			if util.is_valid(timeline) then
				timeline = timeline:GetTimeline()
				if util.is_valid(timeline) then
					local elBm = timeline:FindBookmark(t)
					if util.is_valid(elBm) then
						slide:SetArrowTarget(elBm)
					end
				end
			end

			slide:AddGenericMessageBox()
		end,
		clearCondition = function(tutorialData, slideData)
			local timeline = pm:GetTimeline()
			local playhead = util.is_valid(timeline) and timeline:GetPlayhead() or nil
			if util.is_valid(playhead) == false then
				return true
			end
			local offset = playhead:GetTimeOffset()
			return offset >= 1.999 and offset <= 2.0001
		end,
		clear = function(tutorialData, slideData)
			if slideData.bookmark ~= nil then
				pm:RemoveBookmark(slideData.bookmark:GetTime())
			end
		end,
		nextSlide = "graph_editor_2nd_fov_keyframe",
	})

	elTut:RegisterSlide("graph_editor_2nd_fov_keyframe", {
		init = function(tutorialData, slideData, slide)
			local actorEditor = pm:GetActorEditor()
			local item = actorEditor.m_activeControls[uuidCamera]["ec/camera/fov"].control
			slideData.fovSlider = item

			slide:SetFocusElement(slide:FindElementByPath("contents"))
			slide:AddHighlight(item)

			slide:AddGenericMessageBox()
		end,
		clearCondition = function(tutorialData, slideData)
			if util.is_valid(slideData.fovSlider) == false then
				return true
			end
			local val = slideData.fovSlider:GetValue()
			return val >= 80.0 and val <= 90.0
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "graph_editor_curve",
	})

	elTut:RegisterSlide("graph_editor_curve", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))

			slide:AddHighlight("context_menu/fit_view_to_data")

			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "animated_property",
	})

	elTut:StartSlide("graph_editor_curve")

	-- TODO: Describe graph editor

	-- Clear animation at the end of the tutorial?
	elTut:RegisterSlide("animation_mode_indicator", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR_UI_ID))
			--slide:AddGenericMessageBox()
			slide:AddMessageBox(
				"If you change a property in the actor editor while in animation mode, a keyframe will automatically be created for the current frame. In addition, a yellow outline will appear around the property, indicating that it is animating. There is also an arrow icon next to the property."
					.. "If you exit animation mode, by going back to the clip editor, note how the field is now greyed out. Animated properties cannot be edited outside of animation mode. If you click the greyed out field, you will automatically be redirected to animation mode instead."
					.. "If you want to remove animation, right-click, then choose Clear Animation."
			)
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "scenegraph",
	})

	elTut:RegisterSlide("conclusion", {
		init = function(tutorialData, slideData, slide)
			slide:SetTutorialCompleted()
			slide:AddGenericMessageBox()
		end,
		nextSlide = "viewport_next_tutorial",
	})

	elTut:RegisterSlide("viewport_next_tutorial", {
		init = function(tutorialData, slideData, slide)
			pm:LoadTutorial("interface/render") -- TODO: Which one is the next series? (lighting?)
		end,
	})
end)
