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

craft_guide.you_need_list = {}

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
		if search == nil then 
			search = ""
		end
	end
	if meta:get_string("formspec")=="" then
		meta:set_string("saved_search","|")
		meta:set_string("saved_page","1")
		meta:set_string("saved_pages","1")
		meta:set_string("switch","bookmarks")
		meta:set_string("poslist","down")
		meta:set_string("globalcount","1")
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
	backbutton=""
	if meta:get_string("saved_search")~="|" then
		backbutton="button[6,5.8;2.7,1;back_button;<--- Back]"
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
				..craft_guide.build_button_list(meta,inv,"youneed",12,29,8,7,6)

		else
			changeable_part= changeable_part.."button[10.42,6.35;0.5,0.7;move_down;v]"
				.."tooltip[move_down;Move the list of needed items downwards]"
				..craft_guide.build_button_list(meta,inv,"youneed",12,29,0,1,14,0)
		end
		changeable_part= changeable_part..craft_guide.get_amounts(meta,inv,"youneed")

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
		..backbutton
		.."label[9,5.2;page "..tostring(page).." of "..tostring(pages).."]"
		.."button[11,5;1.5,1;craft_guide_prev;<<]"
		.."button[12.5,5;1.5,1;craft_guide_next;>>]"

		.."label[0,6.5;Output]"
		.."list[current_name;output;0,7;1,1;]"

		.."label[2,6.5;Inventory Craft]"
		..craft_guide.build_button_list(meta,inv,"build",3,11,2,7,3)
		.."label[6,6.5;Cook]"
		..craft_guide.build_button_list(meta,inv,"cook",1,1,6,7,1)
		.."label[6,8.5;Fuel]"
		..craft_guide.build_button_list(meta,inv,"fuel",2,2,6,9,1)
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
		end
	end

	if fields.craft_guide_next then
		page = page + 1
		if page > pages then
			page = 1
		end
		if meta:get_string("switch")=="youneed" and meta:get_string("poslist")=="up" then
			meta:set_string("switch","bookmarks")
		end
	end

	if page > pages then
		page = pages
	end

	if page < 1 then
		page = 1
	end

	-- go back to search result
	if fields.back_button then
		if meta:get_string("switch")=="youneed" and meta:get_string("poslist")=="up" then
			meta:set_string("switch","bookmarks")
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
		end
	end

	if fields.move_down then	
		if meta:get_string("switch")=="youneed" then
			meta:set_string("poslist","down")
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

	--group buttons, finally a solution with a for loop
	local starts=""
	local ends=""
	local xx=""
	local formspec = meta:get_string("formspec")
	for button_number=1,29,1 do
		if fields[("t_758s"..tostring(button_number))] then 
			xx,starts=string.find(formspec,"tooltip%[t_758s"..tostring(button_number)..";")
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
		break
		end
	end
	if starts~="" and meta:get_string("switch")=="youneed" and meta:get_string("poslist")=="up" then --button pressed, need to move back to bookmarks
		meta:set_string("switch","bookmarks")
	end
	-- update the formspec
	craft_guide.create_inventory(inv, search)
	meta:set_string("formspec",craft_guide.get_craft_guide_formspec(meta, search, page, alternate))
end


-- returns formspec string of a inventory list with buttons for group items
craft_guide.build_button_list = function(meta,inv,list,start_index,end_index,x,y,w,show_empty)
	if show_empty~=0 then
		show_empty=1
	end
	local string=""
	for i=1,end_index-start_index+1,1 do
		local string_old=string
		local stack = inv:get_stack(list,i)
		if stack~=nil then
			local name=stack:get_name()
			if string.sub(name,1,6)=="group:" then
				local groups=string.sub(name,7)
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
							string=string.."item_image_button["..tostring(x+((i-1)%w))..","
							..tostring(y+math.floor((i-1)/w))..";1,1;"
							..name..";t_758s"..tostring(i+start_index-1)..";group]"
							.."tooltip[t_758s"..tostring(i+start_index-1)..";"
							..string.upper(string.sub(groups,1,1))..string.sub(groups.." ",2).."]"

							saved=""
							break
						elseif saved=="" then
							saved=name
						end
					end
				end
				if saved~="" then
					string=string.."item_image_button["..tostring(x+((i-1)%w))..","
					..tostring(y+math.floor((i-1)/w))..";1,1;"..saved..";t_758s"..tostring(i+start_index-1)..";group]"
					.."tooltip[t_758s"..tostring(i+start_index-1)..";"
					..string.upper(string.sub(groups,1,1))..string.sub(groups.." ",2).."]"
				end
			end
		end
		if string_old==string and ((stack~=nil and stack:get_name()~="") or show_empty==1) then
			string=string.."list[current_name;"..list..";"..tostring(x+((i-1)%w))..","..tostring(y+math.floor((i-1)/w))
				..";1,1;"..tostring(i-1).."]"
		end
	end
	return string
end


-- returns a formspec string with item amounts
craft_guide.get_amounts = function(meta,inv,list)
	local amounts=""
	local xx=8.1
	local yy=7.45
	local w=6
	local size=18
	if meta:get_string("poslist")=="up" then
		xx=0.1
		yy=1.45
		w=14
		size=70
	end
	for jj=1,size,1 do
		local item=string.lower(inv:get_stack(list,jj):get_name())
		local cnt=1
		if item==nil or item=="" then
			break
		end
		local count=craft_guide.you_need_list[item]
		if count~=nil then
			cnt=math.floor(((count)/tonumber(meta:get_string("globalcount")))*1000+0.49)/1000
			if cnt>1000 then
				cnt=math.floor(cnt+0.49)
			elseif cnt>100 then
				cnt=math.floor(cnt*10+0.49)/10
			elseif cnt>10 then
				cnt=math.floor(cnt*100+0.49)/100
			end
			amounts=amounts.."label["..tostring(xx+((jj-1)%w))..","..tostring(yy+math.floor((jj-1)/w))..";"..tostring(cnt).."]"
		end
		jj=jj+1
		if jj > size then
			break
		end

	end
	return amounts
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
	local globalcount=1
	local list={}
	local list2={}
	local test={}
	local forlist={}
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
		craft_guide.you_need_list=nil
		craft_guide.you_need_list={}
		list[stack:get_name()] = {}
		list[stack:get_name()] = 1
		for j=1,10,1 do	--main iteration loop
			local finished=1
			local limit=inv:get_size("youneed")
			local k=0
			for name,count in pairs(list) do
				if k>limit then
					break
				end
				k=k+1
				local isbase=0
				if name==nil or name=="" or count==0 or string.sub(name,1,6)=="group:" then
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
							if j>1 then
								if #crafts==1 and index<=#crafts then 
									bestvalue=0
									istest=0
								elseif index>#crafts or bestvalue==0 then
									index=bestcraft
									bestvalue=0
									istest=0
								end
							else
								bestvalue=0
								index=alternate
								istest=0
							end
							local craft = crafts[index]
							if craft~=nil and craft.type~="fuel" then
								local amount=count
								if istest==0 then
									list[name]=0
									local output_count=ItemStack(craft.output):get_count()
									if output_count~=1 and (j>1 or k>1) then
										if amount/output_count==math.floor(amount/output_count) then
											amount=amount/output_count
										else
											globalcount=globalcount*output_count
											for _name,_amount in pairs(list) do
												if tonumber(amount)>0 then
													list[_name]=tonumber(_amount)*output_count
												end
											end
										end
									end
								end
								if istest==1 then
									list2=list
									list=nil
									list={}
									list=test
								end
								if craft.type == "cooking" then
									if list[craft.recipe]==nil then
										list[(craft.recipe)]={}
										list[(craft.recipe)]=amount
									else
										local add=amount+tonumber(list[(craft.recipe)])
										list[(craft.recipe)]=add
									end
								else
									if craft.recipe[1] then
										if (type(craft.recipe[1]) == "string") then
											if list[craft.recipe[1]]==nil then
												list[(craft.recipe[1])]={}
												list[(craft.recipe[1])]=amount
											else
												local add =amount+tonumber(list[(craft.recipe[1])])
												list[(craft.recipe[1])]=add
											end
										else
											if craft.recipe[1][1] then
												if list[(craft.recipe[1][1])]==nil then
													list[(craft.recipe[1][1])]={}
													list[(craft.recipe[1][1])]=amount
												else
													local add =amount+tonumber(list[(craft.recipe[1][1])])
													list[(craft.recipe[1][1])]=add
												end
											end
											if craft.recipe[1][2] then
												if list[(craft.recipe[1][2])]==nil then
													list[(craft.recipe[1][2])]={}
													list[(craft.recipe[1][2])]=amount
												else
													local add =amount+tonumber(list[(craft.recipe[1][2])])
													list[(craft.recipe[1][2])]=add
												end
											end
											if craft.recipe[1][3] then
												if list[(craft.recipe[1][3])]==nil then
													list[(craft.recipe[1][3])]={}
													list[(craft.recipe[1][3])]=amount
												else
													local add =amount+tonumber(list[(craft.recipe[1][3])])
													list[(craft.recipe[1][3])]=add
												end
											end
										end
									end
									if craft.recipe[2] then
										if (type(craft.recipe[2]) == "string") then
											if list[(craft.recipe[2])]==nil then
												list[(craft.recipe[2])]={}
												list[(craft.recipe[2])]=amount
											else
												local add =amount+tonumber(list[(craft.recipe[2])])
												list[(craft.recipe[2])]=add
											end
										else
											if craft.recipe[2][1] then
												if list[(craft.recipe[2][1])]==nil then
													list[(craft.recipe[2][1])]={}
													list[(craft.recipe[2][1])]=amount
												else
													local add =amount+tonumber(list[(craft.recipe[2][1])])
													list[(craft.recipe[2][1])]=add
												end
											end
											if craft.recipe[2][2] then
												if list[(craft.recipe[2][2])]==nil then
													list[(craft.recipe[2][2])]={}
													list[(craft.recipe[2][2])]=amount
												else
													local add =amount+tonumber(list[(craft.recipe[2][2])])
													list[(craft.recipe[2][2])]=add
												end
											end
											if craft.recipe[2][3] then
												if list[(craft.recipe[2][3])]==nil then
													list[(craft.recipe[2][3])]={}
													list[(craft.recipe[2][3])]=amount
												else
													local add =amount+tonumber(list[(craft.recipe[2][3])])
													list[(craft.recipe[2][3])]=add
												end
											end
										end
									end
									if craft.recipe[3] then
										if (type(craft.recipe[3]) == "string") then
											if list[(craft.recipe[3])]==nil then
												list[(craft.recipe[3])]={}
												list[(craft.recipe[3])]=amount
											else
												local add =amount+tonumber(list[(craft.recipe[3])])
												list[(craft.recipe[3])]=add
											end
										else
											if craft.recipe[3][1] then
												if list[(craft.recipe[3][1])]==nil then
													list[(craft.recipe[3][1])]={}
													list[(craft.recipe[3][1])]=amount
												else
													local add =amount+tonumber(list[(craft.recipe[3][1])])
													list[(craft.recipe[3][1])]=add
												end
											end
											if craft.recipe[3][2] then
												if list[(craft.recipe[3][2])]==nil then
													list[(craft.recipe[3][2])]={}
													list[(craft.recipe[3][2])]=amount
												else
													local add =amount+tonumber(list[(craft.recipe[3][2])])
													list[(craft.recipe[3][2])]=add
												end
											end
											if craft.recipe[3][3] then
												if list[(craft.recipe[3][3])]==nil then
													list[(craft.recipe[3][3])]={}
													list[(craft.recipe[3][3])]=amount
												else
													local add =amount+tonumber(list[(craft.recipe[3][3])])
													list[(craft.recipe[3][3])]=add
												end
											end
										end
									end
									if craft.recipe[4] then
										if (type(craft.recipe[4]) == "string") then
											if list[(craft.recipe[4])]==nil then
												list[(craft.recipe[4])]={}
												list[(craft.recipe[4])]=amount
											else
												local add =amount+tonumber(list[(craft.recipe[4])])
												list[(craft.recipe[4])]=add
											end
										end
									end
									if craft.recipe[5] then
										if (type(craft.recipe[5]) == "string") then
											if list[(craft.recipe[5])]==nil then
												list[(craft.recipe[5])]={}
												list[(craft.recipe[5])]=amount
											else
												local add =amount+tonumber(list[(craft.recipe[5])])
												list[(craft.recipe[5])]=add
											end
										end
									end
									if craft.recipe[6] then
										if (type(craft.recipe[6]) == "string") then
											if list[(craft.recipe[6])]==nil then
												list[(craft.recipe[6])]={}
												list[(craft.recipe[6])]=amount
											else
												local add =amount+tonumber(list[(craft.recipe[6])])
												list[(craft.recipe[6])]=add
											end
										end
									end
									if craft.recipe[7] then
										if (type(craft.recipe[7]) == "string") then
											if list[(craft.recipe[7])]==nil then
												list[(craft.recipe[7])]={}
												list[(craft.recipe[7])]=amount
											else
												local add =amount+tonumber(list[(craft.recipe[7])])
												list[(craft.recipe[7])]=add
											end
										end
									end
									if craft.recipe[8] then
										if (type(craft.recipe[8]) == "string") then
											if list[(craft.recipe[8])]==nil then
												list[(craft.recipe[8])]={}
												list[(craft.recipe[8])]=amount
											else
												local add =amount+tonumber(list[(craft.recipe[8])])
												list[(craft.recipe[8])]=add
											end
										end
									end
									if craft.recipe[9] then
										if (type(craft.recipe[9]) == "string") then
											if list[(craft.recipe[9])]==nil then
												list[(craft.recipe[9])]={}
												list[(craft.recipe[9])]=amount
											else
												local add =amount+tonumber(list[(craft.recipe[9])])
												list[(craft.recipe[9])]=add
											end
										end
									end
								end
								if istest==1 then
									test=list
									list=nil
									list={}
									list=list2
								end

							end
	

							if istest==1 then
								local value=0
								local h=0
								for name,testcount in pairs(test) do
									h=h+1
									if h>888 then
									break
									end
									if testcount>0 then
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
								end
								if value<bestvalue then
									bestcraft=index
									bestvalue=value
								end
							else
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
	local jj=1
	local duplicate=0
	for name,amount in pairs(list) do
		local count=tonumber(amount)
		if name~=nil and count>0 and string.lower(name)~=string.upper(name) then
			local lower=string.lower(name)
			if craft_guide.you_need_list[lower]~=nil and craft_guide.you_need_list[lower]>0 then
				craft_guide.you_need_list[lower]=count+craft_guide.you_need_list[lower]
			else
				inv:add_item("youneed", lower)
				if inv:get_stack("youneed",jj)==nil or inv:get_stack("youneed",jj):get_name()=="" then
					for jjj=1,jj,1 do
						if inv:get_stack("youneed",jjj):get_count()>1 then
							local alias=string.lower(inv:get_stack("youneed",jjj):get_name())
							craft_guide.you_need_list[alias]=craft_guide.you_need_list[alias]+count
							inv:set_stack("youneed",jjj,alias)

						end
					end
							inv:set_stack("youneed",jj,ItemStack(nil))
							duplicate=1
							list[lower]=0

				elseif string.lower(inv:get_stack("youneed",jj):get_name())~=lower then
					local alias=string.lower(inv:get_stack("youneed",jj):get_name())
					if list[alias]==nil then
						craft_guide.you_need_list[alias]={}
						craft_guide.you_need_list[alias]=count
					else
						list[alias]=list[alias]+count
					end
					list[lower]=0
				else
					craft_guide.you_need_list[lower]={}
					craft_guide.you_need_list[lower]=count
				end
				if duplicate==0 then
					jj=jj+1
				else
					duplicate=0
				end
				if jj>inv:get_size("youneed") then
					break
				end
			end
		end
	end
	meta:set_string("globalcount",tostring(globalcount))
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
