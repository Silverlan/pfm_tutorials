--[[
    Copyright (C) 2023 Silverlan

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
]]

include("/pfm/pfm_core_tutorials.lua")

local uuidCamera = "e95c48a2-ab47-47db-8681-b62acdcf2a8f"
local camStartLocation = Vector(-133.753, 40.5682, -167.544)
local camEndLocation = Vector(-95.7086, 40.5682, -167.544)
local camStartFov = 45
local camEndFov = 85
local fovTolerance = 5.0
local duration = 2.0

local durationEpsilon = 0.0001

local function get_keyframe(pm, i)
	local timeline = pm:GetTimeline()
	local graphEditor = util.is_valid(timeline) and timeline:GetGraphEditor() or nil
	local graphCurve = util.is_valid(graphEditor) and graphEditor:GetGraphCurve(1) or nil
	if graphCurve == nil then
		return
	end
	local dps = {}
	for _, dp in ipairs(graphCurve.curve:GetDataPoints()) do
		if dp:IsValid() then
			table.insert(dps, dp)
		end
	end
	table.sort(dps, function(a, b)
		return a:GetTime() < b:GetTime()
	end)
	return dps[i]
end

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
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/cameras/header"))
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

			slide:AddGenericMessageBox({ tostring(camStartFov) })
		end,
		clearCondition = function(tutorialData, slideData)
			if util.is_valid(slideData.fovSlider) == false then
				return true
			end
			local val = slideData.fovSlider:GetValue()
			return val >= (camStartFov - fovTolerance) and val <= (camStartFov + fovTolerance)
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

			slide:AddGenericMessageBox({ tostring(camStartFov) })
		end,
		nextSlide = "graph_editor_playhead",
	})

	elTut:RegisterSlide("graph_editor_playhead", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))

			local timeline = pm:GetTimeline()
			if util.is_valid(timeline) then
				timeline:SetTimeRange(-4.0, 5.0)
				timeline:SetDataRange(0, 120)
			end

			local t = duration
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

			slide:AddGenericMessageBox({ tostring(duration) })
		end,
		clearCondition = function(tutorialData, slideData)
			local timeline = pm:GetTimeline()
			local playhead = util.is_valid(timeline) and timeline:GetPlayhead() or nil
			if util.is_valid(playhead) == false then
				return true
			end
			local offset = playhead:GetTimeOffset()
			return offset >= (duration - durationEpsilon) and offset <= (duration + durationEpsilon)
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

			slide:AddGenericMessageBox({ tostring(camEndFov) })
		end,
		clearCondition = function(tutorialData, slideData)
			if util.is_valid(slideData.fovSlider) == false then
				return true
			end
			local val = slideData.fovSlider:GetValue()
			return val >= (camEndFov - fovTolerance) and val <= (camEndFov + fovTolerance)
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
		nextSlide = "graph_editor_controls",
	})

	elTut:RegisterSlide("graph_editor_controls", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))

			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "graph_editor_curve_keyframe",
	})

	elTut:RegisterSlide("graph_editor_curve_keyframe", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))

			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID .. "/bookmark"))

			local timeline = pm:GetTimeline()
			local playhead = util.is_valid(timeline) and timeline:GetPlayhead() or nil
			if util.is_valid(playhead) then
				playhead:SetTimeOffset(1.0)
			end

			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		clearCondition = function(tutorialData, slideData)
			local timeline = pm:GetTimeline()
			local graphEditor = util.is_valid(timeline) and timeline:GetGraphEditor() or nil
			local graphCurve = util.is_valid(graphEditor) and graphEditor:GetGraphCurve(1) or nil
			local numDataPoints = 0
			for _, dp in ipairs(graphCurve.curve:GetDataPoints()) do
				if dp:IsValid() then
					numDataPoints = numDataPoints + 1
				end
			end
			return numDataPoints >= 3
		end,
		nextSlide = "graph_editor_select_keyframe",
	})

	elTut:RegisterSlide("graph_editor_select_keyframe", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))

			local timeline = pm:GetTimeline()
			local playhead = util.is_valid(timeline) and timeline:GetPlayhead() or nil
			if util.is_valid(playhead) then
				playhead:SetTimeOffset(0.8)
			end

			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		clearCondition = function(tutorialData, slideData)
			local dp = get_keyframe(pm, 2)
			if dp == nil then
				return true
			end
			return dp:IsSelected()
		end,
		nextSlide = "graph_editor_move_mode",
	})

	elTut:RegisterSlide("graph_editor_move_mode", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID .. "/move"))

			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		clearCondition = function(tutorialData, slideData)
			local timeline = pm:GetTimeline()
			local graphEditor = util.is_valid(timeline) and timeline:GetGraphEditor() or nil
			if util.is_valid(graphEditor) == false then
				return true
			end
			return graphEditor:GetCursorMode() == gui.PFMTimelineGraph.CURSOR_MODE_MOVE
		end,
		nextSlide = "graph_editor_move_keyframe",
	})

	elTut:RegisterSlide("graph_editor_move_keyframe", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))

			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "graph_editor_handles",
	})

	elTut:RegisterSlide("graph_editor_handles", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))

			local dp = get_keyframe(pm, 2)
			local ctrl = util.is_valid(dp) and dp:GetTangentControl() or nil
			local inCtrl = util.is_valid(ctrl) and ctrl:GetInControl() or nil
			if util.is_valid(inCtrl) then
				slide:SetArrowTarget(inCtrl)
			end

			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "graph_editor_handle_type",
	})

	elTut:RegisterSlide("graph_editor_handle_type", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))

			slide:AddHighlight("context_menu/handle_type")
			slide:AddHighlight("context_menu_handle_type/free")

			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "graph_editor_vector_handle_type",
	})

	elTut:RegisterSlide("graph_editor_vector_handle_type", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))

			slide:AddHighlight("context_menu/handle_type")
			slide:AddHighlight("context_menu_handle_type/vector")

			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "graph_editor_interp",
	})

	elTut:RegisterSlide("graph_editor_interp", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))

			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "graph_editor_easing",
	})

	elTut:RegisterSlide("graph_editor_easing", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath("contents"))
			slide:AddHighlight(slide:FindElementByPath("contents"))

			slide:AddHighlight("context_menu/easing_mode")
			local el = slide:FindElementByPath(pfm.WINDOW_WEB_BROWSER_UI_ID .. "/browser", false)
			if el ~= nil then
				slide:SetArrowTarget(el)
			end

			local webBrowser = pm:OpenWindow(pfm.WINDOW_WEB_BROWSER)
			pm:GoToWindow(pfm.WINDOW_WEB_BROWSER)
			if util.is_valid(webBrowser) then
				time.create_simple_timer(0.1, function()
					webBrowser:GetBrowser():SetUrl("https://easings.net/")
					webBrowser:GetBrowser():Update()
				end)
			end

			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "graph_editor_delete_keyframe",
	})

	elTut:RegisterSlide("graph_editor_delete_keyframe", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))

			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "camera_start_frame",
	})

	elTut:RegisterSlide("camera_start_frame", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))

			local timeline = pm:GetTimeline()
			local graphEditor = util.is_valid(timeline) and timeline:GetGraphEditor() or nil
			local dp0 = get_keyframe(pm, 1)
			local dp1 = get_keyframe(pm, 2)
			local dp2 = get_keyframe(pm, 3)
			if util.is_valid(graphEditor) and util.is_valid(dp2) then
				graphEditor:RemoveDataPoint(dp1)
				dp1 = dp2
			end

			if util.is_valid(dp0) then
				dp0:ChangeDataValue(0.0, camStartFov)
			end
			if util.is_valid(dp1) then
				dp1:ChangeDataValue(duration, camEndFov)
			end

			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		clearCondition = function(tutorialData, slideData)
			local timeline = pm:GetTimeline()
			local playhead = util.is_valid(timeline) and timeline:GetPlayhead() or nil
			if util.is_valid(playhead) == false then
				return true
			end
			local offset = playhead:GetTimeOffset()
			return offset >= -durationEpsilon and offset <= durationEpsilon
		end,
		nextSlide = "work_camera",
	})

	elTut:RegisterSlide("work_camera", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddHighlight(slide:FindElementByPath("window_primary_viewport/cc_controls/cc_camera"))

			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		clearCondition = function(tutorialData, slideData)
			local vp = tool.get_filmmaker():GetViewport()
			if util.is_valid(vp) == false then
				return true
			end
			return vp:IsWorkCamera()
		end,
		nextSlide = "camera_move",
	})

	elTut:RegisterSlide("camera_move", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("actor_editor")

			slide:SetFocusElement(slide:FindElementByPath("contents"))
			slide:AddHighlight(slide:FindElementByPath("contents"))
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/cameras/header"))
			slide:AddHighlight(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. uuidCamera .. "/header")

			slide:AddHighlight(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID .. "/manip_controls/manip_move") -- TODO: Set as primary highlight

			slide:AddGenericMessageBox()

			slideData.targetEntity = ents.find_by_uuid(uuidCamera)
			if util.is_valid(slideData.targetEntity) == false then
				return
			end
			slideData.locationMarker = slide:AddLocationMarker(camStartLocation)

			local targetInfo = slide:AddViewportTarget(camStartLocation, function()
				local ent = ents.find_by_uuid(uuidCamera)
				return ent:GetPos()
			end, 4.0)
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
		nextSlide = "camera_pos",
	})

	elTut:RegisterSlide("camera_pos", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID))

			local actorEditor = pm:GetActorEditor()
			local entActor = ents.find_by_uuid(uuidCamera)
			local pfmActorC = (entActor ~= nil) and entActor:GetComponent(ents.COMPONENT_PFM_ACTOR) or nil
			if util.is_valid(actorEditor) then
				actorEditor:SelectActor(pfmActorC:GetActorData(), true, "ec/pfm_actor/position")
			end

			local el = slide:FindElementByPath(pfm.WINDOW_TIMELINE_UI_ID .. "/properties/ec_pfm_actor_position", false)
			if util.is_valid(el) then
				el:Expand()
				el:Select()
				slide:AddHighlight(pfm.WINDOW_TIMELINE_UI_ID .. "/properties/ec_pfm_actor_position")
				slide:SetArrowTarget(el)
			end

			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "camera_end_frame",
	})

	elTut:RegisterSlide("camera_end_frame", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath("contents"))
			slide:AddHighlight(slide:FindElementByPath("contents"))

			slide:AddGenericMessageBox()

			slideData.targetEntity = ents.find_by_uuid(uuidCamera)
			if util.is_valid(slideData.targetEntity) == false then
				return
			end
			slideData.locationMarker = slide:AddLocationMarker(camEndLocation)

			local targetInfo = slide:AddViewportTarget(camEndLocation, function()
				local ent = ents.find_by_uuid(uuidCamera)
				return ent:GetPos()
			end, 4.0)
			if util.is_valid(targetInfo.lineEntity) then
				targetInfo.lineEntity:SetColor(Color.Red)
			end
			slideData.targetInfo = targetInfo
		end,
		clearCondition = function(tutorialData, slideData, slide)
			return slideData.targetInfo.isInRange()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "playback",
	})

	elTut:RegisterSlide("playback", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath("contents"))
			slide:AddHighlight(slide:FindElementByPath("window_primary_viewport/cc_controls/cc_camera"))
			slide:AddHighlight(slide:FindElementByPath("window_primary_viewport/playback_controls"))

			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "conclusion",
	})

	elTut:RegisterSlide("conclusion", {
		init = function(tutorialData, slideData, slide)
			slide:SetTutorialCompleted()
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "next_tutorial",
	})

	elTut:RegisterSlide("next_tutorial", {
		init = function(tutorialData, slideData, slide)
			pm:LoadTutorial("animating/inverse_kinematics")
		end,
	})
	elTut:StartSlide("intro")
end)
