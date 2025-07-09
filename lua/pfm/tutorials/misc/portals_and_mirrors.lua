-- SPDX-FileCopyrightText: (c) 2023 Silverlan <opensource@pragma-engine.com>
-- SPDX-License-Identifier: MIT

include("/pfm/pfm_core_tutorials.lua")

gui.Tutorial.register_tutorial("portals", function(elTut, pm)
	elTut:RegisterSlide("intro", {
		init = function(slideData, slide)
			tool.get_filmmaker():GoToWindow("primary_viewport")
		end,
		clear = function(slideData) end,
		nextSlide = "",
	})

	elTut:StartSlide("intro")
end)
