--[[
    Copyright (C) 2023 Silverlan

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
]]

include("/gui/pfm/tutorials/tutorial.lua")

local uuidChair = "ef049de3-1f6b-4930-b5d5-70529ff99864"

-- lua_exec_cl pfm/tutorials/interface/model_editor.lua

time.create_simple_timer(0.1,function() gui.Tutorial.start_tutorial("model_editor") end)

gui.Tutorial.register_tutorial("model_editor",function(elTut,pm)
	elTut:RegisterSlide("model_editor",{
		init = function(slideData,slide)
			tool.get_filmmaker():GoToWindow("primary_viewport")
			-- TODO: Select "Selection Move"
			slide:AddHighlight(slide:FindElementByPath("pfm_primary_viewport"))
			slide:AddMessageBox("This is the primary viewport, where you can preview your scene/animation, select and transform actors, etc.\nYou can also create additional viewports from the \"Windows\" sub-menu in the menu bar.")
		end,
		clear = function(slideData)

		end,
		nextSlide = "viewport_interaction1"
	})

	elTut:StartSlide("model_editor")
end)
