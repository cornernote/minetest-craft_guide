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
	craft_guide.log("registered craft for - "..itemstack:get_name())
	if craft_guide.crafts[itemstack:get_name()]==nil then
		craft_guide.crafts[itemstack:get_name()] = {}
	end
	table.insert(craft_guide.crafts[itemstack:get_name()],options)
end


-- set_craft_guide_formspec
craft_guide.set_craft_guide_formspec = function(meta, start_i, pagenum, recipenum)
	pagenum = math.floor(pagenum)
	local pagemax = math.floor((craft_guide.craft_guide_size-1) / (5*14) + 1)
	meta:set_string("formspec",
		"size[14,10;]"..
		"label[0,0;--== Learn to Craft ==--]"..
		"label[0,0.4;Drag an item to the Output box]"..
		"label[9,0.2;page "..tostring(pagenum).." of "..tostring(pagemax).."]"..
		"button[11,0;1.5,1;craft_guide_prev;<<]"..
		"button[12.5,0;1.5,1;craft_guide_next;>>]"..
		"list[detached:craft_guide;main;0,1;14,5;"..tostring(start_i).."]"..
		"label[0,6.5;Output]"..
		"list[current_name;output;0,7;1,1;]"..
		"label[0.3,8.6;recipe "..tostring(recipenum).."]"..
		"button[0,9;2,1;alternate;Alternate]"..
		"label[2,6.5;Inventory Craft]"..
		"list[current_name;build;2,7;3,3;]"..
		"label[6,6.5;Cook]"..
		"list[current_name;cook;6,7;1,1;]"..
		"label[6,8.5;Fuel]"..
		"list[current_name;fuel;6,9;1,1;]"..
		"label[8,6.5;Bookmarks]"..
		"list[current_name;bookmark;8,7;6,3;]"..
		"label[12,6.5;Bin ->]"..
		"list[current_name;bin;13,6;1,1;]")
	local inv = meta:get_inventory()
	inv:set_size("output", 1)
	inv:set_size("build", 3*3)
	inv:set_size("cook", 1)
	inv:set_size("fuel", 1)
	inv:set_size("bookmark", 6*3)
	inv:set_size("bin", 1)
end


-- on_construct
craft_guide.on_construct = function(pos)
	craft_guide.set_craft_guide_formspec(minetest.env:get_meta(pos), 0, 1, 1)
end


-- on_receive_fields
craft_guide.on_receive_fields = function(pos, formname, fields, player)
	local meta = minetest.env:get_meta(pos);
	local formspec = meta:get_string("formspec")
	local start_i = string.match(formspec, "list%[detached:craft_guide;main;[%d.]+,[%d.]+;[%d.]+,[%d.]+;(%d+)%]")
	local alternate_i = string.match(formspec, "label%[[%d.]+,[%d.]+;recipe (%d+)%]")

	-- get an alternate recipe
	local stack = meta:get_inventory():get_stack("output",1)
	local crafts = craft_guide.crafts[stack:get_name()]
	if crafts ~= nil then
		alternate_i = tonumber(alternate_i) or 1
		if fields.alternate then
			alternate_i = alternate_i+1
		end
		if alternate_i > #crafts then
			alternate_i = 1
		end
		craft_guide.update_recipe(meta, player, stack, alternate_i)
	end

	-- Figure out current page from formspec
	start_i = tonumber(start_i) or 0

	if fields.craft_guide_prev then
		start_i = start_i - 5*14
	end
	if fields.craft_guide_next then
		start_i = start_i + 5*14
	end

	if start_i < 0 then
		start_i = start_i + 5*14
	end
	if start_i >= craft_guide.craft_guide_size then
		start_i = start_i - 5*14
	end
		
	if start_i < 0 or start_i >= craft_guide.craft_guide_size then
		start_i = 0
	end

	craft_guide.set_craft_guide_formspec(meta, start_i, start_i / (5*14) + 1, alternate_i)
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
		return
	end
	if alternate < 1 or alternate > #crafts then
		alternate = 1
	end
	local craft = crafts[alternate]
	
	-- show me the unknown items
	craft_guide.log(dump(craft))
	minetest.chat_send_player(player:get_player_name(), "recipe for "..stack:get_name()..": "..dump(craft))
	
	local itemstack = ItemStack(craft.output)
	inv:set_stack("output", 1, itemstack)

	-- cook
	if craft.type == "cooking" then
		inv:set_stack("cook", 1, craft.recipe)
		return
	end
	-- fuel
	if craft.type == "fuel" then
		inv:set_stack("fuel", 1, craft.recipe)
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
	if from_list == to_list then
		return count
	end

	local meta = minetest.env:get_meta(pos)
	if to_list == "bin" then
		meta:get_inventory():set_stack(from_list,from_index,nil)
	end
	if to_list == "output" or to_list == "bookmark" then
		meta:get_inventory():set_stack(to_list, to_index, inv:get_stack(from_list, from_index))
	end
	if to_list == "output" then
		craft_guide.update_recipe(meta, player, stack)
	end
	if from_list == "output" then
		craft_guide.update_recipe(meta, player)
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
