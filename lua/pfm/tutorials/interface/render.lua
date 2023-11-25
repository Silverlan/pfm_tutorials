--[[
    Copyright (C) 2023 Silverlan

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
]]

include("/pfm/pfm_core_tutorials.lua")

local imageSequenceFrameCount = 24

gui.Tutorial.register_tutorial("render", "tutorials/interface/render", function(elTut, pm)
	elTut:RegisterSlide("intro", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("render")
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_RENDER_UI_ID))
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "sections",
	})

	elTut:RegisterSlide("sections", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("render")
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_RENDER_UI_ID))
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "render_engine",
	})

	elTut:RegisterSlide("render_engine", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("render")
			slide:AddHighlight("window_render/render_engine")
			slide:AddGenericMessageBox()

			slideData.renderEngineField = slide:FindElementByPath(pfm.WINDOW_RENDER_UI_ID .. "/render_engine")
		end,
		clear = function(tutorialData, slideData) end,
		clearCondition = function(tutorialData, slideData)
			local target = util.is_valid(slideData.renderEngineField) and slideData.renderEngineField:GetTarget() or nil
			if util.is_valid(target) == false then
				return true
			end
			return target:GetValue() == "cycles"
		end,
		nextSlide = "render_image",
	})

	elTut:RegisterSlide("render_image", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("render")
			slide:AddHighlight({
				slide:FindElementByPath("window_render/bt_render_preview"),
				slide:FindElementByPath("window_render/bt_render_image"),
			})
			slide:AddGenericMessageBox()

			slideData.renderStarted = false
			local elWindowRender = slide:FindElementByPath("window_render")
			if util.is_valid(elWindowRender) then
				slideData.elRenderWindow = elWindowRender
				slideData.cbOnRenderImage = elWindowRender:AddCallback(
					"OnRenderImage",
					function(el, preview, prepareOnly)
						if preview ~= true and prepareOnly ~= true then
							util.remove(slideData.cbOnRenderImage)
							slideData.renderStarted = true
						end
					end
				)
			end
		end,
		clearCondition = function(tutorialData, slideData)
			if util.is_valid(slideData.elRenderWindow) == false then
				return true
			end
			return slideData.renderStarted
		end,
		clear = function(tutorialData, slideData)
			util.remove(slideData.cbOnRenderImage)
		end,
		autoContinue = true,
		nextSlide = "render_progress",
	})

	elTut:RegisterSlide("render_progress", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("render")
			slide:SetFocusElement(pm)
			slide:AddHighlight("info_bar/icon_container", true)
			slide:AddGenericMessageBox()

			slideData.renderCompleted = false
			local elWindowRender = slide:FindElementByPath("window_render")
			if util.is_valid(elWindowRender) then
				slideData.elRenderWindow = elWindowRender
				slideData.cbOnRenderComplete = elWindowRender:AddCallback(
					"OnRenderComplete",
					function(el, preview, prepareOnly)
						slideData.renderCompleted = true
					end
				)
			end
		end,
		clearCondition = function(tutorialData, slideData)
			if util.is_valid(slideData.elRenderWindow) == false then
				return true
			end
			return slideData.renderCompleted
		end,
		clear = function(tutorialData, slideData)
			util.remove(slideData.cbOnRenderComplete)
		end,
		nextSlide = "saved_render",
	})

	elTut:RegisterSlide("saved_render", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("render")
			slide:AddHighlight("window_render/misc_options")
			slide:AddHighlight("context_menu/open_output_dir")
			slide:AddGenericMessageBox()
		end,
		nextSlide = "render_job",
	})

	elTut:RegisterSlide("render_job", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("render")
			slide:AddHighlight("window_render/bt_create_render_job")
			slide:AddGenericMessageBox()

			slideData.renderJobCreated = false
			local elWindowRender = slide:FindElementByPath("window_render")
			if util.is_valid(elWindowRender) then
				slideData.elRenderWindow = elWindowRender
				slideData.cbOnRenderImage = elWindowRender:AddCallback(
					"OnRenderImage",
					function(el, preview, prepareOnly)
						if prepareOnly == true then
							util.remove(slideData.cbOnRenderImage)
							slideData.renderJobCreated = true
						end
					end
				)
			end
		end,
		clearCondition = function(tutorialData, slideData)
			if util.is_valid(slideData.elRenderWindow) == false then
				return true
			end
			return slideData.renderJobCreated
		end,
		clear = function(tutorialData, slideData)
			util.remove(slideData.cbOnRenderImage)
		end,
		autoContinue = true,
		nextSlide = "render_job_script",
	})

	elTut:RegisterSlide("render_job_script", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("render")
			local renderFileName = "render"
			if os.SYSTEM_WINDOWS then
				renderFileName = renderFileName .. ".bat"
			else
				renderFileName = renderFileName .. ".sh"
			end
			slide:AddGenericMessageBox({
				renderFileName,
			})
		end,
		nextSlide = "vr_render",
	})

	-- TODO: We should cover color transforms

	elTut:RegisterSlide("vr_render", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("render")
			slide:AddHighlight({
				slide:FindElementByPath("window_render/preset"),
				slide:FindElementByPath("window_render/render_engine"),
			})
			slide:AddGenericMessageBox()

			slideData.renderEngineField = slide:FindElementByPath(pfm.WINDOW_RENDER_UI_ID .. "/render_engine")
			slideData.presetField = slide:FindElementByPath(pfm.WINDOW_RENDER_UI_ID .. "/preset")
		end,
		clearCondition = function(tutorialData, slideData)
			local target = util.is_valid(slideData.renderEngineField) and slideData.renderEngineField:GetTarget() or nil
			local targetPreset = util.is_valid(slideData.presetField) and slideData.presetField:GetTarget() or nil
			if util.is_valid(target) == false or util.is_valid(targetPreset) == false then
				return true
			end
			return target:GetValue() == "pragma" and targetPreset:GetValue() == "vr"
		end,
		nextSlide = "vr_render_start",
	})

	elTut:RegisterSlide("vr_render_start", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("render")
			slide:AddHighlight(slide:FindElementByPath("window_render/bt_render_image"))
			slide:AddGenericMessageBox()

			slideData.renderStarted = false
			local elWindowRender = slide:FindElementByPath("window_render")
			if util.is_valid(elWindowRender) then
				slideData.elRenderWindow = elWindowRender
				slideData.cbOnRenderImage = elWindowRender:AddCallback(
					"OnRenderImage",
					function(el, preview, prepareOnly)
						if preview ~= true and prepareOnly ~= true then
							util.remove(slideData.cbOnRenderImage)
							slideData.renderStarted = true
						end
					end
				)
			end
		end,
		clearCondition = function(tutorialData, slideData)
			if util.is_valid(slideData.elRenderWindow) == false then
				return true
			end
			return slideData.renderStarted
		end,
		clear = function(tutorialData, slideData)
			util.remove(slideData.cbOnRenderImage)
		end,
		autoContinue = true,
		nextSlide = "vr_view",
	})

	elTut:RegisterSlide("vr_view", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("render")
			slide:AddHighlight("window_render/render_viewport")
			slide:AddGenericMessageBox()
		end,
		nextSlide = "vr_view_mode",
	})

	elTut:RegisterSlide("vr_view_mode", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("render")
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddHighlight("window_render/preview_mode", true)
			slide:AddGenericMessageBox()
		end,
		nextSlide = "image_sequence",
	})

	elTut:RegisterSlide("image_sequence", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("render")
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_RENDER_UI_ID))
			slide:AddHighlight("window_render/frame_count", true)
			slide:AddGenericMessageBox({ tostring(imageSequenceFrameCount) })

			local vp = slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID, false, true)
			if util.is_valid(vp) then
				vp:SwitchToSceneCamera()
			end

			local timeline = pm:GetTimeline()
			local playhead = util.is_valid(timeline) and timeline:GetPlayhead() or nil
			if util.is_valid(playhead) then
				playhead:SetTimeOffset(0.0)
			end

			local elPreset = slide:FindElementByPath("window_render/preset")
			elPreset = util.is_valid(elPreset) and elPreset:GetTarget() or nil
			if util.is_valid(elPreset) then
				elPreset:SelectOption("standard")
			end
		end,
		clearCondition = function(tutorialData, slideData, slide)
			local el = slide:FindElementByPath("window_render/frame_count", false)
			if util.is_valid(el) == false then
				return true
			end
			return el:GetValue() == imageSequenceFrameCount
		end,
		nextSlide = "image_sequence_render",
	})

	elTut:RegisterSlide("image_sequence_render", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("render")
			slide:AddHighlight(slide:FindElementByPath("window_render/bt_render_image"))
			slide:AddGenericMessageBox()

			slideData.renderStarted = false
			local elWindowRender = slide:FindElementByPath("window_render")
			if util.is_valid(elWindowRender) then
				slideData.elRenderWindow = elWindowRender
				slideData.cbOnRenderImage = elWindowRender:AddCallback(
					"OnRenderImage",
					function(el, preview, prepareOnly)
						if preview ~= true and prepareOnly ~= true then
							util.remove(slideData.cbOnRenderImage)
							slideData.renderStarted = true
						end
					end
				)
			end
		end,
		clearCondition = function(tutorialData, slideData)
			if util.is_valid(slideData.elRenderWindow) == false then
				return true
			end
			return slideData.renderStarted
		end,
		clear = function(tutorialData, slideData)
			util.remove(slideData.cbOnRenderImage)
		end,
		nextSlide = "image_sequence_render_wait",
		autoContinue = true,
	})

	elTut:RegisterSlide("image_sequence_render_wait", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("render")
			slide:SetFocusElement(pm)
			slide:AddHighlight("info_bar/icon_container", true)
			slide:AddGenericMessageBox()

			slideData.renderCompleted = false
			local elWindowRender = slide:FindElementByPath("window_render")
			if util.is_valid(elWindowRender) then
				slideData.elRenderWindow = elWindowRender
				slideData.cbOnRenderComplete = elWindowRender:AddCallback(
					"OnRenderComplete",
					function(el, preview, prepareOnly)
						slideData.renderCompleted = true
					end
				)
			end
		end,
		clearCondition = function(tutorialData, slideData)
			if util.is_valid(slideData.elRenderWindow) == false then
				return true
			end
			return slideData.renderCompleted
		end,
		clear = function(tutorialData, slideData)
			util.remove(slideData.cbOnRenderComplete)
		end,
		nextSlide = "image_sequence_timeline",
	})

	elTut:RegisterSlide("image_sequence_timeline", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("render")
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_RENDER_UI_ID))
			slide:AddHighlight("window_render/playback_controls/pc_next_frame")
			slide:AddHighlight("window_render/playback_controls/pc_prev_frame", true)
			slide:AddGenericMessageBox()
		end,
		nextSlide = "video",
	})

	elTut:RegisterSlide("video", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("render")
			slide:SetFocusElement(slide:FindElementByPath("menu_bar"))
			slide:AddHighlight("menu_bar/file")
			slide:AddHighlight("context_menu/export")
			slide:AddHighlight("context_menu_export/export_timeline", true)
			slide:AddGenericMessageBox()
		end,
		nextSlide = "video_davinci",
	})

	elTut:RegisterSlide("video_davinci", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("render")
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_RENDER_UI_ID .. "/left_contents"))
			slide:AddHighlight(pfm.WINDOW_RENDER_UI_ID .. "/misc_options")
			slide:AddHighlight("context_menu/import_to_davinci", true)
			slide:AddGenericMessageBox()
		end,
		nextSlide = "conclusion",
	})

	elTut:RegisterSlide("settings", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("render")
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_RENDER_UI_ID))
			slide:AddHighlight(pfm.WINDOW_RENDER_UI_ID .. "/controls_menu")
			slide:AddHighlight(pfm.WINDOW_RENDER_UI_ID .. "/ss_factor", true)
			slide:AddGenericMessageBox()
		end,
		nextSlide = "conclusion",
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
			time.create_simple_timer(0.0, function()
				pm:LoadTutorial("interface/web_browser")
			end)
		end,
	})
	elTut:StartSlide("intro")
end)
