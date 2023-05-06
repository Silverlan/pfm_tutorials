--[[
    Copyright (C) 2023 Silverlan

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
]]

include("/gui/pfm/tutorials/tutorial.lua")

local path = util.Path.CreatePath(util.get_addon_path())
path:PopFront()
path = path +("vo_" .. locale.get_language())
pfm.log("Mounting addon '" .. path:GetString() .. "'...",pfm.LOG_CATEGORY_PFM)
local res = engine.mount_addon(path:GetString())
if(res == false) then
    pfm.log("Failed to mount addon '" .. path:GetString() .. "'!",pfm.LOG_CATEGORY_PFM,pfm.LOG_SEVERITY_ERROR)
end
