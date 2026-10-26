local Players=game:GetService("Players") local RS=game:GetService("ReplicatedStorage") local Run=game:GetService("RunService")
local folder=RS:WaitForChild("MyLittlePets")
local C=require(folder.Config) local B=require(folder.BigNum) local D=require(script.Parent.Profiles) local G=require(script.Parent.GameService)
local R=require(script.Parent.RushService) local V=require(script.Parent.WeatherService) local Shop=require(script.Parent.ShopService) local Boards=require(script.Parent.LeaderboardService)
local W=require(script.Parent.World).Build(C)
local remote=folder.Action G.SetWorld(W,remote) R.Init(G) V.Init(G) Shop.Init(G) Boards.Init(G)
local function snapshot(p) G.Snapshot(p,R,V,Shop.Metadata) end
local function result(p,ok,value,reveal)
 if not ok then G.Tell(p,type(value)=="string" and value or "Please retry.")
 elseif reveal and type(value)=="table" and value.Species then remote:FireClient(p,"Hatch",value) G.Rebuild(p)
 elseif type(value)=="string" then G.Tell(p,value) end snapshot(p)
end
local function at(p,part,distance) local r=G.Root(p) return r and (r.Position-part.Position).Magnitude<=(distance or 18) end
W.EggPrompt.Triggered:Connect(function(p) if at(p,W.Egg,19) then remote:FireClient(p,"Open","Egg") end end)
for _,egg in ipairs(W.Eggs) do egg.Prompt.Triggered:Connect(function(p) if at(p,egg.Part,14) then remote:FireClient(p,"Open","Index") end end) end
W.ShopPrompt.Triggered:Connect(function(p) remote:FireClient(p,"Open","Shop") end)
W.IndexPrompt.Triggered:Connect(function(p) remote:FireClient(p,"Open","Index") end)
W.RushPrompt.Triggered:Connect(function(p)
 if not at(p,W.RushPortal,18) then return end
 if R.State=="Idle" and Run:IsStudio() then R.Begin(true) end
 if R.State=="Registration" then result(p,R.Join(p)) else G.Tell(p,"Next Egg Rush in "..math.ceil(math.max(0,R.Ends-os.clock())).." seconds.") end
end)
for sector,gate in pairs(W.Gates) do gate.Prompt.Triggered:Connect(function(p) if not G.RuntimeFor(p).InRush then result(p,G.Unlock(p,sector)) end end) end
local function safeSpawn(d)
 local v=d.LastSafe if type(v)=="table" and #v==3 and type(v[1])=="number" and math.abs(v[1])<60 and v[3]>=-195 and v[3]<(d.Sector-1)*120+55 then return CFrame.lookAt(Vector3.new(v[1],math.max(4,v[2]),v[3]),Vector3.new(v[1],math.max(4,v[2]),v[3]-10)) end
 return CFrame.new(0,4,-88)
end
local function added(p)
 local ok,s,err=pcall(D.Open,p,G.NewProfile)
 if not ok or not s then p:Kick(err or "Saved profile unavailable. Please rejoin; existing progress is protected.") return end
 if not p.Parent then D.Close(s) return end
 G.Rewards(s.Data) G.RuntimeFor(p)
 p.RespawnLocation=W.Spawn
 local function character(char)
  R.Leave(p,true) local r=char:WaitForChild("HumanoidRootPart",10) if not r then return end
  task.wait(.15) if char.Parent then char:PivotTo(safeSpawn(s.Data)) end
  local h=char:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=G.Speed(s.Data) h.Died:Connect(function() R.Leave(p,true) end) end
  G.Rebuild(p) snapshot(p)
 end
 p.CharacterAdded:Connect(character)
 if p.Character then task.spawn(character,p.Character) end
 local stats=Instance.new("Folder") stats.Name="leaderstats" stats.Parent=p
 local coins=Instance.new("StringValue") coins.Name="Coins" coins.Parent=stats local rate=Instance.new("StringValue") rate.Name="Coins/sec" rate.Parent=stats
 snapshot(p) task.spawn(function() Shop.Reconcile(p) end)
end
Players.PlayerAdded:Connect(added) Players.PlayerRemoving:Connect(function(p)
 R.Leave(p,true) local rt=G.Runtime[p] if rt and rt.Visual then rt.Visual:Destroy() end
 D.Close(D.Get(p)) G.Runtime[p]=nil Shop.Pending[p]=nil
end)
for _,p in ipairs(Players:GetPlayers()) do task.spawn(added,p) end
remote.OnServerEvent:Connect(function(p,action,arg)
 if type(action)~="string" or #action>32 then return end
 local s=D.Get(p) if not s then return end local rt=G.RuntimeFor(p)
 local now=os.clock() local last=rt.Cooldown.Request or 0 if now-last<.18 then return end rt.Cooldown.Request=now
 if action=="Sync" then snapshot(p) return end
 if type(arg)~="table" then arg={} end
 local function handle()
  if action=="LeaveRush" then R.Leave(p) snapshot(p) return end
  if action=="JoinRush" then result(p,R.Join(p)) return end
  if action=="Practice" then if Run:IsStudio() then R.Begin(true) result(p,R.Join(p)) else G.Tell(p,"Practice rounds are available in Studio only.") end return end
  if action=="Swing" then R.Swing(p) return end
  if action=="Save" then
   if now-(rt.Cooldown.Save or 0)<15 then return end rt.Cooldown.Save=now
   result(p,D.Save(s,false),s.Mode=="Studio session" and "Studio session saved in server memory. Cloud saving is used in live servers." or "Progress saved.") return
  end
  if not G.Ready(p) then G.Tell(p,"Profile busy or unavailable. Please retry.") return end
  if rt.InRush then G.Tell(p,"Finish or leave Egg Rush to manage your pets.") return end
  if action=="Hatch" then local ok,v=G.Hatch(p,arg) result(p,ok,v,true)
  elseif action=="Equip" and type(arg.Uid)=="string" then local ok,v=G.Equip(p,arg.Uid) if ok then G.Rebuild(p) end result(p,ok,v)
  elseif action=="EquipBest" then local ok,v=G.EquipBest(p) if ok then G.Rebuild(p) end result(p,ok,v)
  elseif action=="Feed" and type(arg.Uid)=="string" and type(arg.Food)=="string" then local ok,v=G.Feed(p,arg.Uid,arg.Food) if ok then G.Rebuild(p) end result(p,ok,v)
  elseif action=="BuyFood" and type(arg.Food)=="string" then result(p,G.BuyFood(p,arg.Food))
  elseif action=="Unlock" and type(arg.Sector)=="number" then result(p,G.Unlock(p,arg.Sector))
  elseif action=="Boost" and type(arg.Booster)=="string" then result(p,G.Boost(p,arg.Booster))
  elseif action=="Reward" and type(arg.Key)=="string" then local ok,v=G.OpenReward(p,arg.Key) result(p,ok,v,true)
  elseif action=="BuyUpgrade" and type(arg.Tier)=="number" then result(p,Shop.Purchase(p,arg.Tier))
  elseif action=="Skin" and type(arg.Rarity)=="number" then result(p,D.Commit(s,function(d)
   local r=arg.Rarity if r~=0 and not d.Bats[tostring(r)] then return false,"Complete this rarity's Index first." end d.Skin=r return true,"Bat skin selected. Combat stats are unchanged."
  end))
  elseif action=="Delete" and type(arg.Uid)=="string" then
   local ok,v=D.Commit(s,function(d)
    if #d.Pets<=1 then return false,"Keep at least one pet." end
    for i,pet in ipairs(d.Pets) do if pet.Uid==arg.Uid then table.remove(d.Pets,i) return true,"Pet released. Its Index discovery remains." end end return false,"Pet not found."
   end) if ok then G.Rebuild(p) end result(p,ok,v)
  end
 end
 local ok,err=pcall(handle) if not ok then warn("Rejected action "..action..": "..tostring(err)) G.Tell(p,"That request could not finish. Your progress is protected; please retry.") end
end)
local elapsed=0 local raceTick=0 local boardAt=0 local saveAt=os.clock()+45 local globalAt=0 local publishAt=os.clock()+60
local function targetVisible(t,visible)
 for _,p in ipairs(t.Model:GetDescendants()) do if p:IsA("BasePart") then
  if p:GetAttribute("OriginalTransparency")==nil then p:SetAttribute("OriginalTransparency",p.Transparency) end
  p.Transparency=visible and p:GetAttribute("OriginalTransparency") or 1 p.CanCollide=visible and p.Name=="ChestBody"
 end end t.Label.Parent.Enabled=visible
end
Run.Heartbeat:Connect(function(dt)
 raceTick+=dt if raceTick>=.1 then local step=raceTick raceTick=0 R.Tick(step) end
 elapsed+=dt if elapsed<1 then return end local step=math.min(elapsed,1.25) elapsed=0 local now=os.clock()
 local assignments={}
 for _,t in ipairs(W.Targets) do if t.Left=="0" and now>=t.Respawn then t.Left=t.Max t.Model:ScaleTo(1) targetVisible(t,true) end end
 for p,s in pairs(D.All()) do
  local rt=G.RuntimeFor(p) local r=G.Root(p) rt.Assigned=nil
  if r and G.Ready(p) and not rt.InRush then
   local d=s.Data local current=math.clamp(math.floor((r.Position.Z+60)/120)+1,1,5) rt.CurrentSector=current
   if current>d.Sector or math.abs(r.Position.X)>95 or r.Position.Z>541 then p.Character:PivotTo(CFrame.new(0,4,(d.Sector-1)*120+25))
   else
    if r.Position.Y> -2 and r.Position.Y<20 and r.Position.Z> -200 and math.abs(r.Position.X)<60 then d.LastSafe={r.Position.X,4,r.Position.Z} end
    local nearest local distance=28
    for _,t in ipairs(W.Targets) do if t.Sector<=d.Sector and t.Left~="0" then local dist=(r.Position-t.Part.Position).Magnitude if dist<distance then nearest=t distance=dist end end end
    if nearest then
     local scaled=B.Add(B.MulSmall(G.Team(d),math.floor(step*1000)),rt.Fraction or "0") local amount,remainder=B.Div(scaled,"1000") rt.Fraction=remainder
     if amount~="0" then assignments[nearest]=assignments[nearest] or {} table.insert(assignments[nearest],{Player=p,Amount=amount,Session=s,Time=step}) rt.Assigned=nearest end
    end
   end
   local h=G.Humanoid(p) if h then h.WalkSpeed=G.Speed(d) end
  end
  for _,model in pairs(rt.Models) do model:SetAttribute("InRush",rt.InRush or false) model:SetAttribute("Working",rt.Assigned~=nil) if rt.Assigned then model:SetAttribute("Target",rt.Assigned.Part.Position) end end
 end
 for target,requests in pairs(assignments) do
  table.sort(requests,function(a,b) return a.Player.UserId<b.Player.UserId end)
  local shares,left=G.Allocate(target.Left,requests) target.Left=left
  for i,q in ipairs(requests) do if shares[i]~="0" then
   q.Session.Data.Coins=B.Add(q.Session.Data.Coins,shares[i])
   for _,pet in ipairs(q.Session.Data.Pets) do if pet.Equipped then local before=pet.Level G.XP(pet,q.Time) if pet.Level~=before then q.Session.Revision+=1 end end end
  end end
  if target.Left=="0" then target.Respawn=now+target.Delay targetVisible(target,false)
  else local percent=tonumber((B.Div(B.MulSmall(target.Left,100),target.Max))) or 0 target.Model:ScaleTo(.45+.55*percent/100) end
  target.Label.Text=target.Left=="0" and "Regrowing…" or target.Model.Name:gsub("_%d+$","").."\n"..B.Format(target.Left)
 end
 V.Tick()
 for p,s in pairs(D.All()) do if p:FindFirstChild("leaderstats") then p.leaderstats.Coins.Value=B.Format(s.Data.Coins) p.leaderstats["Coins/sec"].Value=B.Format(G.Team(s.Data)) end snapshot(p) end
 if now>=boardAt then boardAt=now+5 Boards.RefreshServer() end
 if now>=saveAt then saveAt=now+45 for _,s in pairs(D.All()) do task.spawn(function() local rev=s.Revision D.Save(s,false) if s.Revision~=rev and s.Player.Parent then G.Rebuild(s.Player) end end) end end
 if now>=globalAt then globalAt=now+30 task.spawn(Boards.RefreshGlobal) end
 if now>=publishAt then publishAt=now+60 task.spawn(Boards.Publish) end
end)
game:BindToClose(function()
 local remaining=0 for _,s in pairs(D.All()) do remaining+=1 task.spawn(function() D.Close(s) remaining-=1 end) end
 local deadline=os.clock()+25 while remaining>0 and os.clock()<deadline do task.wait(.1) end
end)
if Run:IsStudio() and workspace:GetAttribute("MLP_RunTests") then task.spawn(function() require(script.Parent.Tests).Run(G,R,V,Shop) end) end
print("My Little Pets v2 ready • 7 systems connected • exact coin arithmetic • cloud profiles on live servers")


