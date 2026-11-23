================================================================
 ITEMS & ICONS MEGA PACK - 16x16 inventory icons  (v1.0)
 Pack 10 of a free pixel-art series - same grid, style and 58-colour palette
================================================================

HONEST COUNT (computed by code: md5 dedupe over every counted cell, empty cells ignored, rounded DOWN)
  1050 original 16x16 icons  -> advertised as "1,000+ original icons"
      weapons 203, armor & accessories 137, food & drink 178, potions & alchemy 80,
      materials 129, tools 72, gems & treasure 51, quest & misc 136,
      cross-pack icons 64
  1255 recolors (listed separately - material tiers, gem colours, potion effects, wood types, dyes, elements)
  136 animation frames (frames identical to a static icon or <=3 px from another counted cell are NOT counted)
  12 hero 32x32 versions of legendary weapons
  = 2453 unique sprites  (+ 140 inventory UI pieces counted on their own)
  Near-duplicate icons (<=3 px from another icon) excluded from the headline: 0
  A "new icon" = a new silhouette or design. Tier / colour variants never count as originals.

RECOLORS PER CATEGORY
  weapons     349  (crystal, gold, iron, mythril, wood)
  armor       211  (amethyst, dark_steel, diamond, dye_black, dye_green, dye_purple, dye_red, dye_white, emerald, gold, iron, mythril, sapphire, topaz)
  potions     188  (air, earth, fire, frost, love, luck, mana, poison, shadow, spirit, stamina, water)
  materials   284  (adamantite, air, birch, black, bloodwood, blue, bronze, cobalt, copper, dark, earth, ebony, ghostwood, gold, green, iron, light, mythril, orange, pine, pink, purple, silver, spirit, starmetal, tin, water, white, yellow)
  gems        144  (amethyst, aquamarine, diamond, emerald, onyx, peridot, sapphire, topaz)
  tools        56  (crystal, gold, iron, mythril, wood)
  food         19  (berry, blue, blueberry, cola, gold, grape, green, lemon, mango, mint, orange, pistachio, purple, red)
  quest         4  (blue, green, red)

ANIMATIONS (09_Animated, strips left->right, 16x16 frames unless noted)
  Legendary_Glow          8 strips,  26 frames
  Gem_Glint               8 strips,  32 frames
  Potion_Bubble           8 strips,  32 frames
  Coin_Key_Spin           8 strips,  40 frames
  Quest_Shine             7 strips,  26 frames
  Legendary_Glow_32x32    4 strips,  16 frames
  Strip names end in _Nf (N unique frames). Every frame changes pixels (checked by code).
  Each strip has a 4x preview GIF in preview_gifs/.

FOLDERS
  01_Weapons ... 08_Quest_Misc   one sheet per sub-category: <category>_<sub>_sheet.png, 16 columns of 16x16 cells,
                                 row-major, SAME ORDER as the database. icons/ holds one PNG per icon (<category>_<name>.png).
                                 recolors/ holds the tier / colour sheets (same order as the base sheet, tagged recolor).
  01_Weapons/Legendary/hero_32x32   12 hero versions (32x32) of legendary weapons.
  09_Animated                    glow / glint / bubble / spin / twirl / shine strips.
  10_Inventory_UI                slot frames, rarity slots & borders, tooltip (9-slice, 8px border), stack-count font,
                                 equipment silhouettes, category tabs, durability bars, quality stars, NEW badge, drag
                                 ghost, crafting symbols + progress arrow, shop price tags, coin counter, trash, sort.
  11_Cross_Pack_Icons            inventory icons for furniture / town-kit / festival / dungeon objects of packs 2, 4, 5, 8
                                 that only had a world sprite (see CROSS_PACK_ICONS.txt for the source of each).
  Database                       item_database.csv / .json (all 2305 icons incl. recolors)
  items_atlas_16x16.png/.tsx     master atlas, 32 columns; atlas_index in the database = tile id in the .tsx.
  Example_Screens                inventory, crafting, shop, equipment mock-ups (1280x720).
  Previews                       overview pages (1280x720) and the 1,000+ icon wall poster.
  Palette                        palette_58.png / .hex / .gpl (no new colours were added in this pack).

DATABASE COLUMNS
  id, name, category, subcategory, type (original / recolor), base_item (for recolors), sheet, cell_index (in that sheet),
  atlas_index, rarity (common, uncommon, rare, epic, legendary), value (suggested shop price in coins), stats
  (suggested: atk / def / heal / effect / power), source_pack (cross-pack icons).
  Cell -> pixels: x = (cell_index % 16) * 16, y = (cell_index // 16) * 16. Atlas: x = (atlas_index % 32) * 16, y = (atlas_index // 32) * 16.

STYLE
  16x16 icons in 3/4 view, weapons pointing to the top-right, light from the top-left, 1px dark outline (#2b1e2f) around
  every separate part, 1px margin inside the cell (nothing touches the cell border - checked by code).
  Rarity colours match packs 2 and 9: common grey, uncommon green, rare blue, epic purple, legendary gold.

SHEET LAYOUTS (original icons, index:name)
  01_Weapons/Swords/weapons_swords_sheet.png  (28 icons, 16 per row)
      0:Arming Sword, 1:Knights Longsword, 2:Broadsword, 3:Leaf Blade, 4:Flamberge, 5:Cavalry Sabre, 6:Curved Katana
      7:Duelling Rapier, 8:Butcher Cleaver, 9:Falchion, 10:Sawtooth Sword, 11:Khopesh, 12:Zweihander
      13:Crystal Shard Sword, 14:Bone Cutter, 15:Desert Scimitar, 16:Winged Sword, 17:Short Gladius, 18:Estoc
      19:Hooked Blade, 20:Ring Hilt Sword, 21:Pirate Cutlass, 22:Ceremonial Sword, 23:Swept Rapier, 24:Crescent Sword
      25:Training Sword, 26:Great Cleaver, 27:Wavy Kris Sword
  01_Weapons/Daggers/weapons_daggers_sheet.png  (14 icons, 16 per row)
      0:Stiletto, 1:Kris Dagger, 2:Kukri, 3:Parrying Dagger, 4:Tanto, 5:Bone Knife, 6:Hunting Knife, 7:Glass Dagger
      8:Ritual Knife, 9:Main Gauche, 10:Serrated Shiv, 11:Leaf Knife, 12:Karambit, 13:Sai
  01_Weapons/Axes/weapons_axes_sheet.png  (10 icons, 16 per row)
      0:Bearded Axe, 1:Double Bit Axe, 2:Crescent Axe, 3:Hatchet, 4:Tomahawk, 5:Broad Axe, 6:War Pick, 7:Dane Axe
      8:Hooked Axe, 9:Moon Axe
  01_Weapons/Maces_Hammers/weapons_maces_hammers_sheet.png  (12 icons, 16 per row)
      0:Morning Star, 1:Flanged Mace, 2:Spiked Club, 3:Warhammer, 4:Maul, 5:Scepter, 6:Tenderizer, 7:Flail
      8:Bone Club, 9:Studded Club, 10:Sledge, 11:Gavel Hammer
  01_Weapons/Polearms/weapons_polearms_sheet.png  (14 icons, 16 per row)
      0:Leaf Spear, 1:Trident, 2:Partisan, 3:Glaive, 4:Halberd, 5:Naginata, 6:Pike, 7:Jousting Lance, 8:Ranseur
      9:Bec De Corbin, 10:Battle Fork, 11:Harpoon, 12:War Scythe, 13:Voulge
  01_Weapons/Bows_Crossbows/weapons_bows_crossbows_sheet.png  (11 icons, 16 per row)
      0:Longbow, 1:Recurve Bow, 2:Short Bow, 3:Composite Bow, 4:Elven Bow, 5:Bone Bow, 6:Heavy Crossbow
      7:Repeater Crossbow, 8:Hand Crossbow, 9:Light Crossbow, 10:Slingshot
  01_Weapons/Staves_Wands/weapons_staves_wands_sheet.png  (26 icons, 16 per row)
      0:Crook Staff, 1:Orb Cage Staff, 2:Crescent Staff, 3:Branch Staff, 4:Crystal Staff, 5:Feather Staff
      6:Ring Gem Staff, 7:Serpent Staff, 8:Lantern Staff, 9:Skull Staff, 10:Flame Staff, 11:Sun Staff, 12:Leafy Staff
      13:Trident Tip Staff, 14:Hourglass Staff, 15:Bell Staff, 16:Star Wand, 17:Heart Wand, 18:Spiral Wand
      19:Bolt Wand, 20:Drop Wand, 21:Leaf Wand, 22:Flame Wand, 23:Moon Wand, 24:Eye Wand, 25:Snowflake Wand
  01_Weapons/Scythes_Whips/weapons_scythes_whips_sheet.png  (8 icons, 16 per row)
      0:Reaper Scythe, 1:Farm Scythe, 2:Moon Scythe, 3:Bone Scythe, 4:Leather Whip, 5:Chain Whip, 6:Thorn Whip
      7:Flame Whip
  01_Weapons/Throwables/weapons_throwables_sheet.png  (12 icons, 16 per row)
      0:Throwing Star, 1:Chakram, 2:Kunai, 3:Dart, 4:Throwing Axe, 5:Bolas, 6:Boomerang, 7:Bone Boomerang
      8:Steel Boomerang, 9:Throwing Knife Set, 10:Smoke Bomb, 11:Fire Flask
  01_Weapons/Shields/weapons_shields_sheet.png  (16 icons, 16 per row)
      0:Heater Shield, 1:Kite Shield, 2:Round Boss Shield, 3:Tower Shield, 4:Buckler Spike Shield, 5:Pavise Shield
      6:Targe Shield, 7:Scale Shield, 8:Crest Lion Shield, 9:Split Banner Shield, 10:Wooden Planks Shield
      11:Dragon Scale Shield, 12:Mirror Shield, 13:Spiked Round Shield, 14:Turtle Shell Shield, 15:Sun Aegis Shield
  01_Weapons/Ammo/weapons_ammo_sheet.png  (17 icons, 16 per row)
      0:Broadhead Arrow, 1:Bodkin Arrow, 2:Arrow Bundle, 3:Arrow Quiver, 4:Fire Arrow, 5:Ice Arrow, 6:Poison Arrow
      7:Whistle Arrow, 8:Rope Arrow, 9:Crossbow Bolt, 10:Bolt Bundle, 11:Lead Bullets, 12:Musket Ball Pouch
      13:Cannonball, 14:Sling Stones, 15:Blowgun Darts, 16:Ballista Bolt
  01_Weapons/Legendary/weapons_legendary_sheet.png  (35 icons, 16 per row)
      0:Sunblade, 1:Frostfang, 2:Void Reaver, 3:Dragonbone Greatsword, 4:Phoenix Edge, 5:Stormcaller
      6:Moonlight Sabre, 7:Verdant Thornblade, 8:Soul Eater, 9:Kings Oath, 10:Abyss Cleaver, 11:Starfall Rapier
      12:Bloodmoon Katana, 13:Titan Slayer, 14:Assassins Whisper, 15:Ember Kris, 16:World Splitter
      17:Frost Reaver Axe, 18:Forest Warden Axe, 19:Celestial Spear, 20:Sea Kings Trident, 21:Dragon Glaive
      22:Ghost Halberd, 23:Thunder Hammer, 24:Earthshaker, 25:Sunfire Bow, 26:Wind Whisper Bow, 27:Shadow Crossbow
      28:Archmage Staff, 29:World Tree Staff, 30:Chrono Staff, 31:Inferno Staff, 32:Aegis Of Dawn
      33:Dragon Heart Shield, 34:Frost Bastion
  02_Armor/Helmets/armor_helmets_sheet.png  (24 icons, 16 per row)
      0:Great Helm, 1:Sallet, 2:Horned Helm, 3:Winged Helm, 4:Barbute, 5:Bascinet, 6:Kettle Hat, 7:Spangenhelm
      8:Kabuto, 9:Skull Helm, 10:Tricorn, 11:Straw Hat, 12:Top Hat, 13:Feathered Cap, 14:Circlet, 15:Plague Mask
      16:Bandana, 17:Crown Helm, 18:Cloth Cap, 19:Leather Cap, 20:Chain Coif, 21:Plate Helm, 22:Mage Hat
      23:Ranger Hood
  02_Armor/Chest/armor_chest_sheet.png  (17 icons, 16 per row)
      0:Plate Cuirass, 1:Chainmail Shirt, 2:Leather Jerkin, 3:Cloth Robe, 4:Mage Robe, 5:Ranger Tunic, 6:Brigandine
      7:Scale Mail, 8:Lamellar, 9:Emblem Breastplate, 10:Padded Gambeson, 11:Fur Vest, 12:Tabard, 13:Bone Armor
      14:Dragon Scale Vest, 15:Cloth Shirt, 16:Ranger Vest
  02_Armor/Legs/armor_legs_sheet.png  (6 icons, 16 per row)
      0:Cloth Trousers, 1:Leather Pants, 2:Chain Leggings, 3:Plate Greaves, 4:Mage Skirt, 5:Ranger Breeches
  02_Armor/Gloves/armor_gloves_sheet.png  (12 icons, 16 per row)
      0:Cloth Gloves, 1:Leather Gloves, 2:Chain Mitts, 3:Plate Gauntlet, 4:Mage Gloves, 5:Ranger Bracers
      6:Fingerless Gloves, 7:Fur Mittens, 8:Claw Gauntlet, 9:Boxing Wraps, 10:Silk Gloves, 11:Smith Gloves
  02_Armor/Boots/armor_boots_sheet.png  (12 icons, 16 per row)
      0:Cloth Shoes, 1:Leather Boots, 2:Chain Boots, 3:Plate Sabatons, 4:Mage Slippers, 5:Ranger Boots, 6:Winged Boots
      7:Sandals, 8:Fur Boots, 9:Riding Boots, 10:Wooden Clogs, 11:Spiked Boots
  02_Armor/Belts/armor_belts_sheet.png  (10 icons, 16 per row)
      0:Leather Belt, 1:Silk Sash, 2:Utility Belt, 3:Chain Belt, 4:Plate Belt, 5:Champion Belt, 6:Rope Belt
      7:Bandolier, 8:Mage Cord, 9:Ranger Belt
  02_Armor/Cloaks/armor_cloaks_sheet.png  (8 icons, 16 per row)
      0:Hooded Cloak, 1:Clasp Cape, 2:Fur Mantle, 3:Feather Cloak, 4:Tattered Cloak, 5:Royal Cape, 6:Poncho, 7:Shawl
  02_Armor/Rings/armor_rings_sheet.png  (16 icons, 16 per row)
      0:Plain Band, 1:Signet Ring, 2:Twisted Ring, 3:Double Band, 4:Solitaire Ring, 5:Three Stone Ring, 6:Serpent Ring
      7:Leaf Ring, 8:Spiked Ring, 9:Crown Ring, 10:Moon Ring, 11:Heart Ring, 12:Eye Ring, 13:Braided Ring
      14:Claw Set Ring, 15:Skull Ring
  02_Armor/Amulets/armor_amulets_sheet.png  (16 icons, 16 per row)
      0:Teardrop Pendant, 1:Round Locket, 2:Sun Medallion, 3:Moon Pendant, 4:Star Pendant, 5:Key Pendant
      6:Tooth Necklace, 7:Shell Necklace, 8:Feather Charm, 9:Heart Locket, 10:Eye Amulet, 11:Tri Gem Pendant
      12:Pearl Strand, 13:Scarab Amulet, 14:Crystal Shard Pendant, 15:Rune Stone Necklace
  02_Armor/Earrings/armor_earrings_sheet.png  (8 icons, 16 per row)
      0:Hoop Earrings, 1:Stud Earrings, 2:Drop Earrings, 3:Feather Earrings, 4:Chandelier Earrings
      5:Crescent Earrings, 6:Ear Cuff, 7:Chain Drops
  02_Armor/Bracelets/armor_bracelets_sheet.png  (8 icons, 16 per row)
      0:Bangle, 1:Cuff Bracelet, 2:Beaded Bracelet, 3:Chain Bracelet, 4:Charm Bracelet, 5:Leather Band, 6:Gem Bangle
      7:Snake Armlet
  03_Food_Drink/Meals/food_meals_sheet.png  (32 icons, 16 per row)
      0:Spaghetti, 1:Omelette, 2:Curry Rice, 3:Burger, 4:Hot Dog, 5:Pizza Slice, 6:Whole Pizza, 7:Taco, 8:Burrito
      9:Dumpling Steamer, 10:Fried Rice, 11:Meatballs, 12:Shepherds Pie, 13:Lasagna, 14:Mashed Potatoes
      15:Baked Potato, 16:Fries Cone, 17:Chicken Wings, 18:Pork Chop, 19:Bbq Ribs, 20:Bento Box, 21:Club Sandwich
      22:Quiche, 23:Stuffed Pepper, 24:Cheese Fondue, 25:Hot Pot, 26:Gyoza Plate, 27:Roast Turkey, 28:Steak Frites
      29:Noodle Box, 30:Stir Fry Wok, 31:Kebab Plate
  03_Food_Drink/Bakery/food_bakery_sheet.png  (24 icons, 16 per row)
      0:Bagel, 1:Muffin, 2:Cinnamon Roll, 3:Eclair, 4:Fruit Tart, 5:Macaron, 6:Scone, 7:Fruit Danish, 8:Waffle
      9:Crepe Roll, 10:Sweet Bun, 11:Rye Loaf, 12:Braided Loaf, 13:Lattice Pie, 14:Layer Cake, 15:Cheesecake Slice
      16:Swiss Roll, 17:Brownie, 18:Biscotti, 19:Pita Bread, 20:Cornbread, 21:Cream Puff, 22:Bread Basket
      23:Honey Cake
  03_Food_Drink/Fruit_Veg/food_fruit_veg_sheet.png  (38 icons, 16 per row)
      0:Banana Bunch, 1:Kiwi Half, 2:Mango, 3:Papaya Half, 4:Dragonfruit, 5:Lychee Cluster, 6:Coconut Half
      7:Avocado Half, 8:Persimmon, 9:Passion Fruit Half, 10:Durian, 11:Guava, 12:Blood Orange Half, 13:Quince
      14:Gooseberries, 15:Elderberry Sprig, 16:Mulberries, 17:Beetroot, 18:Turnip, 19:Red Onion, 20:Zucchini
      21:Chili Pepper, 22:Broccoli, 23:Shiitake, 24:Enoki Bunch, 25:Red Cap Mushroom, 26:Yam, 27:Taro Root
      28:Lotus Root Slice, 29:Olive Sprig, 30:Edamame Pod, 31:Brussels Sprouts, 32:Celery Bunch, 33:Fennel Bulb
      34:Rainbow Chard, 35:Horseradish Root, 36:Pomelo, 37:Starapple Purple
  03_Food_Drink/Fish_Dishes/food_fish_dishes_sheet.png  (17 icons, 16 per row)
      0:Fish Taco, 1:Fish And Chips, 2:Sashimi Plate, 3:Fish Skewer, 4:Smoked Fish, 5:Fish Pie, 6:Onigiri, 7:Crab Cake
      8:Boiled Shrimp, 9:Lobster, 10:Calamari Rings, 11:Clam Chowder Bowl, 12:Seaweed Salad, 13:Fish Sandwich
      14:Grilled Eel, 15:Fish Soup Pot, 16:Paella Pan
  03_Food_Drink/Sweets/food_sweets_sheet.png  (22 icons, 16 per row)
      0:Lollipop, 1:Swirl Lollipop, 2:Chocolate Bar, 3:Chocolate Truffles, 4:Gummy Bear, 5:Jelly Cubes, 6:Pudding Cup
      7:Caramel Flan, 8:Ice Pop, 9:Wrapped Candy, 10:Rock Candy Stick, 11:Marshmallow Stick, 12:Smore
      13:Toffee Squares, 14:Licorice Wheel, 15:Candy Heart Box, 16:Peppermint Candy, 17:Nougat Bar, 18:Praline Cluster
      19:Fudge Slab, 20:Jelly Bean Jar, 21:Cotton Candy Pink Cone
  03_Food_Drink/Drinks/food_drinks_sheet.png  (22 icons, 16 per row)
      0:Smoothie Cup, 1:Milkshake, 2:Bubble Tea, 3:Cocktail Glass, 4:Sake Bottle, 5:Mead Horn, 6:Soda Bottle
      7:Juice Box, 8:Herbal Flask, 9:Coconut Drink, 10:Wine Goblet, 11:Leather Canteen, 12:Lidded Stein
      13:Espresso Cup, 14:Latte Mug, 15:Matcha Bowl, 16:Punch Bowl, 17:Champagne Flute, 18:Glass Water Bottle
      19:Milk Carton, 20:Cider Jug, 21:Iced Tea Glass
  03_Food_Drink/Festival_Food/food_festival_food_sheet.png  (12 icons, 16 per row)
      0:Dango, 1:Fish Waffle, 2:Mooncake, 3:Funnel Cake, 4:Popcorn Bucket, 5:Nachos Tray, 6:Candied Nuts Cone
      7:Kings Cake, 8:Gingerbread House, 9:Festival Skewer, 10:Sugar Pretzel Stick, 11:Lantern Jelly
  03_Food_Drink/Raw_Ingredients/food_raw_ingredients_sheet.png  (11 icons, 16 per row)
      0:Raw Tbone, 1:Raw Fish Fillet, 2:Raw Sausage Links, 3:Raw Shrimp Pile, 4:Raw Rib Rack, 5:Raw Chicken Wing
      6:Raw Patty, 7:Bread Dough, 8:Raw Squid, 9:Raw Eel, 10:Flour Dough Ball
  04_Potions_Alchemy/Potion_Bottles/potions_potion_bottles_sheet.png  (20 icons, 16 per row)
      0:Round Flask, 1:Conical Flask, 2:Tall Vial, 3:Square Bottle, 4:Heart Bottle, 5:Star Bottle, 6:Teardrop Bottle
      7:Double Bulb, 8:Test Tube, 9:Ampoule, 10:Hip Flask, 11:Gourd Bottle, 12:Potion Jug, 13:Crystal Phial, 14:Beaker
      15:Labeled Bottle, 16:Skull Bottle, 17:Vial Trio, 18:Diamond Bottle, 19:Spiral Bottle
  04_Potions_Alchemy/Elixirs/potions_elixirs_sheet.png  (10 icons, 16 per row)
      0:Dragon Elixir, 1:Phoenix Tears, 2:Elixir Of Life, 3:Giant Draught, 4:Shrink Drops, 5:Liquid Luck
      6:Starlight Essence, 7:Void Tonic, 8:Rainbow Elixir, 9:Philter Of Ages
  04_Potions_Alchemy/Herbs/potions_herbs_sheet.png  (20 icons, 16 per row)
      0:Mandrake Root, 1:Nightshade, 2:Sage Bundle, 3:Wolfsbane, 4:Moonpetal, 5:Sunleaf, 6:Bloodthorn, 7:Frostfern
      8:Glowcap Cluster, 9:Silverleaf, 10:Ghost Orchid, 11:Mint Sprig, 12:Dream Lotus, 13:Ember Moss, 14:Witch Hazel
      15:Star Anise, 16:Thornapple, 17:Cave Lichen, 18:Bog Bean, 19:Rootbark Bundle
  04_Potions_Alchemy/Powders/potions_powders_sheet.png  (10 icons, 16 per row)
      0:Paper Packet, 1:Dust Vial, 2:Drawstring Pouch, 3:Glitter Jar, 4:Ash Urn, 5:Sulfur Bowl, 6:Powder Spoon
      7:Bone Meal Sack, 8:Salt Crystals, 9:Spore Puffball
  04_Potions_Alchemy/Scrolls/potions_scrolls_sheet.png  (10 icons, 16 per row)
      0:Sealed Roll, 1:Open Rune Scroll, 2:Ribbon Scroll, 3:Scroll Case, 4:Burnt Scroll, 5:Double Scroll
      6:Wanted Scroll, 7:Spell Scroll Glow, 8:Map Fragment, 9:Tied Bundle
  04_Potions_Alchemy/Alchemy_Tools/potions_alchemy_tools_sheet.png  (10 icons, 16 per row)
      0:Mortar And Pestle, 1:Alembic, 2:Crucible, 3:Retort, 4:Philosophers Stone, 5:Mini Cauldron, 6:Distill Coil
      7:Balance Scale, 8:Potion Rack, 9:Funnel And Flask
  05_Materials/Metals/materials_metals_sheet.png  (24 icons, 16 per row)
      0:Ore Chunk, 1:Ore Pile, 2:Ore Vein Slab, 3:Nugget, 4:Ingot, 5:Ingot Stack, 6:Metal Rod, 7:Metal Sheet
      8:Wire Coil, 9:Chain Links, 10:Rivets, 11:Gear, 12:Spring, 13:Screws, 14:Hinge, 15:Metal Scrap, 16:Ring Blanks
      17:Molten Bucket, 18:Metal Dust Pile, 19:Alloy Bar, 20:Metal Tube, 21:Nut And Bolt, 22:Buckle Blank, 23:Thimbles
  05_Materials/Wood/materials_wood_sheet.png  (17 icons, 16 per row)
      0:Log, 1:Log Pile, 2:Plank, 3:Plank Stack, 4:Beam, 5:Branch, 6:Stick Bundle, 7:Bark Strip, 8:Sawdust Bag
      9:Wood Chips, 10:Dowel Bundle, 11:Wood Shingles, 12:Stump Round, 13:Carved Block, 14:Twig Bundle, 15:Resin Lump
      16:Wooden Peg Set
  05_Materials/Stone_Building/materials_stone_building_sheet.png  (19 icons, 16 per row)
      0:Stone Block, 1:Cobblestones, 2:Brick, 3:Brick Stack, 4:Marble Slab, 5:Slate Tiles, 6:Roof Tiles, 7:Sand Pile
      8:Gravel Heap, 9:Flint Shard, 10:Mortar Bucket, 11:Cement Bag, 12:Glass Pane, 13:Glass Shards, 14:Pebbles
      15:Marble Tile, 16:Pillar Segment, 17:Clay Brick Raw, 18:Timber Frame
  05_Materials/Textiles_Leather/materials_textiles_leather_sheet.png  (21 icons, 16 per row)
      0:Folded Cloth, 1:Cloth Scrap, 2:Sewing Patch, 3:Thread Spool, 4:Pin Cushion, 5:Buttons, 6:Lace Roll
      7:Silk Cocoon, 8:Felt Squares, 9:Ribbon Roll, 10:Canvas Roll, 11:Burlap Sack, 12:Embroidery Hoop, 13:Yarn Skein
      14:Raw Hide, 15:Tanned Leather Roll, 16:Leather Strips, 17:Fur Pelt, 18:Scaled Hide, 19:Leather Laces
      20:Sinew Cord
  05_Materials/Monster_Parts/materials_monster_parts_sheet.png  (22 icons, 16 per row)
      0:Spider Leg, 1:Eyestalk, 2:Tentacle Tip, 3:Imp Tail, 4:Griffon Talon, 5:Basilisk Eye, 6:Unicorn Horn
      7:Hydra Tooth, 8:Chimera Mane, 9:Wyvern Barb, 10:Golem Rune Stone, 11:Beetle Carapace, 12:Troll Hair
      13:Ghost Chain, 14:Banshee Veil, 15:Cockatrice Comb, 16:Mermaid Scale, 17:Kraken Sucker, 18:Salamander Tail
      19:Minotaur Horn, 20:Sphinx Whisker, 21:Lich Phylactery Shard
  05_Materials/Essences/materials_essences_sheet.png  (10 icons, 16 per row)
      0:Wisp Orb, 1:Essence Flame, 2:Essence Drop, 3:Stardust Pile, 4:Swirl Mote, 5:Essence Tube, 6:Spirit Flame Jar
      7:Rune Mote, 8:Mana Shard, 9:Soul Fragment
  05_Materials/Dyes/materials_dyes_sheet.png  (6 icons, 16 per row)
      0:Pigment Pouch, 1:Paint Tube, 2:Dye Cake, 3:Ink Bottle Round, 4:Pigment Bowl, 5:Chalk Sticks
  05_Materials/Misc_Crafting/materials_misc_crafting_sheet.png  (10 icons, 16 per row)
      0:Glue Pot, 1:Tar Bucket, 2:Wax Block, 3:Charcoal Lumps, 4:Oil Can, 5:Sandpaper, 6:Polish Cloth, 7:Pitch Ball
      8:Quartz Sand Jar, 9:Binding Twine
  06_Tools/Fishing/tools_fishing_sheet.png  (12 icons, 16 per row)
      0:Fly Rod, 1:Bamboo Pole, 2:Hand Net, 3:Tackle Box, 4:Spoon Lure, 5:Fly Lure, 6:Popper Lure, 7:Bobber
      8:Fish Hook, 9:Bait Jar, 10:Fish Trap Basket, 11:Crab Net
  06_Tools/Mining/tools_mining_sheet.png  (10 icons, 16 per row)
      0:Double Pick, 1:Hand Drill, 2:Stone Chisel, 3:Gold Pan, 4:Mining Helmet, 5:Dynamite Bundle, 6:Ore Cart
      7:Prospector Hammer, 8:Rock Sieve, 9:Gem Loupe
  06_Tools/Farming/tools_farming_sheet.png  (10 icons, 16 per row)
      0:Sickle, 1:Garden Rake, 2:Spade, 3:Dibber, 4:Seed Spreader, 5:Pruning Shears, 6:Wheelbarrow, 7:Hand Cultivator
      8:Garden Fork, 9:Hay Hook
  06_Tools/Crafting/tools_crafting_sheet.png  (12 icons, 16 per row)
      0:Wooden Mallet, 1:Smith Tongs, 2:Metal File, 3:Wood Plane, 4:Leather Awl, 5:Measuring Tape, 6:Square Ruler
      7:Sewing Kit, 8:Paint Brush, 9:Carving Knife, 10:Bow Drill, 11:Dividers
  06_Tools/Adventuring/tools_adventuring_sheet.png  (16 icons, 16 per row)
      0:Grappling Hook, 1:Bedroll, 2:Tent Bundle, 3:Spyglass, 4:Sun Compass, 5:Brass Whistle, 6:Flint And Steel
      7:Waterskin, 8:Climbing Pick, 9:Bullseye Lantern, 10:Crystal Lantern, 11:Magnifying Glass, 12:Signal Horn
      13:Rope Ladder, 14:Torch Bundle, 15:Travel Pack
  06_Tools/Keys_Locks/tools_keys_locks_sheet.png  (12 icons, 16 per row)
      0:Crystal Key, 1:Bone Key, 2:Heart Key, 3:Star Key, 4:Gear Key, 5:Double Bit Key, 6:Ornate Key, 7:Tiny Key
      8:Combination Lock, 9:Rune Lock, 10:Lockpick Roll, 11:Skeleton Master Ring
  07_Gems_Treasure/Gem_Cuts/gems_gem_cuts_sheet.png  (20 icons, 16 per row)
      0:Round Brilliant, 1:Oval Cut, 2:Emerald Cut, 3:Pear Cut, 4:Marquise Cut, 5:Heart Cut, 6:Trillion Cut
      7:Cushion Cut, 8:Princess Cut, 9:Baguette Cut, 10:Cabochon, 11:Briolette, 12:Star Cut, 13:Hexagon Cut
      14:Raw Crystal Cluster, 15:Geode Half, 16:Uncut Rough Gem, 17:Gem Shard Pile, 18:Pearl, 19:Fire Opal
  07_Gems_Treasure/Treasure/gems_treasure_sheet.png  (31 icons, 16 per row)
      0:Royal Crown, 1:Spiked Crown, 2:Jeweled Tiara, 3:Laurel Wreath, 4:Cat Idol, 5:Frog Idol, 6:Owl Idol, 7:Sun Disk
      8:Relic Chalice, 9:Jeweled Orb, 10:Golden Mask, 11:Square Hole Coin, 12:Triangle Coin, 13:Gem Coin, 14:Doubloon
      15:Coin Towers, 16:Coin Purse Spill, 17:Treasure Sack, 18:Treasure Pile, 19:Overflowing Chest, 20:Jewelry Box
      21:Silver Platter, 22:Jeweled Egg, 23:Golden Statuette, 24:Ancient Vase, 25:Golden Apple, 26:Golden Feather
      27:Crystal Skull, 28:Jade Dragon, 29:Silver Candelabra, 30:Ornate Mirror
  08_Quest_Misc/Letters_Mail/quest_letters_mail_sheet.png  (10 icons, 16 per row)
      0:Sealed Envelope, 1:Love Letter, 2:Pinned Note, 3:Invitation Card, 4:Telegram Strip, 5:Parcel Package
      6:Postcard, 7:Folded Note, 8:Letter Bundle, 9:Royal Decree
  08_Quest_Misc/Books/quest_books_sheet.png  (14 icons, 16 per row)
      0:Locked Journal, 1:Pocket Book, 2:Book Stack, 3:Ledger, 4:Cookbook, 5:Bestiary Tome, 6:Atlas Book
      7:Open Notebook, 8:Eye Grimoire, 9:Herb Almanac, 10:Star Atlas, 11:Picture Book, 12:Ancient Codex
      13:Bookmarked Novel
  08_Quest_Misc/Maps/quest_maps_sheet.png  (8 icons, 16 per row)
      0:X Marks Map, 1:Star Chart, 2:Nautical Chart, 3:Dungeon Map, 4:Compass Rose Tile, 5:Rolled Maps, 6:Globe Small
      7:Coordinates Note
  08_Quest_Misc/Artefacts/quest_artefacts_sheet.png  (14 icons, 16 per row)
      0:Obelisk Fragment, 1:Mirror Shard, 2:Sundial, 3:Astrolabe, 4:Clockwork Heart, 5:Tribal Mask, 6:Totem Figure
      7:Ancient Gear Relic, 8:Sealed Urn, 9:Phoenix Egg, 10:Soul Lantern, 11:Star Fragment, 12:Light Prism
      13:Runed Bracer
  08_Quest_Misc/Trophies/quest_trophies_sheet.png  (10 icons, 16 per row)
      0:Star Trophy, 1:Silver Medal, 2:Ribbon Rosette, 3:Brass Plaque, 4:Monster Head Plaque, 5:Laurel Cup
      6:Crystal Award, 7:Shield Trophy, 8:Fishing Trophy, 9:Champion Cup Gold
  08_Quest_Misc/Seeds_Sprouts/quest_seeds_sprouts_sheet.png  (8 icons, 16 per row)
      0:Seed Pouch, 1:Sapling Pot, 2:Flower Bulbs, 3:Magic Bean, 4:Seed Tray, 5:Glowing Seed, 6:Mushroom Spawn Bag
      7:Tulip Bulb Sprout
  08_Quest_Misc/Pet_Items/quest_pet_items_sheet.png  (10 icons, 16 per row)
      0:Chew Bone, 1:Fish Treat, 2:Leash, 3:Catnip Mouse, 4:Squeaky Ball, 5:Pet Bowl, 6:Bird Seed Bag
      7:Feather Wand Toy, 8:Pet Bed Cushion, 9:Pet Nametag
  08_Quest_Misc/Gifts/quest_gifts_sheet.png  (5 icons, 16 per row)
      0:Flower Bouquet, 1:Wrapped Bottle Gift, 2:Cake Box, 3:Gift Hamper, 4:Gift Crate
  08_Quest_Misc/Cards/quest_cards_sheet.png  (8 icons, 16 per row)
      0:Heart Card, 1:Card Deck, 2:Fortune Card Sun, 3:Holo Trading Card, 4:Joker Card, 5:Membership Card, 6:Club Card
      7:Bingo Ticket
  08_Quest_Misc/Instruments/quest_instruments_sheet.png  (12 icons, 16 per row)
      0:Lute, 1:Flute, 2:Hand Drum, 3:Small Harp, 4:Trumpet, 5:Ocarina, 6:Violin, 7:Tambourine, 8:Panpipes
      9:Accordion, 10:Xylophone, 11:Maracas
  08_Quest_Misc/Toys/quest_toys_sheet.png  (14 icons, 16 per row)
      0:Yo Yo, 1:Spinning Top, 2:Dice Pair, 3:Marbles Bag, 4:Rubber Duck, 5:Wooden Horse, 6:Hand Puppet, 7:Jack In Box
      8:Bouncy Ball, 9:Toy Boat, 10:Building Blocks, 11:Plush Dragon, 12:Cup And Ball, 13:Puzzle Cube
  08_Quest_Misc/Cosmetics/quest_cosmetics_sheet.png  (11 icons, 16 per row)
      0:Lipstick, 1:Hand Mirror, 2:Powder Compact, 3:Hair Ribbon, 4:Jeweled Hairpin, 5:Nail Polish, 6:Eyepatch
      7:Hairbrush, 8:Monocle, 9:Face Paint Kit, 10:Tinted Spectacles
  08_Quest_Misc/Misc_Junk/quest_misc_junk_sheet.png  (12 icons, 16 per row)
      0:Taper Candles, 1:Pocket Watch, 2:Umbrella, 3:Paper Airplane, 4:Message Bottle, 5:Wax Seal Stamp
      6:Lucky Horseshoe, 7:Game Board, 8:Old Boot, 9:Tin Can, 10:Broken Bottle, 11:Driftwood
  11_Cross_Pack_Icons/Pack4_Furniture/crosspack_pack4_furniture_sheet.png  (45 icons, 16 per row)
      0:Armchair, 1:Sofa, 2:Bookshelf, 3:Writing Desk, 4:Grandfather Clock, 5:Upright Piano, 6:Coat Rack
      7:Standing Mirror, 8:Toy Chest, 9:Wooden Cradle, 10:Folding Screen, 11:Clawfoot Bathtub, 12:Wash Stand
      13:Icebox, 14:Bakery Oven, 15:Butter Churn, 16:Anvil Item, 17:Grindstone, 18:Alchemy Table, 19:Copper Distiller
      20:Lectern, 21:Crystal Ball Stand, 22:Brass Telescope, 23:Spinning Wheel, 24:Weaving Loom, 25:Sewing Table
      26:Workbench, 27:Sawhorse, 28:Marble Statue, 29:Candle Stand, 30:Royal Throne, 31:Canopy Bed, 32:Banquet Table
      33:Wine Rack, 34:Rope Hammock, 35:Map Table, 36:Owl Perch, 37:Oil Lamp Item, 38:Fish Drying Rack
      39:Clay Pot Set, 40:Barrel Tap, 41:Display Case, 42:Dress Mannequin, 43:Weapon Rack, 44:Armor Stand
  11_Cross_Pack_Icons/Pack8_Town_Kit/crosspack_pack8_town_kit_sheet.png  (10 icons, 16 per row)
      0:Wooden Door, 1:Shop Window, 2:Picket Fence, 3:Street Lamp, 4:Hanging Sign, 5:Town Mailbox, 6:Park Bench
      7:Chimney Pot, 8:Window Flower Box, 9:Stone Well
  11_Cross_Pack_Icons/Pack5_Festival_Decor/crosspack_pack5_festival_decor_sheet.png  (5 icons, 16 per row)
      0:Flower Arch, 1:Planter Box, 2:Garland Bunch, 3:Festival Banner, 4:Ribbon Pole
  11_Cross_Pack_Icons/Pack2_Dungeon_Props/crosspack_pack2_dungeon_props_sheet.png  (4 icons, 16 per row)
      0:Iron Brazier, 1:Iron Shackles, 2:Gargoyle Statuette, 3:Spike Trap Tile

ENGINE TIPS
  Unity      Texture Type: Sprite (2D and UI), Sprite Mode: Multiple, Pixels Per Unit 16, Filter Mode: Point (no filter),
             Compression: None. Sprite Editor > Slice > Grid By Cell Size 16x16. Use the atlas + database atlas_index
             to build ScriptableObjects; UI slots are 20x20 (set Image to Native Size, scale the canvas by whole numbers).
  Godot 4    Import the PNG with Filter off (Project Settings > Rendering > Textures > Default Texture Filter: Nearest).
             Use AtlasTexture with region = Rect2(x, y, 16, 16) from the database, or a TileSet from the atlas.
  GameMaker  Import a sheet as a sprite, Image > Convert to Frames (16x16, 16 per row); frame index = cell_index.
             Turn off texture interpolation in Game Options.
  Tiled      Add items_atlas_16x16.tsx; every tile carries item_id and rarity properties for loot / object layers.
  All        Scale only by whole numbers (2x, 3x, 4x) to keep pixels sharp.

COMBINE WITH THE SERIES
  Same palette as packs 1-9: materials use the pack 8 building-kit colours (brick, stone, timber), monster parts are new
  (none duplicate the pack 9 drops), and the UI uses the pack 2 / pack 9 dark slots and rarity colours.

Made with AI assistance - programmatically generated pixel art, reviewed and curated.
See LICENSE.txt for the terms (same as packs 1-9).
