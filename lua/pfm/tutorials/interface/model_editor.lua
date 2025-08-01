-- SPDX-FileCopyrightText: (c) 2023 Silverlan <opensource@pragma-engine.com>
-- SPDX-License-Identifier: MIT

include("/pfm/pfm_core_tutorials.lua")

local uuidChair = "ef049de3-1f6b-4930-b5d5-70529ff99864"

-- lua_exec_cl pfm/tutorials/interface/model_editor.lua

time.create_simple_timer(0.1, function()
	gui.Tutorial.start_tutorial("model_editor")
end)

gui.Tutorial.register_tutorial("model_editor", function(elTut, pm)
	elTut:RegisterSlide("model_editor", {
		init = function(slideData, slide)
			tool.get_filmmaker():GoToWindow("primary_viewport")
			-- TODO: Select "Selection Move"
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddMessageBox(
				'This is the primary viewport, where you can preview your scene/animation, select and transform actors, etc.\nYou can also create additional viewports from the "Windows" sub-menu in the menu bar.'
			)
		end,
		clear = function(slideData) end,
		nextSlide = "viewport_interaction1",
	})

	elTut:StartSlide("model_editor")
end)
