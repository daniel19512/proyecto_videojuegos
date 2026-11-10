// Node incorporado, sin paquetes externos. Ejecutar desde cualquier directorio.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { fileURLToPath } from 'node:url';
const raiz = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const base = path.join(raiz, 'assets/granja');
const logs = path.join(raiz, 'logs/auditoria_assets_granja');
function recorrer(dir) { return fs.readdirSync(dir,{withFileTypes:true}).flatMap(e => e.isDirectory()?recorrer(path.join(dir,e.name)):[path.join(dir,e.name)]); }
const relativos = p => 'RPG/'+path.relative(raiz,p).replaceAll('\\','/');
const archivos = recorrer(base).filter(p=>!p.endsWith('.import'));
const medicion = process.argv[2] ? path.resolve(process.argv[2]) : recorrer(logs).filter(p=>p.endsWith('mediciones.json')&&!p.includes('importacion_limpia')).sort().at(-1);
const datos = JSON.parse(fs.readFileSync(medicion,'utf8'));
const glb = [];
for(const archivo of archivos.filter(p=>p.endsWith('.glb'))) {
  const b=fs.readFileSync(archivo);
  if(b.readUInt32LE(0)!==0x46546c67||b.readUInt32LE(4)!==2||b.readUInt32LE(8)!==b.length) throw Error('Cabecera GLB incorrecta: '+relativos(archivo));
  const j=JSON.parse(b.toString('utf8',20,20+b.readUInt32LE(12)).trim());
  const externos=[...(j.buffers??[]),...(j.images??[])].filter(x=>x.uri&&!x.uri.startsWith('data:')).map(x=>x.uri);
  for(const uri of externos) if(!fs.existsSync(path.resolve(path.dirname(archivo),decodeURIComponent(uri)))) throw Error('Dependencia ausente: '+uri);
  glb.push({ruta:relativos(archivo),materiales:j.materials,imagenes:j.images,texturas:j.textures,animaciones:(j.animations??[]).length,dependencias_externas:externos});
}
const modelos = new Map();
for(const archivo of archivos.filter(p=>/\.(glb|gltf|fbx|obj|blend)$/i.test(p))) {
  const nombre=path.basename(archivo,path.extname(archivo));
  if(!modelos.has(nombre)) modelos.set(nombre,{nombre,archivos:[]});
  modelos.get(nombre).archivos.push(relativos(archivo));
}
for(const modelo of modelos.values()) {
  modelo.archivos.sort();
  modelo.canonico=modelo.archivos.find(p=>p.endsWith('.glb'))??modelo.archivos.find(p=>p.endsWith('.fbx'));
  modelo.importaciones=datos.formatos.filter(f=>modelo.archivos.includes(f.ruta));
}
const pares=glb.map(g=>{
 const a=datos.formatos.find(f=>f.ruta===g.ruta), b=datos.formatos.find(f=>f.ruta===g.ruta.replace('/glTF/','/FBX/').replace('.glb','.fbx'));
 return {nombre:path.basename(g.ruta,'.glb'),max_diferencia_dimensiones:Math.max(...a.dimensiones_xyz.map((v,i)=>Math.abs(v-b.dimensiones_xyz[i])))};
});
const inventario={fase:'6E.0',motor:datos.motor,modelos_unicos_por_nombre:modelos.size,archivos_modelo:archivos.filter(p=>/\.(glb|gltf|fbx|obj|blend)$/i.test(p)).length,formatos_probados:datos.formatos.length,fallos:datos.fallos,modelos:[...modelos.values()],estructura_glb:glb,comparacion_glb_fbx:pares};
fs.writeFileSync(path.join(raiz,'docs/catalogo_assets_granja.json'),JSON.stringify(inventario,null,2)+'\n');
const hashes=archivos.map(p=>({ruta:relativos(p).replace(/^RPG\//,''),hash:crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex').toUpperCase()}));
const instantanea=path.join(logs,'fuentes_iniciales.json');
const inicial=fs.existsSync(instantanea)?JSON.parse(fs.readFileSync(instantanea,'utf8').replace(/^\uFEFF/,'')):null;
const alterados=inicial?inicial.filter(a=>!hashes.some(b=>a.ruta===b.ruta&&a.hash===b.hash)):[];
fs.writeFileSync(path.join(logs,'integridad_fuentes_final.json'),JSON.stringify({originales:hashes.length,comparacion_inicial_disponible:inicial!==null,alterados,hashes},null,2));
console.log(JSON.stringify({modelos:modelos.size,archivos_modelo:inventario.archivos_modelo,formatos_probados:datos.formatos.length,fallos:datos.fallos,originales:hashes.length,alterados:alterados.length,pares_glb_fbx:pares.length,max_diferencia:Math.max(...pares.map(p=>p.max_diferencia_dimensiones))}));
if(alterados.length||datos.fallos||modelos.size!==21) process.exitCode=1;
