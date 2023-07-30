--[[
    Copyright (C) 2023 Silverlan

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
]]

include("/pfm/pfm_core_tutorials.lua")

gui.Tutorial.register_tutorial("asset_catalogues", "tutorials/interface/asset_catalogues", function(elTut, pm)
	elTut:RegisterSlide("intro", {
		init = function(tutorialData, slideData, slide)
			slide:OpenWindow("model_catalog")
			slide:SetMinWindowFrameDividerFraction("model_catalog", 0.5)
			slide:SetFocusElement(slide:FindElementByPath("editor_frame/tab_button_container"))
			slide:AddHighlight(slide:FindElementByPath("model_catalog_tab_button"))
			slide:AddGenericMessageBox()

			-- Only auto-continue if model catalog is not already open
			slideData.autoContinue = not pm:IsWindowActive("model_catalog")
		end,
		clear = function(tutorialData, slideData) end,
		clearCondition = function(tutorialData, slideData)
			return pm:IsWindowActive("model_catalog")
		end,
		nextSlide = "overview",
	})

	elTut:RegisterSlide("overview", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("model_catalog")
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID))
			--slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID .. "/show_external_assets"))
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		clearCondition = function(tutorialData, slideData)
			local window = pm:GetWindow("model_catalog")
			local explorer = util.is_valid(window) and window:GetExplorer() or nil
			if util.is_valid(explorer) == false then
				return true
			end
			return explorer:GetPath() == "pfm/demo/"
		end,
		nextSlide = "overview_external_placeholder",
	})

	elTut:RegisterSlide("overview_external_placeholder", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("model_catalog")
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID))
			local _, elOutline = slide:AddHighlight(
				slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID .. "/models_pfm_demo_plant.glb")
			)
			slide:AddHighlight("context_menu/import_asset")
			slide:SetArrowTarget(elOutline)
			slide:AddGenericMessageBox()
		end,
		clearCondition = function(tutorialData, slideData)
			return asset.exists("pfm/demo/plant", asset.TYPE_MODEL)
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "overview_external_placeholder2",
	})

	elTut:RegisterSlide("overview_external_placeholder2", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("model_catalog")
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID))
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID))
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "smart_filter",
	})

	elTut:RegisterSlide("smart_filter", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("model_catalog")
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID .. "/filter"))
			slide:AddGenericMessageBox()
			slideData.elFilter = slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID .. "/filter")
			local target = util.is_valid(slideData.elFilter) and slideData.elFilter:GetTarget() or nil
			slideData.autoContinue = not (util.is_valid(target) and target:GetText():lower() == "chair")

			local window = pm:GetWindow("model_catalog")
			local explorer = util.is_valid(window) and window:GetExplorer() or nil
			if util.is_valid(explorer) then
				explorer:SetPath("")
				explorer:Update()
			end
		end,
		clear = function(tutorialData, slideData) end,
		clearCondition = function(tutorialData, slideData, slide)
			if util.is_valid(slideData.elFilter) == false then
				return true
			end
			local target = slideData.elFilter:GetTarget()
			if util.is_valid(target) == false then
				return true
			end
			return target:GetText():lower() == "chair" and not slideData.elFilter:IsInEditMode()
		end,
		nextSlide = "smart_filter2",
	})

	elTut:RegisterSlide("smart_filter2", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("model_catalog")
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID .. "/scroll_container"))
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "drag_and_drop",
	})

	elTut:RegisterSlide("drag_and_drop", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("model_catalog", 0.3)
			slide:GoToWindow("primary_viewport", 0.5)
			slide:SetFocusElement(slide:FindElementByPath("contents"))
			slide:AddHighlight(
				slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID .. "/models_props_living_room_armchair")
			)
			-- TODO: Mention holding shift- or alt-key to change placing behavior
			slide:AddGenericMessageBox()
			local gameView = pm:GetGameView()
			local projectC = util.is_valid(gameView) and gameView:GetComponent(ents.COMPONENT_PFM_PROJECT) or nil
			if projectC ~= nil then
				slideData.cbOnActorCreated = projectC:AddEventCallback(
					ents.PFMProject.EVENT_ON_ACTOR_CREATED,
					function(actorC)
						if actorC:GetEntity():GetModelName() == "props/living_room/armchair" then
							slideData.actorWasCreated = true
						end
					end
				)
			else
				slideData.actorWasCreated = true
			end
		end,
		clear = function(tutorialData, slideData)
			util.remove(slideData.cbOnActorCreated)
		end,
		clearCondition = function(tutorialData, slideData, slide)
			return slideData.actorWasCreated == true
		end,
		nextSlide = "context_menu",
	})

	elTut:RegisterSlide("context_menu", {
		init = function(tutorialData, slideData, slide)
			tool.get_filmmaker():GoToWindow("model_catalog")
			slide:AddHighlight(
				slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID .. "/models_props_living_room_armchair")
			)
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "favorites",
	})

	elTut:RegisterSlide("favorites", {
		init = function(tutorialData, slideData, slide)
			tool.get_filmmaker():GoToWindow("model_catalog")
			local _, elOutline = slide:AddHighlight(
				slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID .. "/models_props_living_room_armchair")
			)
			slide:AddHighlight("context_menu/add_to_favorites")
			slide:SetArrowTarget(elOutline)

			slide:AddGenericMessageBox()
		end,
		clearCondition = function(tutorialData, slideData, slide)
			local window = slide:GoToWindow("model_catalog")
			local explorer = util.is_valid(window) and window:GetExplorer() or nil
			if util.is_valid(explorer) == false then
				return true
			end
			return explorer:IsInFavorites("props/living_room/armchair")
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "pack_model",
	})

	elTut:RegisterSlide("pack_model", {
		init = function(tutorialData, slideData, slide)
			tool.get_filmmaker():GoToWindow("model_catalog")
			local _, elOutline = slide:AddHighlight(
				slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID .. "/models_props_living_room_armchair")
			)
			slide:AddHighlight("context_menu/pack_model")
			slide:SetArrowTarget(elOutline)

			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "export_asset",
	})

	elTut:RegisterSlide("export_asset", {
		init = function(tutorialData, slideData, slide)
			tool.get_filmmaker():GoToWindow("model_catalog")
			local _, elOutline = slide:AddHighlight(
				slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID .. "/models_props_living_room_armchair")
			)
			slide:AddHighlight("context_menu/export_asset")
			slide:SetArrowTarget(elOutline)
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "asset_icons",
	})

	elTut:RegisterSlide("asset_icons", {
		init = function(tutorialData, slideData, slide)
			tool.get_filmmaker():GoToWindow("model_catalog")
			slide:AddHighlight(
				slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID .. "/models_props_living_room_armchair")
			)
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "map_import",
	})

	elTut:RegisterSlide("map_import", {
		init = function(tutorialData, slideData, slide)
			local window = slide:GoToWindow("model_catalog")
			local teFilter = util.is_valid(window) and window:GetFilterElement() or nil
			if util.is_valid(teFilter) then
				teFilter:SetText("")
			end
			local explorer = util.is_valid(window) and window:GetExplorer() or nil
			if util.is_valid(explorer) then
				explorer:SetPath("")
				explorer:Update()
			end

			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID))
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID .. "/models_maps"))
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "conclusion",
	})

	elTut:RegisterSlide("conclusion", {
		init = function(tutorialData, slideData, slide)
			slide:SetTutorialCompleted()

			slide:SetFocusElement(slide:FindElementByPath("editor_frame/tab_button_container"))
			local _, elOutline = slide:AddHighlight(slide:FindElementByPath("editor_frame/panel_add_button"))
			slide:AddHighlight("context_menu/material_catalog")
			slide:AddHighlight("context_menu/model_catalog")
			slide:AddHighlight("context_menu/particle_catalog")
			slide:SetArrowTarget(elOutline)
			slide:AddGenericMessageBox()
		end,
		clear = function(tutorialData, slideData) end,
		nextSlide = "next_tutorial",
	})

	elTut:RegisterSlide("next_tutorial", {
		init = function(tutorialData, slideData, slide)
			pm:LoadTutorial("interface/actor_editor")
		end,
	})
	elTut:StartSlide("intro")
end)
