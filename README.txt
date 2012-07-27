----------------------------------
MINETEST CRAFT GUIDE
----------------------------------

Copyright (C) 2012 cornernote, Brett O'Donnell <cornernote@gmail.com>

Source Code: https://github.com/cornernote/minetest-craft_guide



----------------------------------
License
----------------------------------


This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.



----------------------------------
DESCRIPTION
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
CREDITS
----------------------------------

cornernote - author
marktraceur - help in irc
ashenk69 - author of creative_inventory which inspired me to make this
darkrose - updating core to support a craft registry
cactuz_pl - nodebox for the lcd
many others that make up the minetest community!



----------------------------------
VERSION HISTORY
----------------------------------

0.1.1
- complete rewrite of how inventory is stored (copied from new core creative inventory)
- use new core craft registry (no more core hack required)
- use new formspec (next/prev buttons, text, etc)
- added a object - craft_guide:lcd_pc
- added textures

----------------------------------

0.0.2
- added bookmarks
- added support for shapeless recipies
- added support for output quantity
- changed name of the sign to "Learn to Craft"
- fixed bug causing non-building/cooking crafts to not register (eg cooking itself did not load)
- fixed bug causing game to crash when viewing non-craftable items

----------------------------------

0.0.1 
- initial release

----------------------------------