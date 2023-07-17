--[[
    Copyright (C) 2023 Silverlan

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
]]

include("/pfm/pfm_core_tutorials.lua")

local uuidActor = "717ee26d-7a84-4302-a333-639ca8d63589"
local uuidChair = "83481110-e6d6-416d-80fc-a6b4f55d2aba"

local function setup_layout(slide)
	slide:GoToWindow("actor_editor")
	slide:SetMinWindowFrameDividerFraction(pfm.WINDOW_ACTOR_EDITOR, 0.3)
end

local function get_fog_controller(pm)
	local actorEditor = pm:GetActorEditor()
	local filmClip = util.is_valid(actorEditor) and actorEditor:GetFilmClip() or nil
	if filmClip == nil then
		return true
	end
	local actors = filmClip:GetActorList()
	for _, actor in ipairs(actors) do
		if actor:FindComponent("fog_controller") ~= nil then
			return actor
		end
	end
end

gui.Tutorial.register_tutorial("actor_editor", "tutorials/interface/actor_editor", function(elTut, pm)
	elTut:RegisterSlide("intro", {
		init = function(tutorialData, slideData, slide)
			setup_layout(slide)

			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR_UI_ID))
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "scenegraph",
	})

	elTut:RegisterSlide("scenegraph", {
		init = function(tutorialData, slideData, slide)
			local actorEditor = tool.get_filmmaker():GetActorEditor()

			slide:AddHighlight(actorEditor:GetTree())
			slide:AddGenericMessageBox()
		end,
		nextSlide = "collection",
	})

	-- TODO: Mention that you can move all objects in a collection by selecting the collection and then
	-- using the transform manipulator controls
	elTut:RegisterSlide("collection", {
		init = function(tutorialData, slideData, slide)
			local actorEditor = tool.get_filmmaker():GetActorEditor()

			slide:SetFocusElement(actorEditor:GetTree())

			for _, type in ipairs(gui.PFMActorEditor.COLLECTION_TYPES) do
				local col, item = actorEditor:FindCollection(type, false)
				if util.is_valid(item) then
					item:Expand()
					slide:AddHighlight(item:GetHeader())
				end
			end

			slide:AddGenericMessageBox()
		end,
		nextSlide = "actor",
	})

	elTut:RegisterSlide("actor", {
		init = function(tutorialData, slideData, slide)
			setup_layout(slide)

			local actorEditor = tool.get_filmmaker():GetActorEditor()

			for ent, c in ents.citerator(ents.COMPONENT_PFM_ACTOR) do
				local actorData = c:GetActorData()

				local item = actorEditor:GetActorItem(actorData)
				if util.is_valid(item) then
					slide:AddHighlight(item:GetHeader())
				end
			end

			slide:SetFocusElement(actorEditor:GetTree())
			slide:AddGenericMessageBox()
		end,
		nextSlide = "components",
	})

	elTut:RegisterSlide("components", {
		init = function(tutorialData, slideData, slide)
			setup_layout(slide)
			local ent = ents.find_by_uuid(uuidActor)
			local actorC = ent:GetComponent(ents.COMPONENT_PFM_ACTOR)
			local actorEditor = tool.get_filmmaker():GetActorEditor()
			local item = actorEditor:GetActorItem(actorC:GetActorData())
			item:Expand()

			slide:SetFocusElement(item)
			slide:AddHighlight(item:GetChildContainer())
			slide:AddGenericMessageBox()
		end,
		nextSlide = "component",
	})

	elTut:RegisterSlide("component", {
		init = function(tutorialData, slideData, slide)
			setup_layout(slide)
			local actorEditor = tool.get_filmmaker():GetActorEditor()
			local item = actorEditor:GetComponentEntry(uuidActor, "color")

			item:Expand()

			slide:SetFocusElement(item)
			slide:AddHighlight(item:GetChildContainer())
			slide:AddGenericMessageBox()
		end,
		clearCondition = function(tutorialData, slideData)
			local actorEditor = tool.get_filmmaker():GetActorEditor()
			local item = actorEditor:GetPropertyEntry(uuidActor, "color", "ec/color/color")
			return util.is_valid(item) == false or item:IsSelected()
		end,
		nextSlide = "property",
	})

	elTut:RegisterSlide("property", {
		init = function(tutorialData, slideData, slide)
			setup_layout(slide)

			local actorEditor = tool.get_filmmaker():GetActorEditor()
			local item = actorEditor.m_activeControls[uuidActor]["ec/color/color"].control

			slide:SetFocusElement(pm)
			slide:AddHighlight(item)

			slide:AddGenericMessageBox()
		end,
		clearCondition = function(tutorialData, slideData)
			local ent = ents.find_by_uuid(uuidActor)
			if ent == nil then
				return true
			end
			local color = ent:GetColor()
			local defaultColor = Color.White
			return color.r ~= defaultColor.r or color.g ~= defaultColor.g or color.b ~= defaultColor.b
		end,
		nextSlide = "new_component",
	})

	elTut:RegisterSlide("new_component", {
		init = function(tutorialData, slideData, slide)
			setup_layout(slide)
			local actorEditor = pm:GetActorEditor()
			local item = actorEditor:GetActorEntry(uuidChair)
			item:Expand()

			slide:SetFocusElement(item)
			slide:AddHighlight(slide:FindElementByPath(uuidChair .. "/header"))
			slide:AddHighlight(uuidChair .. "/header")
			slide:AddHighlight("context_menu/add_new_component")
			slide:AddHighlight("context_menu_add_new_component/color")
			-- TODO: Describe alt-key input mode
			-- TODO: Describe re-mapping slider range
			slide:AddGenericMessageBox()
		end,
		clearCondition = function(tutorialData, slideData)
			local actorEditor = tool.get_filmmaker():GetActorEditor()
			local item = actorEditor:GetComponentEntry(uuidChair, "color")
			return util.is_valid(item)
		end,
		nextSlide = "chair_color",
	})

	elTut:RegisterSlide("chair_color", {
		init = function(tutorialData, slideData, slide)
			setup_layout(slide)

			slide:SetFocusElement(slide:FindElementByPath("contents"))
			slide:AddHighlight(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. uuidChair .. "/header")
			slide:AddHighlight(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. uuidChair .. "/color/header")
			slide:AddHighlight(
				pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. uuidChair .. "/color/contents_wrapper/color/header"
			)

			slide:AddGenericMessageBox()
		end,
		clearCondition = function(tutorialData, slideData)
			local ent = ents.find_by_uuid(uuidChair)
			if ent == nil then
				return false
			end
			local col = ent:GetColor()
			return col.g > (math.max(col.r, col.b) + 100) and col.g > 200
		end,
		nextSlide = "custom_components",
	})

	elTut:RegisterSlide("custom_components", {
		init = function(tutorialData, slideData, slide)
			setup_layout(slide)

			slide:AddGenericMessageBox()
		end,
		nextSlide = "create_icon",
	})

	elTut:RegisterSlide("create_icon", {
		init = function(tutorialData, slideData, slide)
			setup_layout(slide)
			local ent = ents.find_by_uuid(uuidActor)
			local actorC = ent:GetComponent(ents.COMPONENT_PFM_ACTOR)
			local actorEditor = tool.get_filmmaker():GetActorEditor()

			slide:SetFocusElement(actorEditor)
			slide:AddHighlight(actorEditor:GetToolIconElement())
			slide:AddGenericMessageBox()
		end,
		clearCondition = function(tutorialData, slideData)
			local fogController = get_fog_controller(pm)
			return (fogController ~= nil)
		end,
		nextSlide = "fog_distance",
	})

	elTut:RegisterSlide("fog_distance", {
		init = function(tutorialData, slideData, slide)
			setup_layout(slide)

			local fogController = get_fog_controller(pm)
			if fogController ~= nil then
				local uuid = tostring(fogController:GetUniqueId())
				slide:SetFocusElement(slide:FindElementByPath("contents"))
				slide:AddHighlight(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. uuid .. "/header")
				slide:AddHighlight(pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. uuid .. "/fog_controller/header")
				slide:AddHighlight(
					pfm.WINDOW_ACTOR_EDITOR_UI_ID .. "/" .. uuid .. "/fog_controller/contents_wrapper/start/header"
				)
			end

			slideData.fogController = get_fog_controller(pm)

			slide:AddGenericMessageBox()
		end,
		clearCondition = function(tutorialData, slideData)
			if slideData.fogController == nil then
				return true
			end
			local fogControllerC = slideData.fogController:FindComponent("fog_controller")
			if fogControllerC == nil then
				return true
			end
			return fogControllerC:GetMemberValue("start") < 90.0
		end,
		nextSlide = "fog_distance_range",
	})

	elTut:RegisterSlide("fog_distance_range", {
		init = function(tutorialData, slideData, slide)
			setup_layout(slide)

			-- TODO: Describe alt-key input mode
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR_UI_ID))
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_ACTOR_EDITOR_UI_ID))

			slide:AddGenericMessageBox()
		end,
		nextSlide = "conclusion",
	})

	-- TODO: Explain what the icons in front of actors mean
	-- TODO: Explain additional icons, like math expressions and drivers? (or maybe cover that in those tutorials)

	elTut:RegisterSlide("conclusion", {
		init = function(tutorialData, slideData, slide)
			slide:SetTutorialCompleted()
			slide:AddGenericMessageBox()
		end,
		nextSlide = "viewport_next_tutorial",
	})

	elTut:RegisterSlide("viewport_next_tutorial", {
		init = function(tutorialData, slideData, slide)
			pm:LoadTutorial("interface/render") -- TODO: Which one is the next series? (lighting?)
		end,
	})

	-- TODO: Explain camera link?

	elTut:StartSlide("intro")
end)
