local Players=game:GetService("Players") local RS=game:GetService("ReplicatedStorage") local Run=game:GetService("RunService") local Http=game:GetService("HttpService") local Tween=game:GetService("TweenService")
local player=Players.LocalPlayer local folder=RS:WaitForChild("MyLittlePets")
local C=require(folder:WaitForChild("Config")) local B=require(folder:WaitForChild("BigNum")) local A=require(folder:WaitForChild("Assets")) local remote=folder:WaitForChild("Action")
local gui=Instance.new("ScreenGui") gui.Name="MyLittlePetsUI" gui.ResetOnSpawn=false gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling gui.Parent=player:WaitForChild("PlayerGui")
local palette={Ink=Color3.fromRGB(30,53,69),Blue=Color3.fromRGB(25,109,160),Navy=Color3.fromRGB(22,67,92),Cream=Color3.fromRGB(246,250,238),Green=Color3.fromRGB(44,143,92),Gold=Color3.fromRGB(255,205,66)}
local data local view="Pets" local biome="Forest" local selected local food=1 local page=1 local petTab="Equipped" local lastRevision=-1 local reduced=false local detailOpen=false local deleteConfirm=false
local render local detail local pendingHatch=nil local open
local function corner(o,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 12) c.Parent=o end
local function stroke(o,color,w) local s=Instance.new("UIStroke") s.Color=color or Color3.fromRGB(255,255,255) s.Thickness=w or 1 s.Transparency=.6 s.Parent=o end
local function frame(parent,name,size,pos,color)
 local f=Instance.new("Frame") f.Name=name f.Size=size f.Position=pos f.BackgroundColor3=color or palette.Cream f.BorderSizePixel=0 f.Parent=parent corner(f) return f
end
local function label(parent,text,size,pos,ts,color)
 local t=Instance.new("TextLabel") t.BackgroundTransparency=1 t.Size=size t.Position=pos t.Font=Enum.Font.GothamBold t.TextSize=ts or 14 t.TextColor3=color or palette.Ink t.Text=text t.TextWrapped=true t.Parent=parent return t
end
local function button(parent,text,size,pos,fn,color)
 local b=Instance.new("TextButton") b.Size=size b.Position=pos b.Font=Enum.Font.GothamBold b.TextSize=13 b.TextColor3=Color3.new(1,1,1) b.BackgroundColor3=color or palette.Blue b.BorderSizePixel=0 b.Text=text b.TextWrapped=true b.Parent=parent corner(b,9) b.Activated:Connect(fn) return b
end
local function send(action,args) remote:FireServer(action,args or {}) end
local function viewport(parent,model,size,pos)
 local v=Instance.new("ViewportFrame") v.Size=size v.Position=pos v.BackgroundTransparency=1 v.Ambient=Color3.fromRGB(190,190,190) v.LightColor=Color3.fromRGB(255,251,235) v.LightDirection=Vector3.new(-1,-2,-3) v.Parent=parent
 local world=Instance.new("WorldModel") world.Parent=v model:PivotTo(CFrame.new()) model.Parent=world
 local cam=Instance.new("Camera") cam.CFrame=CFrame.lookAt(Vector3.new(4,2.9,-7.5),Vector3.new(0,.3,0)) cam.FieldOfView=35 cam.Parent=v v.CurrentCamera=cam return v
end
local HUD=require(folder:WaitForChild("HUD"))
local hud=HUD.New(gui,{Open=function(name) open(name) end,Rush=function() send(data and data.InRush and "LeaveRush" or "JoinRush") end})
local coins,rate,small=hud.Coins,hud.Rate,hud.Status
local panel=frame(gui,"MainPanel",UDim2.new(.94,0,.77,0),UDim2.fromScale(.03,.16),palette.Cream) panel.Visible=false
local limit=Instance.new("UISizeConstraint") limit.MaxSize=Vector2.new(1050,650) limit.Parent=panel
panel.AnchorPoint=Vector2.new(.5,0) panel.Position=UDim2.fromScale(.5,.16)
local titleBar=frame(panel,"TitleBar",UDim2.new(1,0,0,47),UDim2.new(),palette.Navy)
local heading=label(titleBar,"MY PETS",UDim2.new(1,-80,1,0),UDim2.fromOffset(18,0),21,Color3.new(1,1,1)) heading.TextXAlignment=Enum.TextXAlignment.Left
button(titleBar,"×",UDim2.fromOffset(36,32),UDim2.new(1,-44,0,7),function() panel.Visible=false detailOpen=false end,Color3.fromRGB(207,77,77))
local subtitle=label(panel,"",UDim2.new(1,-24,0,41),UDim2.fromOffset(12,48),12)
local content=frame(panel,"Content",UDim2.new(1,-24,1,-106),UDim2.fromOffset(12,94),palette.Cream)
local list=Instance.new("ScrollingFrame") list.Name="Cards" list.Size=UDim2.fromScale(1,1) list.BackgroundTransparency=1 list.BorderSizePixel=0 list.ScrollBarThickness=5 list.AutomaticCanvasSize=Enum.AutomaticSize.Y list.CanvasSize=UDim2.new() list.Parent=content
local grid=Instance.new("UIGridLayout") grid.CellPadding=UDim2.fromOffset(8,8) grid.SortOrder=Enum.SortOrder.LayoutOrder grid.Parent=list
local details=Instance.new("ScrollingFrame") details.Name="PetDetails" details.Size=UDim2.new(0,280,1,0) details.Position=UDim2.new(1,-280,0,0) details.BackgroundColor3=Color3.fromRGB(226,239,238) details.BorderSizePixel=0 details.ScrollBarThickness=4 details.AutomaticCanvasSize=Enum.AutomaticSize.Y details.CanvasSize=UDim2.new() details.Parent=content corner(details) details.Visible=false
local extras=frame(content,"Controls",UDim2.new(1,0,0,35),UDim2.new(),palette.Cream) extras.Visible=false
local toast=frame(gui,"Notification",UDim2.new(.84,0,0,48),UDim2.fromScale(.08,.01),palette.Green) toast.Visible=false toast.ZIndex=20
local toastText=label(toast,"",UDim2.new(1,-20,1,0),UDim2.fromOffset(10,0),14,Color3.new(1,1,1)) toastText.ZIndex=21
local toastId=0
local function notify(msg)
 toastId+=1 local id=toastId toast.Visible=true toastText.Text=msg task.delay(5,function() if toastId==id then toast.Visible=false end end)
end
local function clean(parent) for _,v in ipairs(parent:GetChildren()) do if v:IsA("GuiObject") then v:Destroy() end end end
local function card(color)
 local f=frame(list,"Card",UDim2.new(),UDim2.new(),color) stroke(f,Color3.new(1,1,1),2) return f
end
local function columns(width,min,max) return math.clamp(math.floor((width+8)/(min+8)),1,max or 7) end
local function configureGrid(width,min,height,max) local n=columns(width,min,max) grid.CellSize=UDim2.fromOffset(math.floor((width-(n-1)*8-8)/n),height) end
open=function(name)
 view=name=="Inbox" and "Pets" or name if name=="Inbox" then petTab="All pets" end page=1 detailOpen=false deleteConfirm=false panel.Visible=true render()
end
local help=hud.Help local rushButton=hud.Rush
local reveal=frame(gui,"HatchReveal",UDim2.new(.8,0,.6,0),UDim2.fromScale(.1,.2),palette.Cream) reveal.Visible=false
local revealLimit=Instance.new("UISizeConstraint") revealLimit.MaxSize=Vector2.new(430,400) revealLimit.Parent=reveal reveal.AnchorPoint=Vector2.new(.5,.5) reveal.Position=UDim2.fromScale(.5,.5)
local function showHatch(result)
 pendingHatch=nil clean(reveal) reveal.Visible=true local s=C.Species[result.Species] reveal.BackgroundColor3=s.Color
 label(reveal,"YOU HATCHED!",UDim2.new(1,0,0,37),UDim2.fromOffset(0,10),22)
 viewport(reveal,A.Pet(s,nil,C),UDim2.new(1,-30,.58,0),UDim2.fromOffset(15,40))
 label(reveal,s.Name.." • "..C.Rarities[s.Rarity],UDim2.new(1,-20,0,48),UDim2.new(0,10,1,-103),19)
 button(reveal,"Add to my adventure",UDim2.new(1,-40,0,38),UDim2.new(0,20,1,-49),function() reveal.Visible=false end,palette.Green)
end
local function hatch()
 if pendingHatch then send("Hatch",pendingHatch) return end
 pendingHatch={Id=Http:GenerateGUID(false),Time=os.time()} send("Hatch",pendingHatch)
 task.delay(5,function() pendingHatch=nil end)
end
local function selectedPet() if data then for _,pet in ipairs(data.Pets) do if pet.Uid==selected then return pet end end end end
local function makeDetails()
 clean(details) local pet=selectedPet()
 if not pet then label(details,"Choose a pet to inspect its stats and feed it.",UDim2.new(1,-30,0,100),UDim2.fromOffset(15,25),16) return end
 local s=C.Species[pet.Species]
 if content.AbsoluteSize.X<650 then button(details,"← Back to pets",UDim2.new(1,-20,0,28),UDim2.fromOffset(10,5),function() detailOpen=false render() end) end
 label(details,s.Name,UDim2.new(1,-16,0,30),UDim2.fromOffset(8,38),19)
 viewport(details,A.Pet(s,pet,C),UDim2.new(1,-20,0,125),UDim2.fromOffset(10,68))
 local stats=C.Rarities[s.Rarity].." • "..pet.Origin.."\n"..pet.Variant.." • "..pet.Size.." • Level "..pet.Level.." / 100\nXP "..math.floor(pet.XP).." / "..(100*pet.Level).."\n"..B.Format(C.Power(pet,data.Tier,B)).." Coins / sec\nMutations: "..(#pet.Mutations>0 and table.concat(pet.Mutations,", ") or "None").."\nMutation factor: "..C.MutationFactor(pet).."×"
 label(details,stats,UDim2.new(1,-16,0,112),UDim2.fromOffset(8,194),12)
 button(details,pet.Equipped and "Unequip pet" or "Equip pet",UDim2.new(1,-20,0,30),UDim2.fromOffset(10,310),function() send("Equip",{Uid=pet.Uid}) end,pet.Equipped and palette.Navy or palette.Green)
 button(details,"‹",UDim2.fromOffset(28,29),UDim2.fromOffset(10,349),function() food=(food-2)%#C.Foods+1 makeDetails() end)
 label(details,C.Foods[food].Name.." ×"..(data.Food[C.Foods[food].Id] or 0),UDim2.new(1,-84,0,29),UDim2.fromOffset(42,349),12)
 button(details,"›",UDim2.fromOffset(28,29),UDim2.new(1,-38,0,349),function() food=food%#C.Foods+1 makeDetails() end)
 button(details,"Feed • +"..C.Foods[food].XP.." XP",UDim2.new(1,-20,0,30),UDim2.fromOffset(10,384),function() send("Feed",{Uid=pet.Uid,Food=C.Foods[food].Id}) end,palette.Green)
 button(details,deleteConfirm and "Confirm release" or "Release pet",UDim2.new(1,-20,0,26),UDim2.fromOffset(10,423),function() if deleteConfirm then send("Delete",{Uid=pet.Uid}) selected=nil detailOpen=false deleteConfirm=false else deleteConfirm=true end makeDetails() end,Color3.fromRGB(177,91,88))
end
render=function()
 if not data then return end clean(list) clean(extras) details.Visible=false extras.Visible=false list.Visible=true list.Size=UDim2.fromScale(1,1) list.Position=UDim2.new()
 local width=content.AbsoluteSize.X local height=content.AbsoluteSize.Y local mobile=width<650
 if view=="Pets" then
  local equipped=0 for _,p in ipairs(data.Pets) do if p.Equipped then equipped+=1 end end
  local shown={} for _,pet in ipairs(data.Pets) do if petTab=="All pets" or pet.Equipped then table.insert(shown,pet) end end
  heading.Text="MY PETS • "..#data.Pets.." / 200" subtitle.Text=equipped.." / 3 equipped • Tap a pet to inspect • Page "..page.." / "..math.max(1,math.ceil(#shown/24))
  extras.Visible=true
  for i,tab in ipairs({"Equipped","All pets"}) do button(extras,tab,UDim2.fromOffset(105,29),UDim2.fromOffset((i-1)*112,0),function() petTab=tab page=1 detailOpen=false render() end,petTab==tab and palette.Green or palette.Navy) end
  button(extras,"Equip best",UDim2.fromOffset(100,29),UDim2.fromOffset(224,0),function() send("EquipBest") end,palette.Green)
  button(extras,"‹ Previous",UDim2.fromOffset(96,29),UDim2.fromOffset(0,34),function() page=math.max(1,page-1) render() end)
  button(extras,"Next ›",UDim2.fromOffset(80,29),UDim2.fromOffset(104,34),function() page=math.min(math.max(1,math.ceil(#shown/24)),page+1) render() end)
  local gridWidth=mobile and width or width-290 list.Size=UDim2.new(0,gridWidth,1,-76) list.Position=UDim2.fromOffset(0,76)
  configureGrid(gridWidth,114,164,5)
  if not mobile or detailOpen then details.Visible=true details.Position=mobile and UDim2.fromOffset(0,0) or UDim2.new(1,-280,0,0) details.Size=mobile and UDim2.fromScale(1,1) or UDim2.new(0,280,1,0) if mobile then list.Visible=false extras.Visible=false end makeDetails() end
  for i=(page-1)*24+1,math.min(page*24,#shown) do local pet=shown[i] local s=C.Species[pet.Species] local f=card(s.Color)
   viewport(f,A.Pet(s,pet,C),UDim2.new(1,0,0,91),UDim2.new())
   label(f,s.Name,UDim2.new(1,-6,0,31),UDim2.fromOffset(3,88),12)
   label(f,C.Rarities[s.Rarity].." • Lv "..pet.Level,UDim2.new(1,-4,0,18),UDim2.fromOffset(2,119),10)
   button(f,pet.Equipped and "✓ Equipped" or "Inspect",UDim2.new(1,-10,0,23),UDim2.fromOffset(5,137),function() selected=pet.Uid detailOpen=true deleteConfirm=false render() end,pet.Equipped and palette.Green or palette.Navy)
  end
  if petTab=="All pets" and page==1 then
   for key,reward in pairs(data.Inbox or {}) do
    local rewardKey=key local f=card(Color3.fromRGB(255,228,154))
    label(f,"Egg Rush reward",UDim2.new(1,-12,0,80),UDim2.fromOffset(6,10),15)
    button(f,"Open egg",UDim2.new(1,-12,0,32),UDim2.fromOffset(6,110),function() send("Reward",{Key=rewardKey}) end,palette.Green)
   end
  end
 elseif view=="Index" then
  heading.Text="PET INDEX • "..biome:upper() local count=0 for _,s in ipairs(C.Species) do if data.Discovered[s.Id] then count+=1 end end
  subtitle.Text=biome=="Forest" and count.." / 30 discovered • Rarity collections unlock permanent cosmetic bats" or biome=="EXCLUSIVE" and "Separate special collection • excluded from ordinary eggs" or "New biome collection • Coming Soon"
  extras.Visible=true local tabs={"Forest","River","Desert","Ice","Volcanic","EXCLUSIVE"}
  for i,name in ipairs(tabs) do button(extras,name,UDim2.new(1/6,-4,0,29),UDim2.new((i-1)/6,0,0,0),function() biome=name render() end,biome==name and palette.Green or palette.Blue) end
  list.Position=UDim2.fromOffset(0,39) list.Size=UDim2.new(1,0,1,-39) configureGrid(width,105,139,9)
  if biome=="Forest" then for _,s in ipairs(C.Species) do local known=data.Discovered[s.Id] local f=card(s.Color)
   local model=A.Pet(s,nil,C)
   if not known then for _,p in ipairs(model:GetDescendants()) do if p:IsA("BasePart") then p.Color=Color3.fromRGB(39,56,70) p.Material=Enum.Material.SmoothPlastic end end end
   viewport(f,model,UDim2.new(1,0,0,82),UDim2.new())
   label(f,known and s.Name or "Locked discovery",UDim2.new(1,-6,0,31),UDim2.fromOffset(3,80),11)
   label(f,C.Rarities[s.Rarity],UDim2.new(1,-4,0,19),UDim2.fromOffset(2,114),11)
  end else local f=card(palette.Navy) label(f,biome=="EXCLUSIVE" and "EXCLUSIVE\nSpecial events & premium content\nComing Soon" or biome.."\nCOMING SOON",UDim2.fromScale(1,1),UDim2.new(),14,Color3.new(1,1,1)) end
 elseif view=="Food" then
  heading.Text="FOOD & FEEDING" subtitle.Text="Buy food with Coins, then feed a selected pet in My Pets • Food stays in your inventory"
  configureGrid(width,170,215,4)
  for i,f in ipairs(C.Foods) do local tile=card(Color3.fromRGB(225,237,210))
   label(tile,({"●","◆","✦","★"})[i],UDim2.new(1,0,0,60),UDim2.fromOffset(0,9),42,C.Colors[i+1])
   label(tile,f.Name.."\n+"..f.XP.." XP • Owned: "..(data.Food[f.Id] or 0),UDim2.new(1,-16,0,65),UDim2.fromOffset(8,74),16)
   button(tile,"Buy • "..B.Format(f.Cost).." Coins",UDim2.new(1,-20,0,42),UDim2.fromOffset(10,158),function() send("BuyFood",{Food=f.Id}) end,palette.Green)
  end
 elseif view=="Bats" then
  heading.Text="FOREST BAT SKINS" subtitle.Text="Permanent Index rewards • Identical movement, range, cooldown and knockback"
  configureGrid(width,130,213,7)
  for r=0,9 do local owned=r==0 or data.Bats[tostring(r)] local color=r==0 and Color3.fromRGB(190,157,118) or C.Colors[r] local tile=card(color)
   viewport(tile,A.Bat(math.max(1,r),C,false),UDim2.new(1,0,0,125),UDim2.new())
   label(tile,r==0 and "Starter Bat" or "Forest "..C.Rarities[r],UDim2.new(1,-8,0,35),UDim2.fromOffset(4,123),12)
   button(tile,owned and (data.Skin==r and "✓ Selected" or "Select skin") or "Complete Index",UDim2.new(1,-12,0,33),UDim2.fromOffset(6,170),function() if owned then send("Skin",{Rarity=r}) else notify("Collect every Forest "..C.Rarities[r].." species to unlock this bat.") end end,owned and palette.Green or palette.Navy)
  end
 elseif view=="Egg" then
  heading.Text="FOREST EGG • 250K COINS" subtitle.Text=#data.Pets.." / 200 pets • All giant egg pedestals showcase this shared Forest collection"
  extras.Visible=true button(extras,"Hatch • 250K Coins",UDim2.new(.48,-4,0,31),UDim2.new(),hatch,palette.Green)
  button(extras,"View Forest Index",UDim2.new(.48,-4,0,31),UDim2.new(.5,0,0,0),function() biome="Forest" open("Index") end)
  list.Position=UDim2.fromOffset(0,40) list.Size=UDim2.new(1,0,1,-40) configureGrid(width,120,150,7)
  local counts={} for _,s in ipairs(C.Species) do counts[s.Rarity]=(counts[s.Rarity] or 0)+1 end
  for _,s in ipairs(C.Species) do local f=card(s.Color) viewport(f,A.Pet(s,nil,C),UDim2.new(1,0,0,82),UDim2.new())
   label(f,s.Name,UDim2.new(1,-6,0,29),UDim2.fromOffset(3,80),11)
   label(f,string.format("%.4g%%",C.Weights[s.Rarity]/counts[s.Rarity]).." • "..C.Rarities[s.Rarity],UDim2.new(1,-4,0,31),UDim2.fromOffset(2,111),11)
  end
 elseif view=="Settings" then
  heading.Text="SETTINGS" subtitle.Text="Choose comfortable effects and manage saved progress"
  configureGrid(width,220,180,3)
  local tile=card(Color3.fromRGB(219,232,239))
  label(tile,"Visual Effects\n"..(reduced and "Reduced" or "Full").."\nLower effects reduce ambient particles and color animation.",UDim2.new(1,-20,0,112),UDim2.fromOffset(10,7),15)
  button(tile,reduced and "Enable full effects" or "Reduce effects",UDim2.new(1,-20,0,40),UDim2.fromOffset(10,128),function() reduced=not reduced render() end)
  local save=card(Color3.fromRGB(222,239,212))
  label(save,data.Mode.."\n"..(data.Mode=="Studio session" and "Studio progress stays in this running server." or "Account progress saves automatically."),UDim2.new(1,-20,0,112),UDim2.fromOffset(10,7),15)
  button(save,"Save progress",UDim2.new(1,-20,0,40),UDim2.fromOffset(10,128),function() send("Save") end,palette.Green)
  if Run:IsStudio() then local practice=card(Color3.fromRGB(233,215,248)) label(practice,"Studio Practice\nTest the Egg Rush arena with equal stats.",UDim2.new(1,-20,0,112),UDim2.fromOffset(10,7),15) button(practice,"Start practice round",UDim2.new(1,-20,0,40),UDim2.fromOffset(10,128),function() send("Practice") panel.Visible=false end) end
 elseif view=="Shop" then
  heading.Text="FOREST SHOP" subtitle.Text="Your permanent farming multiplier: "..2^data.Tier.."× • Paid upgrades never affect Egg Rush"
  configureGrid(width,190,210,5)
  for i,u in ipairs(C.Upgrades) do local meta=data.Shop[i] or {} local owned=i<=data.Tier local available=meta.Available and i==data.Tier+1 local f=card(owned and Color3.fromRGB(169,217,176) or Color3.fromRGB(220,234,244))
   label(f,u.Multiplier.."×",UDim2.new(1,0,0,55),UDim2.fromOffset(0,12),35,palette.Blue)
   label(f,"Permanent farming\n"..(meta.Price and "R$ "..meta.Price or "Target R$ "..u.TargetPrice.." • not on sale"),UDim2.new(1,-16,0,65),UDim2.fromOffset(8,70),14)
   button(f,owned and "✓ Owned" or available and "Buy next upgrade" or "Coming Soon",UDim2.new(1,-20,0,39),UDim2.fromOffset(10,157),function() if available then send("BuyUpgrade",{Tier=i}) else notify(owned and "You already own this tier permanently." or "Roblox products must be configured before this tier can be sold.") end end,owned and palette.Green or palette.Navy)
  end
  for _,b in ipairs(C.Boosters) do local f=card(Color3.fromRGB(222,207,241))
   label(f,b.Name.."\n+"..math.floor(b.Bonus*100).." percentage points\n5 minutes • Owned "..(data.Boosters[b.Id] or 0),UDim2.new(1,-14,0,105),UDim2.fromOffset(7,12),16)
   label(f,"Direct weather hit required. Timer continues offline. Purchases Coming Soon.",UDim2.new(1,-12,0,42),UDim2.fromOffset(6,113),11)
   button(f,"Activate owned booster",UDim2.new(1,-20,0,38),UDim2.fromOffset(10,163),function() send("Boost",{Booster=b.Id}) end)
  end
  for _,info in ipairs({"EXCLUSIVE PETS\nPremium collection\nComing Soon","HUGE PETS\nAcquisition pending\nComing Soon","FUTURE UPGRADES\nThrough 1,048,576×\nComing Soon"}) do local f=card(palette.Navy) label(f,info,UDim2.fromScale(1,1),UDim2.new(),18,Color3.new(1,1,1)) end
 else
  heading.Text="YOUR LITTLE ADVENTURE" subtitle.Text=data.Mode.." • "..(data.Mode=="Studio session" and "Local playtest progress stays in this server" or "Progress is saved to your account")
  grid.CellSize=UDim2.new(1,-8,0,420)
  local f=card(Color3.fromRGB(225,237,223))
  label(f,"FARM • Stand within 28 studs of coin piles or treasure chests. Equipped pets work automatically.\n\nCOLLECT • Visit the giant clover egg at the plaza to see every species and its exact odds. Hatch for 250K Coins. Equip your best three pets.\n\nGROW • Buy Apples, Fish, Golden Fruit or Mystic Treats, then feed a pet. XP also comes from active farming.\n\nEXPLORE • Unlock the five Forest sectors in order. The River gateway marks a future update.\n\nEGG RUSH • Join during registration. After a five-second countdown, race to one of ten boxes. Hold its prompt for 0.75 seconds. Equip your bat and tap to knock opponents back. You can claim one egg per round; open it from Pets → All pets.\n\nWEATHER • Six random events can directly strike equipped pets. Only a successful direct-hit roll grants a mutation. Boosters improve that roll, not event frequency or PvP.\n\nINDEX • Discover every pet of a rarity to unlock a permanent cosmetic bat. Divine access and weekly EXCLUSIVE summons remain Coming Soon.",UDim2.new(1,-24,1,-18),UDim2.fromOffset(12,9),13)
  local save=card(palette.Navy) button(save,"Save progress",UDim2.new(1,-24,0,43),UDim2.fromOffset(12,12),function() send("Save") end)
  if Run:IsStudio() then button(save,"Start practice Egg Rush",UDim2.new(1,-24,0,43),UDim2.fromOffset(12,67),function() send("Practice") panel.Visible=false end,palette.Green) end
 end
end
panel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() if panel.Visible then task.defer(render) end end)
remote.OnClientEvent:Connect(function(action,value)
 if action=="State" then
  local previous=data data=value coins.Text=B.Format(data.Coins) rate.Text=B.Format(data.Rate).." Coins / sec"
  small.Text=C.Sectors[data.CurrentSector].." • "..data.Weather.." • "..2^data.Tier.."× • "..data.Mode
  if data.SaveError then small.Text="Saving unavailable — existing progress protected. Retry shortly." end
  rushButton.Visible=data.Rush=="Registration" or data.InRush rushButton.Text=data.InRush and "Leave Rush" or "Join Rush"
  help.Text=data.InRush and (data.Rush.." • "..data.RushTime.."s • "..data.BoxesLeft.." boxes • Hold "..math.floor(data.ClaimProgress*100).."%") or "Egg Rush in "..string.format("%02d:%02d",math.floor(data.RushTime/60),data.RushTime%60).." • Stand near treasure to farm"
  if panel.Visible and (not previous or previous.Revision~=data.Revision) then render() end
  for sector,gate in pairs((function() local out={} local world=workspace:FindFirstChild("MyLittlePets") if world then for s=2,5 do local zone=world:FindFirstChild("Sector"..s) local part=zone and zone:FindFirstChild("Gate"..s) if part then out[s]=part end end end return out end)()) do gate.LocalTransparencyModifier=sector<=data.Sector and 1 or 0 local prompt=gate:FindFirstChildOfClass("ProximityPrompt") if prompt then prompt.Enabled=sector>data.Sector end end
 elseif action=="Toast" then pendingHatch=nil notify(value)
 elseif action=="Open" then if value=="Index" then biome="Forest" end open(value)
 elseif action=="Hatch" then showHatch(value)
 elseif action=="PurchaseClosed" then notify(value and "Checking permanent ownership…" or "Purchase closed. Existing upgrades remain owned.")
 elseif action=="Strike" then
  local world=workspace:FindFirstChild("MyLittlePets") local pets=world and world:FindFirstChild("Pets_"..value.Owner)
  if pets then for _,model in ipairs(pets:GetChildren()) do if model:GetAttribute("Uid")==value.Uid and model.PrimaryPart then
   local pos=model.PrimaryPart.Position local strike=A.Part(workspace,"WeatherStrike",Vector3.new(.18,16,.18),pos+Vector3.new(0,8,0),value.Color) strike.Material=Enum.Material.Neon
   if not reduced then local flash=A.Part(workspace,"StrikeRing",Vector3.new(3,.12,3),pos-Vector3.new(0,1,0),value.Color,Enum.PartType.Ball) flash.Transparency=.6 game:GetService("Debris"):AddItem(flash,.6) end
   game:GetService("Debris"):AddItem(strike,.35)
  end end end
 end
end)
local poses={} local weatherParticles={} local particleAt=0
Run.RenderStepped:Connect(function(dt)
 local world=workspace:FindFirstChild("MyLittlePets") if not world then return end
 for _,folder in ipairs(world:GetChildren()) do if folder:IsA("Folder") and folder.Name:sub(1,5)=="Pets_" then for _,model in ipairs(folder:GetChildren()) do
  if model:IsA("Model") and model.PrimaryPart then
   local owner=Players:GetPlayerByUserId(model:GetAttribute("Owner") or 0) local root=owner and owner.Character and owner.Character:FindFirstChild("HumanoidRootPart")
   if root then
    local slot=model:GetAttribute("Slot") or 1 local target=model:GetAttribute("Target") local working=model:GetAttribute("Working") and typeof(target)=="Vector3"
    local pos=working and target+Vector3.new((slot-2)*2.7,2.1,4) or (root.CFrame*CFrame.new((slot-2)*3.2,0,5)).Position
    pos=Vector3.new(pos.X,working and pos.Y or root.Position.Y-1.2,pos.Z)+Vector3.new(0,math.sin(os.clock()*3+slot)*.18,0)
    local look=working and Vector3.new(target.X,pos.Y,target.Z) or pos+root.CFrame.LookVector
    local cf=CFrame.lookAt(pos,look) if model:GetAttribute("InRush") then cf=CFrame.new(0,-100,0) end
    model:PivotTo(model:GetPivot():Lerp(cf,math.min(1,dt*8)))
    if not reduced then for _,p in ipairs(model:GetChildren()) do if p:IsA("BasePart") and p:GetAttribute("Rainbow") then p.Color=Color3.fromHSV((os.clock()*.12+slot*.15)%1,.65,1) end end end
   end
  end
 end end end
 if data and data.Weather~="Sunny" and not reduced and os.clock()>particleAt then
  particleAt=os.clock()+.15 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
  if root then local col=Color3.fromRGB(160,218,244) for _,w in ipairs(C.Weather) do if w.Name==data.Weather then col=w.Color end end
   local pos=root.Position+Vector3.new(math.random(-14,14),12,math.random(-14,14)) local snow=data.Weather=="Snowstorm"
   local p=A.Part(workspace,"AmbientWeather",snow and Vector3.new(.15,.15,.15) or Vector3.new(.07,1.2,.07),pos,col) p.Transparency=.3
   Tween:Create(p,TweenInfo.new(1.2),{Position=pos-Vector3.new(0,20,0),Transparency=1}):Play() game:GetService("Debris"):AddItem(p,1.3)
  end
 end
end)
local function cameraStart(char)
 local h=char:WaitForChild("Humanoid",10) if not h then return end task.wait(.5)
 local cam=workspace.CurrentCamera if cam then cam.CameraType=Enum.CameraType.Scriptable cam.CFrame=CFrame.lookAt(Vector3.new(23,23,-60),Vector3.new(0,5,-145)) task.wait(.2) cam.CameraSubject=h cam.CameraType=Enum.CameraType.Custom end
end
player.CharacterAdded:Connect(cameraStart) if player.Character then task.spawn(cameraStart,player.Character) end
send("Sync") task.delay(2,function() send("Sync") notify("Welcome to My Little Pets! Your Forest Fox is ready to farm.") end)


