--[[
    Copyright (C) 2023 Silverlan

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
]]

include("/pfm/pfm_core_tutorials.lua")

gui.Tutorial.register_tutorial("intro", function(elTut, pm)
	elTut:RegisterSlide("welcome", {
		init = function(slideData, slide)
			slide:AddMessageBox(
				"Hello and welcome to the Pragma Filmmaker (PFM)! This tutorial will give you a brief introduction to PFM and its interface.\n"
					.. 'You can click the "Continue" button to go to the next slide, or quit the tutorial at any time by pressing "End Tutorial".',
				"pfm/tutorials/intro/welcome.mp3"
			)

			-- We'll use the opportunity of this tutorial to build the render kernels, if they haven't been built yet
			-- pm:BuildKernels()
		end,
		nextSlide = "interface_sections",
	})
	elTut:RegisterSlide("interface_sections", {
		init = function(slideData, slide)
			slide:SetMinWindowFrameDividerFraction(pfm.WINDOW_ACTOR_EDITOR, 0.333)
			local elFocus = slide:FindPanelByWindow(pfm.WINDOW_ACTOR_EDITOR)
			slide:SetFocusElement(elFocus)
			slide:AddHighlight(elFocus)
			slide:AddMessageBox(
				"By default, the interface is split into three main sections:\n"
					.. "- Data\n"
					.. "- Viewport\n"
					.. "- Timeline\n\n"
					.. "The highlighted section to the left is the data section. Here you can find various panels for creating and editing actors, "
					.. "editing materials and particle systems, etc."
			)
		end,
		nextSlide = "viewport_section",
	})
	elTut:RegisterSlide("viewport_section", {
		init = function(slideData, slide)
			slide:SetMinWindowFrameDividerFraction(pfm.WINDOW_PRIMARY_VIEWPORT, 0.666)
			local elFocus = slide:FindPanelByWindow(pfm.WINDOW_PRIMARY_VIEWPORT)
			slide:SetFocusElement(elFocus)
			slide:AddHighlight(elFocus)
			slide:AddMessageBox(
				"On the right-hand side, you can find the viewport section. This is where you can view your animation, render images, etc."
			)
		end,
		nextSlide = "timeline_section",
	})
	elTut:RegisterSlide("timeline_section", {
		init = function(slideData, slide)
			local elFocus = slide:FindPanelByWindow(pfm.WINDOW_TIMELINE)
			slide:SetFocusElement(elFocus)
			slide:AddHighlight(elFocus)
			slide:AddMessageBox(
				"Below the viewport section is the timeline section. Here you can manage film clips, edit the animation of your actors, add keyframes, etc."
			)
		end,
		nextSlide = "layout_resize",
	})
	elTut:RegisterSlide("layout_resize", {
		init = function(slideData, slide)
			local divider = slide:SetMinWindowFrameDividerFraction(pfm.WINDOW_ACTOR_EDITOR, 0.5)
			slideData.divider = divider
			slideData.initialDividerPos = util.is_valid(divider) and divider:GetAbsolutePos() or Vector2i(0, 0)
			slide:SetFocusElement(slide:FindElementByPath("contents"))
			slide:AddHighlight(divider)
			slide:AddMessageBox(
				"There are several ways you can change the layout to suit your personal tastes. To start with, you can click and drag these "
					.. "dividers to resize certain sections of the interface.\n\n"
					.. "Try dragging the divider now."
			)
		end,
		clearCondition = function(slideData)
			if util.is_valid(slideData.divider) == false then
				return true
			end
			return slideData.divider:GetAbsolutePos() ~= slideData.initialDividerPos
		end,
		nextSlide = "layout_separate_window",
	})
	elTut:RegisterSlide("layout_separate_window", {
		init = function(slideData, slide)
			pm:GoToWindow(pfm.WINDOW_ACTOR_EDITOR)
			slideData.actorEditor = slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR)
			local elFocus = slide:FindElementByPath("editor_frame")
			slide:SetFocusElement(elFocus)
			slide:AddHighlight(slide:FindElementByPath("actor_editor_tab_button/detach_icon"))
			slide:AddMessageBox(
				"You can also click this icon to the top-right of any panel to separate it from the main window.\n"
					.. "This is especially useful if you want to work with multiple monitors.\n\n"
					.. "Try clicking the icon now."
			)
		end,
		clearCondition = function(slideData)
			if util.is_valid(slideData.actorEditor) == false then
				return true
			end
			return slideData.actorEditor:GetRootWindow() ~= gui.get_primary_window()
		end,
		nextSlide = "layout_reattach_window",
		autoContinue = true,
	})
	elTut:RegisterSlide("layout_reattach_window", {
		init = function(slideData, slide)
			slideData.actorEditor = slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR)
			slide:AddMessageBox(
				"Once you've detached a window, you can resize it and move it around like any other window.\n"
					.. "To re-attach it to the main menu, press the X icon on the top right. This will close the window and move the panel back "
					.. "to its original position.\n\n"
					.. "Try re-attaching the window now."
			)
		end,
		clearCondition = function(slideData)
			if util.is_valid(slideData.actorEditor) == false then
				return true
			end
			return slideData.actorEditor:GetRootWindow() == gui.get_primary_window()
		end,
		nextSlide = "layout_change_core",
	})
	elTut:RegisterSlide("layout_change_core", {
		init = function(slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath("menu_bar"))
			slide:AddHighlight(slide:FindElementByPath("menu_bar/view"))
			slide:AddMessageBox(
				'In addition, you can also change the core layout of the interface by selecting one of the preset options in the "View" '
					.. "menu in the menu bar.\n\n"
					.. 'Try changing the layout now by choosing "View" > "Layout" > "three_columns".'
			)
			slideData.cbOnChangeLayout = pm:AddCallback("OnChangeLayout", function(pm, fileName)
				slideData.layoutChanged = true
			end)
		end,
		clear = function(slideData)
			util.remove(slideData.cbOnChangeLayout)
		end,
		clearCondition = function(slideData)
			return slideData.layoutChanged
		end,
		nextSlide = "layout_change_core2",
		autoContinue = true,
	})
	elTut:RegisterSlide("layout_change_core2", {
		init = function(slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath("contents"))
			slide:AddHighlight(slide:FindElementByPath("contents"))
			slide:AddMessageBox(
				"As you can see, the panels are now divided up into three columns instead of two. Other presets are available as well.\n"
					.. "For the purposes of this tutorial, we'll revert back to the default two-column layout."
			)
		end,
		nextSlide = "layout_save_preference",
	})
	elTut:RegisterSlide("layout_save_preference", {
		init = function(slideData, slide)
			pm:LoadLayout("cfg/pfm/layouts/default.udm")
			slide:AddMessageBox(
				"Once you have arranged the interface to your liking, you can save the current layout state by selecting "
					.. '"View" > "Layout" > "Save Current Layout State as Default".\n'
					.. "The next time you start PFM, this layout will be restored automatically.\n\n"
					.. "The layout is also stored in the project file, so opening a project will restore the layout you were using when "
					.. "you last saved the project."
			)
		end,
		nextSlide = "help_menu",
	})
	elTut:RegisterSlide("help_menu", {
		init = function(slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath("menu_bar"))
			slide:AddHighlight(slide:FindElementByPath("menu_bar/help"))
			slide:AddMessageBox(
				'If you need assistance, you can find useful resources in the "Help" menu in the menu bar.\n'
					.. "Here you can find options to open the online documentation, join the Discord server, check out the online bug tracker or "
					.. "restart this tutorial."
			)
		end,
		nextSlide = "tutorial_panel",
	})
	elTut:RegisterSlide("tutorial_panel", {
		init = function(slideData, slide)
			slide:SetMinWindowFrameDividerFraction(pfm.WINDOW_TUTORIAL_CATALOG, 0.5)
			slide:SetFocusElement(slide:FindElementByPath("editor_frame"))
			slide:AddHighlight(slide:FindElementByPath("editor_frame/tutorial_catalog_tab_button"))
			slide:AddMessageBox(
				'This completes this introductionary tutorial. You can now move on to other tutorials by opening the "Tutorial" panel.'
			)
		end,
		clearCondition = function(slideData)
			return pm:IsWindowActive("tutorial_catalog")
		end,
		nextSlide = "tutorial_panel2",
	})
	-- TODO: Click this icon to detach a window
	elTut:RegisterSlide("tutorial_panel2", {
		init = function(slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath("editor_frame"))
			slide:AddHighlight(slide:FindElementByPath("editor_frame/tutorial_catalog"))
			slide:AddMessageBox(
				"Here you can find all available tutorials, which you can start at any time and in any order."
			)
		end,
		clearCondition = function(slideData)
			return pm:IsWindowActive("tutorial_catalog")
		end,
		nextSlide = "tutorial_panel3",
	})

	elTut:RegisterSlide("tutorial_panel3", {
		init = function(slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath("editor_frame"))
			slide:AddHighlight(slide:FindElementByPath("tutorial_catalog/tutorials_interface"))
			slide:AddMessageBox(
				"All tutorials are grouped by categories. To start a specific tutorial, you can simply double-click it.\n"
					.. "To begin with, it's usually a good idea to familiarize yourself with the interface first.\n\n"
					.. 'Open the "interface" category to continue.'
			)
		end,
		clearCondition = function(slideData)
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
		init = function(slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath("editor_frame"))
			slide:AddHighlight(slide:FindElementByPath("tutorial_catalog/tutorials_interface_viewport.udm"))
			slide:AddMessageBox(
				'You can now end this tutorial and start the "Viewport" tutorial by double-clicking this icon.'
			)
		end,
	})

	elTut:StartSlide("welcome")
end)
