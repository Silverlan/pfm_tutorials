--[[
    Copyright (C) 2023 Silverlan

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
]]

include("/gui/pfm/tutorials/tutorial.lua")

local uuidActor = "3e78882c-d8eb-423c-8a57-757f0158a7c6"

-- lua_exec_cl pfm/tutorials/interface/actor_editor.lua

time.create_simple_timer(0.1,function() gui.Tutorial.start_tutorial("actor_editor") end)

-- TUTORIAL FORMAT:
-- Explain basics
-- Create new light source
-- Explain tree
-- Edit light source color / radius, etc

local function setup_layout(pm)
	pm:GoToWindow("actor_editor")
	pm:GetCentralDivider():SetFraction(0.3)
	pm:GetActorEditor():GetCentralDivider():SetFraction(0.65)
end

gui.Tutorial.register_tutorial("actor_editor",function(elTut,pm)
	elTut:RegisterSlide("intro",{
		init = function(slideData,slide)
			setup_layout(pm)
			-- TODO: Select "Selection Move"
			slide:AddHighlight(slide:FindElementByPath("actor_editor"))
			slide:AddMessageBox("This is the actor editor. Here you can manage the actors in the current film clip and change actor properties.")
		end,
		clear = function(slideData)

		end,
		nextSlide = "ae_scenegraph"
	})

	elTut:RegisterSlide("ae_scenegraph",{
		init = function(slideData,slide)
			local actorEditor = tool.get_filmmaker():GetActorEditor()

			slide:AddHighlight(actorEditor:GetTree())
			slide:AddMessageBox("The most important part of the actor editor is the scene graph, where all of the actors are listed in a tree structure.")
			print(item)
		end,
		nextSlide = "ae_collection"
	})

	elTut:RegisterSlide("ae_collection",{
		init = function(slideData,slide)
			local actorEditor = tool.get_filmmaker():GetActorEditor()

			slide:SetFocusElement(actorEditor:GetTree())

			for _,type in ipairs(gui.PFMActorEditor.COLLECTION_TYPES) do
				local col,item = actorEditor:FindCollection(type,false)
				if(util.is_valid(item)) then
					item:Expand()
					slide:AddHighlight(item:GetHeader())
				end
			end

			slide:AddMessageBox(
				"These are collections, which work like categories. Every collection can contain actors and/or other collections. " ..
				"You can rename a collection, or create a child-collection, by right-clicking it.\n\n" ..
				"If you select a collection in the actor editor, you can also move all of the objects within that collection by " ..
				"using the transform gizmo in the viewport window."
			)
			print(item)
		end,
		nextSlide = "ae_actor"
	})

	elTut:RegisterSlide("ae_actor",{
		init = function(slideData,slide)
			setup_layout(pm)

			local actorEditor = tool.get_filmmaker():GetActorEditor()

			for ent,c in ents.citerator(ents.COMPONENT_PFM_ACTOR) do
				local actorData = c:GetActorData()

				local item = actorEditor:GetActorItem(actorData)
				if(util.is_valid(item)) then
					slide:AddHighlight(item:GetHeader())
				end
			end

			slide:SetFocusElement(actorEditor:GetTree())
			slide:AddMessageBox("These are actors. An actor can be anything from a light source to a prop or the sky. Depending on the context, actors may also be referred to as \"entities\" or \"game objects\".")
		end,
		nextSlide = "ae_components"
	})

	elTut:RegisterSlide("ae_components",{
		init = function(slideData,slide)
			setup_layout(pm)
			local ent = ents.find_by_uuid(uuidActor)
			local actorC = ent:GetComponent(ents.COMPONENT_PFM_ACTOR)
			local actorEditor = tool.get_filmmaker():GetActorEditor()
			local item = actorEditor:GetActorItem(actorC:GetActorData())
			item:Expand()

			slide:SetFocusElement(item)
			slide:AddHighlight(item:GetChildContainer())
			slide:AddMessageBox("Every actor is made up of components, which define the behavior of the actor. For instance, a camera is just a normal actor with a \"camera\" component attached to it. If you were to remove the component, it would no longer be a camera.\nYou can add new components by right-clicking an actor.\n\nCustom components created using the Lua API will also appear here.")
		end,
		nextSlide = "ae_component"
	})

	elTut:RegisterSlide("ae_component",{
		init = function(slideData,slide)
			setup_layout(pm)
			local ent = ents.find_by_uuid(uuidActor)
			local actorC = ent:GetComponent(ents.COMPONENT_PFM_ACTOR)
			local actorEditor = tool.get_filmmaker():GetActorEditor()
			local item = actorEditor:GetComponentEntry(uuidActor,"camera")

			item:Expand()

			slide:SetFocusElement(item)
			slide:AddHighlight(item:GetChildContainer())
			slide:AddMessageBox("Most components have properties, which can be changed to affect its behavior. You can edit a property by clicking on it.\nClick on the \"Field of View\" property to continue.")
		end,
		clearCondition = function(slideData)
			local actorEditor = tool.get_filmmaker():GetActorEditor()
			local item = actorEditor:GetPropertyEntry(uuidActor,"camera","ec/camera/fov")
			return util.is_valid(item) == false or item:IsSelected()
		end,
		nextSlide = "ae_property"
	})

	elTut:RegisterSlide("ae_property",{
		init = function(slideData,slide)
			setup_layout(pm)
			local ent = ents.find_by_uuid(uuidActor)
			local actorC = ent:GetComponent(ents.COMPONENT_PFM_ACTOR)
			local actorEditor = tool.get_filmmaker():GetActorEditor()
			local item = actorEditor.m_activeControls[uuidActor]["ec/camera/fov"].control--actorEditor:GetComponentEntry(uuidActor,"pfm_actor")

			slide:SetFocusElement(item)
			slide:AddHighlight(item)
			-- TODO: Describe alt-key input mode
			-- TODO: Describe re-mapping slider range
			slide:AddMessageBox("This is the current value for the property you have selected. You can click it to change its value. Depending on the type of property, you may get a different input field (e.g. a text input or a slider).\nMost properties can also be animated, with some exceptions (such as text-based properties).")
		end,
		nextSlide = "ae_create_icon"
	})

	-- TODO: Switch to regular camera

	elTut:RegisterSlide("ae_create_icon",{
		init = function(slideData,slide)
			setup_layout(pm)
			local ent = ents.find_by_uuid(uuidActor)
			local actorC = ent:GetComponent(ents.COMPONENT_PFM_ACTOR)
			local actorEditor = tool.get_filmmaker():GetActorEditor()

			slide:SetFocusElement(actorEditor)
			slide:AddHighlight(actorEditor:GetToolIconElement())
			slide:AddMessageBox("You can create new actors by clicking this icon. You can create new cameras, light sources, etc. here.\nIf you want to create a prop or character, it is usually best to create them through the \"Model Catalog\" instead (see the respective tutorial for more information).\nTo continue this tutorial, create a spot-light actor.")
		end,
		nextSlide = "ae_property_value"
	})

	-- TODO: Edit position, color, radius
	-- TODO: Move using camera

	--[[elTut:RegisterSlide("ae_property_value",{
		init = function(slideData,slide)
			tool.get_filmmaker():GetCentralDivider():SetFraction(0.3)
			tool.get_filmmaker():GetActorEditor():GetCentralDivider():SetFraction(0.5)

			local ent = ents.find_by_uuid(uuidActor)
			local actorC = ent:GetComponent(ents.COMPONENT_PFM_ACTOR)
			local actorEditor = tool.get_filmmaker():GetActorEditor()
			local item = actorEditor:GetComponentEntry(uuidActor,"pfm_actor")
			slide:SetFocusElement(item)

			local ent = ents.find_by_uuid(uuidActor)
			local actorC = ent:GetComponent(ents.COMPONENT_PFM_ACTOR)
			local actorEditor = tool.get_filmmaker():GetActorEditor()
			local item = actorEditor:GetPropertyEntry(uuidActor,"pfm_actor","ec/pfm_actor/position")
			item = slide:FindElementByPath("math_expr",item)

			slide:AddHighlight(item)
			slide:AddMessageBox("Math Expr!")
		end,
		nextSlide = "viewport_interaction2"
	})]]

	-- manip_controls
	-- pfm_primary_viewport/manip_select
	-- pfm_primary_viewport/manip_move
	-- pfm_primary_viewport/manip_rotate
	-- pfm_primary_viewport/manip_screen

	-- pc_first_frame
	-- pc_prev_clip
	-- pc_prev_frame
	-- pc_record
	-- pc_player
	-- pc_next_frame
	-- pc_next_clip
	-- pc_last_frame

	-- cc_controls
	-- cc_camera
	-- cc_options

	-- vp_settings

	elTut:RegisterSlide("actor_editor",{
		init = function(slideData,slide)
			slide:AddHighlight(slide:FindElementByPath("pfm_primary_viewport/pc_prev_frame"))
			slide:AddMessageBox("This is the aaae you can do stuff. AAA BBB CCC DDD")
		end,
		clear = function(slideData)

		end,
		nextSlide = "aaa"
	})
	elTut:RegisterSlide("aaa",{
		init = function(slideData,slide)
			slide:AddHighlight(slide:FindElementByPath("pfm_primary_viewport/vp_settings"))
			slide:AddMessageBox("This is the aaae you can do stuff. AAA BBB CCC DDD")
		end,
		clear = function(slideData)

		end
	})

	elTut:StartSlide("intro")
	--_elTut:AddHighlight(gui.find_element_by_index(1177))
	--_elTut:AddMessageBox("This is the viewport where you can do stuff. AAA BBB CCC DDD")
end)
