--[[

Craft Guide for Minetest

Copyright (c) 2012 cornernote, Brett O'Donnell <cornernote@gmail.com>
Source Code: https://github.com/cornernote/minetest-craft_guide
License: GPLv3

CRAFT GUIDE API

]]--



-- expose object to other modules
craft_guide = {}


-- define api variables
craft_guide.crafts = {}
craft_guide.craft_guide_size = 0


-- log
craft_guide.log = function(message)
	--if not craft_guide.DEBUG then return end
	minetest.log("action", "[CraftGuide] "..message)
end


-- register_craft
craft_guide.register_craft = function(options)
	if  options.output == nil then
		return
	end
	local itemstack = ItemStack(options.output)
	if itemstack:is_empty() then
		return
	end
	--craft_guide.log("registered craft for - "..itemstack:get_name())
	if craft_guide.crafts[itemstack:get_name()]==nil then
		craft_guide.crafts[itemstack:get_name()] = {}
	end
	table.insert(craft_guide.crafts[itemstack:get_name()],options)
end


-- get_craft_guide_formspec
craft_guide.get_craft_guide_formspec = function(meta, page, alternate)
	if page == nil then 
		page = craft_guide.get_current_page(meta) 
	end
	if alternate == nil then 
		alternate = craft_guide.get_current_alternate(meta) 
	end
	local start = (page-1) * (5*14) + 1
	local pages = math.floor((craft_guide.craft_guide_size-1) / (5*14) + 1)
	local alternates = 0
	local stack = meta:get_inventory():get_stack("output",1)
	local crafts = craft_guide.crafts[stack:get_name()]
	if crafts ~= nil then
		alternates = #crafts
	end
	local formspec = "size[14,10;]"
		.."label[0,5;--== Learn to Craft ==--]"
		.."label[0,5.4;Drag any item to the Output box to see the]"
		.."label[0,5.8;craft. Save your favorite items in Bookmarks.]"
		.."label[9,5.2;page "..tostring(page).." of "..tostring(pages).."]"
		.."button[11,5;1.5,1;craft_guide_prev;<<]"
		.."button[12.5,5;1.5,1;craft_guide_next;>>]"
		.."list[detached:craft_guide;main;0,0;14,5;"..tostring(start).."]"
		.."label[0,6.5;Output]"
		.."list[current_name;output;0,7;1,1;]"
		.."label[2,6.5;Inventory Craft]"
		.."list[current_name;build;2,7;3,3;]"
		.."label[6,6.5;Cook]"
		.."list[current_name;cook;6,7;1,1;]"
		.."label[6,8.5;Fuel]"
		.."list[current_name;fuel;6,9;1,1;]"
		.."label[8,6.5;Bookmarks]"
		.."list[current_name;bookmark;8,7;6,3;]"
		.."label[12,6.1;Bin ->]"
		.."list[current_name;bin;13,6;1,1;]"
	if alternates > 1 then
		formspec = formspec
			.."label[0,8.6;recipe "..tostring(alternate).." of "..tostring(alternates).."]"
			.."button[0,9;2,1;alternate;Alternate]"
	end
	return formspec
end


-- on_construct
craft_guide.on_construct = function(pos)
	local meta = minetest.env:get_meta(pos)
	local inv = meta:get_inventory()
	inv:set_size("output", 1)
	inv:set_size("build", 3*3)
	inv:set_size("cook", 1)
	inv:set_size("fuel", 1)
	inv:set_size("bookmark", 6*3)
	inv:set_size("bin", 1)
	meta:set_string("formspec",craft_guide.get_craft_guide_formspec(meta))
end


-- on_receive_fields
craft_guide.on_receive_fields = function(pos, formname, fields, player)
	local meta = minetest.env:get_meta(pos);

	local stack = meta:get_inventory():get_stack("output",1)
	local crafts = craft_guide.crafts[stack:get_name()]
	local alternate = craft_guide.get_current_alternate(meta)
	local alternates = 0
	if crafts ~= nil then
		alternates = #crafts
	end

	local page = craft_guide.get_current_page(meta)
	local pages = math.floor((craft_guide.craft_guide_size-1) / (5*14) + 1)

	-- get an alternate recipe
	if fields.alternate then
		alternate = alternate+1
		craft_guide.update_recipe(meta, player, stack, alternate)
	end
	if alternate > alternates then
		alternate = 1
	end

	-- change page
	if fields.craft_guide_prev then
		page = page - 1
	end
	if fields.craft_guide_next then
		page = page + 1
	end
	if page < 1 then
		page = 1
	end
	if page > pages then
		page = pages
	end

	-- update the formspec
	meta:set_string("formspec",craft_guide.get_craft_guide_formspec(meta, page, alternate))
end


-- get_current_page
craft_guide.get_current_page = function(meta)
	local formspec = meta:get_string("formspec")
	local page = string.match(formspec, "label%[[%d.]+,[%d.]+;page (%d+) of [%d.]+%]")
	page = tonumber(page) or 1
	return page
end


-- get_current_alternate
craft_guide.get_current_alternate = function(meta)
	local formspec = meta:get_string("formspec")
	local alternate = string.match(formspec, "label%[[%d.]+,[%d.]+;recipe (%d+) of [%d.]+%]")
	alternate = tonumber(alternate) or 1
	return alternate
end


-- update_recipe
craft_guide.update_recipe = function(meta, player, stack, alternate)
	local inv = meta:get_inventory()
	for i=0,inv:get_size("build"),1 do
		inv:set_stack("build", i, nil)
	end
	inv:set_stack("cook", 1, nil)
	inv:set_stack("fuel", 1, nil)

	if stack==nil then return end
	inv:set_stack("output", 1, stack:get_name())

	alternate = tonumber(alternate) or 1
	craft_guide.log(player:get_player_name().." requests recipe "..alternate.." for "..stack:get_name())
	local crafts = craft_guide.crafts[stack:get_name()]
	
	if crafts == nil then
		minetest.chat_send_player(player:get_player_name(), "no recipe available for "..stack:get_name())
		meta:set_string("formspec",craft_guide.get_craft_guide_formspec(meta))
		return
	end
	if alternate < 1 or alternate > #crafts then
		alternate = 1
	end
	local craft = crafts[alternate]
	
	-- show me the unknown items
	craft_guide.log(dump(craft))
	--minetest.chat_send_player(player:get_player_name(), "recipe for "..stack:get_name()..": "..dump(craft))
	
	local itemstack = ItemStack(craft.output)
	inv:set_stack("output", 1, itemstack)

	-- cook
	if craft.type == "cooking" then
		inv:set_stack("cook", 1, craft.recipe)
		meta:set_string("formspec",craft_guide.get_craft_guide_formspec(meta))
		return
	end
	-- fuel
	if craft.type == "fuel" then
		inv:set_stack("fuel", 1, craft.recipe)
		meta:set_string("formspec",craft_guide.get_craft_guide_formspec(meta))
		return
	end
	-- build (shaped or shapeless)
	if craft.recipe[1] then
		if (type(craft.recipe[1]) == "string") then
			inv:set_stack("build", 1, craft.recipe[1])
		else
			if craft.recipe[1][1] then
				inv:set_stack("build", 1, craft.recipe[1][1])
			end
			if craft.recipe[1][2] then
				inv:set_stack("build", 2, craft.recipe[1][2])
			end
			if craft.recipe[1][3] then
				inv:set_stack("build", 3, craft.recipe[1][3])
			end
		end
	end
	if craft.recipe[2] then
		if (type(craft.recipe[2]) == "string") then
			inv:set_stack("build", 2, craft.recipe[2])
		else
			if craft.recipe[2][1] then
				inv:set_stack("build", 4, craft.recipe[2][1])
			end
			if craft.recipe[2][2] then
				inv:set_stack("build", 5, craft.recipe[2][2])
			end
			if craft.recipe[2][3] then
				inv:set_stack("build", 6, craft.recipe[2][3])
			end
		end
	end
	if craft.recipe[3] then
		if (type(craft.recipe[3]) == "string") then
			inv:set_stack("build", 3, craft.recipe[3])
		else
			if craft.recipe[3][1] then
				inv:set_stack("build", 7, craft.recipe[3][1])
			end
			if craft.recipe[3][2] then
				inv:set_stack("build", 8, craft.recipe[3][2])
			end
			if craft.recipe[3][3] then
				inv:set_stack("build", 9, craft.recipe[3][3])
			end
		end
	end
	if craft.recipe[4] then
		if (type(craft.recipe[4]) == "string") then
			inv:set_stack("build", 4, craft.recipe[4])
		end
	end
	if craft.recipe[5] then
		if (type(craft.recipe[5]) == "string") then
			inv:set_stack("build", 5, craft.recipe[5])
		end
	end
	if craft.recipe[6] then
		if (type(craft.recipe[6]) == "string") then
			inv:set_stack("build", 6, craft.recipe[6])
		end
	end
	if craft.recipe[7] then
		if (type(craft.recipe[7]) == "string") then
			inv:set_stack("build", 7, craft.recipe[7])
		end
	end
	if craft.recipe[8] then
		if (type(craft.recipe[8]) == "string") then
			inv:set_stack("build", 8, craft.recipe[8])
		end
	end
	if craft.recipe[9] then
		if (type(craft.recipe[9]) == "string") then
			inv:set_stack("build", 9, craft.recipe[9])
		end
	end
	meta:set_string("formspec",craft_guide.get_craft_guide_formspec(meta))
end


-- create_detached_inventory
craft_guide.create_detached_inventory = function()
	local inv = minetest.create_detached_inventory("craft_guide", {
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			return 0
		end,
		allow_put = function(inv, listname, index, stack, player)
			return -1
		end,
		allow_take = function(inv, listname, index, stack, player)
			return 0
		end,
		on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
		end,
		on_put = function(inv, listname, index, stack, player)
		end,
		on_take = function(inv, listname, index, stack, player)
		end,
	})
	
	local craft_guide_list = {}
	for name,def in pairs(minetest.registered_items) do
		-- local craft_recipe = minetest.get_craft_recipe(name);
		-- if craft_recipe.items ~= nil then
		local craft = craft_guide.crafts[name];
		if craft ~= nil then
			if (not def.groups.not_in_craft_guide or def.groups.not_in_craft_guide == 0)
					--and (not def.groups.not_in_creative_inventory or def.groups.not_in_creative_inventory == 0)
					and def.description and def.description ~= "" then
				table.insert(craft_guide_list, name)
			end
		end
	end

	table.sort(craft_guide_list)
	inv:set_size("main", #craft_guide_list)
	for _,itemstring in ipairs(craft_guide_list) do
		inv:add_item("main", ItemStack(itemstring))
	end
	craft_guide.craft_guide_size = #craft_guide_list
	craft_guide.log("craft_guide_size: "..dump(craft_guide.craft_guide_size))
end


-- allow_metadata_inventory_move
craft_guide.allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.env:get_meta(pos)
	local inv = meta:get_inventory()
	if from_list == "bookmarks" and to_list == "bookmarks"  then
		return count
	end
	if to_list == "bin" and from_list == "output" then
		inv:set_stack(from_list,from_index,nil)
		craft_guide.update_recipe(meta, player, inv:get_stack(from_list, from_index))
	end
	if to_list == "bin" and from_list == "bookmark" then
		inv:set_stack(from_list,from_index,nil)
	end
	if to_list == "bookmark" then
		inv:set_stack(to_list, to_index, inv:get_stack(from_list, from_index):get_name())
	end
	if to_list == "output" then
		craft_guide.update_recipe(meta, player, inv:get_stack(from_list, from_index))
	end
	return 0
end


-- allow_metadata_inventory_put
craft_guide.allow_metadata_inventory_put = function(pos, listname, index, stack, player)
	if listname == "bookmark" then
		minetest.env:get_meta(pos):get_inventory():set_stack(listname,index,stack)
	end
	if listname == "output" then
		local meta = minetest.env:get_meta(pos)
		craft_guide.update_recipe(meta, player, stack)
	end
	return 0
end


-- allow_metadata_inventory_take
craft_guide.allow_metadata_inventory_take = function(pos, listname, index, stack, player)
	return 0
end
