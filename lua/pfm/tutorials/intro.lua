--[[
    Copyright (C) 2023 Silverlan

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
]]

include("/pfm/pfm_core_tutorials.lua")

local uuidChair = "ef049de3-1f6b-4930-b5d5-70529ff99864"

-- lua_exec_cl pfm/tutorials/intro.lua

time.create_simple_timer(0.1,function() gui.Tutorial.start_tutorial("intro") end)

gui.Tutorial.register_tutorial("intro",function(elTut,pm)
	elTut:RegisterSlide("intro",{
		init = function(slideData,slide)
			slide:AddMessageBox(
				"Welcome to the Pragma Filmmaker (PFM)! This tutorial will give you a quick overview " ..
				"of the interface of PFM and how to use it.",
				"pfm/tutorials/intro/welcome.mp3"
			)

			-- We'll use the opportunity of this tutorial to build the render kernels, if they haven't been built yet
			--pm:BuildKernels()
		end,
		nextSlide = "introX"
	})
	-- TODO: Main window divided into two areas
	elTut:RegisterSlide("introX",{
		init = function(slideData,slide)
			slide:SetFocusElement(slide:FindElementByPath("contents"))
			slide:AddHighlight(pm:GetCentralDivider())
			slide:AddMessageBox("You can click and drag these dividers to resize certain portions of the interface.")
		end,
		nextSlide = "intro2"
	})
	-- TODO: Click this icon to detach a window
	elTut:RegisterSlide("intro2",{
		init = function(slideData,slide)
			pm:GetCentralDivider():SetFraction(0.45)
			slide:SetFocusElement(slide:FindElementByPath("actor_frame"))
			slide:AddHighlight(slide:FindElementByPath("actor_frame/tutorial_catalog_tab_button"))
			slide:AddMessageBox("You can find all available tutorials over here, which you can start at any time and in any order.\n\nClick on the \"Tutorials\" tab to continue.")
		end,
		clearCondition = function(slideData)
			return pm:IsWindowActive("tutorial_catalog")
		end,
		nextSlide = "intro3"
	})
	elTut:RegisterSlide("intro3",{
		init = function(slideData,slide)
			slide:SetFocusElement(slide:FindElementByPath("tutorial_catalog"))
			slide:AddHighlight(slide:FindElementByPath("tutorial_catalog/tutorials_interface"))
			slide:AddMessageBox("All tutorials are grouped by categories. To start a specific tutorial, you can simply double-click it. To begin with, it's usually a good idea to familiarize yourself with the interface first.\n\nOpen the \"interface\" category to continue.")
		end,
		clearCondition = function(slideData)
			local e = pm:GetWindow("tutorial_catalog")
			e = util.is_valid(e) and e:GetExplorer() or nil
			if(util.is_valid(e) == false) then return true end
			return e:GetPath() == "interface/"
		end,
		nextSlide = "intro4",
		autoContinue = true
	})
	elTut:RegisterSlide("intro4",{
		init = function(slideData,slide)
			slide:SetFocusElement(slide:FindElementByPath("tutorial_catalog"))
			slide:AddHighlight(slide:FindElementByPath("tutorial_catalog/tutorials_interface_viewport.udm"))
			slide:AddMessageBox("You can now end this tutorial and start the \"Viewport\" tutorial by double-clicking this icon.")
		end
	})

	elTut:StartSlide("intro")
end)
