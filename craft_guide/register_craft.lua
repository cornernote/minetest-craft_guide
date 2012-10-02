--[[

Craft Guide for Minetest

Copyright (c) 2012 cornernote, Brett O'Donnell <cornernote@gmail.com>
Source Code: https://github.com/cornernote/minetest-craft_guide
License: GPLv3

REGISTER CRAFTS

]]--


-- craft sign
minetest.register_craft({
	output = 'craft_guide:sign_wall',
	recipe = {
		{'default:stick', 'default:stick'},
		{'default:stick', 'default:stick'},
		{'default:stick', ''},
	}
})


-- craft pc
minetest.register_craft({
	output = 'craft_guide:lcd_pc',
	recipe = {
		{'craft_guide:sign_wall'},
		{'default:glass'},
		{'stairs:slab_stone'},
	}
})
minetest.register_craft({
	output = 'craft_guide:lcd_pc',
	recipe = {
		{'craft_guide:sign_wall'},
		{'default:glass'},
		{'stairsplus:slab_stone'},
	}
})
