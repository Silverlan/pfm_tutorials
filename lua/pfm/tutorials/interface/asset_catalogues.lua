--[[
    Copyright (C) 2023 Silverlan

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
]]

include("/pfm/pfm_core_tutorials.lua")

gui.Tutorial.register_tutorial("asset_catalogues", function(elTut, pm)
	elTut:RegisterSlide("welcome", {
		init = function(slideData, slide)
			slide:OpenWindow("model_catalog")
			slide:SetMinWindowFrameDividerFraction("model_catalog", 0.5)
			slide:SetFocusElement(slide:FindElementByPath("editor_frame/tab_button_container"))
			slide:AddHighlight(slide:FindElementByPath("model_catalog_tab_button"))
			slide:AddMessageBox(
				"Welcome to the asset catalog tutorial. Asset catalogs (or explorers) list all of the available assets installed "
					.. "in Pragma, such as models, materials or particle effects. Each of these asset types has a separate catalog, but "
					.. "for the sake of this tutorial we will focus on the model catalog.\n\n"
					.. 'Open the "Model Catalog" to continue.'
			)

			-- Only auto-continue if model catalog is not already open
			slideData.autoContinue = not pm:IsWindowActive("model_catalog")
		end,
		clear = function(slideData) end,
		clearCondition = function(slideData)
			return pm:IsWindowActive("model_catalog")
		end,
		nextSlide = "overview",
	})

	elTut:RegisterSlide("overview", {
		init = function(slideData, slide)
			slide:GoToWindow("model_catalog")
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID))
			--slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID .. "/show_external_assets"))
			slide:AddMessageBox(
				"Here you can find the model catalog. The catalog lists all "
					.. "of the installed models that can be used in your project.\n"
					.. "Models (and other asset types) are distinguished between native and external assets. "
					.. "Native assets are assets that already exist in Pragma's own format and can be used immediately.\n\n"
					.. "External assets are, for example, assets that were detected in installed Source Engine games, which have to be "
					.. "imported first. The import process is fully automatic, however external assets will show as a "
					.. "placeholder icon until they are imported. Once imported, they also count as native assets.\n\n"
					.. 'If you only want native assets shown in the catalog, you can disable the "Show external assets" option at the top.'
			)
		end,
		clear = function(slideData) end,
		nextSlide = "external_assets",
	})

	elTut:RegisterSlide("external_assets", {
		init = function(slideData, slide)
			slide:GoToWindow("model_catalog")
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID))
			--slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID .. "/show_external_assets"))
			slide:AddMessageBox(
				'You can import an external asset by right-clicking it and selecting "Import asset", or you can right-click '
					.. 'the empty space between assets and select "Import all assets". This will import all of the external assets in the current directory, '
					.. "which may require some time (and disk space).\n"
					.. "Otherwise external assets are automatically imported whenever they are used for the first time."
			)
		end,
		clear = function(slideData) end,
		nextSlide = "smart_filter",
	})

	elTut:RegisterSlide("smart_filter", {
		init = function(slideData, slide)
			slide:GoToWindow("model_catalog")
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID .. "/filter"))
			slide:AddMessageBox(
				"You can use the smart filter to search for specific assets. The name does not have to be an exact match.\n\n"
					.. 'Try typing "chair" into the filter field and press enter to continue.'
			)
			slideData.elFilter = slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID .. "/filter")
			local target = util.is_valid(slideData.elFilter) and slideData.elFilter:GetTarget() or nil
			slideData.autoContinue = not (util.is_valid(target) and target:GetText():lower() == "chair")
		end,
		clear = function(slideData) end,
		clearCondition = function(slideData, slide)
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
		init = function(slideData, slide)
			slide:GoToWindow("model_catalog")
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID .. "/scroll_container"))
			slide:AddMessageBox(
				"The filter looks through all available assets in all directories and lists the best matches in order, starting at the top."
			)
		end,
		clear = function(slideData) end,
		nextSlide = "drag_and_drop",
	})

	elTut:RegisterSlide("drag_and_drop", {
		init = function(slideData, slide)
			slide:GoToWindow("model_catalog", 0.3)
			slide:GoToWindow("primary_viewport", 0.5)
			slide:SetFocusElement(slide:FindElementByPath("contents"))
			slide:AddHighlight(
				slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID .. "/models_props_living_room_armchair")
			)
			slide:AddMessageBox(
				"To place a model in your scene, you can simply drag-and-drop it from the catalog into the viewport to the right.\n\n"
					.. "Try placing this chair somewhere in your scene."
			)
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
		clear = function(slideData)
			util.remove(slideData.cbOnActorCreated)
		end,
		clearCondition = function(slideData, slide)
			return slideData.actorWasCreated == true
		end,
		nextSlide = "context_menu",
	})

	elTut:RegisterSlide("context_menu", {
		init = function(slideData, slide)
			tool.get_filmmaker():GoToWindow("model_catalog")
			slide:AddHighlight(
				slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID .. "/models_props_living_room_armchair")
			)
			slide:AddMessageBox(
				"There are also various actions you can perform on a model by right-clicking it in the catalog, or "
					.. "in the viewport.\n"
					.. "You can get more information for each option through the tooltip by hovering over it, but "
					.. "we'll go through some of the more important ones here."
			)
		end,
		clear = function(slideData) end,
		nextSlide = "favorites",
	})

	elTut:RegisterSlide("favorites", {
		init = function(slideData, slide)
			tool.get_filmmaker():GoToWindow("model_catalog")
			slide:AddHighlight(
				slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID .. "/models_props_living_room_armchair")
			)
			slide:AddMessageBox(
				"If you plan on using a model frequently, you can add it to your favorites by selecting "
					.. '"Add to favorites", after which it will appear in the "Favorites" directory in the catalog.'
			)
		end,
		clear = function(slideData) end,
		nextSlide = "pack_model",
	})

	elTut:RegisterSlide("pack_model", {
		init = function(slideData, slide)
			tool.get_filmmaker():GoToWindow("model_catalog")
			slide:AddHighlight(
				slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID .. "/models_props_living_room_armchair")
			)
			slide:AddMessageBox(
				'You can share a model with other people, by right-clicking it and selecting "Pack Model". '
					.. "This will create an archive with the model, as well as all materials and textures used by it. "
					.. "To install the model, the archive can then simply be extracted into the Pragma installation directory.\n\n"
					.. "Try packing the model now."
			)
		end,
		clear = function(slideData) end,
		nextSlide = "export_asset",
	})

	elTut:RegisterSlide("export_asset", {
		init = function(slideData, slide)
			tool.get_filmmaker():GoToWindow("model_catalog")
			slide:AddHighlight(
				slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID .. "/models_props_living_room_armchair")
			)
			slide:AddMessageBox(
				'Similarly, you can also export a model by selecting "Export asset". This will convert the model into the glTF format, '
					.. "which can be used to then import it in a modeling software such as Blender.\n\n"
					.. "Try exporting the model now."
			)
		end,
		clear = function(slideData) end,
		nextSlide = "asset_icons",
	})

	elTut:RegisterSlide("asset_icons", {
		init = function(slideData, slide)
			tool.get_filmmaker():GoToWindow("model_catalog")
			slide:AddHighlight(
				slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID .. "/models_props_living_room_armchair")
			)
			slide:AddMessageBox(
				"Asset icons are automatically generated, but in some cases the default perspective may not be ideal. "
					.. "You can change it by pressing (and holding) the right-mouse button while holding the alt-key and then "
					.. "moving around the mouse. This also allows you to quickly inspect a model from different perspectives without "
					.. "having to place it in the scene first."
			)
		end,
		clear = function(slideData) end,
		nextSlide = "map_import",
	})

	elTut:RegisterSlide("map_import", {
		init = function(slideData, slide)
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
			slide:AddMessageBox(
				"If you import a map (e.g. from the Source Engine), a model will also be generated for the map's world geometry. \n"
					.. 'These models can be found within the "maps" directory in the map catalog and can be used just like any other '
					.. "model. This allows you to use the geometry of multiple maps within the same PFM project."
			)
		end,
		clear = function(slideData) end,
		nextSlide = "misc_catalogs",
	})

	elTut:RegisterSlide("misc_catalogs", {
		init = function(slideData, slide)
			slide:AddMessageBox(
				"Contrary to the model catalog, the other catalog windows are not open by default. You can find the other catalogs "
					.. 'for other asset types under "View" -> "Windows" in the menu bar.'
			)
		end,
		clear = function(slideData) end,
		nextSlide = "conclusion",
	})

	elTut:RegisterSlide("conclusion", {
		init = function(slideData, slide)
			slide:AddMessageBox(
				"This concludes the tutorial on the asset catalogs.\n\n"
					.. "You can now end the tutorial, or press the continue-button to start the next tutorial in this series."
			)
		end,
		clear = function(slideData) end,
		nextSlide = "next_tutorial",
	})

	elTut:RegisterSlide("next_tutorial", {
		init = function(slideData, slide)
			pm:LoadTutorial("interface/actor_editor")
		end,
	})

	-- TODO: Import by drag-and-drop demo?

	elTut:StartSlide("welcome")
end)
