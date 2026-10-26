"""Run: blender --background --python tools/render_samples.py"""
import bpy, math, random, sys
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(Path(__file__).parent))
from build_context import SYSTEMS
random.seed(31)

def material(name,color,metal=0,emission=0):
    m=bpy.data.materials.new(name); m.diffuse_color=(*color,1); m.use_nodes=True
    s=m.node_tree.nodes.get('Principled BSDF'); s.inputs['Base Color'].default_value=(*color,1)
    s.inputs['Metallic'].default_value=metal; s.inputs['Roughness'].default_value=.38
    if emission:
        s.inputs['Emission Color'].default_value=(*color,1); s.inputs['Emission Strength'].default_value=emission
    return m

def cube(name,loc,scale,mat,bevel=.08):
    bpy.ops.mesh.primitive_cube_add(size=1,location=loc); o=bpy.context.object; o.name=name; o.dimensions=scale
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    if mat:o.data.materials.append(mat)
    if bevel:
        mod=o.modifiers.new('Soft toy edges','BEVEL'); mod.width=bevel; mod.segments=3
        o.modifiers.new('Weighted corner normals','WEIGHTED_NORMAL')
    return o

def sphere(name,loc,scale,mat):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=20,ring_count=12,location=loc)
    o=bpy.context.object; o.name=name; o.scale=scale; o.data.materials.append(mat)
    for p in o.data.polygons:p.use_smooth=True
    return o

def cylinder(name,loc,radius,depth,mat):
    bpy.ops.mesh.primitive_cylinder_add(vertices=24,radius=radius,depth=depth,location=loc)
    o=bpy.context.object; o.name=name; o.data.materials.append(mat)
    mod=o.modifiers.new('Edge highlight','BEVEL');mod.width=.035;mod.segments=2
    o.modifiers.new('Weighted normals','WEIGHTED_NORMAL');return o

def text(body,loc,size=.35,mat=None):
    bpy.ops.object.text_add(location=loc,rotation=(math.pi/2,0,0))
    o=bpy.context.object;o.name='Label '+body;o.data.body=body;o.data.align_x='CENTER';o.data.size=size;o.data.extrude=.004
    o.data.materials.append(mat or P['white']);return o

def tree(x,y,s=1):
    cylinder('Tree trunk',(x,y,.7*s),.18*s,1.4*s,P['wood'])
    for z,r in [(1.1,.9),(1.8,.7),(2.4,.5)]:
        bpy.ops.mesh.primitive_cone_add(vertices=7,radius1=r*s,radius2=0,depth=1.4*s,location=(x,y,z*s))
        bpy.context.object.name='Pine foliage';bpy.context.object.data.materials.append(P['leaf'])

def pet(x,y,z=0,color=None,size=1,kind='fox'):
    m=color or P['orange'];cube('Cube pet body',(x,y,z+.8*size),(1.4*size,1.35*size,1.4*size),m,.10*size)
    for dx in [-.43,.43]:
        sphere('Expressive eye',(x+dx*size,y-.687*size,z+.93*size),(.18*size,.065*size,.23*size),P['white'])
        sphere('Pupil',(x+dx*size,y-.744*size,z+.94*size),(.09*size,.035*size,.14*size),P['dark'])
        sphere('Eye glint',(x+(dx-.025)*size,y-.778*size,z+1.01*size),(.025*size,.014*size,.035*size),P['white'])
        cube('Tiny cube foot',(x+dx*size,y-.38*size,z+.13*size),(.27*size,.4*size,.24*size),m,.03)
        ear=cube('Small pointed ear',(x+dx*size,y,z+1.57*size),(.38*size,.42*size,.45*size),m,.05)
        ear.rotation_euler.y=(-.2 if dx<0 else .2)
    sphere('Cute nose',(x,y-.72*size,z+.66*size),(.10*size,.05*size,.075*size),P['pink'])
    return (x,y,z)

def coins(x,y,n=9):
    for j in range(n):
        dx=random.uniform(-.5,.5);dy=random.uniform(-.45,.45)
        cylinder('Leaf gold coin',(x+dx,y+dy,.15+(j%3)*.09),.23,.09,P['gold'])

def chest(x,y,s=1):
    cube('Chest wooden base',(x,y,.53*s),(1.7*s,1.15*s,.85*s),P['wood'])
    cube('Chest rounded lid',(x,y,1.02*s),(1.72*s,1.17*s,.40*s),P['orange'],.18)
    for dx in [-.58,.58]:cube('Chest gold band',(x+dx*s,y,.7*s),(.15*s,1.22*s,1.15*s),P['gold'],.03)
    cube('Chest lock',(x,y-.62*s,.7*s),(.27*s,.12*s,.32*s),P['gold'])

def sign(label,x,y,z=2,width=6):
    cube('Wood sign frame',(x,y,z),(width,.25,.95),P['wood'])
    cube('Sign inset',(x,y-.14,z),(width-.18,.08,.77),P['navy'],.04)
    text(label,(x,y-.195,z-.13),.32)

def init(title):
    global P
    bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
    P={k:material(k,c, .65 if k=='gold' else 0) for k,c in {
        'grass':(.17,.42,.12),'leaf':(.07,.30,.13),'wood':(.29,.12,.055),'gold':(1,.60,.055),
        'orange':(.92,.29,.065),'white':(.94,.96,1),'dark':(.018,.028,.045),'navy':(.025,.09,.13),
        'stone':(.31,.38,.42),'pink':(1,.20,.40),'blue':(.03,.45,.88),'purple':(.42,.065,.8),
        'red':(.83,.035,.07),'mint':(.05,.8,.55),'ice':(.30,.8,1)}.items()}
    cube('Diorama foundation',(0,0,-.38),(22,17,.75),P['navy'],.3)
    cube('Grass terrain',(0,0,.02),(21.7,16.7,.18),P['grass'],.15)
    cube('Front title plaque',(0,-8.57,.1),(20,.3,1),P['navy'])
    text('MY LITTLE PETS  /  '+title,(0,-8.75,-.02),.47)
    for x,y in [(-9,6),(9,6),(-9,2),(9,2)]:tree(x,y,1.3)

def scene_pets():
    colors=['orange','mint','blue','purple','gold','red','purple','white','gold','dark']
    names=['Common','Uncommon','Rare','Epic','Legendary','Mythic','Eternal','Heroic','Divine','EXCLUSIVE']
    for i,(c,label) in enumerate(zip(colors,names)):
        x=(i%5-2)*3.5;y=3.4-(i//5)*5
        cylinder('Pet display pedestal',(x,y,.22),1.3,.4,P['stone'])
        pet(x,y,.42,P[c]);text(label,(x,y-1.1,.25),.28)
        if i>=6:
            bpy.ops.mesh.primitive_torus_add(major_radius=.48,minor_radius=.07,location=(x,y,2.5))
            bpy.context.object.data.materials.append(P['gold'])
    sign('CUBE PET COLLECTION',0,6.6,3,10)

def scene_world():
    labels=['ENTRANCE','CLEARING','DEEP WOODS','ANCIENT GROVE','GATEWAY']
    for i,label in enumerate(labels):
        y=-5.8+i*2.65
        cube('Sector path',(0,y,.15),(10,2.4,.13),P['stone'],.03)
        for x in [-6.5,6.5]:tree(x,y,.8)
        coins(-2,y);chest(2,y,.6)
        text(label,(0,y-.4,.3),.28)
    sign('RIVER - COMING SOON',0,7.5,3,8)
    for x in [-4,4]:cube('River gateway pillar',(x,7.4,1.5),(.6,.7,3),P['stone'])
    pet(-1,-6.5,.3);pet(1,-6.5,.3,P['blue'])

def scene_treasure():
    for x,y,n in [(-6,2,12),(-1,2,28),(5,2,65)]:coins(x,y,n)
    chest(-4,-2,1.8);chest(3,-2,2.2)
    for x in [-6,-3,0,3,6]:pet(x,-5.4,0,P['blue'] if x%2 else P['orange'],.7)
    sign('TREASURE FARMING',0,6.8,2.5,9)
    for label,x in [('PILE',-6),('LARGE PILE',-1),('HOARD',5)]:text(label,(x,.8,.25),.32)

def scene_eggs():
    colors=['white','mint','blue','purple','gold','red','purple','white','gold']
    names=['COMMON','UNCOMMON','RARE','EPIC','LEGENDARY','MYTHIC','ETERNAL','HEROIC','DIVINE']
    for i,c in enumerate(colors):
        a=math.pi*.14+i*math.pi*.72/8;x=8*math.cos(a);y=5.7*math.sin(a)-.3
        cylinder('Rarity pedestal '+names[i],(x,y,.4),.8,.7,P['stone'])
        sphere('Forest egg '+names[i],(x,y,1.9),(.63,.63,1.05),P[c])
        text(names[i],(x,y-.84,.52),.20)
    cylinder('Central egg platform',(0,-2,.4),2,.7,P['stone'])
    sphere('Central clover egg',(0,-2,2.4),(1.2,1.2,1.8),P['white'])
    for dx,dz in [(-.18,.18),(.18,.18),(-.18,-.18),(.18,-.18)]:sphere('Clover leaf',(dx,-3.16,2.5+dz),(.25,.09,.25),P['mint'])
    sign('GIANT EGG PLAZA',0,7,4,9)

def scene_arena():
    # Keep the final numbered box visible from the sample camera.
    for o in list(bpy.context.scene.objects):
        if o.location.x>8 and o.location.y<4 and o.name.startswith(('Tree trunk','Pine foliage')):
            bpy.data.objects.remove(o,do_unlink=True)
    cube('Racing grass',(0,0,.2),(18,13,.18),P['leaf'])
    cube('Start stripe',(0,-5,.32),(18,1.2,.08),P['red'])
    text('START',(0,-5.3,.41),.75)
    for i in range(10):
        x=-8.1+i*1.8
        cube('Egg box %02d'%(i+1),(x,5,.85),(1.4,1.2,1.2),P['blue'] if i%2 else P['purple'])
        sphere('Reward egg %02d'%(i+1),(x,5,1.9),(.37,.37,.55),P['gold'])
        text(str(i+1),(x,4.36,.8),.6)
    for x in [-9.5,9.5]:
        for y in range(-6,7,2):cube('Fence post',(x,y,.75),(.18,.18,1.5),P['wood'])
        cube('Fence rail',(x,0,1),( .12,13,.16),P['wood'])
    sign('EGG RUSH - 10 BOXES',0,7.3,3.8,11)

def scene_weather():
    names=['SOAKED 1.5x','FROZEN 2.5x','THUNDERSTRUCK 4x','ENRAGED 7x','CELESTIAL 12x','ASTRAL 25x']
    colors=['blue','ice','purple','red','navy','mint']
    for i,(label,c) in enumerate(zip(names,colors)):
        x=(i%3-1)*6;y=2.8-(i//3)*6
        cylinder('Mutation stage',(x,y,.22),2,.4,P['stone'])
        pet(x,y,.43,P[c],1.25)
        for j in range(12):
            a=j*math.pi/6;sphere('Weather contact sparkle',(x+1.5*math.cos(a),y+.65*math.sin(a),1.2+(j%4)*.5),(.06,.06,.12),P[c])
        text(label,(x,y-1.8,.4),.29)
    sign('PERMANENT WEATHER MUTATIONS',0,7,3.2,15)

def scene_shop():
    cube('Shop back wall',(0,3,2.3),(10,.4,4.5),P['wood'])
    cube('Counter',(0,1,1.1),(11,2,2),P['wood'])
    cube('Counter trim',(0,1,2.15),(11.5,2.4,.25),P['gold'])
    for i in range(10):cube('Awning stripe',(-4.95+i*1.1,1.4,4.5),(1.1,3.5,.25),P['blue'] if i%2 else P['white'])
    for x in [-5,5]:cube('Kiosk pillar',(x,1.2,2.3),(.25,.25,4.6),P['wood'])
    for x,c in [(-3,'mint'),(0,'purple'),(3,'gold')]:
        sphere('Lucky booster bottle',(x,.8,2.8),(.45,.45,.6),P[c])
        cylinder('Bottle neck',(x,.8,3.35),.18,.3,P[c]);cylinder('Bottle cork',(x,.8,3.55),.2,.13,P['wood'])
    sign('SHOP - PERMANENT UPGRADES',0,3,5.6,13)
    sign('1x > 2x > 4x > ... > 4096x',0,-2.4,1,11)
    pet(-7,-3,0,P['gold']);pet(7,-3,0,P['purple'])

def finish(folder,slug):
    scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=24
    scene.cycles.use_denoising=True
    scene.render.resolution_x=1600;scene.render.resolution_y=1100;scene.render.resolution_percentage=100
    scene.world.color=(.25,.25,.25)
    for loc,power,size in [((0,-8,18),2300,10),((10,4,12),1800,8),((-10,0,10),1500,8)]:
        bpy.ops.object.light_add(type='AREA',location=loc);o=bpy.context.object;o.data.energy=power;o.data.shape='DISK';o.data.size=size
        o.rotation_euler=(Vector((0,0,0))-o.location).to_track_quat('-Z','Y').to_euler()
    bpy.ops.object.camera_add(location=(18,-28,24));camera=bpy.context.object
    camera.rotation_euler=(Vector((0,0,1))-camera.location).to_track_quat('-Z','Y').to_euler()
    camera.data.type='ORTHO';camera.data.ortho_scale=29;scene.camera=camera
    scene.view_settings.view_transform='AgX'
    out=ROOT/'game-system-overview'/folder/'images'
    scene.render.image_settings.file_format='PNG';scene.render.filepath=str(out/(slug+'-render.png'))
    bpy.ops.wm.save_as_mainfile(filepath=str(out/(slug+'.blend')))
    bpy.ops.render.render(write_still=True)
    print('COMPLETED',slug,flush=True)

builders=[scene_pets,scene_world,scene_treasure,scene_eggs,scene_arena,scene_weather,scene_shop]
for (folder,filename,reference,slug),builder in zip(SYSTEMS,builders):
    if '--' in sys.argv and slug not in sys.argv[sys.argv.index('--')+1:]:
        continue
    init(slug.upper().replace('-',' '));builder();finish(folder,slug)
