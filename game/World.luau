local W={}
function W.Build(C)
 local A=require(game.ReplicatedStorage.MyLittlePets.Assets) local B=require(game.ReplicatedStorage.MyLittlePets.BigNum)
 local old=workspace:FindFirstChild("MyLittlePets") if old then old:Destroy() end
 local base=workspace:FindFirstChild("Baseplate") if base then base.Position=Vector3.new(base.Position.X,-base.Size.Y/2-9,base.Position.Z) end
 local root=Instance.new("Folder") root.Name="MyLittlePets" root.Parent=workspace
 W.Root=root W.Targets={} W.Gates={} W.Boxes={} W.Eggs={} W.Part=A.Part W.Sign=A.Label
 local gold=Color3.fromRGB(255,199,47) local wood=Color3.fromRGB(119,76,43) local stone=Color3.fromRGB(142,157,143) local dark=Color3.fromRGB(20,72,63)
 local function block(parent,name,size,pos,color,collide)
  local p=A.Part(parent or root,name,size,pos,color) p.CanCollide=collide or false return p
 end
 local function cylinder(parent,name,radius,h,pos,color,collide) local p=A.Cylinder(parent or root,name,radius,h,CFrame.new(pos),color) p.CanCollide=collide or false return p end
 local function tree(parent,x,z,k)
  local y=0 local h=12+(k%4)*2
  block(parent,"PineTrunk",Vector3.new(2,h,2),Vector3.new(x,h/2,z),wood,true)
  for j=1,3 do local width=13-j*2 local cf=CFrame.new(x,h*.45+j*3,z)*CFrame.Angles(0,k*.7,0)
   A.Wedge(parent,"PineCrown",Vector3.new(width,6,width/2),cf*CFrame.new(0,0,width/4),Color3.fromRGB(37+j*8,131+j*12,54+j*5))
   A.Wedge(parent,"PineCrown",Vector3.new(width,6,width/2),cf*CFrame.Angles(0,math.pi,0)*CFrame.new(0,0,width/4),Color3.fromRGB(37+j*8,131+j*12,54+j*5))
  end
 end
 local function lantern(parent,pos)
  block(parent,"LampPost",Vector3.new(.6,4,.6),pos+Vector3.new(0,2,0),wood)
  local glow=block(parent,"LanternGlow",Vector3.new(1,1.25,1),pos+Vector3.new(0,4.3,0),Color3.fromRGB(255,206,112)) glow.Material=Enum.Material.Neon
  block(parent,"LanternCap",Vector3.new(1.4,.25,1.4),pos+Vector3.new(0,5.05,0),wood)
 end
 local function fence(parent,x,z,length,axis)
  for i=0,math.floor(length/10) do local pos=Vector3.new(x,0,z)+(axis=="x" and Vector3.new(i*10,0,0) or Vector3.new(0,0,i*10))
   block(parent,"FencePost",Vector3.new(1,4.5,1),pos+Vector3.new(0,2.25,0),wood,true)
   if i<math.floor(length/10) then for _,h in ipairs({1.5,3}) do block(parent,"FenceRail",axis=="x" and Vector3.new(10,.5,.5) or Vector3.new(.5,.5,10),pos+(axis=="x" and Vector3.new(5,h,0) or Vector3.new(0,h,5)),wood) end end
  end
 end
 local function board(name,pos,size,text)
  local cf=CFrame.lookAt(pos,Vector3.new(0,pos.Y,-82)) local p=block(root,name,size+Vector3.new(1.2,1.2,.4),cf,wood)
  local face=block(root,name.."Face",size,cf*CFrame.new(0,0,-.3),dark) local label=A.Face(face,text)
  for side=-1,1,2 do block(root,"BoardPost",Vector3.new(1,7,1),cf*CFrame.new(side*(size.X/2-1),-size.Y/2-2,0),wood) end
  return face,label
 end
 local terrainColors={Color3.fromRGB(112,197,65),Color3.fromRGB(90,184,73),Color3.fromRGB(68,160,81),Color3.fromRGB(63,147,89),Color3.fromRGB(51,132,96)}
 for s=1,5 do
  local zone=Instance.new("Folder") zone.Name="Sector"..s zone.Parent=root local z=(s-1)*120
  block(zone,"Meadow",Vector3.new(160,4,120),Vector3.new(0,-2,z),terrainColors[s],true)
  block(zone,"ForestTrail",Vector3.new(15,.12,120),Vector3.new(0,.08,z),Color3.fromRGB(202,181,129))
  for side=-1,1,2 do
   for i=1,8 do local tz=z-67+i*15 local x=side*(77+(i%3)) local height=18+(i%3)*4
    block(zone,"Cliff",Vector3.new(16,height,17),Vector3.new(x,height/2-2,tz),Color3.fromRGB(123+(i%3)*8,96+(i%2)*8,73),true)
    block(zone,"CliffGrass",Vector3.new(17,1.5,18),Vector3.new(x,height-1.25,tz),terrainColors[s])
    if i%2==0 then tree(zone,side*65,tz,i+s) end
    if i%3==0 then local rock=block(zone,"MossRock",Vector3.new(4,3,5),Vector3.new(side*57,1.5,tz),stone,true) rock.Orientation=Vector3.new(0,i*18,10) end
   end
   fence(zone,side*61,z-60,120,"z")
   for i=1,3 do lantern(zone,Vector3.new(side*59,0,z-48+i*28)) end
  end
  for i=1,12 do
   local kind=(i-1)%4+1 local def=C.Targets[kind] local x=(i%2==0 and -1 or 1)*(20+(i%3)*12) local tz=z-42+math.floor((i-1)/2)*17
   local model=Instance.new("Model") model.Name=def.Name.."_"..i model.Parent=zone
   local cf=CFrame.new(x,0,tz) local core
   if kind==4 then
    core=block(model,"ChestBody",Vector3.new(6,3.2,4.4),cf*CFrame.new(0,1.8,0),s>=4 and gold or Color3.fromRGB(153,89,38),true)
    block(model,"ChestLid",Vector3.new(6.2,1.4,4.6),cf*CFrame.new(0,4.1,0),Color3.fromRGB(159,97,43))
    for side=-1,1,2 do block(model,"GoldBand",Vector3.new(.55,4.1,4.7),cf*CFrame.new(side*1.9,2.45,0),gold) end
    block(model,"Lock",Vector3.new(.9,1.1,.35),cf*CFrame.new(0,2.7,-2.4),gold)
   else
    core=block(model,"CoinCore",Vector3.new(1,1,1),cf*CFrame.new(0,.5,0),gold) core.Transparency=1
    for j=1,def.Count do local a=j*2.399 local rad=math.sqrt(j)*.48 local layers=j%3
     local coin=cylinder(model,"LeafCoin",.85,.24,Vector3.new(x+math.cos(a)*rad,.3+layers*.25,tz+math.sin(a)*rad),gold)
     local leaf=block(model,"LeafEngraving",Vector3.new(.23,.04,.5),coin.Position+Vector3.new(0,.14,0),Color3.fromRGB(218,151,29)) leaf.Orientation=Vector3.new(0,j*26,0)
    end
   end
   model.PrimaryPart=core local max=def.Work for _=2,s do max=B.MulSmall(max,10) end
   local lab=A.Label(core,def.Name.."\n"..B.Format(max),145,34,kind==4 and 4.5 or 3,40)
   table.insert(W.Targets,{Id=s.."_"..i,Model=model,Part=core,Sector=s,Max=max,Left=max,Respawn=0,Delay=def.Respawn,Label=lab,Hidden=false})
  end
  local title=block(zone,"SectorBoard",Vector3.new(24,4,1),Vector3.new(-24,6,z-53),dark) A.Face(title,C.Sectors[s])
  if s>1 then
   local pos=Vector3.new(0,0,z-60)
   for side=-1,1,2 do block(zone,"GateColumn",Vector3.new(4,13,4),pos+Vector3.new(side*15,6.5,0),stone,true) lantern(zone,pos+Vector3.new(side*15,12,0)) end
   local head=block(zone,"GateTitle",Vector3.new(30,4,2),pos+Vector3.new(0,13,0),dark) A.Face(head,C.Sectors[s].." • "..B.Format(C.Gates[s]))
   local gate=block(zone,"Gate"..s,Vector3.new(27,9,1),pos+Vector3.new(0,4.5,0),Color3.fromRGB(74,203,173)) gate.Transparency=.45
   W.Gates[s]={Part=gate,Prompt=A.Prompt(gate,"Unlock sector",B.Format(C.Gates[s]).." Coins")}
  end
  task.wait()
 end
 local plaza=Instance.new("Folder") plaza.Name="GiantEggPlaza" plaza.Parent=root
 block(plaza,"PlazaGround",Vector3.new(190,4,150),Vector3.new(0,-2,-135),Color3.fromRGB(193,192,148),true)
 block(plaza,"ArrivalPath",Vector3.new(23,.13,145),Vector3.new(0,.09,-132),Color3.fromRGB(228,208,164))
 for side=-1,1,2 do for i=1,6 do tree(plaza,side*87,-63-i*22,i) end end
 for i=1,5 do cylinder(plaza,"PlazaStep",16+i*2,.45,Vector3.new(0,.225*i,-145),i%2==0 and stone or Color3.fromRGB(179,192,169),true) end
 local function egg(pos,r,large)
  local radius=large and 7 or 4 local h=large and 11 or 6.5 local col=large and Color3.fromRGB(247,255,227) or C.Colors[r]
  cylinder(plaza,"EggPedestal",radius+1,1,Vector3.new(pos.X,2,pos.Z),stone,true)
  cylinder(plaza,"RarityTrim",radius+.3,.4,Vector3.new(pos.X,2.7,pos.Z),large and Color3.fromRGB(78,198,89) or col)
  local e=A.Part(plaza,large and "ForestEgg" or "ShowcaseEgg"..r,Vector3.new(radius*1.3,h,radius*1.3),Vector3.new(pos.X,3.2+h/2,pos.Z),col,Enum.PartType.Ball) e.CanCollide=true
  if large then
   for _,offset in ipairs({Vector3.new(-.6,.6,-4.1),Vector3.new(.6,.6,-4.1),Vector3.new(-.6,-.5,-4.1),Vector3.new(.6,-.5,-4.1)}) do A.Part(plaza,"CloverLeaf",Vector3.new(1.8,1.8,.5),e.CFrame+offset,Color3.fromRGB(46,183,72),Enum.PartType.Ball) end
   A.Label(e,"FOREST EGG • 250K\nView pets & odds",210,45,h/2+1,65) W.Egg=e W.EggPrompt=A.Prompt(e,"View egg","Forest • 250K Coins")
  else
   A.Label(e,C.Rarities[r].."\nCollection showcase",110,35,h/2+.8,38)
   table.insert(W.Eggs,{Part=e,Prompt=A.Prompt(e,"View collection",C.Rarities[r]),Rarity=r})
   for side=-1,1,2 do lantern(plaza,Vector3.new(pos.X+side*(radius+1.4),0,pos.Z)) end
  end return e
 end
 for r=1,9 do local a=(r-5)*math.pi/10 egg(Vector3.new(math.sin(a)*69,0,-143-math.cos(a)*42),r,false) end
 egg(Vector3.new(0,0,-145),1,true)
 board("Welcome",Vector3.new(0,19,-196),Vector3.new(49,6,1),"MY LITTLE PETS\nGIANT EGG PLAZA")
 local shop=Instance.new("Folder") shop.Name="ForestShop" shop.Parent=plaza local sx,sz=65,-153
 block(shop,"Counter",Vector3.new(21,4,9),Vector3.new(sx,2,sz),wood,true)
 block(shop,"CounterTop",Vector3.new(23,.6,11),Vector3.new(sx,4.3,sz),Color3.fromRGB(188,133,71))
 for side=-1,1,2 do block(shop,"KioskPost",Vector3.new(.8,8,.8),Vector3.new(sx+side*10,8,sz+3),wood) end
 for i=1,10 do local q=block(shop,"AwningStripe",Vector3.new(2.3,.5,13),CFrame.new(sx-12.65+i*2.3,12,sz-1)*CFrame.Angles(.12,0,0),i%2==0 and Color3.fromRGB(84,176,238) or Color3.fromRGB(249,249,231)) end
 local shopFace=block(shop,"ShopSign",Vector3.new(22,3,1),CFrame.lookAt(Vector3.new(sx,14,sz-1),Vector3.new(0,14,-82)),dark) A.Face(shopFace,"SHOP • PERMANENT UPGRADES")
 for i,b in ipairs(C.Boosters) do local bottle=A.Part(shop,"BoosterBottle",Vector3.new(1.2,1.7,1.2),Vector3.new(sx-5+i*2.5,5.4,sz-2),C.Colors[i*2],Enum.PartType.Ball) block(shop,"BottleCork",Vector3.new(.5,.45,.5),bottle.Position+Vector3.new(0,1,0),gold) end
 W.ShopPrompt=A.Prompt(shopFace,"Open shop","Permanent upgrades • Boosters",0,20)
 W.ServerBoard,W.ServerText=board("ServerLeaderboard",Vector3.new(65,9,-93),Vector3.new(28,16,1),"SERVER LEADERBOARD\nLoading…")
 W.GlobalBoard,W.GlobalText=board("GlobalLeaderboard",Vector3.new(-65,9,-93),Vector3.new(28,16,1),"GLOBAL LEADERBOARD\nLoading…")
 W.ServerText.TextScaled=false W.ServerText.TextSize=29 W.ServerText.TextYAlignment=Enum.TextYAlignment.Top
 W.GlobalText.TextScaled=false W.GlobalText.TextSize=29 W.GlobalText.TextYAlignment=Enum.TextYAlignment.Top
 local portal=block(root,"RushPortal",Vector3.new(11,13,2),Vector3.new(48,6.5,-59),Color3.fromRGB(150,90,239)) portal.Material=Enum.Material.Neon portal.Transparency=.2
 A.Label(portal,"EGG RUSH\nJoin or practice",180,45,8,65) W.RushPortal=portal W.RushPrompt=A.Prompt(portal,"Join Egg Rush","Equal stats • Every 20 minutes")
 local archive=block(plaza,"PetGallery",Vector3.new(4,7,3),Vector3.new(-38,3.5,-131),Color3.fromRGB(103,176,104)) A.Label(archive,"PET INDEX",120,30,5,45) W.IndexPrompt=A.Prompt(archive,"Open Pet Index","Forest collection")
 local river=block(root,"RiverGateway",Vector3.new(36,17,3),Vector3.new(0,8.5,540),Color3.fromRGB(80,182,217),true) river.Material=Enum.Material.Glass A.Face(river,"RIVER\nCOMING SOON")
 for side=-1,1,2 do block(root,"RiverPillar",Vector3.new(5,22,5),Vector3.new(side*20,11,540),stone,true) end
 for i=1,13 do local x=-100+i*15 local h=18+(i%3)*3 block(plaza,"PlazaCliff",Vector3.new(16,h,14),Vector3.new(x,h/2-2,-209),Color3.fromRGB(134,104,77),true) block(plaza,"PlazaCliffGrass",Vector3.new(17,1,15),Vector3.new(x,h-1.5,-209),Color3.fromRGB(100,177,65)) if i%2==0 then tree(plaza,x,-211,i) end end
 local spawn=Instance.new("SpawnLocation") spawn.Name="ForestSpawn" spawn.Size=Vector3.new(7,.4,7) spawn.CFrame=CFrame.lookAt(Vector3.new(0,.3,-88),Vector3.new(0,.3,-150)) spawn.Anchored=true spawn.Neutral=true spawn.Duration=0 spawn.Transparency=1 spawn.CanCollide=false spawn.Parent=root W.Spawn=spawn
 local oldSpawn=workspace:FindFirstChild("SpawnLocation") if oldSpawn then oldSpawn.Enabled=false end
 local arena=Instance.new("Folder") arena.Name="MiniField" arena.Parent=root
 block(arena,"ArenaGrass",Vector3.new(132,4,150),Vector3.new(250,-2,15),Color3.fromRGB(102,184,89),true)
 for side=-1,1,2 do fence(arena,250+side*65,-60,150,"z") for i=1,7 do lantern(arena,Vector3.new(250+side*65,0,-69+i*21)) tree(arena,250+side*74,-69+i*21,i) end end
 fence(arena,185,-60,130,"x") fence(arena,185,90,130,"x")
 block(arena,"StartingStripe",Vector3.new(128,.18,12),Vector3.new(250,.12,-40),Color3.fromRGB(222,101,104))
 local top=block(arena,"RaceTitle",Vector3.new(48,7,1),Vector3.new(250,16,86),dark) A.Face(top,"EGG RUSH\n10 BOXES • EQUAL STATS")
 for i=1,10 do
  local x=195+(i-1)*12 local col=C.Colors[(i-1)%9+1]
  local box=block(arena,"EggBox"..i,Vector3.new(8,4.5,7),Vector3.new(x,2.25,72),col,true)
  block(arena,"BoxTrim",Vector3.new(8.3,.5,7.3),Vector3.new(x,4.7,72),gold)
  A.Part(arena,"BoxEgg",Vector3.new(2.7,3.7,2.7),Vector3.new(x,6.8,72),col,Enum.PartType.Ball)
  A.Face(box,tostring(i)) A.Label(box,tostring(i),45,30,8,90)
  local prompt=A.Prompt(box,"Claim egg","Box "..i,C.Rush.Hold,C.Rush.Range) prompt.Enabled=false
  table.insert(W.Boxes,{Part=box,Prompt=prompt,Claimed=false,Number=i})
 end
 local lighting=game:GetService("Lighting") lighting.ClockTime=13 lighting.Brightness=2.5 lighting.Ambient=Color3.fromRGB(149,169,143) lighting.OutdoorAmbient=Color3.fromRGB(168,188,163)
 local atmosphere=lighting:FindFirstChild("MLPAtmosphere") or Instance.new("Atmosphere") atmosphere.Name="MLPAtmosphere" atmosphere.Density=.2 atmosphere.Offset=.2 atmosphere.Color=Color3.fromRGB(201,230,247) atmosphere.Parent=lighting
 return W
end
return W

