--[[
    Copyright (C) 2023 Silverlan

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
]]

include("/pfm/pfm_core_tutorials.lua")

-- lua_exec_cl pfm/tutorials/interface/render.lua

time.create_simple_timer(0.1, function()
	gui.Tutorial.start_tutorial("render")
end)

gui.Tutorial.register_tutorial("render", function(elTut, pm)
	elTut:RegisterSlide("render", {
		init = function(slideData, slide)
			tool.get_filmmaker():GoToWindow("render")
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_RENDER_UI_ID))
			slide:AddMessageBox(
				"Welcome to the render tutorial. This tutorial will show you how to render images and animations in the render panel."
			)
		end,
		clear = function(slideData) end,
		nextSlide = "1",
	})

	elTut:RegisterSlide("1", {
		init = function(slideData, slide)
			tool.get_filmmaker():GoToWindow("render")
			slide:AddHighlight(slide:FindElementByPath(pfm.WINDOW_RENDER_UI_ID))
			slide:AddMessageBox(
				"This is the render panel. It is split into two sections:\n"
					.. "To the left is the render preview, which is initially black because nothing has been rendered yet.\n"
					.. "On the right you can find various controls, which allow you to change the renderer, the render resolution, etc."
			)
		end,
		clear = function(slideData) end,
		nextSlide = "2",
	})

	elTut:RegisterSlide("2", {
		init = function(slideData, slide)
			tool.get_filmmaker():GoToWindow("render")
			slide:AddHighlight(slide:FindElementByPath("window_render/render_engine"))
			slide:AddMessageBox(
				"By default there are two render engines available: Pragma and Cycles X.\n"
					.. "The Pragma render engine simply uses Pragma's own renderer for the image. The overall render quality will be lower "
					.. "compared to Cycles X, but rendering will be significantly faster. Pragma is recommended if you're planning on rendering animations.\n\n"
					.. "Cycles X is a path tracing renderer, which can be used to create highly realistic images at the cost of very slow render times.\n"
					.. "This renderer is usually a good option if you want to render a single still image.\n\n"
					.. "For this demonstration we will be using the Cycles X renderer. Switch to it to continue."
			)
		end,
		clear = function(slideData) end,
		nextSlide = "viewport_interaction1",
	})

	elTut:RegisterSlide("3", {
		init = function(slideData, slide)
			tool.get_filmmaker():GoToWindow("render")
			slide:AddHighlight({
				slide:FindElementByPath("window_render/bt_render_preview"),
				slide:FindElementByPath("window_render/bt_render_image"),
			})
			slide:AddMessageBox(
				"You can use these buttons to render the image.\n"
					.. "Rendering a preview will create a low-resolution image, which will not get saved to disk.\n"
					.. "It's fast to render and should give you a good approximation of what the final render will look like.\n\n"
					.. '"Render Image" will generate the full-resolution image. Depending on the project, your hardware and the render settings, '
					.. "this can take several minutes or more.\n\n"
					.. "Try rendering the full-resolution image now. Please note that Pragma may appear frozen for a bit if this is the first render for this project session."
			)

			slideData.renderStarted = false
			local elWindowRender = slide:FindElementByPath("window_render")
			if util.is_valid(elWindowRender) then
				slideData.elRenderWindow = elWindowRender
				slideData.cbOnRenderImage = elWindowRender:AddCallback(
					"OnRenderImage",
					function(el, preview, prepareOnly)
						if preview ~= true and prepareOnly ~= true then
							util.remove(slideData.cbOnRenderImage)
							slideData.renderStarted = true
						end
					end
				)
			end
		end,
		clearCondition = function(slideData)
			if util.is_valid(slideData.elRenderWindow) == false then
				return true
			end
			return slideData.renderStarted
		end,
		clear = function(slideData)
			util.remove(slideData.cbOnRenderImage)
		end,
		autoContinue = true,
		nextSlide = "4",
	})

	elTut:RegisterSlide("4", {
		init = function(slideData, slide)
			tool.get_filmmaker():GoToWindow("render")
			slide:SetFocusElement(pm)
			slide:AddHighlight(slide:FindElementByPath("info_bar/icon_container"))
			slide:AddMessageBox(
				"When rendering using an offline renderer like Cycles X, you can view the render progress down here.\n"
					.. "During a render, PFM may react slowly to inputs. This is because PFM's FPS is intentionally lowered "
					.. "to open up additional GPU cycles for the renderer.\n\n"
					.. "Please wait for the render to complete before continuing."
			)

			slideData.renderCompleted = false
			local elWindowRender = slide:FindElementByPath("window_render")
			if util.is_valid(elWindowRender) then
				slideData.elRenderWindow = elWindowRender
				slideData.cbOnRenderComplete = elWindowRender:AddCallback(
					"OnRenderComplete",
					function(el, preview, prepareOnly)
						slideData.renderCompleted = true
					end
				)
			end
		end,
		clearCondition = function(slideData)
			if util.is_valid(slideData.elRenderWindow) == false then
				return true
			end
			return slideData.renderCompleted
		end,
		clear = function(slideData)
			util.remove(slideData.cbOnRenderComplete)
		end,
		nextSlide = "5",
	})

	elTut:RegisterSlide("5", {
		init = function(slideData, slide)
			tool.get_filmmaker():GoToWindow("render")
			slide:AddHighlight(slide:FindElementByPath("window_render/bt_open_output_dir"))
			slide:AddMessageBox(
				"The image is automatically saved to the disk. You can press this button to reveal it in the file explorer."
			)
		end,
		nextSlide = "6",
	})

	elTut:RegisterSlide("6", {
		init = function(slideData, slide)
			tool.get_filmmaker():GoToWindow("render")
			slide:AddHighlight(slide:FindElementByPath("window_render/bt_create_render_job"))
			slide:AddMessageBox(
				'Alternatively to rendering within PFM, you can also create a "Render Job". This will create a render file, which can be used '
					.. "to render the image without having to keep PFM running.\n"
					.. "In some cases this can be significantly faster compared to rendering within PFM, because it allows the renderer to use "
					.. "all available GPU resources, some of which would otherwise be taken up by PFM.\n\n"
					.. "Try creating a render job now."
			)

			slideData.renderJobCreated = false
			local elWindowRender = slide:FindElementByPath("window_render")
			if util.is_valid(elWindowRender) then
				slideData.elRenderWindow = elWindowRender
				slideData.cbOnRenderImage = elWindowRender:AddCallback(
					"OnRenderImage",
					function(el, preview, prepareOnly)
						if prepareOnly == true then
							util.remove(slideData.cbOnRenderImage)
							slideData.renderJobCreated = true
						end
					end
				)
			end
		end,
		clearCondition = function(slideData)
			if util.is_valid(slideData.elRenderWindow) == false then
				return true
			end
			return slideData.renderJobCreated
		end,
		clear = function(slideData)
			util.remove(slideData.cbOnRenderImage)
		end,
		autoContinue = true,
		nextSlide = "7",
	})

	elTut:RegisterSlide("7", {
		init = function(slideData, slide)
			tool.get_filmmaker():GoToWindow("render")
			slide:AddHighlight(slide:FindElementByPath("window_render/bt_open_output_dir"))
			local renderFileName = "render"
			if os.SYSTEM_WINDOWS then
				renderFileName = renderFileName .. ".bat"
			else
				renderFileName = renderFileName .. ".sh"
			end
			slide:AddMessageBox(
				'A file explorer window should now have appeared, which contains a "'
					.. renderFileName
					.. '". '
					.. "Executing this file will start the render process, and the image will be saved in the same directory once complete.\n"
					.. "You can also create a render job for a sequence of images, in which case it will render them all one after another.\n\n"
					.. "Render jobs are only available for offline renderers like Cycles X, and cannot be used for the Pragma renderer."
			)
		end,
		nextSlide = "8",
	})

	elTut:RegisterSlide("8", {
		init = function(slideData, slide)
			tool.get_filmmaker():GoToWindow("render")
			slide:AddHighlight({
				slide:FindElementByPath("window_render/preset"),
				slide:FindElementByPath("window_render/render_engine"),
			})
			slide:AddMessageBox(
				"You can also use PFM to render other image types, such as equirectangular images for VR.\n\n"
					.. 'Change the preset to "VR" and the render engine to "Pragma" to continue.'
			)
		end,
		nextSlide = "9",
	})

	elTut:RegisterSlide("9", {
		init = function(slideData, slide)
			tool.get_filmmaker():GoToWindow("render")
			slide:AddHighlight(slide:FindElementByPath("window_render/bt_render_image"))
			slide:AddMessageBox(
				'Now press the "Render Image" button to start the render. To get the full VR experience '
					.. "the scene will have to be rendered twice, once for the left eye and once for the right eye.\n"
					.. "The resulting image will then be stitched together into one equirectangular image."
			)

			slideData.renderStarted = false
			local elWindowRender = slide:FindElementByPath("window_render")
			if util.is_valid(elWindowRender) then
				slideData.elRenderWindow = elWindowRender
				slideData.cbOnRenderImage = elWindowRender:AddCallback(
					"OnRenderImage",
					function(el, preview, prepareOnly)
						if preview ~= true and prepareOnly ~= true then
							util.remove(slideData.cbOnRenderImage)
							slideData.renderStarted = true
						end
					end
				)
			end
		end,
		clearCondition = function(slideData)
			if util.is_valid(slideData.elRenderWindow) == false then
				return true
			end
			return slideData.renderStarted
		end,
		clear = function(slideData)
			util.remove(slideData.cbOnRenderImage)
		end,
		autoContinue = true,
		nextSlide = "10",
	})

	elTut:RegisterSlide("10", {
		init = function(slideData, slide)
			tool.get_filmmaker():GoToWindow("render")
			slide:AddHighlight(slide:FindElementByPath("window_render/render_viewport"))
			slide:AddMessageBox(
				"You can click and drag the left mouse button in the rendered image to "
					.. "look around as a 360 degree view."
			)
		end,
		nextSlide = "11",
	})

	elTut:RegisterSlide("11", {
		init = function(slideData, slide)
			tool.get_filmmaker():GoToWindow("render")
			slide:SetFocusElement(slide:FindElementByPath(pfm.WINDOW_PRIMARY_VIEWPORT_UI_ID))
			slide:AddHighlight(slide:FindElementByPath("window_render/preview_mode"))
			slide:AddMessageBox(
				'You can toggle between the left and right eye view for the preview viewport, or select "Flat" '
					.. "to view the actual image."
			)
		end,
		nextSlide = "12",
	})

	elTut:RegisterSlide("12", {
		init = function(slideData, slide)
			slide:AddMessageBox(
				"PFM can only render image sequences, so you will still need a video editing software capable of generating VR videos."
			)
		end,
		nextSlide = "13",
	})

	elTut:RegisterSlide("13", {
		init = function(slideData, slide)
			slide:AddMessageBox(
				"This concludes the tutorial on the render panel.\n\n"
					.. "You can now end the tutorial, or press the continue-button to start the next tutorial in this series."
			)
		end,
		nextSlide = "viewport_next_tutorial",
	})
	elTut:StartSlide("10")

	elTut:RegisterSlide("viewport_next_tutorial", {
		init = function(slideData, slide)
			pm:LoadTutorial("interface/render")
		end,
	})

	--elTut:StartSlide("viewport_fin")
end)
