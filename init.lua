----------------------------------
-- Craft Guide for MineTest 0.4 --
-- Copyright 2012 by cornernote --
-- Lisence: GPL                 --
----------------------------------

local version = "0.1.1"

local craft_guide_inventory = {}

craft_guide_inventory.set_craft_guide_formspec = function(meta, start_i, pagenum)
	pagenum = math.floor(pagenum)
	local pagemax = math.floor((craft_guide_inventory.craft_guide_inventory_size-1) / (5*14) + 1)
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
		"label[2,6.5;Inventory Craft]"..
		"list[current_name;build;2,7;3,3;]"..
		"label[6,6.5;Cook]"..
		"list[current_name;cook;6,7;1,1;]"..
		"label[6,8.5;Fuel]"..
		"list[current_name;fuel;6,9;1,1;]"..
		"label[8,6.5;Bookmarks]"..
		"list[current_name;bookmark;8,7;6,3;]")
	local inv = meta:get_inventory()
	inv:set_size("output", 1)
	inv:set_size("build", 3*3)
	inv:set_size("cook", 1)
	inv:set_size("fuel", 1)
	inv:set_size("bookmark", 6*3)
end

craft_guide_inventory.on_receive_fields = function(pos, formname, fields, player)
	-- Figure out current page from formspec
	local current_page = 0
	local meta = minetest.env:get_meta(pos);
	local formspec = meta:get_string("formspec")
	local start_i = string.match(formspec, "list%[detached:craft_guide;main;[%d.]+,[%d.]+;[%d.]+,[%d.]+;(%d+)%]")
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
	if start_i >= craft_guide_inventory.craft_guide_inventory_size then
		start_i = start_i - 5*14
	end
		
	if start_i < 0 or start_i >= craft_guide_inventory.craft_guide_inventory_size then
		start_i = 0
	end

	craft_guide_inventory.set_craft_guide_formspec(meta, start_i, start_i / (5*14) + 1)
end



-- UPDATE RECIPE
craft_guide_inventory.update_recipe = function(meta, player, stack)
	minetest.log("action", "[craft_guide] "..player:get_player_name().." requests recipe for "..stack:get_name())

	-- clear out build items
	local inv = meta:get_inventory()
	for var=0,inv:get_size("build"),1 do
		inv:set_stack("build", var, nil)
	end
	inv:set_stack("cook", 1, nil)
	inv:set_stack("fuel", 1, nil)

	-- ensure we have a recipe
	local craft_recipe = minetest.get_craft_recipe(stack:get_name());
	if craft_recipe.items == nil then
		minetest.chat_send_player(player:get_player_name(), "no recipe available for "..stack:get_name())
		return
	end
	
	-- show me the unknown items
	print(dump(craft_recipe.items))
	--minetest.chat_send_player(player:get_player_name(), "recipe for "..stack:get_name()..": "..dump(craft_recipe.items))

	-- output with quantity
	local craft_result = minetest.get_craft_result(craft_recipe);
	local itemstack = ItemStack(craft_result.item)
	if itemstack:get_count() > 0 then
		inv:set_stack("output", 1, itemstack)
	else
		inv:set_stack("output", 1, stack)
	end

	-- cook
	if craft_recipe.type == "cooking" then
		inv:set_stack("cook", 1, craft_recipe.items['0'])
		return
	end
	-- fuel
	if craft_recipe.type == "fuel" then
		inv:set_stack("fuel", 1, craft_recipe.items['0'])
		return
	end
	-- build (shaped or shapeless)
	
	if craft_recipe.items['0'] then
		inv:set_stack("build", 1, craft_recipe.items['0'])
	end
	if craft_recipe.items['1'] then
		if craft_recipe.width == 1 then
			inv:set_stack("build", 4, craft_recipe.items['1'])
		else
			inv:set_stack("build", 2, craft_recipe.items['1'])
		end
	end
	if craft_recipe.items['2'] then
		if craft_recipe.width == 1 then
			inv:set_stack("build", 7, craft_recipe.items['2'])
		elseif craft_recipe.width == 2 then
			inv:set_stack("build", 4, craft_recipe.items['2'])
		else
			inv:set_stack("build", 3, craft_recipe.items['2'])
		end
	end
	if craft_recipe.items['3'] then
		if craft_recipe.width == 2 then
			inv:set_stack("build", 5, craft_recipe.items['3'])
		else
			inv:set_stack("build", 4, craft_recipe.items['3'])
		end
	end
	if craft_recipe.items['4'] then
		if craft_recipe.width == 2 then
			inv:set_stack("build", 7, craft_recipe.items['4'])
		else
			inv:set_stack("build", 5, craft_recipe.items['4'])
		end
	end
	if craft_recipe.items['5'] then
		if craft_recipe.width == 2 then
			inv:set_stack("build", 8, craft_recipe.items['5'])
		else
			inv:set_stack("build", 6, craft_recipe.items['5'])
		end
	end
	if craft_recipe.items['6'] then
		inv:set_stack("build", 7, craft_recipe.items['6'])
	end
	if craft_recipe.items['7'] then
		inv:set_stack("build", 8, craft_recipe.items['7'])
	end
	if craft_recipe.items['8'] then
		inv:set_stack("build", 9, craft_recipe.items['8'])
	end
end

-- REGISTER CRAFT SIGN NODE
minetest.register_node("craft_guide:sign_wall", {
	description = "Craft Sign",
	drawtype = "signlike",
	tiles = {"craft_guide_sign.png"},
	inventory_image = "craft_guide_sign.png",
	paramtype = 'light',
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	groups = {choppy=2,dig_immediate=2},
	sounds = default.node_sound_defaults(),
	selection_box = {
		type = "wallmounted",
	},
	on_construct = function(pos)
		craft_guide_inventory.set_craft_guide_formspec(minetest.env:get_meta(pos), 0, 1)
	end,
	on_receive_fields = craft_guide_inventory.on_receive_fields,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if from_list == to_list then
			return count
		end
		--print("allow_metadata_inventory_move to list: "..to_list)
		if to_list == "output" or to_list == "bookmark" then
			local meta = minetest.env:get_meta(pos)
			local inv = meta:get_inventory()
			local stack = inv:get_stack(from_list, from_index);
			inv:set_stack(to_list, to_index, stack)
			if to_list == "output" then
				craft_guide_inventory.update_recipe(meta, player, stack)
			end
		end
		return 0
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		--print("allow_metadata_inventory_put to list: "..listname)
		if listname == "bookmark" then
			return 1
		end
		if listname == "output" then
			local meta = minetest.env:get_meta(pos)
			if listname == "output" then
				craft_guide_inventory.update_recipe(meta, player, stack)
				return 0
			end
		end
		return 0
	end,
})

-- REGISTER CRAFT SIGN RECIPE
minetest.register_craft({
	output = 'craft_guide:sign_wall',
	recipe = {
		{'default:stick', 'default:stick'},
		{'default:stick', 'default:stick'},
		{'default:stick', ''},
	}
})

-- REGISTER CRAFT SIGN NODE
minetest.register_node("craft_guide:lcd_pc", {
	description = "Craft PC",
	drawtype = "nodebox",
	tiles = {
		"craft_guide_pc_grey.png",
		"craft_guide_pc_grey.png",
		"craft_guide_pc_grey.png",
		"craft_guide_pc_grey.png",
		"craft_guide_pc_black.png",
		"craft_guide_pc_screen.png",
	},
	paramtype = 'light',
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {type="regular"},
	groups = {choppy=2,dig_immediate=2},
	-- thanks cactuz_pl for the nodebox code!  =)
	node_box = {
        type = "fixed",
        fixed = {
            {-1.0000000e-1,-0.45259861,2.5136044e-2, 0.10000000,-2.5986075e-3,-2.4863956e-2},
            {-0.40006064,-0.25615262,-0.13023723, -0.37006064,0.26767738,-0.16023723},
            {0.37054221,-0.25615274,-0.13023723, 0.40054221,0.26767750,-0.16023723},
            {-0.40000000,-0.30600000,-0.13023723, 0.40000000,-0.25600000,-0.16023723},
            {-0.40000000,0.26433021,-0.12945597, 0.40000000,0.29433021,-0.15945597},
            {-0.35000000,-0.25514168,-2.9045502e-2, 0.35000000,0.24485832,-7.9045502e-2},
            {-0.40000000,-0.30617002,-8.0237234e-2, 0.40000000,0.29382998,-0.13023723},
            {-0.25000000,-0.50000000,0.25000000, 0.25000000,-0.45000000,-0.25000000}
        },
    },
	sounds = default.node_sound_defaults(),
	on_construct = function(pos)
		craft_guide_inventory.set_craft_guide_formspec(minetest.env:get_meta(pos), 0, 1)
	end,
	on_receive_fields = craft_guide_inventory.on_receive_fields,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if from_list == to_list then
			return count
		end
		--print("allow_metadata_inventory_move to list: "..to_list)
		if to_list == "output" or to_list == "bookmark" then
			local meta = minetest.env:get_meta(pos)
			local inv = meta:get_inventory()
			local stack = inv:get_stack(from_list, from_index);
			inv:set_stack(to_list, to_index, stack)
			if to_list == "output" then
				craft_guide_inventory.update_recipe(meta, player, stack)
			end
		end
		return 0
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		--print("allow_metadata_inventory_put to list: "..listname)
		if listname == "bookmark" then
			return 1
		end
		if listname == "output" then
			local meta = minetest.env:get_meta(pos)
			if listname == "output" then
				craft_guide_inventory.update_recipe(meta, player, stack)
				return 0
			end
		end
		return 0
	end,
})

-- REGISTER CRAFT PC RECIPE
minetest.register_craft({
	output = 'craft_guide:lcd_pc',
	recipe = {
		{'craft_guide:sign_wall'},
		{'default:glass'},
		{'stairs:slab_stone'},
	}
})

-- AFTER MINETEST STARTS
minetest.after(0, function()
	local inv = minetest.create_detached_inventory("craft_guide", {
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			return 0
		end,
		allow_put = function(inv, listname, index, stack, player)
			return -1
		end,
		allow_take = function(inv, listname, index, stack, player)
			return -1
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
		local craft_recipe = minetest.get_craft_recipe(name);
		if craft_recipe.items ~= nil then
			if (not def.groups.not_in_craft_guide_inventory or def.groups.not_in_craft_guide_inventory == 0)
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
	craft_guide_inventory.craft_guide_inventory_size = #craft_guide_list
	print("craft_guide inventory size: "..dump(craft_guide_inventory.craft_guide_inventory_size))
end)

-- LOG THAT WE STARTED
minetest.log("action", "[craft_guide] "..version.." loaded")
