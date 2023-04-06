--[[
    Copyright (C) 2023 Silverlan

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
]]

include("/gui/pfm/tutorials/tutorial.lua")

local nextTutorial = "tutorials/interface/03_model_catalog"
local assetUrl = "https://sfmlab.com/project/28508/"
local assetPath = "lordaardvark/sfm/props/studio"

-- lua_exec_cl pfm/tutorials/interface/web_browser.lua

time.create_simple_timer(0.1,function() gui.Tutorial.start_tutorial("web_browser") end)


gui.Tutorial.register_tutorial("web_browser",function(elTut,pm)
	elTut:RegisterSlide("wb_intro",{
		init = function(slideData,slide)
			pm:GetCentralDivider():SetFraction(0.6)
			pm:OpenWindow("web_browser")
			pm:GoToWindow("web_browser")

			slide:AddHighlight(slide:FindElementByPath("web_browser"))
			slide:AddMessageBox(
				"This is the integrated web browser. You can use it to quickly look up information on the Pragma wiki, " ..
				"or to download and install custom assets.\n" ..
				"If you download any assets through this browser, Pragma will usually be able to automatically detect and install them."
			)
		end,
		nextSlide = "asset_download"
	})

	elTut:RegisterSlide("asset_download",{
		init = function(slideData,slide)
			slide:AddHighlight(slide:FindElementByPath("web_browser/enable_nsfw_content"))
			slide:AddMessageBox(
				"There are several preset bookmarks available, which offer a large amount of assets to download. " .. 
				"Since most of these websites contain NSFW content or ads, they are hidden by default.\n\n" ..
				"For the purpose of this tutorial we will download a simple SFW model, however the website may still contain NSFW advertisement.\n" ..
				"If that is a problem, please end the tutorial now, otherwise enable \"NSFW Content\" to continue."
			)
		end,
		clearCondition = function(slideData)
			local elWb = pm:GetWindow("web_browser")
			local browser = util.is_valid(elWb) and elWb:GetBrowser() or nil
			if(util.is_valid(browser) == false) then return true end
			return browser:IsNsfwContentEnabled()
		end,
		nextSlide = "asset_download_website"
	})

	elTut:RegisterSlide("asset_download_website",{
		init = function(slideData,slide)
			slide:AddHighlight(slide:FindElementByPath("web_browser/bookmark"))
			slide:AddMessageBox(
				"Select \"SFM Lab\" from the bookmark list to continue."
			)
		end,
		clearCondition = function(slideData)
			local elWb = pm:GetWindow("web_browser")
			local browser = util.is_valid(elWb) and elWb:GetBrowser() or nil
			if(util.is_valid(browser) == false) then return true end
			return browser:GetUrl():find("sfmlab.com") ~= nil
		end,
		nextSlide = "sfm_lab",
		autoContinue = true
	})
	elTut:RegisterSlide("sfm_lab",{
		init = function(slideData,slide)
			slide:AddHighlight(slide:FindElementByPath("web_browser/browser"))
			slide:AddMessageBox("Side note: To change the category in the search filter option on SFM Lab, scroll down and click the \"Category\" drop-down menu and use the up/down arrow keys.")
		
			local vp = tool.get_filmmaker():GetViewport()
			if(util.is_valid(vp)) then vp:SetManipulatorMode(gui.PFMViewport.MANIPULATOR_MODE_SELECT) end
		end,
		nextSlide = "sfm_lab_prop"
	})

	elTut:RegisterSlide("sfm_lab_prop",{
		init = function(slideData,slide)
			slide:AddHighlight(slide:FindElementByPath("web_browser/browser"))
			slide:AddMessageBox(
				"For this tutorial we will download this film-studio prop pack by LordAardvark.\n" ..
				"Scroll down to the green download button and click it. Then select a free server in the popup and start the download."
			)

			local elWb = pm:GetWindow("web_browser")
			local browser = util.is_valid(elWb) and elWb:GetBrowser() or nil
			if(util.is_valid(browser) == false) then return end
			browser:SetUrl(assetUrl)
			slideData.cbOnDownloadStarted = browser:AddCallback("OnDownloadStarted",function(elWb,id,state,percentage)
				slideData.downloadStarted = true
				util.remove(slideData.cbOnDownloadStarted)
			end)
		end,
		clear = function(slideData)
			util.remove(slideData.cbOnDownloadStarted)
		end,
		clearCondition = function(slideData)
			return slideData.downloadStarted
		end,
		nextSlide = "sfm_lab_prop_dl",
		autoContinue = true
	})

	elTut:RegisterSlide("sfm_lab_prop_dl",{
		init = function(slideData,slide)
			slide:AddHighlight(slide:FindElementByPath("web_browser/log"))
			slide:AddMessageBox(
				"The tutorial will continue once the download has completed. You can check the download progress in the log window."
			)

			local elWb = pm:GetWindow("web_browser")
			local browser = util.is_valid(elWb) and elWb:GetBrowser() or nil
			if(util.is_valid(browser) == false) then return end
			slideData.cbOnDownloadComplete = browser:AddCallback("OnDownloadAssetsImported",function(elWb)
				slideData.downloadComplete = true
				util.remove(slideData.cbOnDownloadComplete)
			end)
		end,
		clear = function(slideData)
			util.remove(slideData.cbOnDownloadComplete)
		end,
		clearCondition = function(slideData)
			return slideData.downloadComplete
		end,
		nextSlide = "sfm_lab_prop_explorer",
		autoContinue = true
	})

	elTut:RegisterSlide("sfm_lab_prop_explorer",{
		init = function(slideData,slide)
			pm:OpenWindow("model_catalog")
			pm:GoToWindow("model_catalog")

			local elMe = pm:GetWindow("model_catalog")
			local explorer = util.is_valid(elMe) and elMe:GetExplorer() or nil
			if(util.is_valid(explorer)) then
				explorer:SetPath(assetPath)
			end
			
			slide:AddHighlight(slide:FindElementByPath("model_catalog"))
			slide:AddMessageBox(
				"The download is complete and the assets have been automatically extracted, imported and converted " .. 
				"and can now be found in the model explorer.\n" ..
				"Please note that the automatic installation may not work for all assets, especially .rar-archives may cause issues.\n" ..
				"In that case you will have to install the assets manually. You can find more information on how to do that in the tutorial " ..
				"for the model explorer."
			)
		end,
		nextSlide = "wb_fin"
	})

	elTut:RegisterSlide("wb_fin",{
		init = function(slideData,slide)
			slide:AddMessageBox(
				"This concludes the tutorial on the web browser.\n\n" ..
				"You can now end the tutorial, or press the continue-button to start the next tutorial in this series."
			)
		end,
		clear = function(slideData)

		end,
		nextSlide = "wb_next_tutorial"
	})

	elTut:RegisterSlide("wb_next_tutorial",{
		init = function(slideData,slide)
			pm:LoadProject("projects/" .. nextTutorial)
		end
	})

	elTut:StartSlide("wb_intro")
	--_elTut:AddHighlight(gui.find_element_by_index(1177))
	--_elTut:AddMessageBox("This is the viewport where you can do stuff. AAA BBB CCC DDD")
end)
