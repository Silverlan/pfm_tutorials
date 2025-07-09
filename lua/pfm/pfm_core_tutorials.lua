-- SPDX-FileCopyrightText: (c) 2023 Silverlan <opensource@pragma-engine.com>
-- SPDX-License-Identifier: MIT

include("/gui/pfm/tutorials/tutorial.lua")

local res = engine.mount_sub_addon("vo_" .. locale.get_language())
if res == false then
	pfm.log(
		"Failed to mount addon '" .. "vo_" .. locale.get_language() .. "'!",
		pfm.LOG_CATEGORY_PFM,
		pfm.LOG_SEVERITY_ERROR
	)
end
