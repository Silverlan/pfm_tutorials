--[[
    Copyright (C) 2023 Silverlan

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
]]

include("/pfm/pfm_core_tutorials.lua")

local nextTutorial = "tutorials/interface/03_model_catalog"
local assetUrl = "https://sfmlab.com/project/28508/"
local assetPath = "lordaardvark/sfm/props/studio"

gui.Tutorial.register_tutorial("web_browser", "tutorials/interface/web_browser", function(elTut, pm)
	elTut:RegisterSlide("intro", {
		init = function(tutorialData, slideData, slide)
			slide:GoToWindow("web_browser")
			slide:SetWindowFrameDividerFraction(pfm.WINDOW_WEB_BROWSER, 0.666, false)

			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_WEB_BROWSER_UI_ID))
			slide:AddGenericMessageBox()
		end,
		nextSlide = "asset_download",
	})

	-- TODO: Add segment on how to navigate PFM wiki before getting into asset downloads
	elTut:RegisterSlide("asset_download", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_WEB_BROWSER_UI_ID .. "/enable_nsfw_content"))
			slide:AddGenericMessageBox()
		end,
		clearCondition = function(tutorialData, slideData)
			local elWb = pm:GetWindow("web_browser")
			local browser = util.is_valid(elWb) and elWb:GetBrowser() or nil
			if util.is_valid(browser) == false then
				return true
			end
			return browser:IsNsfwContentEnabled()
		end,
		nextSlide = "asset_download_website",
	})

	elTut:RegisterSlide("asset_download_website", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_WEB_BROWSER_UI_ID .. "/bookmark"))
			slide:AddHighlight("sfm_lab")
			slide:AddGenericMessageBox()
		end,
		clearCondition = function(tutorialData, slideData)
			local elWb = pm:GetWindow("web_browser")
			local browser = util.is_valid(elWb) and elWb:GetBrowser() or nil
			if util.is_valid(browser) == false then
				return true
			end
			return browser:GetUrl():find("sfmlab.com") ~= nil
		end,
		nextSlide = "sfm_lab",
		autoContinue = true,
	})
	elTut:RegisterSlide("sfm_lab", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_WEB_BROWSER_UI_ID .. "/browser"))
			slide:AddGenericMessageBox()

			local vp = tool.get_filmmaker():GetViewport()
			if util.is_valid(vp) then
				vp:SetManipulatorMode(gui.PFMViewport.MANIPULATOR_MODE_SELECT)
			end
		end,
		nextSlide = "sfm_lab_prop",
	})

	elTut:RegisterSlide("sfm_lab_prop", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_WEB_BROWSER_UI_ID .. "/browser"))
			slide:AddGenericMessageBox()

			local elWb = pm:GetWindow("web_browser")
			local browser = util.is_valid(elWb) and elWb:GetBrowser() or nil
			if util.is_valid(browser) == false then
				return
			end
			browser:SetUrl(assetUrl)
			slideData.cbOnDownloadStarted = browser:AddCallback(
				"OnDownloadStarted",
				function(elWb, id, state, percentage)
					slideData.downloadStarted = true
					util.remove(slideData.cbOnDownloadStarted)
				end
			)
		end,
		clear = function(slideData)
			util.remove(slideData.cbOnDownloadStarted)
		end,
		clearCondition = function(tutorialData, slideData)
			return slideData.downloadStarted
		end,
		nextSlide = "sfm_lab_prop_dl",
		autoContinue = true,
	})

	elTut:RegisterSlide("sfm_lab_prop_dl", {
		init = function(tutorialData, slideData, slide)
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_WEB_BROWSER_UI_ID .. "/log"))
			slide:AddGenericMessageBox()

			local elWb = pm:GetWindow("web_browser")
			local browser = util.is_valid(elWb) and elWb:GetBrowser() or nil
			if util.is_valid(browser) == false then
				return
			end
			slideData.cbOnDownloadComplete = browser:AddCallback("OnDownloadAssetsImported", function(elWb)
				slideData.downloadComplete = true
				util.remove(slideData.cbOnDownloadComplete)
			end)
		end,
		clear = function(slideData)
			util.remove(slideData.cbOnDownloadComplete)
		end,
		clearCondition = function(tutorialData, slideData)
			return slideData.downloadComplete
		end,
		nextSlide = "sfm_lab_prop_explorer",
		autoContinue = true,
	})

	elTut:RegisterSlide("sfm_lab_prop_explorer", {
		init = function(tutorialData, slideData, slide)
			pm:OpenWindow("model_catalog")
			pm:GoToWindow("model_catalog")

			local elMe = pm:GetWindow("model_catalog")
			local explorer = util.is_valid(elMe) and elMe:GetExplorer() or nil
			if util.is_valid(explorer) then
				explorer:SetPath(assetPath)
				explorer:Update()
			end

			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_MODEL_CATALOG_UI_ID))
			slide:AddGenericMessageBox()
		end,
		nextSlide = "fin",
	})

	elTut:RegisterSlide("fin", {
		init = function(tutorialData, slideData, slide)
			slide:SetTutorialCompleted()
			slide:AddGenericMessageBox()
		end,
		clear = function(slideData) end,
		nextSlide = "next_tutorial",
	})

	elTut:RegisterSlide("next_tutorial", {
		init = function(tutorialData, slideData, slide)
			time.create_simple_timer(0.0, function()
				pm:LoadTutorial("interface/actor_editor")
			end)
		end,
	})

	elTut:StartSlide("intro")
end)
