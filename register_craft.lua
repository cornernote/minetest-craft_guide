-- OVERRIDE REGISTER CRAFT
crafts = {}
local minetest_register_craft = minetest.register_craft
minetest.register_craft = function (options) 
	minetest_register_craft(options) 
	if  options.output == nil then
		return
	end
	local itemstack = ItemStack(options.output)
	if itemstack:is_empty() then
		return
	end
	minetest.log("action", "REGISTER CRAFT - "..itemstack:get_name())
	crafts[itemstack:get_name()] = options
end