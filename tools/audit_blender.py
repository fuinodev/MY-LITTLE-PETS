"""Run with Blender after rendering to inspect all native scenes."""
import bpy, json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
results=[]
for path in sorted((root/'game-system-overview').rglob('*.blend')):
    bpy.ops.wm.open_mainfile(filepath=str(path))
    objects=list(bpy.context.scene.objects)
    row={'scene':str(path.relative_to(root)), 'objects':len(objects),
         'meshes':sum(o.type=='MESH' for o in objects),
         'lights':sum(o.type=='LIGHT' for o in objects),
         'camera':bool(bpy.context.scene.camera)}
    assert row['meshes']>0 and row['lights']==3 and row['camera'],row
    if path.stem=='egg-rush':
        names=sorted(o.name for o in objects if o.name.startswith('Egg box '))
        assert names==['Egg box %02d'%i for i in range(1,11)],names
        row['verified_egg_boxes']=10
    results.append(row)
assert len(results)==7
(root/'blender-verification.json').write_text(json.dumps({'status':'PASS','scenes':results},indent=2))
print('PASS: seven native scenes; cameras, lighting, meshes, and ten arena boxes verified.')
