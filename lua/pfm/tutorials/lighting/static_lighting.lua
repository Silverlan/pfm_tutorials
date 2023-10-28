--[[
    Copyright (C) 2023 Silverlan

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
]]

include("/pfm/pfm_core_tutorials.lua")

local TARGET_SKY_STRENGTH = 8.0
local TARGET_REFLECTION_PROBE_LOCATION = Vector(23.9548, 95.6181, -3.19058)

local function find_light_source_actor(pm)
	local actorEditor = pm:GetActorEditor()
	if util.is_valid(actorEditor) == false then
		return
	end
	local filmClip = actorEditor:GetFilmClip()
	for _, actor in ipairs(filmClip:GetActorList()) do
		if actor:HasComponent("light_point") then
			return actor
		end
	end
end

local function find_sky_actor(pm)
	local actorEditor = pm:GetActorEditor()
	if util.is_valid(actorEditor) == false then
		return
	end
	local filmClip = actorEditor:GetFilmClip()
	for _, actor in ipairs(filmClip:GetActorList()) do
		if actor:HasComponent("skybox") then
			return actor
		end
	end
end

local function find_lightmapper_actor(pm)
	local actorEditor = pm:GetActorEditor()
	if util.is_valid(actorEditor) == false then
		return
	end
	local filmClip = actorEditor:GetFilmClip()
	for _, actor in ipairs(filmClip:GetActorList()) do
		if actor:HasComponent("pfm_baked_lighting") then
			return actor
		end
	end
end

local function find_reflection_probe_actor(pm)
	local actorEditor = pm:GetActorEditor()
	if util.is_valid(actorEditor) == false then
		return
	end
	local filmClip = actorEditor:GetFilmClip()
	for _, actor in ipairs(filmClip:GetActorList()) do
		if actor:HasComponent("reflection_probe") then
			return actor
		end
	end
end

gui.Tutorial.register_tutorial("static_lighting", "tutorials/lighting/static_lighting", function(elTut, pm)
	elTut:RegisterSlide("intro", {
		init = function(tutorialData, slideData, slide)
			tool.get_filmmaker():GoToWindow("primary_viewport")
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "lightmap_atlas",
	})

	elTut:RegisterSlide("lightmap_atlas", {
		init = function(tutorialData, slideData, slide)
			tool.get_filmmaker():GoToWindow("actor_editor")
			slide:AddHighlight("window_actor_editor/new_actor_button")
			slide:AddHighlight("context_menu")
			slide:AddHighlight("context_menu/point_light", true)
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		clearCondition = function(tutorialData, slideData, slide)
			local lm = find_light_source_actor(pm)
			return (lm ~= nil)
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
					slide:AddHighlight(gui.PFMActorEditor.COLLECTION_LIGHTS .. "/header")
					slide:AddHighlight(tostring(lm:GetUniqueId()) .. "/header")
					slide:AddHighlight(tostring(lm:GetUniqueId()) .. "/light/header")
					slide:AddHighlight(tostring(lm:GetUniqueId()) .. "/light/baked/header")
					slide:AddHighlight("property_controls/baked", true)
					slideData.lightActor = lm
				end
			end
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		clearCondition = function(tutorialData, slideData, slide)
			return slideData.lightActor:GetMemberValue("ec/light/baked")
		end,
		nextSlide = "live_rt",
	})

	elTut:RegisterSlide("live_rt", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddHighlight("window_primary_viewport/vp_settings/rt_enabled", true)
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		clearCondition = function(tutorialData, slideData, slide)
			local el = slide:FindElementByPath("window_primary_viewport/vp_settings/rt_enabled", false)
			local tgt = util.is_valid(el) and el:GetTarget() or nil
			if util.is_valid(tgt) == false then
				return true
			end
			return toboolean(tgt:GetValue())
		end,
		nextSlide = "live_rt_edit",
	})

	elTut:RegisterSlide("live_rt_edit", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath("contents"))
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
					slide:AddHighlight(tostring(lm:GetUniqueId()) .. "/light/intensity/header")
					slide:AddHighlight(tostring(lm:GetUniqueId()) .. "/color/header")
					slide:AddHighlight(tostring(lm:GetUniqueId()) .. "/color/contents_wrapper/color/header")
					slideData.lightActor = lm
				end
			end
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "sky",
	})

	elTut:RegisterSlide("sky", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight("window_actor_editor/new_actor_button")
			slide:AddHighlight("context_menu")
			slide:AddHighlight("context_menu/sky", true)
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		clearCondition = function(tutorialData, slideData, slide)
			local lm = find_sky_actor(pm)
			return (lm ~= nil)
		end,
		nextSlide = "refresh_rt_view",
	})

	elTut:RegisterSlide("refresh_rt_view", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			local refreshRtViewPath = "window_primary_viewport/refresh_rt_view"
			local elRefresh = slide:FindElementByPath(refreshRtViewPath)
			slide:AddHighlight(refreshRtViewPath, true)
			slide:AddGenericMessageBox()

			slideData.cbOnPressed = elRefresh:AddCallback("OnPressed", function()
				slideData.rtViewRefreshed = true
			end)
		end,
		clear = function(tutorialData, slideData)
			util.remove(slideData.cbOnPressed)
		end,
		clearCondition = function(tutorialData, slideData, slide)
			return slideData.rtViewRefreshed
		end,
		nextSlide = "sky_strength",
	})

	elTut:RegisterSlide("sky_strength", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath("contents"))

			local sky = find_sky_actor(pm)
			if sky ~= nil then
				local actorEditor = pm:GetActorEditor()
				local item = actorEditor:GetActorItem(sky)
				if util.is_valid(item) then
					item:Expand(true)
					slide:AddHighlight(gui.PFMActorEditor.COLLECTION_ENVIRONMENT .. "/header")
					slide:AddHighlight(tostring(sky:GetUniqueId()) .. "/header")
					slide:AddHighlight(tostring(sky:GetUniqueId()) .. "/pfm_sky/header")
					slide:AddHighlight(tostring(sky:GetUniqueId()) .. "/pfm_sky/strength/header")
					slide:AddHighlight("property_controls/strength", true)
				end
			end
			slide:AddGenericMessageBox({ TARGET_SKY_STRENGTH })

			local elRefresh = slide:FindElementByPath("window_primary_viewport/refresh_rt_view")
			if util.is_valid(elRefresh) then
				slideData.cbOnPressed = elRefresh:AddCallback("OnPressed", function()
					if slideData.inRange then
						slideData.rtViewRefreshed = true
					end
				end)
			end
		end,
		clear = function(tutorialData, slideData)
			util.remove(slideData.cbOnPressed)
		end,
		clearCondition = function(tutorialData, slideData)
			local actor = find_sky_actor(pm)
			if actor == nil then
				return true
			end
			local val = actor:GetMemberValue("ec/pfm_sky/strength")
			if val == nil then
				return true
			end
			local diff = math.abs(val - TARGET_SKY_STRENGTH)
			slideData.inRange = (diff < 0.5)
			return slideData.rtViewRefreshed
		end,
		nextSlide = "lightmapper",
	})

	elTut:RegisterSlide("lightmapper", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight("window_actor_editor/new_actor_button")
			slide:AddHighlight("window_actor_editor/new_actor_button")
			slide:AddHighlight("context_menu")
			slide:AddHighlight("context_menu/baking")
			slide:AddHighlight("context_menu_baking/lightmapper", true)
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		clearCondition = function(tutorialData, slideData, slide)
			local lm = find_lightmapper_actor(pm)
			return (lm ~= nil)
		end,
		nextSlide = "lightmapper_select",
		autoContinue = true,
	})

	elTut:RegisterSlide("lightmapper_select", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR_UI_ID))
			local lm = find_lightmapper_actor(pm)
			if lm ~= nil then
				local actorEditor = pm:GetActorEditor()
				local item = actorEditor:GetActorItem(lm)
				if util.is_valid(item) then
					item:Expand(true)
					slide:AddHighlight(gui.PFMActorEditor.COLLECTION_BAKING .. "/header")
					slide:AddHighlight(tostring(lm:GetUniqueId()) .. "/header")
					slide:AddHighlight(tostring(lm:GetUniqueId()) .. "/pfm_baked_lighting/header", true)
					slideData.lightActor = lm
				end
			end
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		clearCondition = function(tutorialData, slideData, slide)
			local actor = find_lightmapper_actor(pm)
			local actorEditor = tool.get_filmmaker():GetActorEditor()
			local item = actorEditor:GetComponentEntry(tostring(actor:GetUniqueId()), "pfm_baked_lighting")
			return util.is_valid(item) == false or item:IsSelected()
		end,
		nextSlide = "lightmapper_resolution",
	})

	elTut:RegisterSlide("lightmapper_resolution", {
		init = function(tutorialData, slideData, slide)
			local lm = find_lightmapper_actor(pm)
			if lm ~= nil then
				local actorEditor = pm:GetActorEditor()
				local item = actorEditor:GetActorItem(lm)
				if util.is_valid(item) then
					item:Expand(true)
					local presetElementPath = pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/property_controls/bake_preset_quality"
					local presetElement = slide:FindElementByPath(presetElementPath)
					slide:AddHighlight(presetElementPath, true)
					slideData.presetElement = presetElement
				end
			end
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		clearCondition = function(tutorialData, slideData, slide)
			if util.is_valid(slideData.presetElement) == false then
				return false
			end
			local target = slideData.presetElement:GetTarget()
			if util.is_valid(target) == false then
				return false
			end
			if target:GetSelectedOption() == -1 then
				return false
			end
			local val = target:GetOptionValue(target:GetSelectedOption())
			return toint(val) == 0
		end,
		nextSlide = "lightmapper_render",
	})

	elTut:RegisterSlide("lightmapper_render", {
		init = function(tutorialData, slideData, slide)
			local lm = find_lightmapper_actor(pm)
			if lm ~= nil then
				local actorEditor = pm:GetActorEditor()
				local item = actorEditor:GetActorItem(lm)
				if util.is_valid(item) then
					item:Expand(true)
					local presetElementPath = pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/property_controls/bake_lightmaps"
					local presetElement = slide:FindElementByPath(presetElementPath)
					slide:AddHighlight(presetElementPath, true)
					local cb
					cb = presetElement:GetBaker():AddCallback("OnBakingStarted", function()
						util.remove(cb)
						slideData.bakingStarted = true
					end)
					slideData.onBakingStartedCb = cb
				end
			end
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData)
			util.remove(slideData.onBakingStartedCb)
		end,
		clearCondition = function(tutorialData, slideData, slide)
			return slideData.bakingStarted
		end,
		autoContinue = true,
		nextSlide = "lightmapper_render_progress",
	})

	elTut:RegisterSlide("lightmapper_render_progress", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight("info_bar/icon_container", true)

			local lm = find_lightmapper_actor(pm)
			local isBaking = false
			if lm ~= nil then
				local actorEditor = pm:GetActorEditor()
				local item = actorEditor:GetActorItem(lm)
				if util.is_valid(item) then
					item:Expand(true)
					local presetElement =
						slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/property_controls/bake_lightmaps")
					local cb
					cb = presetElement:GetBaker():AddCallback("OnBakingCompleted", function()
						util.remove(cb)
						slideData.bakingCompleted = true
					end)
					isBaking = presetElement:GetBaker():IsBaking()
					slideData.onBakingCompletedCb = cb
				end
			end
			slideData.bakingCompleted = not isBaking

			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData)
			util.remove(slideData.onBakingCompletedCb)
		end,
		clearCondition = function(tutorialData, slideData)
			return slideData.bakingCompleted
		end,
		nextSlide = "lightmapper_render_complete",
		autoContinue = true,
	})

	elTut:RegisterSlide("lightmapper_render_complete", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight(slide:FindElementByPath("window_primary_viewport/viewport"))

			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "lightmapper_render_job",
	})

	elTut:RegisterSlide("lightmapper_render_job", {
		init = function(tutorialData, slideData, slide)
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "lightmapper_render_job_create",
	})

	elTut:RegisterSlide("lightmapper_render_job_create", {
		init = function(tutorialData, slideData, slide)
			local lm = find_lightmapper_actor(pm)
			if lm ~= nil then
				local actorEditor = pm:GetActorEditor()
				local item = actorEditor:GetActorItem(lm)
				if util.is_valid(item) then
					item:Expand(true)
					local btPath = pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/property_controls/create_lightmap_render_job"
					local btCreateRenderJob = slide:FindElementByPath(btPath)
					slide:AddHighlight(btPath, true)

					local cb
					slideData.initBakeCallback = function()
						if util.is_valid(cb) then
							return
						end
						local btBake = slide:FindElementByPath(btPath, false)
						if btBake ~= nil then
							cb = btBake:AddCallback("OnPressed", function()
								util.remove(cb)
								slideData.renderJobCreated = true
							end)
							slideData.onLightmapRenderJobCreated = cb
						end
					end
				end
			end

			local shellFileName
			if os.SYSTEM_WINDOWS then
				shellFileName = "render.bat"
			else
				shellFileName = "render.sh"
			end

			slide:AddGenericMessageBox({ shellFileName })
		end,
		clear = function(tutorialData, slideData)
			util.remove(slideData.onLightmapRenderJobCreated)
		end,
		clearCondition = function(tutorialData, slideData)
			slideData.initBakeCallback()
			return slideData.renderJobCreated
		end,
		nextSlide = "lightmapper_render_job_import",
	})

	elTut:RegisterSlide("lightmapper_render_job_import", {
		init = function(tutorialData, slideData, slide)
			local lm = find_lightmapper_actor(pm)
			if lm ~= nil then
				local actorEditor = pm:GetActorEditor()
				local item = actorEditor:GetActorItem(lm)
				if util.is_valid(item) then
					item:Expand(true)
					local btPath = pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/property_controls/import_lightmaps"
					local btCreateRenderJob = slide:FindElementByPath(btPath)
					slide:AddHighlight(btPath, true)
				end
			end

			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "lightmapper_exposure",
	})

	elTut:RegisterSlide("lightmapper_exposure", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight(slide:FindElementByPath("contents"))
			local lm = find_lightmapper_actor(pm)
			if lm ~= nil then
				local actorEditor = pm:GetActorEditor()
				local item = actorEditor:GetActorItem(lm)
				if util.is_valid(item) then
					item:Expand(true)
					slide:AddHighlight(gui.PFMActorEditor.COLLECTION_BAKING .. "/header")
					slide:AddHighlight(tostring(lm:GetUniqueId()) .. "/header")
					slide:AddHighlight(tostring(lm:GetUniqueId()) .. "/light_map/header")
					slide:AddHighlight(tostring(lm:GetUniqueId()) .. "/light_map/exposure/header")
					slide:AddHighlight("property_controls/exposure", true)
					slideData.lightActor = lm
				end
			end

			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "reflection_probe",
	})

	elTut:RegisterSlide("reflection_probe", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight(slide:FindElementByPath("window_actor_editor/new_actor_button"))
			slide:AddHighlight("window_actor_editor/new_actor_button")
			slide:AddHighlight("context_menu")
			slide:AddHighlight("context_menu/baking")
			slide:AddHighlight("context_menu_baking/reflection_probe", true)
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		clearCondition = function(tutorialData, slideData, slide)
			local reflectionProbe = find_reflection_probe_actor(pm)
			return reflectionProbe ~= nil
		end,
		nextSlide = "reflection_probe_placement",
		autoContinue = true,
	})

	elTut:RegisterSlide("reflection_probe_placement", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight("window_primary_viewport", true)

			slide:AddGenericMessageBox()

			local reflectionProbe = find_reflection_probe_actor(pm)
			if reflectionProbe ~= nil then
				local actorEditor = pm:GetActorEditor()
				actorEditor:SelectActor(reflectionProbe, true)
			end
			local ent = (reflectionProbe ~= nil) and reflectionProbe:FindEntity() or nil
			if util.is_valid(ent) == false then
				return
			end
			slideData.locationMarker = slide:AddLocationMarker(TARGET_REFLECTION_PROBE_LOCATION)
			local toleranceDistance = 4.0

			local targetInfo = slide:AddViewportTarget(TARGET_REFLECTION_PROBE_LOCATION, function()
				local reflectionProbe = find_reflection_probe_actor(pm)
				local ent = (reflectionProbe ~= nil) and reflectionProbe:FindEntity() or nil
				return util.is_valid(ent) and ent:GetPos() or Vector()
			end, toleranceDistance)
			if util.is_valid(targetInfo.lineEntity) then
				targetInfo.lineEntity:SetColor(Color.Red)
			end
			slideData.targetInfo = targetInfo
		end,
		clearCondition = function(tutorialData, slideData, slide)
			if slideData.targetInfo == nil then
				return true
			end
			return slideData.targetInfo.isInRange()
		end,
		clear = function(tutorialData, slideData)
			util.remove(slideData.locationMarker)
		end,
		nextSlide = "reflection_probe_bake",
	})

	elTut:RegisterSlide("reflection_probe_bake", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR_UI_ID))
			local actor = find_reflection_probe_actor(pm)
			if actor ~= nil then
				local actorEditor = pm:GetActorEditor()
				local item = actorEditor:GetActorItem(actor)
				if util.is_valid(item) then
					item:Expand(true)
					local btPath = pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/property_controls/bake_reflection_probe"
					slide:AddHighlight(gui.PFMActorEditor.COLLECTION_BAKING .. "/header")
					slide:AddHighlight(tostring(actor:GetUniqueId()) .. "/header")
					slide:AddHighlight(tostring(actor:GetUniqueId()) .. "/reflection_probe/header")
					slide:AddHighlight("property_controls/bake_reflection_probe")

					slide:AddHighlight(btPath, true)

					local cb
					slideData.initBakeCallback = function()
						if util.is_valid(cb) then
							return
						end
						local btBakeReflectionProbe = slide:FindElementByPath(btPath, false)
						if btBakeReflectionProbe ~= nil then
							cb = btBakeReflectionProbe:AddCallback("OnPressed", function()
								util.remove(cb)
								slideData.bakingReflectionProbe = true
							end)
							slideData.onBakeReflectionProbe = cb
						end
					end
				end
			end

			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData)
			util.remove(slideData.onBakeReflectionProbe)
		end,
		clearCondition = function(tutorialData, slideData)
			slideData.initBakeCallback()
			return slideData.bakingReflectionProbe or false
		end,
		autoContinue = true,
		nextSlide = "reflection_probe_baking",
	})

	elTut:RegisterSlide("reflection_probe_baking", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight("info_bar/icon_container", true)

			local probeActor = find_reflection_probe_actor(pm)
			if probeActor ~= nil then
				local actorEditor = pm:GetActorEditor()
				local item = actorEditor:GetActorItem(probeActor)
				if util.is_valid(item) then
					item:Expand(true)
					local btBakeProbe = slide:FindElementByPath(
						pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/property_controls/bake_reflection_probe"
					)
					local cb
					cb = btBakeProbe:GetBaker():AddCallback("OnBakingCompleted", function()
						util.remove(cb)
						slideData.bakingCompleted = true
					end)
					slideData.onBakingCompletedCb = cb
				end
			end
			slideData.bakingCompleted = false

			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData)
			util.remove(slideData.onBakingCompletedCb)
		end,
		clearCondition = function(tutorialData, slideData)
			return slideData.bakingCompleted
		end,
		nextSlide = "reflection_probe_view",
	})

	elTut:RegisterSlide("reflection_probe_view", {
		init = function(tutorialData, slideData, slide)
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "reflection_probe_dynamic_actors",
	})

	elTut:RegisterSlide("reflection_probe_dynamic_actors", {
		init = function(tutorialData, slideData, slide)
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddHighlight(slide:FindElementByPath("contents"))
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "conclusion",
	})

	elTut:RegisterSlide("conclusion", {
		init = function(tutorialData, slideData, slide)
			slide:SetTutorialCompleted()
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "next_tutorial",
	})

	elTut:RegisterSlide("next_tutorial", {
		init = function(tutorialData, slideData, slide)
			pm:LoadTutorial("animating/animation_basics")
		end,
	})

	elTut:StartSlide("intro")
end)
