--[[
    Copyright (C) 2023 Silverlan

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
]]

include("/pfm/pfm_core_tutorials.lua")


local function find_light_source_actor(pm)
	local actorEditor = pm:GetActorEditor()
	if util.is_valid(actorEditor) == false then
		return
	end
	local filmClip = actorEditor:GetFilmClip()
	for _, actor in ipairs(filmClip:GetActorList()) do
		if actor:HasComponent("light_spot") then
			return actor
		end
	end
end

gui.Tutorial.register_tutorial("dynamic_lighting", "tutorials/lighting/dynamic_lighting", function(elTut, pm)
	elTut:RegisterSlide("intro", {
		init = function(tutorialData, slideData, slide)
			tool.get_filmmaker():GoToWindow("primary_viewport")
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "soft_shadows",
	})

	elTut:RegisterSlide("soft_shadows", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight(slide:FindElementByPath("window_primary_viewport"))

			tool.get_filmmaker():GoToWindow("primary_viewport")
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "light_types",
	})

	elTut:RegisterSlide("light_types", {
		init = function(tutorialData, slideData, slide)
			tool.get_filmmaker():GoToWindow("primary_viewport")
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "spot_light",
	})

	elTut:RegisterSlide("spot_light", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight(slide:FindElementByPath("window_actor_editor/new_actor_button"))
			slide:AddHighlight("window_actor_editor/new_actor_button")
			slide:AddHighlight("context_menu/spot_light")
			slide:SetArrowTarget("context_menu/spot_light")
			slide:AddGenericMessageBox()
		end,
		clearCondition = function(tutorialData, slideData, slide)
			local lm = find_light_source_actor(pm)
			return (lm ~= nil)
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "components",
	})

	elTut:RegisterSlide("components", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR_UI_ID))
			local lm = find_light_source_actor(pm)
			if lm ~= nil then
				local actorEditor = pm:GetActorEditor()
				local item = actorEditor:GetActorItem(lm)
				if util.is_valid(item) then
					item:Expand(true)
					slide:AddHighlight(gui.PFMActorEditor.COLLECTION_LIGHTS .. "/header")
					slide:AddHighlight(tostring(lm:GetUniqueId()) .. "/header")
					slide:AddHighlight(tostring(lm:GetUniqueId()) .. "/light/header")
					--[[slide:AddHighlight(tostring(lm:GetUniqueId()) .. "/radius/header")
					slide:AddHighlight(tostring(lm:GetUniqueId()) .. "/color/header")
					slide:AddHighlight(tostring(lm:GetUniqueId()) .. "/light_spot/header")
					slide:AddHighlight(tostring(lm:GetUniqueId()) .. "/pfm_light_spot/header")]]
				end
			end
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "intensity_type",
	})

	elTut:RegisterSlide("intensity_type", {
		init = function(tutorialData, slideData, slide)
			local lm = find_light_source_actor(pm)
			if lm ~= nil then
				local actorEditor = pm:GetActorEditor()
				local item = actorEditor:GetActorItem(lm)
				if util.is_valid(item) then
					item:Expand(true)
					local itemComponent = actorEditor:GetActorComponentItem(lm, "light")
					if util.is_valid(itemComponent) then
						itemComponent:Expand(true)
					end
					slide:AddHighlight(tostring(lm:GetUniqueId()) .. "/light/intensity/header")
					slide:AddHighlight(tostring(lm:GetUniqueId()) .. "/light/intensityType/header")
					local elPath = tostring(lm:GetUniqueId()) .. "/light/intensity/header"
					slide:SetArrowTarget(elPath)
				end
			end
			slide:SetFocusElement(slide:FindElementByPath("contents"))
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "shadows",
	})

	elTut:RegisterSlide("shadows", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath("contents"))
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR_UI_ID))
			local lm = find_light_source_actor(pm)
			if lm ~= nil then
				local actorEditor = pm:GetActorEditor()
				local item = actorEditor:GetActorItem(lm)
				if util.is_valid(item) then
					item:Expand(true)
					local elPath = tostring(lm:GetUniqueId()) .. "/light/castShadows/header"
					slide:AddHighlight(elPath)
					slide:SetArrowTarget(slide:FindElementByPath(elPath))
				end
			end
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		clearCondition = function(tutorialData, slideData, slide)
			local lm = find_light_source_actor(pm)
			if lm == nil then
				return true
			end
			return lm:GetMemberValue("ec/light/castShadows")
		end,
		nextSlide = "baked",
	})

	elTut:RegisterSlide("baked", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR_UI_ID))
			local lm = find_light_source_actor(pm)
			if lm ~= nil then
				local actorEditor = pm:GetActorEditor()
				local item = actorEditor:GetActorItem(lm)
				if util.is_valid(item) then
					item:Expand(true)
					local elPath = tostring(lm:GetUniqueId()) .. "/light/baked/header"
					slide:AddHighlight(elPath)
					slide:SetArrowTarget(slide:FindElementByPath(elPath))
				end
			end
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "blend_fraction",
	})

	elTut:RegisterSlide("blend_fraction", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath("contents"))
			slide:AddHighlight(slide:FindElementByPath("contents"))
			local lm = find_light_source_actor(pm)
			if lm ~= nil then
				local actorEditor = pm:GetActorEditor()
				local item = actorEditor:GetActorItem(lm)
				if util.is_valid(item) then
					item:Expand(true)
					local elPath = tostring(lm:GetUniqueId()) .. "/light_spot/blendFraction/header"
					slide:AddHighlight(elPath)
					slide:AddHighlight("property_controls/blendFraction")
					slide:SetArrowTarget("property_controls/blendFraction")
				end
			end
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "camera_link",
	})

	elTut:RegisterSlide("camera_link", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR_UI_ID))
			local lm = find_light_source_actor(pm)
			if lm ~= nil then
				slide:AddHighlight(tostring(lm:GetUniqueId()) .. "/header")
				slide:AddHighlight("context_menu/toggle_camera_link")
				slide:SetArrowTarget("context_menu/toggle_camera_link")
				local actorEditor = pm:GetActorEditor()
				if util.is_valid(actorEditor) then
					slideData.cbLinkModeStarted = actorEditor:AddCallback("OnCameraLinkModeEntered", function()
						util.remove(slideData.cbLinkModeStarted)
						slideData.linkModeEntered = true
					end)
				end
			end
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData)
			util.remove(slideData.cbLinkModeStarted)
		end,
		clearCondition = function(tutorialData, slideData, slide)
			return slideData.linkModeEntered or false
		end,
		nextSlide = "camera_link_placement",
		autoContinue = true,
	})

	elTut:RegisterSlide("camera_link_placement", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "cycles",
	})

	elTut:RegisterSlide("cycles", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddHighlight(slide:FindElementByPath("window_primary_viewport/vp_settings/rt_enabled"))
			slide:AddHighlight("window_primary_viewport/vp_settings/rt_enabled")
			slide:SetArrowTarget("window_primary_viewport/vp_settings/rt_enabled")
			slide:AddGenericMessageBox()
		end,
		clearCondition = function(tutorialData, slideData, slide)
			local el = slide:FindElementByPath("window_primary_viewport/vp_settings/rt_enabled", false)
			local tgt = util.is_valid(el) and el:GetTarget() or nil
			if util.is_valid(tgt) == false then
				return true
			end
			return toboolean(tgt:GetValue())
		end,
		autoContinue = true,
		nextSlide = "cycles_editing",
	})

	elTut:RegisterSlide("cycles_editing", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath("contents"))
			slide:AddHighlight(slide:FindElementByPath("contents"))
			slide:SetTutorialCompleted()
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "conclusion",
	})

	elTut:RegisterSlide("conclusion", {
		init = function(tutorialData, slideData, slide)
			-- Disable live RT
			local el = slide:FindElementByPath("window_primary_viewport/vp_settings/rt_enabled", false)
			local tgt = util.is_valid(el) and el:GetTarget() or nil
			if util.is_valid(tgt) then
				tgt:SelectOption(0)
			end

			slide:SetTutorialCompleted()
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "next_tutorial",
	})

	elTut:RegisterSlide("next_tutorial", {
		init = function(tutorialData, slideData, slide)
			pm:LoadTutorial("lighting/static_lighting")
		end,
	})
	elTut:StartSlide("intro")
end)
