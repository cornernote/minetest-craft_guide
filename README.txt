----------------------------------
Craft Guide for Minetest
----------------------------------

Copyright (C) 2012 cornernote, Brett O'Donnell <cornernote@gmail.com>
Source Code: https://github.com/cornernote/minetest-craft_guide

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


----------------------------------
Description
----------------------------------

Provides items that will show you how to craft any craftable or cookable item.

It works like this...
build a craft_guide:sign_wall using default:stick shaped like a question mark:
stick stick
stick stick
stick     

(ok, so a question mark isn't perfect in a 3x3)  =)

place the sign, then right click on it... it will open like a chest.

to see the recipe for an item, drop the item into the output slot

you can bookmark items using the block on the right


----------------------------------
SOME ITEMS NOT LOADING?
----------------------------------

If items are not loading then it is probably because craft_guide is loaded after the other items. 

To fix this simply create a depends.txt in the module in question, and add the text "craft_guide".

EG: crafts from default mod are not available - create games/minetest_game/default/depends.txt with this inside:
craft_guide


----------------------------------
MY ITEM IS SECRET, HOW CAN I HIDE IT?
----------------------------------

In your node definition, set groups={not_in_craft_guide}


----------------------------------
Credits
----------------------------------

marktraceur - help in irc
ashenk69 - author of creative_inventory which inspired me to make this
darkrose - updating core to support a craft registry
cactuz_pl - nodebox for the lcd

