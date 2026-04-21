# Blender Workflow for Creature 3D Models

## Setup
1. Install Blender 3.6 or later
2. Set units to Metric
3. Set scale to 1.0

## Modeling Steps
1. Create base mesh (box, cylinder, or sculpt)
2. Add details with extrusion, bevel, and subdivision
3. Check triangle count (target: 1000-3000)
4. Apply modifiers (Mirror, Subdivision Surface)

## Rigging
1. Add armature (Shift+A → Armature)
2. Create bones for major body parts
3. Parent mesh to armature (Ctrl+P → With Automatic Weights)
4. Test bone influence in Weight Paint mode

## Animation
1. Set timeline to 24 FPS
2. Create keyframes for idle animation (loop 2s)
3. Create keyframes for attack animation (1s)
4. Create keyframes for capture animation (1.5s)
5. Create keyframes for escape animation (2s)

## Materials
1. Create PBR material
2. Add texture nodes:
   - Base Color (Albedo)
   - Normal Map
   - Roughness
   - Metallic (if needed)
3. Set viewport shading to Material Preview

## Export
1. File → Export → glTF 2.0 (.glb/.gltf)
2. Check "Include → Selected Objects"
3. Check "Mesh → Apply Modifiers"
4. Check "Animation → All Actions"
5. Set scale to 1.0
6. Export

## Import to Godot
1. Import .glb file in Godot
2. Create scene with imported model
3. Add AnimationPlayer node
4. Test animations in editor
