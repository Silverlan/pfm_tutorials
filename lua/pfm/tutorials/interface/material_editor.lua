--[[
    Copyright (C) 2023 Silverlan

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
]]

include("/pfm/pfm_core_tutorials.lua")

gui.Tutorial.register_tutorial("material_editor", function(elTut, pm)
	elTut:RegisterSlide("intro", {
		init = function(slideData, slide)
			tool.get_filmmaker():GoToWindow("primary_viewport")
		end,
		clear = function(slideData) end,
		nextSlide = "",
	})

	elTut:StartSlide("intro")
end)
