--[[
    Copyright (C) 2023 Silverlan

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
]]

include("/pfm/pfm_core_tutorials.lua")

gui.Tutorial.register_tutorial("intro", "tutorials/intro", function(elTut, pm)
	elTut:RegisterSlide("welcome", {
		init = function(tutorialData, slideData, slide)
			slide:AddGenericMessageBox()

			-- We'll use the opportunity of this tutorial to build the render kernels, if they haven't been built yet
			-- pm:BuildKernels()
		end,
		nextSlide = "interface_sections",
	})
	elTut:RegisterSlide("interface_sections", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("actor_editor")
			slide:SetMinWindowFrameDividerFraction(pfm.WINDOW_ACTOR_EDITOR, 0.333)
			local elFocus = slide:FindPanelByWindow(pfm.WINDOW_ACTOR_EDITOR)
			slide:SetFocusElement(elFocus)
			slide:AddHighlight(elFocus)
			slide:AddGenericMessageBox()
		end,
		nextSlide = "viewport_section",
	})
	elTut:RegisterSlide("viewport_section", {
		init = function(tutorialData, slideData, slide)
			slide:SetMinWindowFrameDividerFraction(pfm.WINDOW_PRIMARY_VIEWPORT, 0.666)
			local elFocus = slide:FindPanelByWindow(pfm.WINDOW_PRIMARY_VIEWPORT)
			slide:SetFocusElement(elFocus)
			slide:AddHighlight(elFocus)
			slide:AddGenericMessageBox()
		end,
		nextSlide = "timeline_section",
	})
	elTut:RegisterSlide("timeline_section", {
		init = function(tutorialData, slideData, slide)
			local elFocus = slide:FindPanelByWindow(pfm.WINDOW_TIMELINE)
			slide:SetFocusElement(elFocus)
			slide:AddHighlight(elFocus)
			slide:AddGenericMessageBox()
		end,
		nextSlide = "layout_resize",
	})
	elTut:RegisterSlide("layout_resize", {
		init = function(tutorialData, slideData, slide)
			local divider = slide:SetMinWindowFrameDividerFraction(pfm.WINDOW_ACTOR_EDITOR, 0.5)
			slideData.divider = divider
			slideData.initialDividerPos = util.is_valid(divider) and divider:GetAbsolutePos() or Vector2i(0, 0)
			slide:SetFocusElement(slide:FindElementByPath("contents"))
			slide:AddHighlight(divider)
			slide:AddGenericMessageBox()
		end,
		clearCondition = function(tutorialData, slideData)
			if util.is_valid(slideData.divider) == false then
				return true
			end
			return slideData.divider:GetAbsolutePos() ~= slideData.initialDividerPos
		end,
		nextSlide = "layout_separate_window",
	})
	elTut:RegisterSlide("layout_separate_window", {
		init = function(tutorialData, slideData, slide)
			pm:GoToWindow(pfm.WINDOW_ACTOR_EDITOR)
			slideData.actorEditor = slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR_UI_ID)
			local elFocus = slide:FindElementByPath("editor_frame")
			slide:SetFocusElement(elFocus)
			slide:AddHighlight(slide:FindElementByPath("actor_editor_tab_button/detach_icon"))
			slide:AddGenericMessageBox()
		end,
		clearCondition = function(tutorialData, slideData)
			if util.is_valid(slideData.actorEditor) == false then
				return true
			end
			return slideData.actorEditor:GetRootWindow() ~= gui.get_primary_window()
		end,
		nextSlide = "layout_reattach_window",
		autoContinue = true,
	})
	elTut:RegisterSlide("layout_reattach_window", {
		init = function(tutorialData, slideData, slide)
			slideData.actorEditor = slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR_UI_ID)
			slide:AddGenericMessageBox()
		end,
		clearCondition = function(tutorialData, slideData)
			if util.is_valid(slideData.actorEditor) == false then
				return true
			end
			return slideData.actorEditor:GetRootWindow() == gui.get_primary_window()
		end,
		nextSlide = "layout_change_core",
	})
	elTut:RegisterSlide("layout_change_core", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath("menu_bar"))
			slide:AddHighlight(slide:FindElementByPath("menu_bar/view"))
			slide:SetArrowTarget(slide:FindElementByPath("menu_bar/view"))
			slide:AddHighlight("context_menu/layout")
			slide:AddHighlight("context_menu_layout/three_columns")
			slide:AddGenericMessageBox()
			slideData.cbOnChangeLayout = pm:AddCallback("OnChangeLayout", function(pm, fileName)
				slideData.layoutChanged = true
			end)
		end,
		clear = function(tutorialData, slideData)
			util.remove(slideData.cbOnChangeLayout)
		end,
		clearCondition = function(tutorialData, slideData)
			return slideData.layoutChanged
		end,
		nextSlide = "layout_change_core2",
		autoContinue = true,
	})
	elTut:RegisterSlide("layout_change_core2", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath("contents"))
			slide:AddHighlight(slide:FindElementByPath("contents"))
			slide:AddGenericMessageBox()
		end,
		nextSlide = "layout_save_preference",
	})
	elTut:RegisterSlide("layout_save_preference", {
		init = function(tutorialData, slideData, slide)
			pm:LoadLayout("cfg/pfm/layouts/default.udm")
			slide:AddGenericMessageBox()
		end,
		nextSlide = "help_menu",
	})
	elTut:RegisterSlide("help_menu", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath("menu_bar"))
			slide:AddHighlight(slide:FindElementByPath("menu_bar/help"))
			slide:AddGenericMessageBox()
		end,
		nextSlide = "tutorial_panel",
	})
	elTut:RegisterSlide("tutorial_panel", {
		init = function(tutorialData, slideData, slide)
			slide:SetMinWindowFrameDividerFraction(pfm.WINDOW_TUTORIAL_CATALOG, 0.5)
			slide:SetFocusElement(slide:FindElementByPath("editor_frame"))
			slide:AddHighlight(slide:FindElementByPath("editor_frame/tutorial_catalog_tab_button"))
			slide:AddGenericMessageBox()
		end,
		clearCondition = function(tutorialData, slideData)
			return pm:IsWindowActive("tutorial_catalog")
		end,
		nextSlide = "tutorial_panel2",
	})
	elTut:RegisterSlide("tutorial_panel2", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("tutorial_catalog")
			slide:SetFocusElement(slide:FindElementByPath("editor_frame"))
			slide:AddHighlight(slide:FindElementByPath("editor_frame/window_tutorial_catalog"))
			slide:AddGenericMessageBox()
		end,
		nextSlide = "tutorial_panel3",
	})

	elTut:RegisterSlide("tutorial_panel3", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath("editor_frame"))
			slide:AddHighlight(slide:FindElementByPath("window_tutorial_catalog/tutorials_interface"))
			slide:AddGenericMessageBox()
		end,
		clearCondition = function(tutorialData, slideData)
			local e = pm:GetWindow("tutorial_catalog")
			e = util.is_valid(e) and e:GetExplorer() or nil
			if util.is_valid(e) == false then
				return true
			end
			return e:GetPath() == "interface/"
		end,
		nextSlide = "tutorial_panel4",
		autoContinue = true,
	})

	elTut:RegisterSlide("tutorial_panel4", {
		init = function(tutorialData, slideData, slide)
			slide:SetTutorialCompleted()
			slide:SetFocusElement(slide:FindElementByPath("editor_frame"))
			slide:AddHighlight(slide:FindElementByPath("window_tutorial_catalog/tutorials_interface_viewport.udm"))
			slide:AddGenericMessageBox()
		end,
	})

	elTut:StartSlide("welcome")
end)
