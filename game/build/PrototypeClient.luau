local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local player=Players.LocalPlayer
local folder=RS:WaitForChild("MyLittlePets")
local C=require(folder:WaitForChild("Config"))
local remote=folder:WaitForChild("Action")
local gui=Instance.new("ScreenGui") gui.Name="MyLittlePetsUI" gui.ResetOnSpawn=false gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling gui.Parent=player:WaitForChild("PlayerGui")
local ink=Color3.fromRGB(35,57,58) local cream=Color3.fromRGB(255,250,231) local green=Color3.fromRGB(48,108,86)
local function round(obj,r) local v=Instance.new("UICorner") v.CornerRadius=UDim.new(0,r or 14) v.Parent=obj end
local function label(parent,text,size,pos,ts,color)
 local x=Instance.new("TextLabel") x.BackgroundTransparency=1 x.Size=size x.Position=pos x.Font=Enum.Font.GothamBold x.TextSize=ts or 16 x.TextColor3=color or ink x.Text=text x.TextWrapped=true x.Parent=parent return x
end
local function button(parent,text,size,pos,fn,color)
 local b=Instance.new("TextButton") b.Size=size b.Position=pos b.BackgroundColor3=color or green b.TextColor3=cream b.Font=Enum.Font.GothamBold b.TextSize=14 b.Text=text b.AutoButtonColor=true b.Parent=parent round(b,10) b.Activated:Connect(fn) return b
end
local header=Instance.new("Frame") header.Size=UDim2.new(1,-32,0,82) header.Position=UDim2.fromOffset(16,12) header.BackgroundColor3=cream header.BackgroundTransparency=.03 header.Parent=gui round(header)
label(header,"MY LITTLE PETS",UDim2.new(.36,0,0,30),UDim2.fromOffset(14,9),20,green)
local coins=label(header,"0 Coins",UDim2.new(.34,0,0,30),UDim2.new(.37,0,0,8),24)
local rate=label(header,"10K / sec",UDim2.new(.25,-8,0,30),UDim2.new(.74,0,0,8),17,green)
local status=label(header,"Forest Entrance • Sunny",UDim2.new(1,-24,0,24),UDim2.fromOffset(12,47),13)
local hint=label(gui,"Walk near gold piles and chests — your pets farm automatically.",UDim2.new(.8,0,0,34),UDim2.new(.1,0,1,-139),14,cream) hint.TextStrokeTransparency=.35
local nav=Instance.new("Frame") nav.Size=UDim2.new(1,-32,0,48) nav.Position=UDim2.new(0,16,1,-98) nav.BackgroundTransparency=1 nav.Parent=gui
local panel=Instance.new("Frame") panel.Name="CollectionPanel" panel.AnchorPoint=Vector2.new(.5,.5) panel.Size=UDim2.fromOffset(770,460) panel.Position=UDim2.fromScale(.5,.53) panel.BackgroundColor3=cream panel.Visible=false panel.Parent=gui round(panel,20)
local scale=Instance.new("UIScale") scale.Parent=panel
local function resize() local cam=workspace.CurrentCamera if cam then scale.Scale=math.min(1,(cam.ViewportSize.X-28)/770,(cam.ViewportSize.Y-145)/460) end end
resize() workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(resize) if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) end
local heading=label(panel,"MY PETS",UDim2.new(1,-100,0,38),UDim2.fromOffset(20,12),23,green) heading.TextXAlignment=Enum.TextXAlignment.Left
button(panel,"×",UDim2.fromOffset(38,34),UDim2.new(1,-52,0,14),function() panel.Visible=false end)
local sub=label(panel,"",UDim2.new(1,-40,0,38),UDim2.fromOffset(20,51),13)
local list=Instance.new("ScrollingFrame") list.Size=UDim2.new(1,-32,1,-112) list.Position=UDim2.fromOffset(16,96) list.BackgroundTransparency=1 list.BorderSizePixel=0 list.ScrollBarThickness=5 list.AutomaticCanvasSize=Enum.AutomaticSize.Y list.CanvasSize=UDim2.new() list.Parent=panel
local grid=Instance.new("UIGridLayout") grid.CellSize=UDim2.fromOffset(98,142) grid.CellPadding=UDim2.fromOffset(7,8) grid.SortOrder=Enum.SortOrder.LayoutOrder grid.Parent=list
local data local view="Pets" local render
local function open(name) view=name panel.Visible=true render() end
local names={"My Pets","Pet Index","Bat Skins","How to Play"}
for i,name in ipairs(names) do button(nav,name,UDim2.new(.25,-6,1,0),UDim2.new((i-1)*.25,3,0,0),function() open(({"Pets","Index","Bats","Help"})[i]) end) end
local toast=label(gui,"",UDim2.new(.8,0,0,55),UDim2.new(.1,0,0,102),18,cream) toast.BackgroundColor3=green toast.BackgroundTransparency=.1 round(toast) toast.Visible=false local toastId=0
local function notify(text) toastId+=1 local id=toastId toast.Text=text toast.Visible=true task.delay(4,function() if id==toastId then toast.Visible=false end end) end
local reveal=Instance.new("Frame") reveal.AnchorPoint=Vector2.new(.5,.5) reveal.Position=UDim2.fromScale(.5,.5) reveal.Size=UDim2.fromOffset(320,250) reveal.BackgroundColor3=cream reveal.Visible=false reveal.Parent=gui round(reveal,22)
local revealTitle=label(reveal,"YOU HATCHED",UDim2.new(1,0,0,40),UDim2.fromOffset(0,18),18)
local revealName=label(reveal,"",UDim2.new(1,-24,0,100),UDim2.fromOffset(12,65),29)
button(reveal,"Wonderful!",UDim2.new(1,-48,0,44),UDim2.fromOffset(24,186),function() reveal.Visible=false end)
local function tile(color)
 local f=Instance.new("Frame") f.BackgroundColor3=color f.Parent=list round(f,12) return f
end
render=function()
 for _,v in ipairs(list:GetChildren()) do if v:IsA("GuiObject") then v:Destroy() end end
 if not data then return end
 if view=="Pets" then
  heading.Text="MY PETS • "..#data.Pets.." / 200" sub.Text="Equip up to 3 • Feed an apple for 100K Coins / +100 XP • Tap a pet to equip"
  grid.CellSize=UDim2.fromOffset(137,165)
  for _,pet in ipairs(data.Pets) do
   local s=C.Species[pet.Species] local f=tile(s.Color)
   label(f,s.Name,UDim2.new(1,-10,0,38),UDim2.fromOffset(5,7),14)
   label(f,C.Rarities[s.Rarity].." • Lv. "..pet.Level.."\n"..C.Format(s.Rate*(1+(pet.Level-1)*.01)).."/s\n"..(#pet.Mutations>0 and table.concat(pet.Mutations,", ") or "Normal"),UDim2.new(1,-8,0,57),UDim2.fromOffset(4,43),12)
   button(f,pet.Equipped and "✓ Equipped" or "Equip",UDim2.new(1,-12,0,25),UDim2.fromOffset(6,104),function() remote:FireServer("Equip",pet.Uid) end)
   button(f,"Feed • 100K",UDim2.new(1,-12,0,25),UDim2.fromOffset(6,134),function() remote:FireServer("Feed",pet.Uid) end,Color3.fromRGB(125,91,67))
  end
 elseif view=="Index" then
  local count=0 for _ in pairs(data.Discovered) do count+=1 end
  heading.Text="FOREST INDEX • "..count.." / 30" sub.Text="Complete each rarity to earn a cosmetic bat • Other biomes coming soon • Divine access pending"
  grid.CellSize=UDim2.fromOffset(98,130)
  for i,s in ipairs(C.Species) do local known=data.Discovered[tostring(i)] local f=tile(s.Color)
   label(f,known and "◆" or "?",UDim2.new(1,0,0,42),UDim2.fromOffset(0,8),32)
   label(f,known and s.Name or "Undiscovered",UDim2.new(1,-8,0,36),UDim2.fromOffset(4,51),12)
   label(f,C.Rarities[s.Rarity],UDim2.new(1,-4,0,25),UDim2.fromOffset(2,96),11)
  end
 elseif view=="Bats" then
  heading.Text="FOREST BAT SKINS" sub.Text="Collection rewards • Every bat has equal range, cooldown and knockback"
  grid.CellSize=UDim2.fromOffset(137,145)
  for r,name in ipairs(C.Rarities) do local owned=data.Bats[tostring(r)] local f=tile(C.Colors[r])
   label(f,name.."\nForest Bat",UDim2.new(1,-12,0,65),UDim2.fromOffset(6,9),17)
   button(f,owned and (data.Skin==r and "Selected" or "Select") or "Collect all pets",UDim2.new(1,-12,0,42),UDim2.fromOffset(6,91),function() if owned then remote:FireServer("Skin",r) else notify("Discover every Forest "..name.." pet to unlock this skin.") end end)
  end
 else
  heading.Text="YOUR FOREST ADVENTURE" sub.Text="Playable prototype • progress lasts for this server session"
  grid.CellSize=UDim2.fromOffset(710,275)
  local f=tile(Color3.fromRGB(228,237,212))
  label(f,"1. Follow the trail and stand near treasure. Pets farm within 28 studs.\n\n2. Return to the giant egg in the plaza. Hold E or tap its prompt to hatch for 250K Coins.\n\n3. Equip your best three pets, feed apples, and unlock Forest gates in order.\n\n4. Use the purple portal to join a practice Egg Rush. Race to a box, hold E to claim, and use your bat to knock opponents away.\n\nRain can strike pets and give a permanent Soaked bonus for this session.\nOrdinary eggs: Common 45% • Uncommon 30% • Rare 15% • Epic 7%\nLegendary 2% • Mythic 0.8% • Eternal 0.15% • Heroic 0.05%",UDim2.new(1,-28,1,-16),UDim2.fromOffset(14,8),14)
 end
end
local leave=button(gui,"Leave Egg Rush",UDim2.fromOffset(150,36),UDim2.new(1,-170,0,103),function() remote:FireServer("LeaveRush") end) leave.Visible=false
remote.OnClientEvent:Connect(function(action,value)
 if action=="State" then
  data=value coins.Text=C.Format(data.Coins).." Coins" rate.Text=C.Format(data.Rate).." / sec"
  status.Text=C.Sectors[data.Sector].." • "..data.Weather.."  |  Egg Rush: "..data.Rush.." "..string.format("%02d:%02d",math.floor(data.RushTime/60),data.RushTime%60).."  |  SESSION PROTOTYPE"
  leave.Visible=data.InRush
  hint.Text=data.InRush and (data.Rush=="Running" and "Race to a numbered box • Hold E to claim • Equip your bat to knock opponents" or data.Rush.." • "..data.RushTime.."s") or "Stand near treasure to farm • Hatch at the plaza • Equip your best 3 pets"
  if panel.Visible then render() end
 elseif action=="Toast" then notify(value)
 elseif action=="Hatch" then local s=C.Species[value.Species] revealName.Text=s.Name.."\n"..C.Rarities[s.Rarity] reveal.BackgroundColor3=s.Color reveal.Visible=true end
end)
remote:FireServer("Sync")
task.delay(2,function() remote:FireServer("Sync") notify("Welcome! Your Forest Fox is ready. Walk up the trail to find treasure.") end)
task.delay(1,function() local cam=workspace.CurrentCamera if cam then cam.CFrame=CFrame.lookAt(Vector3.new(25,25,-125),Vector3.new(0,3,-55)) end end)
