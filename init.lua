----------------------------------
-- Craft Guide for MineTest 0.4 --
----------------------------------

----------------------------------
-- DESCRIPTION
----------------------------------
-- Provides items that will show you how to craft any craftable or cookable item.
----------------------------------

----------------------------------
-- LICENSE
----------------------------------
-- GNU General Public License
-- http://www.gnu.org/copyleft/gpl.html
----------------------------------

----------------------------------
-- CREDITS
----------------------------------
-- cornernote - author
-- marktraceur - help in irc
-- ashenk69 - author of creative_inventory (parts of that were copied to make the gui)
-- darkrose - updating core to support a craft registry
----------------------------------

----------------------------------
-- NOTES
----------------------------------
--
-- version 0.4.dev-20120606-c57e508 and below
--
-- Due to a limit in the core you will not see ALL recipies.  You will only see the ones
-- that were loaded after this mod.
--
-- The screenshot contains no additional mods, so if you see less than this you are missing some.
-- 
-- If you would like to see ALL the recipies, and not just 
-- the ones loaded after this module, please follow the 3 steps below:
--
-- 1) Copy register_craft.lua to games/minetest_game/mods/default/
--
-- 2) The following line must be placed in your games/minetest_game/mods/default/init.lua
-- dofile(minetest.get_modpath("default").."/register_craft.lua") -- place this line into default/init.lua
--
-- 3) the following line must be removed
--dofile(minetest.get_modpath("craft_guide").."/register_craft.lua") -- comment out this line
--
----------------------------------

----------------------------------
-- VERSION HISTORY
----------------------------------
-- 0.0.3 (planned)
-- use core craft registry
----------------------------------
-- 0.0.2
-- added bookmarks
-- added support for shapeless recipies
-- added support for output quantity
-- changed name of the sign to "Learn to Craft"
-- fixed bug causing non-building/cooking crafts to not register (eg cooking itself did not load)
-- fixed bug causing game to crash when viewing non-craftable items
----------------------------------
-- 0.0.1 
-- initial release
----------------------------------




----------------------------------
-- THE CODE
----------------------------------
local version = "0.0.2"
craft_guide_start = 0
craft_guide_items = {}

-- PAGINATION
local function paginate(meta, start)
	local node
	local name
	local count = 0
	local inv = meta:get_inventory()
	if start > #craft_guide_items then
		local remain = #craft_guide_items%56
		start = #craft_guide_items-remain
	end
	if start < 0 then
		start = 0
	end
	if not inv:is_empty("main") then
		for var=0,inv:get_size("main"),1 do
			inv:set_stack("main", var, nil)
		end
	end
	for node,name in pairs(craft_guide_items) do
		if count >= start then
			inv:add_item("main", name)
		end
		count = count+1
	end
	craft_guide_start = start
end

-- UPDATE RECIPE
local function updateRecipe(meta, player, stack)
	local inv = meta:get_inventory()
	local craft = crafts[stack:get_name()];
	
	for var=0,inv:get_size("build"),1 do
		inv:set_stack("build", var, nil)
	end
	inv:set_stack("cook", 1, nil)
	inv:set_stack("fuel", 1, nil)

	inv:set_stack("output", 1, stack:get_name())
	
	if crafts[stack:get_name()] == nil then
		minetest.chat_send_player(player:get_player_name(), "no recipe available for "..stack:get_name())
		return
	end
	
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

-- REGISTER CRAFT SIGN NODE
minetest.register_node("craft_guide:sign_wall", {
	description = "Learn to Craft",
	drawtype = "signlike",
	tiles ={"default_sign_wall.png"},
	inventory_image = "default_sign_wall.png",
	wield_image = "default_sign_wall.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "wallmounted",
	},
	groups = {choppy=2,dig_immediate=2},
	legacy_wallmounted = true,
	sounds = default.node_sound_defaults(),
	on_construct = function(pos)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("formspec",
			"invsize[14,9;]"..
			"list[current_name;main;0,0;14,4;]"..
			"list[current_name;previous;6,4;1,1;]"..
			"list[current_name;next;7,4;1,1;]"..
			"list[current_name;output;0,6;1,1;]"..
			"list[current_name;build;2,6;3,3;]"..
			"list[current_name;cook;6,6;1,1;]"..
			"list[current_name;fuel;6,8;1,1;]"..
			"list[current_name;bookmark;8,6;6,3;]"..
			"list[current_name;bin;13,5;1,1;]")
		meta:set_string("infotext", "Learn to Craft")
		local inv = meta:get_inventory()
		inv:set_size("main", 14*4)
		inv:set_size("previous", 1)
		inv:set_size("next", 1)
		inv:set_size("output", 1)
		inv:set_size("build", 3*3)
		inv:set_size("cook", 1)
		inv:set_size("fuel", 1)
		inv:set_size("bookmark", 6*3)
		inv:set_size("bin", 1)
		local node
		craft_guide_items = {}
		for node in pairs(minetest.registered_items) do
			if crafts[node] then
				table.insert(craft_guide_items, {name = node})
			end
		end
		table.sort(craft_guide_items, function(a,b)
			return a.name < b.name
		end)
		paginate(meta, craft_guide_start)
	end,
	can_dig = function(pos,player)
		craft_guide_start = 0
		local meta = minetest.env:get_meta(pos);
		local inv = meta:get_inventory()
		return true
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local meta = minetest.env:get_meta(pos)
		local inv = meta:get_inventory()
		if to_list == "previous" then
			minetest.log("action", "[craft_guide] "..player:get_player_name().." change to previous page in craft_guide:sign_wall ")
			paginate(meta, craft_guide_start-inv:get_size("main"))
			return
		end
		if to_list == "next" then
			minetest.log("action", "[craft_guide] "..player:get_player_name().." change to next page in craft_guide:sign_wall ")
			paginate(meta, craft_guide_start+inv:get_size("main"))
			return
		end
		if to_list == "output" then
			minetest.log("action", "[craft_guide] "..player:get_player_name().." requests recipe for "..inv:get_stack(from_list, from_index):get_name())
			updateRecipe(meta, player, inv:get_stack(from_list, from_index))
			return
		end
		if to_list == "bookmark" then
			minetest.log("action", "[craft_guide] "..player:get_player_name().." adds to bookmark "..inv:get_stack(from_list, from_index):get_name())
			inv:set_stack(to_list, to_index, inv:get_stack(from_list, from_index))
			return
		end
		if to_list == "bin" and from_list == "bookmark" then
			minetest.log("action", "[craft_guide] "..player:get_player_name().." removes from bookmark "..inv:get_stack(from_list, from_index):get_name())
			inv:set_stack(from_list, from_index, nil)
			return
		end
	end,
})

-- REGISTER CRAFT SIGN RECIPE
minetest.register_craft({
	output = 'node "craft_guide:sign_wall" 1',
	recipe = {
		{'', 'node "default:stick"', 'node "default:stick"'},
		{'', 'node "default:stick"', 'node "default:stick"'},
		{'', 'node "default:stick"', ''},
	}
})

-- LOG THAT WE STARTED
minetest.log("action", "[craft_guide] "..version.." loaded")

----------------------------------
-- THE END - thanks for reading =)
----------------------------------