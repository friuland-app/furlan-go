# Creature 3D Models

## Folder Structure
- `dragon_natisone/` - Drago del Natisone model
- `warrior_cividale/` - Guerriero di Cividale model
- `water_spirit_tagliamento/` - Spirito del Tagliamento model
- `devil_boss/` - Diavolo Boss model
- `river_monster/` - Mostro del fiume model

## Export Format
- Use `.glb` or `.gltf` format for Godot compatibility
- Include textures in the export
- Set scale to 1.0 in Blender before export

## Optimization Guidelines
- Target poly count: 1000-3000 triangles per model
- Texture resolution: 512x512 or 1024x1024
- Use baked lighting where possible
- Minimize draw calls

## Animation Rig
- Create simple armature for each creature
- Include idle, attack, capture, escape animations
- Export animations in same file as model

## Material Requirements
- Use PBR materials
- Include albedo, normal, roughness maps
- Keep material count minimal (1-2 per creature)
