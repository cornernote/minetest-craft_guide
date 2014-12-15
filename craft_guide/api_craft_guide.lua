--[[

Craft Guide for Minetest

Copyright (c) 2012 cornernote, Brett O'Donnell <cornernote@gmail.com>
Source Code: https://github.com/cornernote/minetest-craft_guide
License: BSD-3-Clause https://raw.github.com/cornernote/minetest-craft_guide/master/LICENSE

CRAFT GUIDE API

]]--





-- expose object to other modules
craft_guide = {}


-- define api variables
craft_guide.crafts = {}

-- here you can disable "you need" feature if you don't want it
craft_guide.you_need=true

-- here you can define base items for "you need" feature

--all items with this prefix are base items:

craft_guide.basic_item_prefixes = { 

	"dye:",

}

--all items which belong to this groups are base items

craft_guide.basic_item_groups = { 

	"wood",
	"stone",
	"stick",
	"tree",
	"sand",
	"glass",

}

--all items which end with these strings are base items

craft_guide.basic_item_endings = {

	"ingot",
	"lump",
	"glass",
	"dust",

}

-- here you can define single items as base items.
-- items without crafting recipe or items which match criterias from the tables above are base items too.

craft_guide.basic_items	= { 

	"default:dirt",
	"default:sand",
	"default:cobble",
	"default:snowblock",
	"default:ice",
	"default:wood",
	"default:stone",
	"default:stick",
	"default:clay_brick",
	"default:gravel",
	"default:mossycobble",
	"default:desert_stone",
	"default:desert_cobble",
	"default:desert_sand",
	"default:diamond",
	"default:mese_crystal",
	"default:glass",
	"default:obsidian",
	"bucket:bucket_water",
	"bucket:bucket_lava",
	"technic:uranium",
	"technic:raw_latex",
	"homedecor:roof_tile_terracotta",
	"homedecor:terracotta_base",
	"mesecons_materials:glue",

}

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
craft_guide.get_craft_guide_formspec = function(meta, search, page, alternate)
	if search == nil then 
		search = meta:get_string("search")
	end
	if meta:get_string("formspec")=="" then
		meta:set_string("saved_search","|")
		meta:set_string("saved_page","1")
		meta:set_string("saved_pages","1")
		meta:set_string("switch","bookmarks")
		meta:set_string("poslist","down")
		meta:set_string("amounts","")
	end	
	if page == nil then 
		page = craft_guide.get_current_page(meta) 
	end
	if alternate == nil then 
		alternate = craft_guide.get_current_alternate(meta) 
	end
	local inv = meta:get_inventory()
	local size = inv:get_size("main")
	local start = (page-1) * (5*14) --was 1 too much before
	local pages = math.floor((size-1) / (5*14) + 1)
	local alternates = 0
	local stack = inv:get_stack("output",1)
	local crafts = craft_guide.crafts[stack:get_name()]
	if crafts ~= nil then
		alternates = #crafts
	end
	local build=""
	for ii=1,9,1 do
		local build_old=build
		local build_stack = inv:get_stack("build",ii)
		if build_stack~=nil then
			local build_name=build_stack:get_name()
			if string.sub(build_name,1,6)=="group:" then
				local groups=string.sub(build_name,7)
				local saved=""
				for name,def in pairs(minetest.registered_items) do
					local hasgroup=1
					for group in string.gmatch(groups,"([^,]+)") do
						if minetest.get_item_group(name, group)==0 then
							hasgroup=0
						end
					end
					if hasgroup==1 then
                                                --prefer items from default mod
						if string.sub(name,1,8)=="default:" then
							build=build.."item_image_button["..tostring(2+((ii-1)%3))..","
							..tostring(7+math.floor((ii-1)/3))..";1,1;"
							..name..";t_758s"..tostring(ii)..";group]"
							.."tooltip[t_758s"..tostring(ii)..";"
							..string.upper(string.sub(groups,1,1))..string.sub(groups.." ",2).."]"

							saved=""
							break
						elseif saved=="" then
							saved=name
						end
					end
				end
				if saved~="" then
					build=build.."item_image_button["..tostring(2+((ii-1)%3))..","
					..tostring(7+math.floor((ii-1)/3))..";1,1;"..saved..";t_758s"..tostring(ii)..";group]"
					.."tooltip[t_758s"..tostring(ii)..";"
					..string.upper(string.sub(groups,1,1))..string.sub(groups.." ",2).."]"
				end
			end
		end
		if build_old==build then
			build=build.."list[current_name;build;"..tostring(2+((ii-1)%3))..","..tostring(7+math.floor((ii-1)/3))
				..";1,1;"..tostring(ii-1).."]"
		end
	end
	local cook=""
	local cook_stack = inv:get_stack("cook",1)
	if cook_stack~=nil then
		local cook_name=cook_stack:get_name()
		if string.sub(cook_name,1,6)=="group:" then
			local groups=string.sub(cook_name,7)
			local saved=""
			for name,def in pairs(minetest.registered_items) do
				local hasgroup=1
				for group in string.gmatch(groups,"([^,]+)") do
					if minetest.get_item_group(name, group)==0 then
						hasgroup=0
					end
				end
				if hasgroup==1 then
					if string.sub(name,1,8)=="default:" then
						cook="item_image_button[6,7;1,1;"..name..";c_758s1;group]"
						.."tooltip[c_758s1;"..string.upper(string.sub(groups,1,1))..string.sub(groups.." ",2).."]"
	
						saved=""
						break
					elseif saved=="" then
						saved=name
					end
				end
			end
			if saved~="" then
				cook="item_image_button[6,7;1,1;"..saved..";c_758s1;group]"
				.."tooltip[c_758s1;"..string.upper(string.sub(groups,1,1))..string.sub(groups.." ",2).."]"
			end
		end
		if cook=="" then
			cook="list[current_name;cook;6,7;1,1;]"
		end
	end

	local fuel=""
	local fuel_stack = inv:get_stack("fuel",1)
	if fuel_stack~=nil then
		local fuel_name=fuel_stack:get_name()
		if string.sub(fuel_name,1,6)=="group:" then
			local groups=string.sub(fuel_name,7)
			local saved=""
			for name,def in pairs(minetest.registered_items) do
				local hasgroup=1
				for group in string.gmatch(groups,"([^,]+)") do
					if minetest.get_item_group(name, group)==0 then
						hasgroup=0
					end
				end
				if hasgroup==1 then
					if string.sub(name,1,8)=="default:" then
						fuel="item_image_button[6,9;1,1;"..name..";f_758s1;group]"
						.."tooltip[f_758s1;"..string.upper(string.sub(groups,1,1))..string.sub(groups.." ",2).."]"
	
						saved=""
						break
					elseif saved=="" then
						saved=name
					end
				end
			end
			if saved~="" then
				fuel="item_image_button[6,9;1,1;"..saved..";f_758s1;group]"
				.."tooltip[f_758s1;"..string.upper(string.sub(groups,1,1))..string.sub(groups.." ",2).."]"
			end
		end
		if fuel=="" then
			fuel="list[current_name;fuel;6,9;1,1;]"
		end
	end
	bk=""
	if meta:get_string("saved_search")~="|" then
		bk="button[6,5.8;2.7,1;back_button;<--- Back]"
	end

	local changeable_part=""
	if meta:get_string("switch")=="youneed" and craft_guide.you_need then
		changeable_part="button[9.7,6.35;0.8,0.7;switch_to_bookmarks;>>]"
				.."tooltip[switch_to_bookmarks;Show your saved bookmarks]"

		if meta:get_string("poslist")=="down" then
			changeable_part= changeable_part.."label[8,6.5;You need:]"
				.."button[10.42,6.35;0.5,0.7;move_up;^]"
				.."tooltip[move_up;Move the list of needed items upwards]"
				.."label[11.4,6.0;Add to]"
				.."label[11.2,6.35;bookmarks]"
				.."label[12.6,6.05;->]"
				.."list[current_name;add;13,6;1,1;]"
		else
			changeable_part= changeable_part.."button[10.42,6.35;0.5,0.7;move_down;v]"
				.."tooltip[move_down;Move the list of needed items downwards]"
		end

		local itemlist=""
		local x=8
		local y=7
		local widht=6
		if meta:get_string("switch")=="youneed" and meta:get_string("poslist")=="up" then
			x=0
			y=1
			widht=14
		end
		for ii=1,18,1 do
			local itemlist_old=itemlist
			local itemlist_stack = inv:get_stack("youneed",ii)
			if itemlist_stack~=nil then
				local itemlist_name=itemlist_stack:get_name()
				if string.sub(itemlist_name,1,6)=="group:" then
					local groups=string.sub(itemlist_name,7)
					local saved=""
					for name,def in pairs(minetest.registered_items) do
						local hasgroup=1
						for group in string.gmatch(groups,"([^,]+)") do
							if minetest.get_item_group(name, group)==0 then
								hasgroup=0
							end
						end
						if hasgroup==1 then
        	                                        --prefer items from default mod
							if string.sub(name,1,8)=="default:" then
								itemlist=itemlist.."item_image_button["..tostring(x+((ii-1)%widht))..","
								..tostring(y+math.floor((ii-1)/widht))..";1,1;"
								..name..";u_758s"..tostring(ii)..";group]"
								.."tooltip[u_758s"..tostring(ii)..";"
								..string.upper(string.sub(groups,1,1))..string.sub(groups.." ",2).."]"
	
								saved=""
								break
							elseif saved=="" then
								saved=name
							end
						end
					end
					if saved~="" then
						itemlist=itemlist.."item_image_button["..tostring(x+((ii-1)%widht))..","
						..tostring(y+math.floor((ii-1)/widht))..";1,1;"..saved..";u_758s"..tostring(ii)..";group]"
						.."tooltip[u_758s"..tostring(ii)..";"..string.upper(string.sub(groups,1,1))..string.sub(groups.." ",2).."]"
					end
				end
			end
			if itemlist_old==itemlist
				and (meta:get_string("poslist")=="down"
				or (inv:get_stack("youneed",ii)~= nil and inv:get_stack("youneed",ii):get_name()~=""))
				then
				itemlist=itemlist.."list[current_name;youneed;"..tostring(x+((ii-1)%widht))..","
					..tostring(y+math.floor((ii-1)/widht))..";1,1;"..tostring(ii-1).."]"
			end
		end
		changeable_part= changeable_part..itemlist..meta:get_string("amounts")
	end
 	if meta:get_string("switch")=="bookmarks" or (not craft_guide.you_need) or meta:get_string("poslist")=="up" then

		changeable_part= changeable_part.."label[8,6.5;Bookmarks]"
		if craft_guide.you_need and meta:get_string("switch")=="bookmarks" then
			changeable_part= changeable_part.."button[9.7,6.35;0.8,0.7;switch_to_youneed;>>]"
			.."tooltip[switch_to_youneed;Show amount of basic items needed]"
		end
		changeable_part= changeable_part.."list[current_name;bookmark;8,7;6,3;]"
			.."label[12,6.1;Bin ->]"
			.."list[current_name;bin;13,6;1,1;]"
	end

	local formspec = "size[14,10;]"
	if meta:get_string("switch")=="youneed" and meta:get_string("poslist")=="up" then
		formspec=formspec.."label[0.1,0.3;You need:]"
	else
		formspec=formspec.."list[current_name;main;0,0;14,5;"..tostring(start).."]"
	end
	formspec=formspec.."label[0,5;--== Learn to Craft ==--]"

		.."label[0,5.4;Drag any item to the Output box to see the]"
		.."label[0,5.8;craft. Save your favorite items in Bookmarks.]"

		.."field[6,5.4;2,1;craft_guide_search_box;;"..tostring(search).."]"
		.."button[7.5,5.1;1.2,1;craft_guide_search_button;Search]"
		..bk

		.."label[9,5.2;page "..tostring(page).." of "..tostring(pages).."]"
		.."button[11,5;1.5,1;craft_guide_prev;<<]"
		.."button[12.5,5;1.5,1;craft_guide_next;>>]"

		.."label[0,6.5;Output]"
		.."list[current_name;output;0,7;1,1;]"

		.."label[2,6.5;Inventory Craft]"
		..build
		.."label[6,6.5;Cook]"
		..cook
		.."label[6,8.5;Fuel]"
		..fuel
		..changeable_part
		.."button_exit[0,9.2;1,0.8;close_mm;ESC]"

	if alternates > 1 then
		if alternate>alternates then
			alternate=1	
		end
		formspec = formspec
			.."label[0,8;recipe "..tostring(alternate).." of "..tostring(alternates).."]"
			.."button[0,8.4;2,1;alternate;Alternate]"

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
	inv:set_size("youneed", 6*15)
	inv:set_size("trylist", 6*10)
	inv:set_size("overflow", 6*6)
	inv:set_size("bin", 1)
	inv:set_size("add", 1)
	craft_guide.create_inventory(inv)
	meta:set_string("formspec",craft_guide.get_craft_guide_formspec(meta))
	meta:set_string("out","")
	meta:set_string("addindex","1")
end


-- on_receive_fields
craft_guide.on_receive_fields = function(pos, formname, fields, player)
	local meta = minetest.env:get_meta(pos);

	local inv = meta:get_inventory()
	local size = inv:get_size("main",1)
	local stack = inv:get_stack("output",1)
	local crafts = craft_guide.crafts[stack:get_name()]
	local alternate = craft_guide.get_current_alternate(meta)
	local alternates = 0
	if crafts ~= nil then
		alternates = #crafts
	end

	local page = craft_guide.get_current_page(meta)
	local pages = math.floor((size-1) / (5*14) + 1)

	
	-- search
	local search
	search = fields.craft_guide_search_box
	if search~=nil then
		if string.lower(search)==string.upper(search) and tonumber(search)==nil and search~="*" then
			search=""
		end
	end
	meta:set_string("search", search)
	if fields.craft_guide_search_button then
		if meta:get_string("switch")=="youneed" and meta:get_string("poslist")=="up" then
			meta:set_string("switch","bookmarks")
			craft_guide.update_recipe(meta, player, stack, alternate)
		end		
		meta:set_string("saved_search", "|")
		page = 1
	end

	-- change page
	if fields.craft_guide_prev then
		page = page - 1
		if page < 1 then
			page = pages
		end
		if meta:get_string("switch")=="youneed" and meta:get_string("poslist")=="up" then
			meta:set_string("switch","bookmarks")
			craft_guide.update_recipe(meta, player, stack, alternate)
		end
	end

	if fields.craft_guide_next then
		page = page + 1
		if page > pages then
			page = 1
		end
		if meta:get_string("switch")=="youneed" and meta:get_string("poslist")=="up" then
			meta:set_string("switch","bookmarks")
			craft_guide.update_recipe(meta, player, stack, alternate)
		end
	end

	if page < 1 then
		page = 1
	end
	if page > pages then
		page = pages
	end

	-- go back to search result
	if fields.back_button then
		if meta:get_string("switch")=="youneed" and meta:get_string("poslist")=="up" then
			meta:set_string("switch","bookmarks")
			craft_guide.update_recipe(meta, player, stack, alternate)
		end		
		local saved_search = meta:get_string("saved_search")
		if saved_search~="|" then
			search=saved_search
			meta:set_string("search", saved_search)
			page=tonumber(meta:get_string("saved_page"))
			pages=tonumber(meta:get_string("saved_pages"))
			meta:set_string("saved_search", "|")
		end
	end


	--toogle between bookmarks/you need
	if fields.switch_to_bookmarks then	
		meta:set_string("switch","bookmarks")
	end

	if fields.switch_to_youneed then	
		meta:set_string("switch","youneed")
		craft_guide.update_recipe(meta, player, stack, alternate)
	end

	--replacing bookmarks or main item list?
	if fields.move_up then	
		if meta:get_string("switch")=="youneed" then
			meta:set_string("poslist","up")
			craft_guide.update_recipe(meta, player, stack, alternate)
		end
	end

	if fields.move_down then	
		if meta:get_string("switch")=="youneed" then
			meta:set_string("poslist","down")
			craft_guide.update_recipe(meta, player, stack, alternate)
		end
	end


	-- get an alternate recipe
	if fields.alternate then
		alternate = alternate+1
		craft_guide.update_recipe(meta, player, stack, alternate)
	end
	if alternate > alternates then
		alternate = 1
	end

	--group buttons

	--button in cook list
	local starts=""
	local ends=""
	local xx=""
	local formspec = meta:get_string("formspec")
	if fields.c_758s1 then 
		xx,starts=string.find(formspec,"tooltip%[c_758s1;")
		if starts~=nil then
			ends,xx=string.find(formspec,"%]",starts+1)
			local group=string.lower(string.sub(formspec,starts+1,ends-2))
			meta:set_string("search", "group:"..group)
			if meta:get_string("saved_search")=="|" then
				meta:set_string("saved_search", search)
				meta:set_string("saved_page", tostring(page))
				meta:set_string("saved_pages", tostring(pages))
			end
			page = 1
			search="group:"..group
		end
	end
	--button in fuel list
	if fields.f_758s1 then 
		xx,starts=string.find(formspec,"tooltip%[f_758s1;")
		if starts~=nil then
			ends,xx=string.find(formspec,"%]",starts+1)
			local group=string.lower(string.sub(formspec,starts+1,ends-2))
			meta:set_string("search", "group:"..group)
			if meta:get_string("saved_search")=="|" then
				meta:set_string("saved_search", search)
				meta:set_string("saved_page", tostring(page))
				meta:set_string("saved_pages", tostring(pages))
			end
			page = 1
			search="group:"..group
		end
	end
	--buttons in Inventory Craft
	if fields.t_758s1 then 
		xx,starts=string.find(formspec,"tooltip%[t_758s1;")
		if starts~=nil then
			ends,xx=string.find(formspec,"%]",starts+1)
			local group=string.lower(string.sub(formspec,starts+1,ends-2))
			meta:set_string("search", "group:"..group)
			if meta:get_string("saved_search")=="|" then
				meta:set_string("saved_search", search)
				meta:set_string("saved_page", tostring(page))
				meta:set_string("saved_pages", tostring(pages))
			end
			page = 1
			search="group:"..group
		end
	end
	if fields.t_758s2 then 
		xx,starts=string.find(formspec,"tooltip%[t_758s2;")
		if starts~=nil then
			ends,xx=string.find(formspec,"%]",starts+1)
			local group=string.lower(string.sub(formspec,starts+1,ends-2))
			meta:set_string("search", "group:"..group)
			if meta:get_string("saved_search")=="|" then
				meta:set_string("saved_search", search)
				meta:set_string("saved_page", tostring(page))
				meta:set_string("saved_pages", tostring(pages))
			end
			page = 1
			search="group:"..group
		end
	end
	if fields.t_758s3 then 
		xx,starts=string.find(formspec,"tooltip%[t_758s3;")
		if starts~=nil then
			ends,xx=string.find(formspec,"%]",starts+1)
			local group=string.lower(string.sub(formspec,starts+1,ends-2))
			meta:set_string("search", "group:"..group)
			if meta:get_string("saved_search")=="|" then
				meta:set_string("saved_search", search)
				meta:set_string("saved_page", tostring(page))
				meta:set_string("saved_pages", tostring(pages))
			end
			page = 1
			search="group:"..group
		end
	end
	if fields.t_758s4 then 
		xx,starts=string.find(formspec,"tooltip%[t_758s4;")
		if starts~=nil then
			ends,xx=string.find(formspec,"%]",starts+1)
			local group=string.lower(string.sub(formspec,starts+1,ends-2))
			meta:set_string("search", "group:"..group)
			if meta:get_string("saved_search")=="|" then
				meta:set_string("saved_search", search)
				meta:set_string("saved_page", tostring(page))
				meta:set_string("saved_pages", tostring(pages))
			end
			page = 1
			search="group:"..group
		end
	end
	if fields.t_758s5 then 
		xx,starts=string.find(formspec,"tooltip%[t_758s5;")
		if starts~=nil then
			ends,xx=string.find(formspec,"%]",starts+1)
			local group=string.lower(string.sub(formspec,starts+1,ends-2))
			meta:set_string("search", "group:"..group)
			if meta:get_string("saved_search")=="|" then
				meta:set_string("saved_search", search)
				meta:set_string("saved_page", tostring(page))
				meta:set_string("saved_pages", tostring(pages))
			end
			page = 1
			search="group:"..group
		end
	end
	if fields.t_758s6 then 
		xx,starts=string.find(formspec,"tooltip%[t_758s6;")
		if starts~=nil then
			ends,xx=string.find(formspec,"%]",starts+1)
			local group=string.lower(string.sub(formspec,starts+1,ends-2))
			meta:set_string("search", "group:"..group)
			if meta:get_string("saved_search")=="|" then
				meta:set_string("saved_search", search)
				meta:set_string("saved_page", tostring(page))
				meta:set_string("saved_pages", tostring(pages))
			end
			page = 1
			search="group:"..group
		end
	end
	if fields.t_758s7 then 
		xx,starts=string.find(formspec,"tooltip%[t_758s7;")
		if starts~=nil then
			ends,xx=string.find(formspec,"%]",starts+1)
			local group=string.lower(string.sub(formspec,starts+1,ends-2))
			meta:set_string("search", "group:"..group)
			if meta:get_string("saved_search")=="|" then
				meta:set_string("saved_search", search)
				meta:set_string("saved_page", tostring(page))
				meta:set_string("saved_pages", tostring(pages))
			end
			page = 1
			search="group:"..group
		end
	end
	if fields.t_758s8 then 
		xx,starts=string.find(formspec,"tooltip%[t_758s8;")
		if starts~=nil then
			ends,xx=string.find(formspec,"%]",starts+1)
			local group=string.lower(string.sub(formspec,starts+1,ends-2))
			meta:set_string("search", "group:"..group)
			if meta:get_string("saved_search")=="|" then
				meta:set_string("saved_search", search)
				meta:set_string("saved_page", tostring(page))
				meta:set_string("saved_pages", tostring(pages))
			end
			page = 1
			search="group:"..group
		end
	end
	if fields.t_758s9 then 
		xx,starts=string.find(formspec,"tooltip%[t_758s9;")
		if starts~=nil then
			ends,xx=string.find(formspec,"%]",starts+1)
			local group=string.lower(string.sub(formspec,starts+1,ends-2))
			meta:set_string("search", "group:"..group)
			if meta:get_string("saved_search")=="|" then
				meta:set_string("saved_search", search)
				meta:set_string("saved_page", tostring(page))
				meta:set_string("saved_pages", tostring(pages))
			end
			page = 1
			search="group:"..group
		end
	end

	--buttons in You Need
	if fields.u_758s1 then 
		xx,starts=string.find(formspec,"tooltip%[u_758s1;")
		if starts~=nil then
			ends,xx=string.find(formspec,"%]",starts+1)
			local group=string.lower(string.sub(formspec,starts+1,ends-2))
			meta:set_string("search", "group:"..group)
			if meta:get_string("saved_search")=="|" then
				meta:set_string("saved_search", search)
				meta:set_string("saved_page", tostring(page))
				meta:set_string("saved_pages", tostring(pages))
			end
			page = 1
			search="group:"..group
		end
	end
	if fields.u_758s2 then 
		xx,starts=string.find(formspec,"tooltip%[u_758s2;")
		if starts~=nil then
			ends,xx=string.find(formspec,"%]",starts+1)
			local group=string.lower(string.sub(formspec,starts+1,ends-2))
			meta:set_string("search", "group:"..group)
			if meta:get_string("saved_search")=="|" then
				meta:set_string("saved_search", search)
				meta:set_string("saved_page", tostring(page))
				meta:set_string("saved_pages", tostring(pages))
			end
			page = 1
			search="group:"..group
		end
	end
	if fields.u_758s3 then 
		xx,starts=string.find(formspec,"tooltip%[u_758s3;")
		if starts~=nil then
			ends,xx=string.find(formspec,"%]",starts+1)
			local group=string.lower(string.sub(formspec,starts+1,ends-2))
			meta:set_string("search", "group:"..group)
			if meta:get_string("saved_search")=="|" then
				meta:set_string("saved_search", search)
				meta:set_string("saved_page", tostring(page))
				meta:set_string("saved_pages", tostring(pages))
			end
			page = 1
			search="group:"..group
		end
	end
	if fields.u_758s4 then 
		xx,starts=string.find(formspec,"tooltip%[u_758s4;")
		if starts~=nil then
			ends,xx=string.find(formspec,"%]",starts+1)
			local group=string.lower(string.sub(formspec,starts+1,ends-2))
			meta:set_string("search", "group:"..group)
			if meta:get_string("saved_search")=="|" then
				meta:set_string("saved_search", search)
				meta:set_string("saved_page", tostring(page))
				meta:set_string("saved_pages", tostring(pages))
			end
			page = 1
			search="group:"..group
		end
	end
	if fields.u_758s5 then 
		xx,starts=string.find(formspec,"tooltip%[u_758s5;")
		if starts~=nil then
			ends,xx=string.find(formspec,"%]",starts+1)
			local group=string.lower(string.sub(formspec,starts+1,ends-2))
			meta:set_string("search", "group:"..group)
			if meta:get_string("saved_search")=="|" then
				meta:set_string("saved_search", search)
				meta:set_string("saved_page", tostring(page))
				meta:set_string("saved_pages", tostring(pages))
			end
			page = 1
			search="group:"..group
		end
	end
	if fields.u_758s6 then 
		xx,starts=string.find(formspec,"tooltip%[u_758s6;")
		if starts~=nil then
			ends,xx=string.find(formspec,"%]",starts+1)
			local group=string.lower(string.sub(formspec,starts+1,ends-2))
			meta:set_string("search", "group:"..group)
			if meta:get_string("saved_search")=="|" then
				meta:set_string("saved_search", search)
				meta:set_string("saved_page", tostring(page))
				meta:set_string("saved_pages", tostring(pages))
			end
			page = 1
			search="group:"..group
		end
	end
	if fields.u_758s7 then 
		xx,starts=string.find(formspec,"tooltip%[u_758s7;")
		if starts~=nil then
			ends,xx=string.find(formspec,"%]",starts+1)
			local group=string.lower(string.sub(formspec,starts+1,ends-2))
			meta:set_string("search", "group:"..group)
			if meta:get_string("saved_search")=="|" then
				meta:set_string("saved_search", search)
				meta:set_string("saved_page", tostring(page))
				meta:set_string("saved_pages", tostring(pages))
			end
			page = 1
			search="group:"..group
		end
	end
	if fields.u_758s8 then 
		xx,starts=string.find(formspec,"tooltip%[u_758s8;")
		if starts~=nil then
			ends,xx=string.find(formspec,"%]",starts+1)
			local group=string.lower(string.sub(formspec,starts+1,ends-2))
			meta:set_string("search", "group:"..group)
			if meta:get_string("saved_search")=="|" then
				meta:set_string("saved_search", search)
				meta:set_string("saved_page", tostring(page))
				meta:set_string("saved_pages", tostring(pages))
			end
			page = 1
			search="group:"..group
		end
	end
	if fields.u_758s9 then 
		xx,starts=string.find(formspec,"tooltip%[u_758s9;")
		if starts~=nil then
			ends,xx=string.find(formspec,"%]",starts+1)
			local group=string.lower(string.sub(formspec,starts+1,ends-2))
			meta:set_string("search", "group:"..group)
			if meta:get_string("saved_search")=="|" then
				meta:set_string("saved_search", search)
				meta:set_string("saved_page", tostring(page))
				meta:set_string("saved_pages", tostring(pages))
			end
			page = 1
			search="group:"..group
		end
	end
	if fields.u_758s11 then 
		xx,starts=string.find(formspec,"tooltip%[u_758s11;")
		if starts~=nil then
			ends,xx=string.find(formspec,"%]",starts+1)
			local group=string.lower(string.sub(formspec,starts+1,ends-2))
			meta:set_string("search", "group:"..group)
			if meta:get_string("saved_search")=="|" then
				meta:set_string("saved_search", search)
				meta:set_string("saved_page", tostring(page))
				meta:set_string("saved_pages", tostring(pages))
			end
			page = 1
			search="group:"..group
		end
	end
	if fields.u_758s12 then 
		xx,starts=string.find(formspec,"tooltip%[u_758s12;")
		if starts~=nil then
			ends,xx=string.find(formspec,"%]",starts+1)
			local group=string.lower(string.sub(formspec,starts+1,ends-2))
			meta:set_string("search", "group:"..group)
			if meta:get_string("saved_search")=="|" then
				meta:set_string("saved_search", search)
				meta:set_string("saved_page", tostring(page))
				meta:set_string("saved_pages", tostring(pages))
			end
			page = 1
			search="group:"..group
		end
	end
	if fields.u_758s13 then 
		xx,starts=string.find(formspec,"tooltip%[u_758s13;")
		if starts~=nil then
			ends,xx=string.find(formspec,"%]",starts+1)
			local group=string.lower(string.sub(formspec,starts+1,ends-2))
			meta:set_string("search", "group:"..group)
			if meta:get_string("saved_search")=="|" then
				meta:set_string("saved_search", search)
				meta:set_string("saved_page", tostring(page))
				meta:set_string("saved_pages", tostring(pages))
			end
			page = 1
			search="group:"..group
		end
	end
	if fields.u_758s14 then 
		xx,starts=string.find(formspec,"tooltip%[u_758s14;")
		if starts~=nil then
			ends,xx=string.find(formspec,"%]",starts+1)
			local group=string.lower(string.sub(formspec,starts+1,ends-2))
			meta:set_string("search", "group:"..group)
			if meta:get_string("saved_search")=="|" then
				meta:set_string("saved_search", search)
				meta:set_string("saved_page", tostring(page))
				meta:set_string("saved_pages", tostring(pages))
			end
			page = 1
			search="group:"..group
		end
	end
	if fields.u_758s15 then 
		xx,starts=string.find(formspec,"tooltip%[u_758s15;")
		if starts~=nil then
			ends,xx=string.find(formspec,"%]",starts+1)
			local group=string.lower(string.sub(formspec,starts+1,ends-2))
			meta:set_string("search", "group:"..group)
			if meta:get_string("saved_search")=="|" then
				meta:set_string("saved_search", search)
				meta:set_string("saved_page", tostring(page))
				meta:set_string("saved_pages", tostring(pages))
			end
			page = 1
			search="group:"..group
		end
	end
	if fields.u_758s16 then 
		xx,starts=string.find(formspec,"tooltip%[u_758s16;")
		if starts~=nil then
			ends,xx=string.find(formspec,"%]",starts+1)
			local group=string.lower(string.sub(formspec,starts+1,ends-2))
			meta:set_string("search", "group:"..group)
			if meta:get_string("saved_search")=="|" then
				meta:set_string("saved_search", search)
				meta:set_string("saved_page", tostring(page))
				meta:set_string("saved_pages", tostring(pages))
			end
			page = 1
			search="group:"..group
		end
	end
	if fields.u_758s17 then 
		xx,starts=string.find(formspec,"tooltip%[u_758s17;")
		if starts~=nil then
			ends,xx=string.find(formspec,"%]",starts+1)
			local group=string.lower(string.sub(formspec,starts+1,ends-2))
			meta:set_string("search", "group:"..group)
			if meta:get_string("saved_search")=="|" then
				meta:set_string("saved_search", search)
				meta:set_string("saved_page", tostring(page))
				meta:set_string("saved_pages", tostring(pages))
			end
			page = 1
			search="group:"..group
		end
	end
	if fields.u_758s18 then 
		xx,starts=string.find(formspec,"tooltip%[u_758s18;")
		if starts~=nil then
			ends,xx=string.find(formspec,"%]",starts+1)
			local group=string.lower(string.sub(formspec,starts+1,ends-2))
			meta:set_string("search", "group:"..group)
			if meta:get_string("saved_search")=="|" then
				meta:set_string("saved_search", search)
				meta:set_string("saved_page", tostring(page))
				meta:set_string("saved_pages", tostring(pages))
			end
			page = 1
			search="group:"..group
		end
	end
	if fields.u_758s10 then 
		xx,starts=string.find(formspec,"tooltip%[u_758s10;")
		if starts~=nil then
			ends,xx=string.find(formspec,"%]",starts+1)
			local group=string.lower(string.sub(formspec,starts+1,ends-2))
			meta:set_string("search", "group:"..group)
			if meta:get_string("saved_search")=="|" then
				meta:set_string("saved_search", search)
				meta:set_string("saved_page", tostring(page))
				meta:set_string("saved_pages", tostring(pages))
			end
			page = 1
			search="group:"..group
		end
	end
	if starts~="" and meta:get_string("switch")=="youneed" and meta:get_string("poslist")=="up" then --button pressed, need to move back to bookmarks
		meta:set_string("switch","bookmarks")
	end
	-- update the formspec
	craft_guide.create_inventory(inv, search)
	meta:set_string("formspec",craft_guide.get_craft_guide_formspec(meta, search, page, alternate))
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
	meta:set_string("amounts","")
	local count={}
	local globalcount=1
	local m="tq7k" --random modifier to turn unstackable items in stackable items

	local inv = meta:get_inventory()
	if meta:get_string("out")~="" then
		inv:set_stack("output", 1, ItemStack(meta:get_string("out")))
	end

	for i=0,inv:get_size("build"),1 do
		inv:set_stack("build", i, nil)
	end
	for i=0,inv:get_size("youneed"),1 do
		inv:set_stack("youneed", i, nil)
	end
	for i=0,inv:get_size("trylist"),1 do
		inv:set_stack("trylist", i, nil)
	end
	for i=0,inv:get_size("overflow"),1 do
		inv:set_stack("overflow", i, nil)
	end

	inv:set_stack("cook", 1, nil)
	inv:set_stack("fuel", 1, nil)

	if stack==nil then return end
	inv:set_stack("output", 1, stack:get_name())

	alternate = tonumber(alternate) or 1
	local crafts = craft_guide.crafts[stack:get_name()]
	if stack:get_name()~=nil and stack:get_name()~="" then
		craft_guide.log(player:get_player_name().." requests recipe "..alternate.." for "..stack:get_name())
	end	
	if crafts == nil then
		if stack:get_name()~=nil and stack:get_name()~="" then
			minetest.chat_send_player(player:get_player_name(), "no recipe available for "..stack:get_name())
		end
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
	else
	
		-- fuel
		if craft.type == "fuel" then
			inv:set_stack("fuel", 1, craft.recipe)
			meta:set_string("formspec",craft_guide.get_craft_guide_formspec(meta))
	
		else
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
	end
	if meta:get_string("switch")=="youneed" and craft_guide.you_need then
		count[1]=1
		inv:set_stack("youneed", 1,ItemStack(stack:get_name()))
		for j=1,5,1 do
			local finished=1
			local limit=inv:get_size("youneed")
			for k=1,limit,1 do
				local name=string.lower(inv:get_stack("youneed", k):get_name())
				if string.len(name)>4 and string.sub(name,string.len(name)-3)==m then
					name=string.sub(name,1,string.len(name)-4)
				end
				local isbase=0
				if name==nil or name=="" or string.sub(name,1,6)=="group:" then
					isbase=1
				elseif j>1 or k>1 then
					for ii=1,999,1 do
						if craft_guide.basic_item_prefixes[ii]==nil or craft_guide.basic_item_prefixes[ii]=="" then  
							break
						elseif string.sub(name,1,string.len(craft_guide.basic_item_prefixes[ii]))==
							string.lower(craft_guide.basic_item_prefixes[ii]) then
							isbase=1
							break
						end
					end
					if isbase==0 then
						for aa=1,999,1 do
							if craft_guide.basic_item_groups[aa]==nil or craft_guide.basic_item_groups[aa]=="" then  
								break
							elseif minetest.get_item_group(name, string.lower(craft_guide.basic_item_groups[aa]))>0 then
								isbase=1
								break
							end
						end
						if isbase==0 then
							for bb=1,999,1 do
								if craft_guide.basic_item_endings[bb]==nil or craft_guide.basic_item_endings[bb]=="" then  
									break
								elseif string.sub(name,string.len(name)-(string.len(craft_guide.basic_item_endings[bb])-1))==
									string.lower(craft_guide.basic_item_endings[bb]) then
									isbase=1
									break
								end
							end
							if isbase==0 then
								for cc=1,999,1 do
									if craft_guide.basic_items[cc]==nil or craft_guide.basic_items[cc]=="" then  
										break
									elseif name==string.lower(craft_guide.basic_items[cc]) then
										isbase=1
										break
									end
								end
							end
						end
					end
				end
				if isbase==0 then
					finished=0
					crafts = craft_guide.crafts[name]
					if crafts ~= nil then
						local istest=1
						local bestcraft=1
						local bestvalue=10 --lower is better
						for craftnumber=1,#crafts+1,1 do
							if craftnumber>49 then
								craftnumber=#crafts+1
							end
							local index=craftnumber
							local list="trylist"
							if j>1 then
								if #crafts==1 and index<=#crafts then 
									bestvalue=0
									istest=0
									list="youneed"
								elseif index>#crafts or bestvalue==0 then
									index=bestcraft
									bestvalue=0
									istest=0
									list="youneed"
								end
							else
								bestvalue=0
								index=alternate
								istest=0
								list="youneed"
							end
							local craft = crafts[index]
							if craft~=nil and craft.type~="fuel" then
								local amount=count[k]
								if istest==0 then
									inv:set_stack("youneed", k,nil)
									count[k]=0
									local output_count=ItemStack(craft.output):get_count()
									if output_count~=1 and (j>1 or k>1) then
										if amount/output_count==math.floor(amount/output_count) then
											amount=amount/output_count
										else
											globalcount=globalcount*output_count
											for ii=1,100,1 do
												if count[ii]==nil then
													ii=111
												else
													count[ii]=count[ii]*output_count
												end
											end
										end
									end
								end
								if(amount>50) then
									amount=math.floor(amount/50+0.49)
									if list=="youneed" then
										list="overflow"
									end
								end
								if craft.type == "cooking" then
									for ci=1,amount,1 do
										inv:add_item(list,ItemStack(craft.recipe))
									end
								else
									if craft.recipe[1] then
										if (type(craft.recipe[1]) == "string") then
											local item=ItemStack(craft.recipe[1])
											if item:get_stack_max()<10 then
												item=ItemStack(item:get_name()..m)
											end
											for ci=1,amount,1 do
												inv:add_item(list,item)
											end
										else
											if craft.recipe[1][1] then
												local item=ItemStack(craft.recipe[1][1])
												if item:get_stack_max()<10 then
													item=ItemStack(item:get_name()..m)
												end
												for ci=1,amount,1 do
													inv:add_item(list,item)
												end
											end
											if craft.recipe[1][2] then
												local item=ItemStack(craft.recipe[1][2])
												if item:get_stack_max()<10 then
													item=ItemStack(item:get_name()..m)
												end
												for ci=1,amount,1 do
													inv:add_item(list,item)
												end
											end
											if craft.recipe[1][3] then
												local item=ItemStack(craft.recipe[1][3])
												if item:get_stack_max()<10 then
													item=ItemStack(item:get_name()..m)
												end
												for ci=1,amount,1 do
													inv:add_item(list,item)
												end
											end
										end
									end
									if craft.recipe[2] then
										if (type(craft.recipe[2]) == "string") then
											local item=ItemStack(craft.recipe[2])
											if item:get_stack_max()<10 then
												item=ItemStack(item:get_name()..m)
											end
											for ci=1,amount,1 do
												inv:add_item(list,item)
											end
										else
											if craft.recipe[2][1] then
												local item=ItemStack(craft.recipe[2][1])
												if item:get_stack_max()<10 then
													item=ItemStack(item:get_name()..m)
												end
												for ci=1,amount,1 do
													inv:add_item(list,item)
												end
											end
											if craft.recipe[2][2] then
												local item=ItemStack(craft.recipe[2][2])
												if item:get_stack_max()<10 then
													item=ItemStack(item:get_name()..m)
												end
												for ci=1,amount,1 do
													inv:add_item(list,item)
												end
											end
											if craft.recipe[2][3] then
												local item=ItemStack(craft.recipe[2][3])
												if item:get_stack_max()<10 then
													item=ItemStack(item:get_name()..m)
												end
												for ci=1,amount,1 do
													inv:add_item(list,item)
												end
											end
										end
									end
									if craft.recipe[3] then
										if (type(craft.recipe[3]) == "string") then
											local item=ItemStack(craft.recipe[3])
											if item:get_stack_max()<10 then
												item=ItemStack(item:get_name()..m)
											end
											for ci=1,amount,1 do
												inv:add_item(list,item)
											end
										else
											if craft.recipe[3][1] then
												local item=ItemStack(craft.recipe[3][1])
												if item:get_stack_max()<10 then
													item=ItemStack(item:get_name()..m)
												end
												for ci=1,amount,1 do
													inv:add_item(list,item)
												end
											end
											if craft.recipe[3][2] then
												local item=ItemStack(craft.recipe[3][2])
												if item:get_stack_max()<10 then
													item=ItemStack(item:get_name()..m)
												end
												for ci=1,amount,1 do
													inv:add_item(list,item)
												end
											end
											if craft.recipe[3][3] then
												local item=ItemStack(craft.recipe[3][3])
												if item:get_stack_max()<10 then
													item=ItemStack(item:get_name()..m)
												end
												for ci=1,amount,1 do
													inv:add_item(list,item)
												end
											end
										end
									end
									if craft.recipe[4] then
										if (type(craft.recipe[4]) == "string") then
											local item=ItemStack(craft.recipe[4])
											if item:get_stack_max()<10 then
												item=ItemStack(item:get_name()..m)
											end
											for ci=1,amount,1 do
												inv:add_item(list,item)
											end
										end
									end
									if craft.recipe[5] then
										if (type(craft.recipe[5]) == "string") then
											local item=ItemStack(craft.recipe[5])
											if item:get_stack_max()<10 then
												item=ItemStack(item:get_name()..m)
											end
											for ci=1,amount,1 do
												inv:add_item(list,item)
											end
										end
									end
									if craft.recipe[6] then
										if (type(craft.recipe[6]) == "string") then
											local item=ItemStack(craft.recipe[6])
											if item:get_stack_max()<10 then
												item=ItemStack(item:get_name()..m)
											end
											for ci=1,amount,1 do
												inv:add_item(list,item)
											end
										end
									end
									if craft.recipe[7] then
										if (type(craft.recipe[7]) == "string") then
											local item=ItemStack(craft.recipe[7])
											if item:get_stack_max()<10 then
												item=ItemStack(item:get_name()..m)
											end
											for ci=1,amount,1 do
												inv:add_item(list,item)
											end
										end
									end
									if craft.recipe[8] then
										if (type(craft.recipe[8]) == "string") then
											local item=ItemStack(craft.recipe[8])
											if item:get_stack_max()<10 then
												item=ItemStack(item:get_name()..m)
											end
											for ci=1,amount,1 do
												inv:add_item(list,item)
											end
										end
									end
									if craft.recipe[9] then
										if (type(craft.recipe[9]) == "string") then
											local item=ItemStack(craft.recipe[9])
											if item:get_stack_max()<10 then
												item=ItemStack(item:get_name()..m)
											end
											for ci=1,amount,1 do
												inv:add_item(list,item)
											end
										end
									end
								end
							end
	
							if istest==1 then
								for jj=1,inv:get_size("trylist"),1 do
									local item=inv:get_stack("trylist", jj):get_name()
									inv:set_stack("trylist", jj, ItemStack(nil))
									if string.len(item)>4 and string.sub(item,string.len(item)-3)==m then
										item=string.sub(item,1,string.len(item)-4)
									end
									inv:set_stack("trylist", jj, ItemStack(item))
								end
								local value=0
								for h=1,inv:get_size("trylist"),1 do
									if inv:get_stack("trylist", h)~=nil then
										local name=string.lower(inv:get_stack("trylist", h):get_name())
										if name.def==nil or (craft_guide.crafts[name]==nil 
											and string.sub(name,1,8)=="technic:")
											then
											bestvalue=10
											h=999
										else
											local testcrafts = craft_guide.crafts[name]
											local testcraft=""
											if testcrafts~=nil then
												testcraft=testcrafts[1]
											end
											local isbase=0

--too much tabs needed, starting here left again till this section is over
	
if	name==nil or name==""
	or string.sub(name,1,6)=="group:" 
	or testcrafts==nil or testcraft==nil
	or testcraft.type=="cooking" 
	or testcraft.type=="fuel"
	then
	isbase=1
else
	for ii=1,999,1 do
		if craft_guide.basic_item_prefixes[ii]==nil or craft_guide.basic_item_prefixes[ii]=="" then  
			break
		elseif string.sub(name,1,string.len(craft_guide.basic_item_prefixes[ii]))==string.lower(craft_guide.basic_item_prefixes[ii]) then
			isbase=1
			break
		end
	end
	if isbase==0 then
		for aa=1,999,1 do
			if craft_guide.basic_item_groups[aa]==nil or craft_guide.basic_item_groups[aa]=="" then  
				break
			elseif minetest.get_item_group(name, string.lower(craft_guide.basic_item_groups[aa]))>0 then
				isbase=1
				break
			end
		end
		if isbase==0 then
			for bb=1,999,1 do
				if craft_guide.basic_item_endings[bb]==nil or craft_guide.basic_item_endings[bb]=="" then  
					break
				elseif string.sub(name,string.len(name)-(string.len(craft_guide.basic_item_endings[bb])-1))==
					string.lower(craft_guide.basic_item_endings[bb]) then
					isbase=1
					break
				end
			end
			if isbase==0 then
				for cc=1,999,1 do
					if craft_guide.basic_items[cc]==nil or craft_guide.basic_items[cc]=="" then  
						break
					elseif name==string.lower(craft_guide.basic_items[cc]) then
						isbase=1
						break
					end
				end
			end
		end
	end
end

--starting with correct tabs here again

											if isbase==0 then
												value=value+1
--												if string.find(name,"slab")~=nil
--												or string.find(name,"panel")~=nil
--												or string.find(name,"microblock")~=nil
--												or string.find(name,"stair")~=nil
--												then
--													value=value+5
--												end
											end
										end
									end
									inv:set_stack("trylist", h,ItemStack(nil))
								end
								if value<bestvalue then
									bestcraft=index
									bestvalue=value
								end
							else
								local overflow_index=1
								for h=1,inv:get_size("youneed"),1 do
									if inv:get_stack("youneed", h)~=nil and inv:get_stack("youneed", h):get_name()~=nil 
										and inv:get_stack("youneed", h):get_name()~="" then
										if count[h]==nil or count[h]==0 then 
											count[h]=inv:get_stack("youneed", h):get_count()
										else
											count[h]=count[h]+(inv:get_stack("youneed", h):get_count()-1)
										end
										inv:set_stack("youneed", h,ItemStack(inv:get_stack("youneed", h):get_name()))
									else
										if overflow_index==0 or inv:get_stack("overflow", overflow_index)==nil 
											or inv:get_stack("overflow", overflow_index):get_name()==nil
											or inv:get_stack("overflow", overflow_index):get_name()==""
											then
												overflow_index=0
										else
											local additem=inv:get_stack("overflow",overflow_index):get_name()
											count[h]=inv:get_stack("overflow", overflow_index):get_count()*50
											inv:set_stack("youneed", h, ItemStack(additem))
											inv:set_stack("overflow", overflow_index,ItemStack(nil))
											overflow_index=overflow_index+1
										end
									end
								end
								local size=inv:get_size("youneed")
								for jjj=1,size,1 do
									local item1=inv:get_stack("youneed", jjj):get_name()
									if item1~=nil then
										for jj=jjj+1,size,1 do
											local item2=inv:get_stack("youneed", jj):get_name()
											if item1==item2 and count[jjj]~=nil and count[jj]~=nil then
												count[jjj]=count[jjj]+count[jj]
												count[jj]=0
												inv:set_stack("youneed", jj,ItemStack(nil))
											end
										end
									end
								end
								craftnumber=999
								break
							end
						end
					end
				end
			end
			if finished==1 then
				break
			end
		end
	end
	local itemlist=""
	local size=inv:get_size("youneed")
	for jjj=1,size,1 do
		local item1=inv:get_stack("youneed", jjj):get_name()
		if item1~=nil then
			for jj=jjj+1,size,1 do
				local item2=inv:get_stack("youneed", jj):get_name()
				if item1==item2 and count[jjj]~=nil and count[jj]~=nil then
					count[jjj]=count[jjj]+count[jj]
					count[jj]=0
					inv:set_stack("youneed", jj,ItemStack(nil))
				end
			end
		end
	end
	for jj=1,inv:get_size("youneed"),1 do
		local item=inv:get_stack("youneed", jj):get_name()
		inv:set_stack("youneed", jj, ItemStack(nil))
		if string.len(item)>4 and string.sub(item,string.len(item)-3)==m then
			item=string.sub(item,1,string.len(item)-4)
		end
		inv:add_item("youneed", ItemStack(item))
	end
	for jjj=1,55,1 do
		if count[jjj]~=nil then 
			if count[jjj]==0 then
				for jj=jjj+1,55,1 do
					if count[jj]~=nil and count[jj]~=0 then
						count[jjj]=count[jj]
						count[jj]=0
						break
					end
				end
			end
		end
	end
	local xx=8.1
	local yy=7.45
	local widht=6
	if meta:get_string("switch")=="youneed" and meta:get_string("poslist")=="up" then
		xx=0.1
		yy=1.45
		widht=14
	end
	for jj=1,inv:get_size("youneed"),1 do
		if count[jj]==nil then
			jj=111
			break
		else
			if count[jj]>0 then
				local cnt=math.floor(((count[jj])/globalcount)*1000+0.49)/1000
				if cnt>1000 then
					cnt=math.floor(cnt+0.49)
				elseif cnt>100 then
					cnt=math.floor(cnt*10+0.49)/10
				elseif cnt>10 then
					cnt=math.floor(cnt*100+0.49)/100
				end
				itemlist=itemlist.."label["..tostring(xx+((jj-1)%widht))..","..tostring(yy+math.floor((jj-1)/widht))..";"..tostring(cnt).."]"
			end
		end
	end
	meta:set_string("amounts",itemlist)
	meta:set_string("formspec",craft_guide.get_craft_guide_formspec(meta))
end


-- create_inventory
craft_guide.create_inventory = function(inv, search)
	local craft_guide_list = {}
	for name,def in pairs(minetest.registered_items) do
		-- local craft_recipe = minetest.get_craft_recipe(name);
		-- if craft_recipe.items ~= nil then
				local craft = craft_guide.crafts[name];
		if (not def.groups.not_in_craft_guide or def.groups.not_in_craft_guide == 0)
			and (craft ~= nil or (not def.groups.not_in_creative_inventory or def.groups.not_in_creative_inventory == 0))
			--and (not def.groups.not_in_creative_inventory or def.groups.not_in_creative_inventory == 0)
			and def.description and def.description ~= "" then
			if search and search~="" then
				--search used to display groups of items
				--if you enter something in search field it displays items without crafting recipes too
				search=string.lower(search)
				if string.sub(search,1,6)=="group:" then
					local groups=string.sub(search,7)
					local hasgroup=0
					for group in string.gmatch(groups,"([^,]+)") do
						if minetest.get_item_group(name, group)>0 then
							hasgroup=1
						else
							hasgroup=0
							break
						end
					end
					if hasgroup==1 then
						table.insert(craft_guide_list, name)
					end
				else
					search=string.lower(search)
					local test1=0
					local test2=0
					local test3=0
					test1,test2=string.find(string.lower(def.name.."           "), search)					
					test2,test3=string.find(string.lower(def.description.."           "), search)					
					if (test1~=nil and test1>0) or (test2~=nil and test2>0) or search=="*" then
						table.insert(craft_guide_list, name)
					end
				end
			else
				if craft ~= nil then
					table.insert(craft_guide_list, name)
				end
			end
		end
	end
	table.sort(craft_guide_list)
	for i=0,inv:get_size("main"),1 do
		inv:set_stack("main", i, nil)
	end
	inv:set_size("main", #craft_guide_list)
	for _,itemstring in ipairs(craft_guide_list) do
		inv:add_item("main", ItemStack(itemstring))
	end
end


-- allow_metadata_inventory_move
craft_guide.allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.env:get_meta(pos)
	local inv = meta:get_inventory()
	if to_list == "bin" and from_list == "output" then
		inv:set_stack(from_list,from_index,nil)
		craft_guide.update_recipe(meta, player, inv:get_stack(from_list, from_index))
	end
	if to_list == "bin" and from_list == "bookmark" then
		inv:set_stack(from_list,from_index,nil)
		inv:set_stack("add",1,nil)--clear this because bookmarks aren't full anymore
	end
	if to_list == "bookmark" and not inv:contains_item("bookmark",inv:get_stack(from_list, from_index):get_name()) then
		inv:set_stack(to_list, to_index, inv:get_stack(from_list, from_index):get_name())
		if not inv:contains_item("bookmark",ItemStack(nil)) then
			inv:set_stack("add", 1, inv:get_stack("bookmark", tonumber(meta:get_string("addindex"))):get_name())
		end
	end
	if to_list == "add" and not inv:contains_item("bookmark",inv:get_stack(from_list, from_index):get_name()) then
		local index=tonumber(meta:get_string("addindex"))
		local stack=inv:get_stack("bookmark",index)
		local status=0
		if stack~=nil and stack:get_name()~=nil and stack:get_name()~="" then
			for i=1,inv:get_size("bookmark"),1 do
				stack=inv:get_stack("bookmark",i)
				if stack~=nil and stack:get_name()~=nil and stack:get_name()~="" then
				else
					if status==0 then
						inv:set_stack("bookmark", i, inv:get_stack(from_list, from_index):get_name())
						meta:set_string("addindex",tostring(i))
						status=1
					elseif status==1 then
						status=2
					end
				end
			end
			if status==1 then --bookmarks are full now
				inv:set_stack("add", to_index, inv:get_stack(from_list, from_index):get_name())
			elseif status==2 then --bookmarks has still empty slots after adding this stack
				inv:set_stack("add", to_index, nil)
			elseif status==0 then --bookmarks were already full, replace last added item
				inv:set_stack("bookmark", index, inv:get_stack(from_list, from_index):get_name())
				inv:set_stack("add", to_index, inv:get_stack(from_list, from_index):get_name())
			end
		else
			inv:set_stack("bookmark", index, inv:get_stack(from_list, from_index):get_name())
			inv:set_stack("add", to_index, nil)
		end
	end
	if to_list == "output" or from_list == "output" then
		if from_list ~= "output" and to_list == "output" then
			local name=inv:get_stack(from_list, from_index)
			if name~=nil then
				name=name:get_name()
			end
			if name~=nil then
				meta:set_string("out",name)
				inv:set_stack(to_list, to_index, nil)
			end
		end
		if from_list == "output" and (to_list == "bin" or to_list=="add" ) then
			meta:set_string("out","")
		end
		craft_guide.update_recipe(meta, player, inv:get_stack(from_list, from_index))
	end
	if from_list == "bookmark" and to_list == "bookmark"  then
		return count
	end
	return 0
end


-- allow_metadata_inventory_put
craft_guide.allow_metadata_inventory_put = function(pos, listname, index, stack, player)
	return 0
end


-- allow_metadata_inventory_take
craft_guide.allow_metadata_inventory_take = function(pos, listname, index, stack, player)
	return 0
end

