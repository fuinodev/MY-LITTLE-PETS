local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Http=game:GetService("HttpService")
local Run=game:GetService("RunService")
local C=require(RS.MyLittlePets.Config)
local W=require(script.Parent.World).Build(C)
local remote=RS.MyLittlePets.Action
local profiles={} local rng=Random.new()
local rush={State="Idle",Ends=os.clock()+1200,Members={},Round=0}
local weather="Sunny" local weatherEnd=os.clock()+90
local function root(p) return p.Character and p.Character:FindFirstChild("HumanoidRootPart") end
local function tell(p,msg) remote:FireClient(p,"Toast",msg) end
local function addPet(d,id)
 if #d.Pets>=200 then return nil end
 local pet={Uid=Http:GenerateGUID(false),Species=id,Level=1,XP=0,Equipped=false,Mutations={}}
 table.insert(d.Pets,pet) d.Discovered[tostring(id)]=true
 for r=1,9 do local all=true for i,s in ipairs(C.Species) do if s.Rarity==r and not d.Discovered[tostring(i)] then all=false break end end if all then d.Bats[tostring(r)]=true end end
 return pet
end
local function roll()
 local r=rng:NextNumber(0,100) local sum=0 local rarity=1
 for i,w in ipairs(C.Weights) do sum+=w if r<sum then rarity=i break end end
 local pool={} for i,s in ipairs(C.Species) do if s.Rarity==rarity then table.insert(pool,i) end end
 return pool[rng:NextInteger(1,#pool)]
end
local function xp(pet,amount)
 pet.XP+=amount while pet.Level<100 and pet.XP>=100*pet.Level do pet.XP-=100*pet.Level pet.Level+=1 end
 if pet.Level==100 then pet.XP=0 end
end
local function power(pet)
 local bonus=1 for _,v in ipairs(pet.Mutations) do if v=="Soaked" then bonus+=.5 end end
 return C.Species[pet.Species].Rate*(1+(pet.Level-1)*.01)*bonus
end
local function team(d) local n=0 for _,p in ipairs(d.Pets) do if p.Equipped then n+=power(p) end end return n end
local function snapshot(p)
 local d=profiles[p] if not d then return end
 remote:FireClient(p,"State",{Coins=d.Coins,Pets=d.Pets,Discovered=d.Discovered,Bats=d.Bats,Skin=d.Skin,Sector=d.Sector,Rate=team(d),Rush=rush.State,RushTime=math.max(0,math.ceil(rush.Ends-os.clock())),InRush=rush.Members[p]~=nil,Weather=weather,SessionOnly=true})
end
local function rebuild(p)
 local d=profiles[p] if not d then return end
 if d.Visual then d.Visual:Destroy() end
 local folder=Instance.new("Folder") folder.Name="Pets_"..p.UserId folder.Parent=W.Root d.Visual=folder d.Models={}
 for _,pet in ipairs(d.Pets) do if pet.Equipped then
  local s=C.Species[pet.Species] local model=Instance.new("Model") model.Name=s.Name model.Parent=folder
  local body=W.Part("Body",Vector3.new(2.5,2.5,2.5),Vector3.new(0,-20,0),s.Color,model) body.CanCollide=false model.PrimaryPart=body
  for side=-1,1,2 do
   local eye=W.Part("Eye",Vector3.new(.3,.45,.15),body.Position+Vector3.new(side*.57,.2,-1.28),Color3.fromRGB(34,47,56),model) eye.CanCollide=false
   local ear=W.Part("Ear",Vector3.new(.65,1,.7),body.Position+Vector3.new(side*.8,1.5,0),s.Color,model) ear.CanCollide=false
  end
  local nose=W.Part("Nose",Vector3.new(.35,.22,.18),body.Position+Vector3.new(0,-.3,-1.3),Color3.fromRGB(244,139,153),model) nose.CanCollide=false
  W.Sign(body,s.Name,2.7,130)
  d.Models[pet.Uid]=model
 end end
end
local function hatch(p)
 local d=profiles[p] local r=root(p)
 if not d or not r or rush.Members[p] or (r.Position-W.Egg.Position).Magnitude>17 then return end
 if os.clock()-(d.LastHatch or 0)<1.5 then return end d.LastHatch=os.clock()
 if #d.Pets>=200 then tell(p,"Your inventory is full (200 pets).") return end
 if d.Coins<C.EggCost then tell(p,"You need 250K Coins. Walk near treasure to farm!") return end
 d.Coins-=C.EggCost local pet=addPet(d,roll())
 local equipped=0 for _,v in ipairs(d.Pets) do if v.Equipped then equipped+=1 end end
 if equipped<3 then pet.Equipped=true rebuild(p) end
 remote:FireClient(p,"Hatch",{Species=pet.Species}) snapshot(p)
end
local function unlock(p,s)
 local d=profiles[p] local r=root(p) if not d or not r or rush.Members[p] or (r.Position-W.Gates[s].Part.Position).Magnitude>18 then return end
 if d.Sector>=s then tell(p,"Already unlocked — walk through!") return end
 if d.Sector~=s-1 then tell(p,"Unlock the previous sector first.") return end
 if d.Coins<C.Gates[s] then tell(p,"You need "..C.Format(C.Gates[s]).." Coins.") return end
 d.Coins-=C.Gates[s] d.Sector=s tell(p,C.Sectors[s].." unlocked!") snapshot(p)
end
W.EggPrompt.Triggered:Connect(hatch)
for s,g in pairs(W.Gates) do g.Prompt.Triggered:Connect(function(p) unlock(p,s) end) end
local function returnPlayer(p)
 local d=profiles[p] local entry=rush.Members[p]
 rush.Members[p]=nil
 if p.Character then local h=p.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=16 h.JumpPower=50 end local bat=p.Character:FindFirstChild("Forest Bat") if bat then bat:Destroy() end end
 local bag=p:FindFirstChildOfClass("Backpack") if bag then local bat=bag:FindFirstChild("Forest Bat") if bat then bat:Destroy() end end
 if root(p) then p.Character:PivotTo(entry and entry.Return or CFrame.lookAt(Vector3.new(0,4,-96),Vector3.new(0,4,0))) end
 if d then snapshot(p) end
end
local function swing(p)
 local d=profiles[p] local a=root(p)
 if not d or not a or rush.State~="Running" or not rush.Members[p] then return end
 if os.clock()-(d.LastSwing or 0)<.8 then return end d.LastSwing=os.clock()
 for other,entry in pairs(rush.Members) do
  local b=root(other) if other~=p and b and (b.Position-a.Position).Magnitude<=6 and (b.Position-a.Position).Magnitude>.1 and a.CFrame.LookVector:Dot((b.Position-a.Position).Unit)>.15 and os.clock()-(entry.LastHit or 0)>.5 then
   entry.LastHit=os.clock() b.AssemblyLinearVelocity=a.CFrame.LookVector*45+Vector3.new(0,18,0)
  end
 end
end
local function join(p)
 local d=profiles[p] local r=root(p) if not d or not r or rush.Members[p] then return end
 if rush.State~="Registration" then tell(p,"Join during registration at the purple portal.") return end
 if #d.Pets>=200 then tell(p,"Inventory full — cannot enter this prototype round.") return end
 rush.Members[p]={Return=r.CFrame,Claimed=false}
 tell(p,"Joined! The race begins after registration.") snapshot(p)
end
local function beginRush(practice)
 if rush.State~="Idle" then return end
 rush.State="Registration" rush.Ends=os.clock()+(practice and 10 or 30) rush.Round+=1
 for _,p in ipairs(Players:GetPlayers()) do tell(p,"Egg Rush registration is open! Join at the purple portal.") end
 task.spawn(function()
  task.wait(practice and 10 or 30)
  if next(rush.Members)==nil then rush.State="Idle" rush.Ends=os.clock()+1200 return end
  rush.State="Countdown" rush.Ends=os.clock()+5 local i=0
  for p,entry in pairs(rush.Members) do
   local r=root(p) if r then i+=1 p.Character:PivotTo(CFrame.lookAt(Vector3.new(165+((i-1)%10)*10,4,-32),Vector3.new(210,4,65))) r.Anchored=true end
  end
  task.wait(5)
  for p in pairs(rush.Members) do
   local r=root(p) if r then r.Anchored=false local h=p.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=16 end
    local tool=Instance.new("Tool") tool.Name="Forest Bat" tool.RequiresHandle=true tool.CanBeDropped=false
    local handle=Instance.new("Part") handle.Name="Handle" handle.Size=Vector3.new(.7,4,.7) handle.Color=C.Colors[profiles[p].Skin or 1] handle.CanCollide=false handle.Massless=true handle.Parent=tool
    tool.Activated:Connect(function() swing(p) end) tool.Parent=p.Backpack
   end
  end
  for _,box in ipairs(W.Boxes) do box.Claimed=false box.Part.Transparency=0 box.Prompt.Enabled=true end
  rush.State="Running" rush.Ends=os.clock()+60
  while os.clock()<rush.Ends and next(rush.Members) do
   local left=0 for _,box in ipairs(W.Boxes) do if not box.Claimed then left+=1 end end
   local eligible=false for _,entry in pairs(rush.Members) do if not entry.Claimed then eligible=true end end
   if left==0 or not eligible then break end task.wait(.5)
  end
  rush.State="Results" rush.Ends=os.clock()+5
  for _,box in ipairs(W.Boxes) do box.Prompt.Enabled=false end
  task.wait(5)
  local all={} for p in pairs(rush.Members) do table.insert(all,p) end for _,p in ipairs(all) do returnPlayer(p) end
  rush.State="Idle" rush.Ends=os.clock()+1200
 end)
end
W.RushPrompt.Triggered:Connect(function(p)
 local r=root(p) if not r or (r.Position-Vector3.new(30,6.5,-92)).Magnitude>18 then return end
 if rush.State=="Idle" then beginRush(true) end join(p)
end)
for _,box in ipairs(W.Boxes) do
 box.Prompt.PromptButtonHoldBegan:Connect(function(p) local e=rush.Members[p] if e then e.Hold={Box=box,Start=os.clock(),Hit=e.LastHit or 0} end end)
 box.Prompt.PromptButtonHoldEnded:Connect(function(p) local e=rush.Members[p] if e then task.defer(function() if e.Hold and e.Hold.Box==box then e.Hold=nil end end) end end)
 box.Prompt.Triggered:Connect(function(p)
  local e=rush.Members[p] local d=profiles[p] local r=root(p)
  if rush.State~="Running" or not e or not d or not r or e.Claimed or box.Claimed or #d.Pets>=200 or (r.Position-box.Part.Position).Magnitude>8 then return end
  local hold=e.Hold if not hold or hold.Box~=box or os.clock()-hold.Start<.7 or (e.LastHit or 0)~=hold.Hit then return end
  box.Claimed=true box.Prompt.Enabled=false box.Part.Transparency=.7 e.Claimed=true
  local pet=addPet(d,roll()) remote:FireClient(p,"Hatch",{Species=pet.Species}) tell(p,"Egg claimed! Your reward is in My Pets.") snapshot(p)
 end)
end
remote.OnServerEvent:Connect(function(p,action,arg)
 local d=profiles[p] if not d then return end
 if os.clock()-(d.RequestAt or 0)<.15 then return end d.RequestAt=os.clock()
 if action=="Sync" then snapshot(p) return end
 if action=="Hatch" then hatch(p) return end
 if action=="Swing" then swing(p) return end
 if action=="LeaveRush" then if rush.Members[p] then local r=root(p) if r then r.Anchored=false end returnPlayer(p) end return end
 if action=="Skin" then if type(arg)=="number" and d.Bats[tostring(arg)] then d.Skin=arg snapshot(p) end return end
 if action=="Equip" or action=="Feed" then
  if type(arg)~="string" or rush.Members[p] then return end
  for _,pet in ipairs(d.Pets) do if pet.Uid==arg then
   if action=="Equip" then
    local count=0 for _,v in ipairs(d.Pets) do if v.Equipped then count+=1 end end
    if not pet.Equipped and count>=3 then tell(p,"Equip up to three pets. Unequip one first.") return end
    pet.Equipped=not pet.Equipped rebuild(p)
   else
    if pet.Level>=100 then tell(p,"This pet is already level 100.") return end
    if d.Coins<100000 then tell(p,"An apple costs 100K Coins.") return end
    d.Coins-=100000 xp(pet,100) tell(p,"Apple fed • +100 XP")
   end snapshot(p) return
  end end
 end
end)
local function added(p)
 local d={Coins=0,Sector=1,Pets={},Discovered={},Bats={},Skin=1,Models={}} profiles[p]=d
 local starter=addPet(d,1) starter.Equipped=true rebuild(p)
 local stats=Instance.new("Folder") stats.Name="leaderstats" stats.Parent=p local coins=Instance.new("StringValue") coins.Name="Coins" coins.Parent=stats
 p.RespawnLocation=W.Spawn
 p.CharacterAdded:Connect(function(char)
  if rush.Members[p] then rush.Members[p]=nil end
  task.wait(.2) if char.Parent then char:PivotTo(CFrame.lookAt(Vector3.new(0,4,-96),Vector3.new(0,4,0))) end
 end)
 if p.Character then p.Character:PivotTo(CFrame.lookAt(Vector3.new(0,4,-96),Vector3.new(0,4,0))) end
 snapshot(p)
end
Players.PlayerAdded:Connect(added) Players.PlayerRemoving:Connect(function(p) local d=profiles[p] if d and d.Visual then d.Visual:Destroy() end profiles[p]=nil rush.Members[p]=nil end)
for _,p in ipairs(Players:GetPlayers()) do added(p) end
local elapsed=0
Run.Heartbeat:Connect(function(dt)
 elapsed+=dt
 for p,d in pairs(profiles) do local r=root(p) if r then
  local n=0 for _,pet in ipairs(d.Pets) do if pet.Equipped then n+=1 local model=d.Models[pet.Uid] if model then
   local offset=Vector3.new((n-2)*3,1.7+math.sin(os.clock()*3+n)*.25,4)
   local cf=r.CFrame*CFrame.new(offset)
   model:PivotTo(model:GetPivot():Lerp(cf,math.min(dt*7,1)))
  end end end
 end end
 if elapsed<1 then return end local tick=math.min(elapsed,1.25) elapsed=0
 for _,t in ipairs(W.Targets) do if t.Left<=0 and os.clock()>=t.Respawn then t.Left=t.Max t.Part.Size=t.Size t.Part.Transparency=0 end end
 for p,d in pairs(profiles) do local r=root(p)
  if r and not rush.Members[p] then
   local current=math.clamp(math.floor((r.Position.Z+55)/110)+1,1,5)
   if current>d.Sector then p.Character:PivotTo(CFrame.new(0,4,(d.Sector-1)*110+30)) tell(p,"Unlock the next sector at its gate first.") end
   local nearest=nil local distance=28
   for _,t in ipairs(W.Targets) do if t.Sector<=d.Sector and t.Left>0 then local dist=(r.Position-t.Part.Position).Magnitude if dist<distance then distance=dist nearest=t end end end
   if nearest then
    local amount=math.min(nearest.Left,team(d)*tick) nearest.Left-=amount d.Coins=math.min(9e15,d.Coins+amount)
    for _,pet in ipairs(d.Pets) do if pet.Equipped then xp(pet,tick) end end
    if nearest.Left<=0 then nearest.Part.Transparency=1 nearest.Respawn=os.clock()+8 else nearest.Part.Size=nearest.Size*(.4+.6*nearest.Left/nearest.Max) end
   end
   local best=1 for _,pet in ipairs(d.Pets) do if pet.Equipped then best=math.max(best,C.Species[pet.Species].Rarity) end end
   local h=p.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=16*(1+(best-1)*.03) end
  end
  if p:FindFirstChild("leaderstats") then p.leaderstats.Coins.Value=C.Format(d.Coins) end snapshot(p)
 end
 for _,t in ipairs(W.Targets) do t.Label.Text=t.Left<=0 and "Regrowing…" or (t.Chest and "CHEST • " or "COINS • ")..C.Format(t.Left) end
 if rush.State=="Idle" and os.clock()>=rush.Ends then beginRush(false) end
 if os.clock()>=weatherEnd then
  weather=weather=="Sunny" and "Rainy" or "Sunny" weatherEnd=os.clock()+(weather=="Rainy" and 35 or 90)
  game:GetService("Lighting").Brightness=weather=="Rainy" and 1 or 2
 end
 if weather=="Rainy" then
  for p,d in pairs(profiles) do if root(p) and not rush.Members[p] and rng:NextNumber()<.08 then
   local equipped={} for _,pet in ipairs(d.Pets) do if pet.Equipped then table.insert(equipped,pet) end end
   if #equipped>0 then local pet=equipped[rng:NextInteger(1,#equipped)] local model=d.Models[pet.Uid]
    if model then local drop=W.Part("RainStrike",Vector3.new(.25,12,.25),model.PrimaryPart.Position+Vector3.new(0,5,0),Color3.fromRGB(119,206,255)) drop.CanCollide=false drop.Material=Enum.Material.Neon game:GetService("Debris"):AddItem(drop,.3)
     if #pet.Mutations==0 and rng:NextNumber()<.2 then table.insert(pet.Mutations,"Soaked") tell(p,C.Species[pet.Species].Name.." gained Soaked! +50% farming.") end
    end
   end
  end end
 end
end)
print("My Little Pets prototype ready: 5 sectors, 30 species, 40 treasures, 10 Egg Rush boxes. Session progress only.")

