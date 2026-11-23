# Larchrow RPG Item Icons (239 icons, 16x16)

239 pixel-art item icons for RPGs, roguelikes, crafting and farming games. Every icon is 16x16 with a 1px dark outline
(#120e1a), hard pixels (alpha is only 0 or 255) and uses only the 32-colour Larchrow palette, the same one as our
*Pixel Dungeon & Overworld Tileset* and *Village & Cave Expansion*.

## Contents
```
PNG/<category>/<name>.png                       one 16x16 PNG per icon
Spritesheet/larchrow_rpg_icons_16x16.png        all icons, 16 columns, no spacing/margin (256x320)
Spritesheet/larchrow_rpg_icons_64x64_4x.png     same sheet scaled 4x (nearest neighbour)
icon_index.csv / icon_index.json                id, name, category, x, y (pixel top-left in the 1x sheet)
Godot4/larchrow_rpg_icons/                      sheet + one AtlasTexture .tres per icon + larchrow_icons.gd helper
Palette/                                        the 32 colours as .png, .gpl (GIMP/Aseprite) and .hex (Lospec)
Previews/                                       labelled overview (4x) + animated hotbar preview
screenshots/, cover_*.png                       store images (UI in the mockup is not part of the pack)
qa-report.json                                  automatic checks (see below)
```

## Categories (each starts on a new sheet row)
| Category | Icons | Sheet rows | Folder |
|---|---|---|---|
| Weapons | 36 | 0-2 | PNG/weapons/ |
| Armour | 38 | 3-5 | PNG/armour/ |
| Potions | 23 | 6-7 | PNG/potions/ |
| Food | 33 | 8-10 | PNG/food/ |
| Materials, ores & gems | 33 | 11-13 | PNG/materials/ |
| Tools | 18 | 14-15 | PNG/tools/ |
| Magic | 26 | 16-17 | PNG/magic/ |
| Keys, coins, chests & misc | 32 | 18-19 | PNG/misc/ |

## Godot 4 (tested with Godot 4.3)
1. Copy the folder `Godot4/larchrow_rpg_icons/` into your project so it ends up at `res://larchrow_rpg_icons/`
   (the .tres files use that path).
2. For crisp pixels set *Project Settings > Rendering > Textures > Canvas Textures > Default Texture Filter* to **Nearest**
   (or set `texture_filter = Nearest` on the node).
3. Use an icon:
   - drag `res://larchrow_rpg_icons/atlas/<name>.tres` into any texture slot (Sprite2D, TextureRect, Button icon ...), or
   - in code: `$TextureRect.texture = LarchrowIcons.get_icon("potion_flask_red")`
     (`LarchrowIcons.has_icon(name)`, `LarchrowIcons.ICONS` = name -> pixel position, `LarchrowIcons.CATEGORIES` = category -> names)

## Other engines
Use the 1x sheet with a 16x16 grid (no spacing, no margin) and `icon_index.csv` for names, or the single PNGs.
Unity: Sprite Mode Multiple, Grid By Cell Size 16x16, Filter Point, Compression None. GameMaker / Phaser / LOVE / Pygame: 16x16 frames.
Scale only by whole numbers (2x, 3x, 4x) with nearest-neighbour filtering.

## Quality checks (qa-report.json)
Every icon 16x16 on the grid; only palette colours; no semi-transparent pixels; closed 1px outline; no empty or
near-empty icons; no two icons identical (closest pair still differs by 10+ pixels); sheet, PNGs, index and Godot
files match; all .tres files load in Godot 4.3.

## Origin
Every icon is drawn by Larchrow's own Python code (numpy + Pillow): small hand-written pixel templates and shape rules
with top-left lighting, then reviewed by eye. No generative AI, no third-party assets, nothing traced or copied from
existing games. The ore and crystal icons reuse our own Village & Cave tiles.

## License
See LICENSE.txt: royalty-free for commercial and non-commercial use; do not resell or redistribute the icons as-is.
