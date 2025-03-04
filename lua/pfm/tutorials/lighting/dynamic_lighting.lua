--[[
    Copyright (C) 2023 Silverlan

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
]]

include("/pfm/pfm_core_tutorials.lua")

local TARGET_ACTOR_VOLUMETRIC = "ffeb47d2-8174-4c54-a7ad-4569a5e1b397"
local TARGET_VOLUMETRIC_LIGHT_POS = Vector(-115.369, 68.8087, -68.6765)
local TARGET_VOLUMETRIC_LIGHT_ANG = EulerAngles(5.50483, -19.7964, 0)

local function find_light_source_actor(pm)
	local actorEditor = pm:GetActorEditor()
	if util.is_valid(actorEditor) == false then
		return
	end
	local filmClip = actorEditor:GetFilmClip()
	for _, actor in ipairs(filmClip:GetActorList()) do
		if actor:HasComponent("light_spot") and tostring(actor:GetUniqueId()) ~= TARGET_ACTOR_VOLUMETRIC then
			return actor
		end
	end
end

local function find_volumetric_light_source_actor(pm)
	return pfm.dereference(TARGET_ACTOR_VOLUMETRIC)
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
			slide:AddHighlight("window_primary_viewport")

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
			slide:AddHighlight("window_actor_editor/new_actor_button")
			slide:AddHighlight("context_menu/lights")
			slide:AddHighlight("context_menu_lights/spot_light", true)
			slide:AddGenericMessageBox()

			-- Move work camera to target location
			local vp = pm:GetViewport()
			local cam = util.is_valid(vp) and vp:GetWorkCamera() or nil
			if util.is_valid(cam) then
				local ent = cam:GetEntity()
				vp:SetWorkCameraPose(
					math.Transform(
						Vector(-86.9118, 35.3855, 14.2118),
						EulerAngles(0.732017, -157.95, 1.09934e-05):ToQuaternion()
					)
				)
			end
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
					slide:AddHighlight(tostring(lm:GetUniqueId()) .. "/light/header", true)
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
					slide:AddHighlight(tostring(lm:GetUniqueId()) .. "/light/header")
					slide:AddHighlight(tostring(lm:GetUniqueId()) .. "/light/intensityType/header")
					slide:AddHighlight(tostring(lm:GetUniqueId()) .. "/light/intensity/header", true)
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
					slide:AddHighlight(tostring(lm:GetUniqueId()) .. "/light/castShadows/header", true)
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
				local cmd = pfm.create_command(
					"set_actor_property",
					tostring(lm:GetUniqueId()),
					"ec/light/baked",
					nil,
					false,
					udm.TYPE_BOOLEAN
				)
				if cmd ~= nil then
					cmd:Execute()
				end
				local actorEditor = pm:GetActorEditor()
				local item = actorEditor:GetActorItem(lm)
				if util.is_valid(item) then
					item:Expand(true)
					slide:AddHighlight(tostring(lm:GetUniqueId()) .. "/light_spot/header")
					slide:AddHighlight(tostring(lm:GetUniqueId()) .. "/light_spot/blendFraction/header")
					slide:AddHighlight("property_controls/blendFraction", true)
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
				slide:AddHighlight("context_menu/toggle_camera_link", true)
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
			slide:AddHighlight("window_primary_viewport/vp_settings/rt_enabled", true)
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

			local lm = find_light_source_actor(pm)
			if lm ~= nil then
				slide:AddHighlight(tostring(lm:GetUniqueId()) .. "/header")
			end

			slide:SetTutorialCompleted()
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "volumetric",
	})

	elTut:RegisterSlide("volumetric", {
		init = function(tutorialData, slideData, slide)
			-- Disable Live RT mode
			local el = slide:FindElementByPath("window_primary_viewport/vp_settings/rt_enabled", false)
			local tgt = util.is_valid(el) and el:GetTarget() or nil
			if util.is_valid(tgt) then
				tgt:SelectOption(0)
			end

			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR_UI_ID))
			local lm = find_volumetric_light_source_actor()
			if lm ~= nil then
				local actorEditor = pm:GetActorEditor()
				local item = actorEditor:GetActorItem(lm)
				if util.is_valid(item) then
					item:Expand(true)
				end
				slide:AddHighlight(tostring(lm:GetUniqueId()) .. "/header")
				slide:AddHighlight("context_menu/add_component")
				slide:AddHighlight("context_menu_add_component/rendering")
				slide:AddHighlight("context_menu_rendering/lighting")
				slide:AddHighlight("context_menu_lighting/light_spot_volume", true)

				local actor = pfm.dereference(TARGET_ACTOR_VOLUMETRIC)
				if actor ~= nil then
					-- Turn on demo light source
					pfm.create_command(
						"set_actor_property",
						actor,
						"ec/pfm_actor/visible",
						false,
						true,
						udm.TYPE_BOOLEAN
					)
						:Execute()

					-- Move work camera to target location
					local vp = pm:GetViewport()
					local cam = util.is_valid(vp) and vp:GetWorkCamera() or nil
					if util.is_valid(cam) then
						local ent = cam:GetEntity()
						vp:SetWorkCameraPose(
							math.Transform(TARGET_VOLUMETRIC_LIGHT_POS, TARGET_VOLUMETRIC_LIGHT_ANG:ToQuaternion())
						)
					end
				end
			end
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		clearCondition = function(tutorialData, slideData, slide)
			local actor = pfm.dereference(TARGET_ACTOR_VOLUMETRIC)
			if actor == nil then
				return true
			end
			return actor:HasComponent("light_spot_volume")
		end,

		nextSlide = "volumetric_settings",
		autoContinue = true,
	})

	elTut:RegisterSlide("volumetric_settings", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight("contents")
			local lm = find_volumetric_light_source_actor()
			if lm ~= nil then
				slide:AddHighlight(TARGET_ACTOR_VOLUMETRIC .. "/header")
				slide:AddHighlight(TARGET_ACTOR_VOLUMETRIC .. "/light_spot_volume/header")
				slide:AddHighlight("property_controls/intensity", true)
			end
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
