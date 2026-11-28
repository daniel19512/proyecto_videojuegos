import { mkdirSync, copyFileSync, existsSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import { deflateSync } from "node:zlib";

// Autoría offline. Las tres hojas aprobadas se copian sin alterar sus píxeles.
const root = fileURLToPath(new URL("../../", import.meta.url));
const assets = join(root, "assets/personajes");
const approved = { rodrigo: "npcs", alba: "npcs", viajero: "protagonista" };
const designs = [
  ["elias","chaleco","claro","saco",0,0,"#c7ad88","#cab493","#8f7b63","#848075","#d9ae88"],
  ["ines","vestido","moño","hierbas",-1,0,"#938267","#927e63","#626c44","#574239","#cb9776"],
  ["baltasar","chaleco","bigote","monedero",1,1,"#b5a38b","#9d8871","#754e55","#5c4841","#bf8d6e"],
  ["martin","cuero","barba","guantes",2,2,"#a78267","#87634f","#845a4a","#493930","#bb8a68"],
  ["hernan","capa","capucha","rollo",-1,1,"#7e8270","#777056","#485947","#615144","#ac8062"],
  ["mateo","camisa","paja","semillas",0,-1,"#d1bc99","#b09b7b","#a2835e","#8a8475","#ab7858"],
  ["clara","delantal","pañuelo","broche",1,-1,"#c4b398","#c2b197","#627789","#694b3a","#d2a284"],
  ["samuel","chaleco","corto","semillas",-1,-2,"#bdab85","#ae9873","#ab884e","#684f3b","#a87553"],
  ["esteban","cuero","barba","guantes",2,1,"#9b9185","#90806f","#635c55","#99958b","#c39676"],
  ["aurora","capa","coleta","mochila",-1,1,"#ab927b","#a18b6d","#607483","#624a3a","#a67456"],
  ["diego","camisa","corto","farol",2,0,"#8b8174","#8f775f","#57534d","#413830","#a97a5c"],
  ["ramiro","chaleco","bigote","rollo",-1,-1,"#a4907e","#867563","#67484b","#9b9589","#bb8e71"],
  ["octavio","túnica","barba","libro",-1,-2,"#b8aa91","#a29580","#4e5969","#c3bdb0","#c99b7b"],
  ["leonor","camisa","trenza","cartera",0,0,"#cab594","#bb9e78","#a06951","#624939","#b78566"],
  ["viajero_17","vestido","melena","broche",-1,0,"#c4ac8d","#ad9271","#88686d","#70503f","#c7936f"],
  ["viajero_18","chaleco","corto","cartera",0,-2,"#ac9880","#a39176","#63737a","#463c35","#946747"],
  ["viajero_20","capa","trenza","broche",0,1,"#bca583","#9d8165","#836564","#554238","#bd8460"],
  ["viajero_21","camisa","raya","morral",1,-1,"#b5a181","#9c876d","#8b7857","#79563c","#d1a37c"],
  ["viajero_22","vestido","moño","broche",1,-2,"#beae94","#9f9179","#57715a","#37312c","#a37155"],
  ["viajero_23","chaleco","barba","morral",1,2,"#a49b86","#93927f","#4c6478","#554638","#b6886b"],
  ["viajero_24","túnica","melena","cartera",-1,0,"#d0bba0","#b29b7e","#90694d","#a66746","#d9ab87"]
];
const W = 40;
const H = 48;
const OUTLINE = "#302720";
const directions = ["izquierda", "derecha", "arriba", "abajo"];

function shade(hex, amount) {
  const base = Number.parseInt(hex.slice(1), 16);
  const rgb = [base >> 16, (base >> 8) & 255, base & 255];
  return "#" + rgb.map(value => Math.max(0, Math.min(255, value + amount)).toString(16).padStart(2, "0")).join("");
}

function draw(design, direction, column, walk) {
  const [name, outfit, hairStyle, accessory, build, height, shirt, trousers, fabric, hair, skin] = design;
  const pixels = Buffer.alloc(W * H * 4);
  const side = direction < 2;
  const rear = direction === 2;
  const mirror = direction === 1;
  const bob = walk ? Number(column % 2 === 0) : Number(column === 2);
  const stride = walk ? [4, 0, -4, 0][column] : 0;
  const swing = walk ? [2, 0, -2, 0][column] : 0;

  function pixel(x, y, color) {
    if (mirror) x = W - 1 - x;
    if (x < 0 || x >= W || y < 0 || y >= H) return;
    const rgb = Number.parseInt(color.slice(1), 16);
    const offset = (y * W + x) * 4;
    pixels[offset] = rgb >> 16;
    pixels[offset + 1] = rgb >> 8;
    pixels[offset + 2] = rgb;
    pixels[offset + 3] = 255;
  }

  function rect(x, y, width, length, color) {
    for (let row = y; row < y + length; row++) {
      for (let col = x; col < x + width; col++) pixel(col, row, color);
    }
  }

  function polygon(points, color) {
    for (let row = 0; row < H; row++) {
      const crossings = [];
      const y = row + 0.5;
      for (let i = 0; i < points.length; i++) {
        const [a, b] = [points[i], points[(i + 1) % points.length]];
        if ((a[1] <= y && b[1] > y) || (b[1] <= y && a[1] > y)) {
          crossings.push(a[0] + (y - a[1]) * (b[0] - a[0]) / (b[1] - a[1]));
        }
      }
      crossings.sort((a, b) => a - b);
      for (let i = 0; i < crossings.length; i += 2) {
        for (let x = Math.ceil(crossings[i] - 0.5); x < crossings[i + 1] - 0.5; x++) pixel(x, row, color);
      }
    }
  }

  function leg(x, displacement, lift, far) {
    const toe = x + displacement;
    const foot = 48 - lift;
    polygon([[x, 33 + bob], [x + 6, 33 + bob], [toe + 6, foot - 3], [toe - 1, foot - 3]], OUTLINE);
    polygon([[x + 1, 34 + bob], [x + 5, 34 + bob], [toe + 5, foot - 4], [toe, foot - 4]], shade(trousers, far ? -34 : -16));
    rect(toe + 1, foot - 9, 2, 4, shade(trousers, 7));
    polygon([[toe - 1, foot - 5], [toe + 6, foot - 5], [toe + 7, foot - 2], [toe + 6, foot], [toe - 2, foot]], OUTLINE);
    rect(toe, foot - 4, 5, 3, far ? "#4b392d" : "#654b39");
  }

  if (side) {
    leg(16, -stride, walk && column === 0 ? 2 : 0, true);
    leg(20, stride, walk && column === 2 ? 2 : 0, false);
  } else {
    leg(13, walk && column === 2 ? -1 : 0, walk && column === 2 ? 2 : 0, false);
    leg(21, walk && column === 0 ? 1 : 0, walk && column === 0 ? 2 : 0, true);
  }

  const top = bob - height;
  const hem = name === "ramiro" ? 39 : ({ vestido: 42, túnica: 43, delantal: 40 })[outfit] ?? 36;
  const left = side ? 13 : 12 - build;
  const right = side ? 26 : 28 + build;
  const shoulder = 20 + top;
  const bottom = hem + bob;
  function arm(x, shift, shadow) {
    const y = shoulder + 2 + shift;
    rect(x, y, 5, 13, OUTLINE);
    const cuff = ["esteban", "diego", "viajero_18"].includes(name) ? 6 : 8;
    rect(x + 1, y + 1, 3, cuff, shade(shirt, shadow ? -24 : 0));
    rect(x + 1, y + cuff, 3, 12 - cuff, skin);
    if (accessory === "guantes") rect(x + 1, y + 10, 3, 2, "#765741");
    rect(x + 1, y + cuff - 1, 3, 1, shade(shirt, 16));
  }
  if (!side) {
    arm(left - 5, -swing, false);
    arm(right, swing, true);
  }

  polygon([[15, shoulder], [25, shoulder], [right, shoulder + 4], [right + 1, bottom - 2], [right - 1, bottom], [left + 1, bottom], [left - 1, bottom - 2], [left, shoulder + 4]], OUTLINE);
  polygon([[16, shoulder + 1], [24, shoulder + 1], [right - 1, shoulder + 4], [right - 1, bottom - 1], [left + 1, bottom - 1], [left + 1, shoulder + 4]], fabric);
  polygon([[left + 1, shoulder + 5], [20, shoulder + 2], [19, 32 + bob], [17, bottom - 1], [left + 1, bottom - 1]], shade(fabric, 17));
  rect(left + 2, bottom - 3, right - left - 4, 1, shade(fabric, -23));

  if (outfit === "chaleco") {
    if (!rear) {
      polygon([[15, shoulder + 1], [24, shoulder + 1], [20, shoulder + 9]], shirt);
      rect(19, shoulder + 8, 2, 5, shade(fabric, -22));
      for (let i = 9; i <= 13; i += 2) rect(20, shoulder + i, 1, 1, "#b69b73");
    }
    rect(left + 3, bottom - 5, 3, 1, shade(fabric, -28));
  } else if (outfit === "delantal") {
    const front = side ? left + 1 : left + 3;
    rect(front, 30 + bob, right - front - 2, 8, rear ? shade(fabric, -21) : shirt);
    rect(front + 1, 31 + bob, 4, 4, rear ? fabric : shade(shirt, 16));
    rect(front, 29 + bob, right - front - 1, 2, "#817052");
    if (!rear) rect(17, shoulder + 4, 6, 7, shade(shirt, 5));
  } else if (outfit === "capa") {
    polygon([[14, shoulder - 1], [26, shoulder - 1], [right + 2, shoulder + 6], [right - 1, shoulder + 10], [left + 1, shoulder + 11], [left - 2, shoulder + 6]], shade(fabric, -22));
    polygon([[15, shoulder], [24, shoulder], [right, shoulder + 5], [left + 1, shoulder + 7]], shade(fabric, 9));
    if (!rear) rect(19, shoulder + 4, 3, 2, "#bb9e72");
  } else if (outfit === "cuero") {
    rect(left + 1, shoulder + 3, 4, 3, shade(shirt, -13));
    rect(right - 5, shoulder + 3, 4, 3, shade(shirt, -23));
    rect(left + 2, 30 + bob, right - left - 4, 3, "#503a2e");
    rect(19, 31 + bob, 3, 1, "#a89878");
  } else {
    rect(left + 2, 30 + bob, right - left - 4, 2, "#66513d");
    if (!rear) {
      rect(17, shoulder + 2, 6, 2, shade(shirt, 13));
      rect(19, shoulder + 4, 2, 4, shade(fabric, -18));
    }
    if (hem > 40) rect(left + 2, bottom - 5, right - left - 4, 1, shade(fabric, 18));
  }

  if (side) arm(18 + swing, 0, false);

  if (name === "diego") {
    rect(left + 2, 29 + bob, right - left - 4, 4, "#47352c");
    if (!rear) rect(18, 30 + bob, 4, 2, "#a79369");
    rect(left + 3, bottom - 6, 5, 1, "#77695d");
  } else if (name === "elias") {
    rect(left + 3, bottom - 5, 5, 2, "#a99b85");
    rect(left + 5, bottom - 7, 4, 1, "#b8aa94");
  } else if (name === "ramiro" && !rear) {
    rect(left + 4, shoulder + 5, 3, 6, "#9a7d68");
    rect(left + 6, shoulder + 6, 2, 5, "#946f5a");
  } else if (name === "viajero_17") {
    rect(left + 2, bottom - 6, right - left - 4, 2, "#b09c86");
    rect(left + 3, bottom - 5, right - left - 6, 1, "#a48670");
  } else if (name === "viajero_24") {
    rect(left + 4, shoulder + 6, 3, 10, "#ac8d68");
    rect(left + 3, bottom - 6, right - left - 6, 2, "#b28c68");
  }

  const kitX = side ? 23 + swing : rear ? 8 : right - 3;
  const kitY = 32 + bob;
  function pouch(width, color) {
    rect(kitX + 1, kitY - 2, width - 2, 2, OUTLINE);
    polygon([[kitX, kitY], [kitX + width, kitY], [kitX + width, kitY + 5], [kitX + width - 1, kitY + 6], [kitX + 1, kitY + 6], [kitX, kitY + 4]], OUTLINE);
    rect(kitX + 1, kitY + 1, width - 2, 4, color);
    rect(kitX + 1, kitY + 1, width - 2, 1, shade(color, 23));
  }
  switch (accessory) {
    case "saco":
      pouch(8, "#b4a488");
      rect(kitX + 2, kitY - 2, 4, 1, "#d4c4a2");
      break;
    case "hierbas":
      pouch(7, "#8d7350");
      rect(kitX + 2, kitY - 3, 1, 4, "#849562");
      rect(kitX + 4, kitY - 4, 1, 5, "#718349");
      rect(kitX + 3, kitY - 3, 2, 1, "#9e9f63");
      break;
    case "semillas":
      pouch(6, "#b09a6b");
      if (!side) rect(left + 1, kitY, 4, 4, "#86724d");
      break;
    case "monedero":
      pouch(6, "#775345");
      rect(kitX + 2, kitY + 2, 2, 2, "#b89a5f");
      break;
    case "farol":
      rect(kitX + 1, kitY - 3, 4, 3, OUTLINE);
      pouch(6, "#b48c52");
      rect(kitX + 2, kitY + 2, 2, 2, "#d1ad69");
      break;
    case "rollo":
      pouch(7, "#ae9873");
      rect(kitX + 2, kitY + 2, 4, 2, "#c7b497");
      break;
    case "libro":
      rect(kitX, kitY - 2, 8, 9, OUTLINE);
      rect(kitX + 1, kitY - 1, 6, 7, "#8b6550");
      rect(kitX + 6, kitY, 1, 5, "#d1b88f");
      rect(kitX + 2, kitY + 1, 2, 1, "#b48c5b");
      break;
    case "mochila":
      if (rear || side) {
        const x = side ? 24 : 14;
        rect(x, shoulder + 4, 10, 10, OUTLINE);
        rect(x + 1, shoulder + 5, 8, 8, "#84674c");
        rect(x + 1, shoulder + 5, 8, 3, "#a18465");
        rect(x + 4, shoulder + 9, 2, 2, "#c0a173");
      } else {
        rect(14, shoulder + 5, 2, 8, "#8e7153");
        rect(24, shoulder + 5, 2, 8, "#8e7153");
      }
      break;
    case "cartera":
    case "morral":
      polygon([[14, shoulder + 2], [16, shoulder + 2], [26, kitY], [24, kitY + 1]], "#886748");
      pouch(accessory === "cartera" ? 7 : 8, "#886548");
      break;
    case "broche":
      if (!rear) {
        rect(19, shoulder + 5, 3, 2, "#bbaa78");
        rect(20, shoulder + 4, 1, 4, "#bbaa78");
      }
      break;
  }

  function headRect(x, y, width, length, color) {
    rect(x, y + top + 1, width, length, color);
  }
  function headShape(points, color) {
    polygon(points.map(([x, y]) => [x, y + top + 1]), color);
  }
  const longHair = ["melena", "moño", "coleta", "trenza"].includes(hairStyle);
  const jaw = hairStyle === "corto" || longHair ? 2 : 0;
  const brow = hairStyle === "claro" || hairStyle === "bigote" ? 1 : 0;
  if (longHair) {
    const x = side ? 23 : rear ? 20 : 23;
    headShape([[x, 7], [x + 4, 7], [x + 6, 14], [x + 5, 18], [x + 6, hairStyle === "melena" ? 25 : 22], [x + 2, 24], [x - 1, 20]], OUTLINE);
    headRect(x + 2, 12, 2, hairStyle === "melena" ? 11 : 8, hair);
    headRect(x + 2, 17, 2, 1, shade(hair, 25));
    if (hairStyle === "moño") headRect(x + 3, 7, 4, 5, shade(hair, -9));
    if (hairStyle === "trenza" || hairStyle === "coleta") headRect(x + 1, 21, 3, 1, shade(fabric, 25));
  }
  headShape([[14, 3], [24, 3], [28, 6], [28, 12], [29, 14], [26, 17], [24 - jaw, 19], [16 + jaw, 19], [12, 16], [10, 13], [11, 7]], OUTLINE);
  headShape([[14, 4], [24, 4], [27, 7], [27, 13], [26, 16], [23 - jaw, 18], [17 + jaw, 18], [13, 15], [11, 13], [12, 8]], rear ? hair : skin);
  if (!rear) {
    headShape([[14, 9], [23, 8], [25, 12], [23 - jaw, 16], [17 + jaw, 16], [13, 13]], shade(skin, 18));
    headRect(side ? 13 : 15, 10 + brow, 2, 2, OUTLINE);
    if (!side) headRect(23, 10 + brow, 2, 2, OUTLINE);
    headRect(side ? 11 : 19, 13, 2, 1, shade(skin, -19));
    headRect(side ? 13 : 18, 15, 3, 1, shade(skin, -21));
  }
  headShape([[14, 4], [24, 4], [27, 7], [27, 12], [25, 12], [24, 8], [20, hairStyle === "raya" ? 6 : 8], [16, 8], [12, 10]], hair);
  headRect(15, 5, 8, 1, shade(hair, 24));
  if (hairStyle === "corto") {
    headRect(13, 7, 3, 2, shade(hair, 13));
    headRect(24, 8, 3, 2, shade(hair, -12));
  } else if (hairStyle === "melena" && !side) {
    headRect(12, 10, 2, 7, hair);
    headRect(26, 11, 2, 7, shade(hair, -14));
  }
  if (rear) {
    headShape([[13, 8], [25, 7], [27, 11], [24, 16], [21, 17], [16, 17], [13, 14]], shade(hair, -16));
    headRect(16, 9, 7, 2, shade(hair, 10));
  }
  if (!rear && hairStyle === "barba") {
    const end = accessory === "libro" ? 25 : 21;
    headShape([[12, 13], [16, 15], [20, 14], [23, 15], [26, 13], [26, 17], [22, end], [17, end], [14, 18]], shade(hair, -14));
    headRect(17, 17, 4, end - 17, shade(hair, 14));
    headRect(side ? 13 : 18, 15, 3, 1, shade(skin, -12));
  } else if (hairStyle === "bigote" && !rear) {
    headShape([[14, 15], [17, 13], [22, 13], [25, 15], [23, 16], [20, 15], [17, 16]], shade(hair, -8));
  }
  if (hairStyle === "paja") {
    headShape([[13, 5], [14, 2], [23, 2], [26, 5], [31, 6], [31, 9], [8, 9], [8, 6]], OUTLINE);
    headShape([[14, 5], [15, 3], [23, 3], [25, 6], [30, 7], [29, 8], [9, 8], [10, 7]], "#c5a369");
    headRect(14, 5, 11, 1, "#876d49");
    headRect(16, 3, 5, 1, "#ddc58b");
  } else if (hairStyle === "pañuelo" || hairStyle === "capucha") {
    const hood = hairStyle === "capucha";
    headShape([[12, 6], [15, 2], [24, 2], [28, 6], [29, hood ? 18 : 11], [26, hood ? 20 : 13], [26, 9], [15, 8], [11, hood ? 17 : 10]], OUTLINE);
    headShape([[13, 6], [16, 3], [24, 3], [27, 6], [28, hood ? 17 : 10], [27, hood ? 18 : 11], [26, 8], [16, 7], [12, hood ? 15 : 8]], fabric);
    headRect(16, 4, 7, 1, shade(fabric, 28));
    if (hood && rear) headShape([[13, 8], [26, 8], [27, 16], [23, 19], [16, 18], [13, 16]], shade(fabric, -7));
  }
  if (side) {
    // El perfil mira hacia el borde izquierdo antes de aplicar el espejo.
    headRect(14, 11, 2, 2, OUTLINE);
    headRect(10, 13, 3, 1, skin);
    headRect(10, 14, 2, 1, OUTLINE);
  }
  return pixels;
}

function sheet(design, walk) {
  const image = Buffer.alloc(160 * 192 * 4);
  for (let row = 0; row < 4; row++) {
    for (let col = 0; col < 4; col++) {
      const frame = draw(design, row, col, walk);
      for (let y = 0; y < H; y++) frame.copy(image, ((row * H + y) * 160 + col * W) * 4, y * W * 4, (y + 1) * W * 4);
    }
  }
  return image;
}

function png(rgba) {
  function chunk(name, data) {
    const body = Buffer.concat([Buffer.from(name), data]);
    let crc = -1;
    for (const byte of body) {
      crc ^= byte;
      for (let i = 0; i < 8; i++) crc = (crc >>> 1) ^ ((crc & 1) ? 0xedb88320 : 0);
    }
    const size = Buffer.alloc(4);
    size.writeUInt32BE(data.length);
    const check = Buffer.alloc(4);
    check.writeUInt32BE((~crc) >>> 0);
    return Buffer.concat([size, body, check]);
  }
  const head = Buffer.alloc(13);
  head.writeUInt32BE(160);
  head.writeUInt32BE(192, 4);
  head[8] = 8;
  head[9] = 6;
  const raw = Buffer.alloc(641 * 192);
  for (let y = 0; y < 192; y++) rgba.copy(raw, y * 641 + 1, y * 640, (y + 1) * 640);
  return Buffer.concat([
    Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
    chunk("IHDR", head),
    chunk("IDAT", deflateSync(raw)),
    chunk("IEND", Buffer.alloc(0)),
  ]);
}

function writeFrames(group, name) {
  const sections = ["[gd_resource type=\"SpriteFrames\" format=3]"];
  const animations = [];
  for (const [state, speed] of [["idle", 4], ["walk", 8]]) {
    sections.push(`[ext_resource type="Texture2D" path="res://assets/personajes/definitivos/${group}/hojas/${name}_${state}.png" id="${state}"]`);
    directions.forEach((direction, row) => {
      const frames = [];
      for (let col = 0; col < 4; col++) {
        const id = `${state}_${direction}_${col}`;
        sections.push(`[sub_resource type="AtlasTexture" id="${id}"]\natlas = ExtResource("${state}")\nregion = Rect2(${col * W}, ${row * H}, ${W}, ${H})\nfilter_clip = true`);
        frames.push(`{"duration": 1.0, "texture": SubResource("${id}")}`);
      }
      animations.push(`{"frames": [${frames.join(", ")}], "loop": true, "name": &"${state}_${direction}", "speed": ${speed}.0}`);
    });
  }
  // Godot requires external resources before any subresources.
  const sorted = [sections[0], ...sections.filter(s => s.startsWith("[ext_resource")), ...sections.filter(s => s.startsWith("[sub_resource"))];
  sorted.push(`[resource]\nanimations = [\n${animations.join(",\n")}\n]`);
  writeFileSync(join(assets, "definitivos", group, "frames", `${name}.tres`), sorted.join("\n\n") + "\n");
}

function writeCharacter(group, name, design) {
  const directory = join(assets, "definitivos", group);
  mkdirSync(join(directory, "hojas"), { recursive: true });
  mkdirSync(join(directory, "frames"), { recursive: true });
  for (const state of ["idle", "walk"]) {
    const file = `${name}_${state}.png`;
    const target = join(directory, "hojas", file);
    if (design) {
      writeFileSync(target, png(sheet(design, state === "walk")));
    } else if (!existsSync(target)) {
      copyFileSync(join(assets, "npcs", "prueba_estilo", file), target);
    }
  }
  writeFrames(group, name);
}

for (const [name, group] of Object.entries(approved)) writeCharacter(group, name);
for (const design of designs) {
  const name = design[0];
  writeCharacter(name.startsWith("viajero_") ? "protagonista" : "npcs", name, design);
}
console.log(`${designs.length + Object.keys(approved).length} personajes preparados.`);
