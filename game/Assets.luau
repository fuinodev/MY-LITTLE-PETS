-- Shared editable toy geometry, built from Roblox primitives; no external mesh or texture dependencies.
local A={}
function A.Part(parent,name,size,cf,color,shape)
 local p=Instance.new("Part") p.Name=name p.Size=size p.CFrame=typeof(cf)=="CFrame" and cf or CFrame.new(cf) p.Anchored=true p.CanCollide=false p.CanTouch=false p.Material=Enum.Material.SmoothPlastic p.Color=color p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth
 if shape==Enum.PartType.Ball then local mesh=Instance.new("SpecialMesh") mesh.MeshType=Enum.MeshType.Sphere mesh.Parent=p elseif shape then p.Shape=shape end p.Parent=parent return p
end
function A.Wedge(parent,name,size,cf,color)
 local p=Instance.new("WedgePart") p.Name=name p.Size=size p.CFrame=cf p.Color=color p.Anchored=true p.CanCollide=false p.CanTouch=false p.Material=Enum.Material.SmoothPlastic p.Parent=parent return p
end
function A.Cylinder(parent,name,radius,height,cf,color)
 return A.Part(parent,name,Vector3.new(height,radius*2,radius*2),cf*CFrame.Angles(0,0,math.pi/2),color,Enum.PartType.Cylinder)
end
function A.Label(part,text,width,height,offset,max)
 local g=Instance.new("BillboardGui") g.Name="Label" g.Size=UDim2.fromOffset(width or 180,height or 40) g.StudsOffset=Vector3.new(0,offset or 4,0) g.MaxDistance=max or 70 g.AlwaysOnTop=false g.Parent=part
 local l=Instance.new("TextLabel") l.BackgroundTransparency=1 l.Size=UDim2.fromScale(1,1) l.Text=text l.TextColor3=Color3.fromRGB(255,249,222) l.TextStrokeColor3=Color3.fromRGB(36,59,52) l.TextStrokeTransparency=.25 l.Font=Enum.Font.GothamBold l.TextSize=16 l.TextWrapped=true l.Parent=g return l
end
function A.Face(part,text,color,face)
 local g=Instance.new("SurfaceGui") g.Name="SignFace" g.Face=face or Enum.NormalId.Front g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud g.PixelsPerStud=35 g.Parent=part
 local t=Instance.new("TextLabel") t.Size=UDim2.new(1,-12,1,-8) t.Position=UDim2.fromOffset(6,4) t.BackgroundTransparency=1 t.Font=Enum.Font.GothamBold t.TextScaled=true t.TextColor3=color or Color3.fromRGB(255,248,214) t.Text=text t.TextWrapped=true t.Parent=g return t
end
function A.Prompt(part,text,object,hold,distance)
 local p=Instance.new("ProximityPrompt") p.ActionText=text p.ObjectText=object p.HoldDuration=hold or 0 p.MaxActivationDistance=distance or 12 p.RequiresLineOfSight=false p.Parent=part return p
end
function A.Particles(parent,color,rate)
 local e=Instance.new("ParticleEmitter") e.Color=ColorSequence.new(color) e.LightEmission=.5 e.Rate=rate or 2 e.Lifetime=NumberRange.new(.6,1.4) e.Speed=NumberRange.new(.3,1) e.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.12),NumberSequenceKeypoint.new(1,0)}) e.SpreadAngle=Vector2.new(180,180) e.Parent=parent return e
end
function A.Pet(species,pet,C)
 pet=pet or {Variant="Normal",Mutations={},Size="Normal",Level=1}
 local m=Instance.new("Model") m.Name=species.Name local color=species.Color local r=species.Rarity local gold=Color3.fromRGB(255,205,60) local pale=Color3.fromRGB(255,242,211)
 if pet.Variant=="Silver" then color=Color3.fromRGB(195,207,218) elseif pet.Variant=="Gold" then color=gold elseif pet.Variant=="Diamond" then color=Color3.fromRGB(123,222,255) elseif pet.Variant=="Rainbow" then color=Color3.fromRGB(240,128,232) end
 local function p(n,s,pos,c,shape) return A.Part(m,n,s,CFrame.new(pos),c,shape) end
 local body=p("Body",Vector3.new(2.7,2.7,2.7),Vector3.zero,color) m.PrimaryPart=body
 if pet.Variant=="Silver" or pet.Variant=="Gold" then body.Material=Enum.Material.Metal elseif pet.Variant=="Diamond" then body.Material=Enum.Material.Glass body.Reflectance=.15 end
 local name=species.Name:lower()
 local bird=name:find("owl") or name:find("jay") or name:find("raven") or name:find("chick") or name:find("phoenix")
 for side=-1,1,2 do
  p("EyeWhite",Vector3.new(.78,.94,.26),Vector3.new(side*.65,.25,-1.34),Color3.new(1,1,1),Enum.PartType.Ball)
  p("Pupil",Vector3.new(.4,.62,.18),Vector3.new(side*.65,.23,-1.5),Color3.fromRGB(29,40,48),Enum.PartType.Ball)
  p("EyeShine",Vector3.new(.13,.19,.08),Vector3.new(side*.65-.07,.39,-1.61),Color3.new(1,1,1),Enum.PartType.Ball)
  p("TinyFoot",Vector3.new(.64,.36,.78),Vector3.new(side*.78,-1.47,-.55),bird and gold or color:Lerp(pale,.25))
  if bird then
   local wing=p("Wing",Vector3.new(.45,1.2,1.25),Vector3.new(side*1.43,-.1,.1),color:Lerp(pale,.2)) wing.Orientation=Vector3.new(0,0,side*12)
  else
   local tall=name:find("bunny") and 1.65 or .85
   local ear=p("Ear",Vector3.new(.68,tall,.6),Vector3.new(side*.88,1.38+tall*.3,0),color)
   p("InnerEar",Vector3.new(.35,tall*.65,.08),ear.Position+Vector3.new(0,0,-.32),Color3.fromRGB(241,162,167))
  end
 end
 if bird then
  A.Wedge(m,"Beak",Vector3.new(.5,.5,.6),CFrame.new(0,-.35,-1.62)*CFrame.Angles(math.pi/2,0,0),gold)
 else
  p("Muzzle",Vector3.new(1.2,.65,.17),Vector3.new(0,-.55,-1.37),pale,Enum.PartType.Ball)
  p("Nose",Vector3.new(.35,.22,.18),Vector3.new(0,-.34,-1.56),Color3.fromRGB(90,55,55),Enum.PartType.Ball)
  local smile=p("Smile",Vector3.new(.37,.06,.08),Vector3.new(0,-.7,-1.48),Color3.fromRGB(76,57,57))
 end
 if name:find("fox") or name:find("cat") or name:find("wolf") or name:find("lynx") or name:find("pup") or name:find("hound") then
  local tail=p("Tail",Vector3.new(.65,.65,1.6),Vector3.new(.8,-.7,1.9),color) tail.Orientation=Vector3.new(-20,25,0)
  p("TailTip",Vector3.new(.67,.67,.55),Vector3.new(1.1,-.4,2.55),pale)
 end
 if name:find("deer") or name:find("stag") or name:find("dragon") or name:find("drake") or name:find("imp") then
  for side=-1,1,2 do local horn=p("Horn",Vector3.new(.28,1.1,.28),Vector3.new(side*.9,1.9,.4),gold) horn.Orientation=Vector3.new(-12,0,side*-20)
   if name:find("deer") or name:find("stag") then p("Antler",Vector3.new(.6,.2,.2),Vector3.new(side*1.04,2,.4),gold) end
  end
 end
 if name:find("moth") or name:find("dragon") or name:find("pegasus") or name:find("seraph") or name:find("griffin") or name:find("phoenix") then
  for side=-1,1,2 do
   for i=1,3 do local wing=p("WingFeather",Vector3.new(.9,.36,1.4),Vector3.new(side*(1.4+i*.22),.5-i*.2,.3+i*.15),r>=8 and pale or color:Lerp(pale,.3)) wing.Orientation=Vector3.new(0,side*25,side*30) end
  end
 end
 if name:find("hedgehog") or name:find("badger") then for i=1,5 do A.Wedge(m,"Spine",Vector3.new(.5,.65,.7),CFrame.new(-1.1+i*.38,1.55,.6),color:Lerp(Color3.fromRGB(63,73,76),.4)) end end
 if r==4 then
  A.Cylinder(m,"HatBrim",1.1,.13,CFrame.new(0,1.65,0),Color3.fromRGB(80,45,116))
  local hat=p("WizardHat",Vector3.new(1,1.1,1),Vector3.new(0,2.17,0),Color3.fromRGB(91,50,143)) hat.Orientation=Vector3.new(0,0,-12)
  p("HatStar",Vector3.new(.22,.3,.1),Vector3.new(0,2.17,-.56),gold)
 elseif r>=5 then
  for i=1,5 do local a=i*math.pi*2/5 local q=p("Crown",Vector3.new(.26,.55,.26),Vector3.new(math.sin(a)*.77,1.64,math.cos(a)*.77),gold) q.Material=Enum.Material.Metal end
 end
 if r>=8 then
  for i=1,12 do local a=i*math.pi/6 local h=p("Halo",Vector3.new(.5,.13,.24),Vector3.new(math.sin(a)*1.05,2.3,math.cos(a)*1.05),gold) h.Orientation=Vector3.new(0,-math.deg(a),0) h.Material=Enum.Material.Neon end
 end
 for _,id in ipairs(pet.Mutations or {}) do
  for _,w in ipairs(C.Weather) do if id==w.Mutation then
   A.Particles(body,w.Color,2)
   if id=="Soaked" then for i=1,3 do p("Droplet",Vector3.new(.16,.35,.13),Vector3.new(-1+i*.5,.65-i*.25,-1.45),w.Color,Enum.PartType.Ball) end
   elseif id=="Frozen" then for side=-1,1,2 do local ice=A.Wedge(m,"FrostCrystal",Vector3.new(.45,.85,.45),CFrame.new(side*1.25,1.5,.5),w.Color) ice.Material=Enum.Material.Glass end
   elseif id=="Thunderstruck" then for i=1,3 do local spark=p("ElectricArc",Vector3.new(.12,.55,.12),Vector3.new(1.5,.9-i*.45,-.8),w.Color) spark.Orientation=Vector3.new(0,0,i%2==0 and 35 or -35) spark.Material=Enum.Material.Neon end
   elseif id=="Enraged" then for side=-1,1,2 do local flame=A.Wedge(m,"Flame",Vector3.new(.45,.8,.4),CFrame.new(side*1.4,-.6,.4),w.Color) flame.Material=Enum.Material.Neon end
   elseif id=="Celestial" then for i=1,3 do local star=p("StarFragment",Vector3.new(.24,.24,.24),Vector3.new(-1+i*.5,1.6,.4),w.Color) star.Orientation=Vector3.new(30,0,45) star.Material=Enum.Material.Neon end
   elseif id=="Astral" then for i=1,6 do local a=i*math.pi/3 local ribbon=p("AuroraRibbon",Vector3.new(.65,.12,.18),Vector3.new(math.sin(a)*1.65,.5+math.cos(a)*.3,math.cos(a)*1.65),w.Color) ribbon.Orientation=Vector3.new(0,-math.deg(a),10) ribbon.Material=Enum.Material.Neon end end
  end end
 end
 if pet.Variant=="Rainbow" or r==10 then body:SetAttribute("Rainbow",true) A.Particles(body,Color3.fromRGB(255,139,231),3) end
 if pet.Level>=50 then p("Scarf",Vector3.new(2.76,.3,2.76),Vector3.new(0,-.9,0),gold) end
 if pet.Size=="Huge" then m:ScaleTo(2.2) end
 return m
end
function A.Bat(r,C,tool)
 local m=tool and Instance.new("Tool") or Instance.new("Model") m.Name=tool and "Forest Bat" or C.Rarities[r].." Bat"
 if tool then m.CanBeDropped=false end
 local brown=Color3.fromRGB(124,78,41) local col=C.Colors[r] local base=Vector3.zero
 local handle=A.Part(m,"Handle",Vector3.new(.42,3.8,.42),CFrame.new(),r>=8 and Color3.fromRGB(242,232,201) or brown,Enum.PartType.Cylinder)
 handle.Orientation=Vector3.new(0,0,90) handle.Anchored=not tool handle.Massless=true
 local barrel=A.Part(m,"Barrel",Vector3.new(.8,2.2,.8),CFrame.new(0,1.4,0),r==1 and brown or col,Enum.PartType.Cylinder) barrel.Orientation=Vector3.new(0,0,90)
 for i=1,3 do
  local leaf=A.Part(m,"Leaf",Vector3.new(.38,.65,.14),CFrame.new((i%2==0 and 1 or -1)*.38,.3+i*.55,0)*CFrame.Angles(0,0,i%2==0 and -.6 or .6),r<=2 and Color3.fromRGB(75,161,67) or col)
 end
 if r>=3 then for i=1,3 do local q=A.Wedge(m,"Crystal",Vector3.new(.4,.7,.4),CFrame.new((i-2)*.35,2.6,0),col) q.Material=Enum.Material.Neon end end
 if r>=4 then A.Particles(barrel,col,2) end
 if tool then
  for _,p in ipairs(m:GetDescendants()) do if p:IsA("BasePart") then p.Anchored=false p.Massless=true if p~=handle then local weld=Instance.new("WeldConstraint") weld.Part0=handle weld.Part1=p weld.Parent=p end end end
 else m.PrimaryPart=handle end return m
end
return A


