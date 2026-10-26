local R={State="Idle",Ends=os.clock()+1200,Members={},Round="",BoxesLeft=10}
local Players=game:GetService("Players") local Http=game:GetService("HttpService")
function R.Init(G)
 R.G=G R.C=G.C.Rush R.Ends=os.clock()+R.C.Interval
 for _,box in ipairs(G.World.Boxes) do
  box.Prompt.PromptButtonHoldBegan:Connect(function(p) R.StartHold(p,box) end)
  box.Prompt.PromptButtonHoldEnded:Connect(function(p) local e=R.Members[p] if e and e.Hold then e.Hold.Ended=os.clock() end end)
  box.Prompt.Triggered:Connect(function(p) R.Claim(p,box) end)
 end
end
function R.Begin(practice)
 if R.State~="Idle" then return false end
 R.State="Registration" R.Ends=os.clock()+(practice and 10 or R.C.Registration) R.Round=Http:GenerateGUID(false) R.BoxesLeft=10
 for _,p in ipairs(Players:GetPlayers()) do R.G.Tell(p,"Egg Rush registration is open! Join at the portal or use Join Rush.") end return true
end
function R.Join(p)
 if R.State~="Registration" then return false,"Registration is closed." end
 if R.Members[p] then return false,"You are already registered." end
 if not R.G.Ready(p) then return false,"Wait for your profile and character to be ready." end
 local r=R.G.Root(p) if not r then return false,"Character unavailable." end
 R.Members[p]={Return=p.Character:GetPivot(),Claimed=false,LastHit=0,LastSwing=0}
 R.G.RuntimeFor(p).InRush=true return true,"Joined Egg Rush. Registration ends in "..math.ceil(R.Ends-os.clock()).."s."
end
function R.Leave(p,respawn)
 local entry=R.Members[p] if not entry then return end R.Members[p]=nil
 local rt=R.G.RuntimeFor(p) rt.InRush=false rt.ClaimProgress=0
 local r=R.G.Root(p) local h=R.G.Humanoid(p)
 if r then r.Anchored=false if not respawn then p.Character:PivotTo(entry.Return or CFrame.new(0,4,-88)) end end
 if h then h.WalkSpeed=R.G.D.Get(p) and R.G.Speed(R.G.D.Get(p).Data) or 16 h.JumpPower=entry.JumpPower or 50 h.JumpHeight=entry.JumpHeight or 7.2 h.AutoRotate=true end
 for _,parent in ipairs({p.Character,p:FindFirstChildOfClass("Backpack")}) do if parent then local bat=parent:FindFirstChild("Forest Bat") if bat then bat:Destroy() end end end
end
function R.StartHold(p,box)
 local entry=R.Members[p] local r=R.G.Root(p)
 if R.State~="Running" or not entry or entry.Claimed or entry.Reserving or box.Claimed or box.Reserved or not r or (r.Position-box.Part.Position).Magnitude>R.C.Range then return false end
 entry.Hold={Box=box,Start=os.clock(),Hit=entry.LastHit} return true
end
function R.Claim(p,box)
 local entry=R.Members[p] local r=R.G.Root(p)
 if R.State~="Running" or not entry or entry.Claimed or entry.Reserving or box.Claimed or box.Reserved or not r or (r.Position-box.Part.Position).Magnitude>R.C.Range then return false end
 local hold=entry.Hold
 if not hold or hold.Box~=box or os.clock()-hold.Start<R.C.Hold-.02 or hold.Hit~=entry.LastHit or (hold.Ended and os.clock()-hold.Ended>.15) then return false end
 box.Reserved=p entry.Reserving=true entry.Hold=nil
 local key="rush:"..R.Round..":"..box.Number local pet=R.G.NewPet(R.G.Roll())
 task.spawn(function()
  local ok=false local err
  for _=1,3 do ok,err=R.G.InboxGrant(p,key,pet) if ok then break end task.wait(.7) end
  entry.Reserving=false box.Reserved=nil
  if ok then
   entry.Claimed=true box.Claimed=true R.BoxesLeft-=1 box.Part.Transparency=.6 box.Prompt.Enabled=false
   if p.Parent then R.G.Tell(p,"Egg #"..box.Number.." secured! Open it from Pets → All pets.") end
  elseif p.Parent then R.G.Tell(p,err or "Could not save this claim. Please retry.") end
 end) return true
end
function R.Swing(p)
 local entry=R.Members[p] local a=R.G.Root(p) local tool=p.Character and p.Character:FindFirstChild("Forest Bat")
 if R.State~="Running" or not entry or not a or not tool or os.clock()-entry.LastSwing<R.C.Cooldown then return false end entry.LastSwing=os.clock()
 R.G.Remote:FireAllClients("Swing",p.UserId)
 for other,victim in pairs(R.Members) do local b=R.G.Root(other) local h=R.G.Humanoid(other)
  if other~=p and b and h and h.Health>0 then local delta=b.Position-a.Position local distance=delta.Magnitude
   if distance>0 and distance<=R.C.Range and a.CFrame.LookVector:Dot(delta.Unit)>.15 and os.clock()-victim.LastHit>=R.C.Grace then
    victim.LastHit=os.clock() victim.Hold=nil
    pcall(function() b:SetNetworkOwner(nil) end) b.AssemblyLinearVelocity=a.CFrame.LookVector*42+Vector3.new(0,18,0)
    task.delay(.25,function() if b.Parent then pcall(function() b:SetNetworkOwnershipAuto() end) end end)
   end
  end
 end return true
end
function R.Tick(dt)
 for p,e in pairs(R.Members) do
  local r=R.G.Root(p) local h=R.G.Humanoid(p) local rt=R.G.RuntimeFor(p)
  if not r or not h or h.Health<=0 or not p.Parent then R.Leave(p,true)
  elseif R.State=="Running" then
   h.WalkSpeed=R.C.Speed
   if e.LastPosition and (r.Position-e.LastPosition).Magnitude>math.max(8,70*dt) then p.Character:PivotTo(CFrame.new(e.LastPosition)) e.Hold=nil end
   if r.Position.X<183 or r.Position.X>317 or r.Position.Z< -61 or r.Position.Z>92 then p.Character:PivotTo(CFrame.new(250,4,-40)) e.Hold=nil end
   e.LastPosition=r.Position
   if e.Hold then
    if (r.Position-e.Hold.Box.Part.Position).Magnitude>R.C.Range or e.Hold.Hit~=e.LastHit or (e.Hold.Ended and os.clock()-e.Hold.Ended>.15) then e.Hold=nil end
   end
   rt.ClaimProgress=e.Hold and math.clamp((os.clock()-e.Hold.Start)/R.C.Hold,0,1) or 0
  end
 end
 if os.clock()<R.Ends then
  if R.State=="Running" then
   local eligible=false for _,e in pairs(R.Members) do if not e.Claimed or e.Reserving then eligible=true end end
   if R.BoxesLeft==0 or not eligible then R.Ends=os.clock() end
  end return
 end
 if R.State=="Idle" then R.Begin(false)
 elseif R.State=="Registration" then
  if next(R.Members)==nil then R.State="Idle" R.Ends=os.clock()+R.C.Interval return end
  R.State="Teleporting" local i=0
  for p,e in pairs(R.Members) do local r=R.G.Root(p) local h=R.G.Humanoid(p) if r and h then
   i+=1 e.JumpPower=h.JumpPower e.JumpHeight=h.JumpHeight
   local pos=Vector3.new(196+((i-1)%10)*12,4,-40-math.floor((i-1)/10)*5)
   p.Character:PivotTo(CFrame.lookAt(pos,Vector3.new(pos.X,4,72))) r.Anchored=true h.WalkSpeed=0 e.LastPosition=pos
  end end
  R.State="Countdown" R.Ends=os.clock()+R.C.Countdown
 elseif R.State=="Countdown" then
  local A=require(game.ReplicatedStorage.MyLittlePets.Assets)
  for p,e in pairs(R.Members) do local r=R.G.Root(p) local h=R.G.Humanoid(p) if r and h then
   r.Anchored=false h.WalkSpeed=R.C.Speed h.JumpPower=50 h.JumpHeight=7.2
   local s=R.G.D.Get(p) local bat=A.Bat(s and math.max(1,s.Data.Skin) or 1,R.G.C,true) bat.Parent=p.Backpack bat.Activated:Connect(function() R.Swing(p) end)
   h:EquipTool(bat) e.LastPosition=r.Position
  end end
  for _,box in ipairs(R.G.World.Boxes) do box.Claimed=false box.Reserved=nil box.Part.Transparency=0 box.Prompt.Enabled=true end
  R.State="Running" R.Ends=os.clock()+R.C.Duration
 elseif R.State=="Running" then R.State="Results" R.Ends=os.clock()+R.C.Results for _,box in ipairs(R.G.World.Boxes) do box.Prompt.Enabled=false end
 elseif R.State=="Results" then
  -- Finish any in-flight durable claim before tearing down the round.
  for _,e in pairs(R.Members) do if e.Reserving then R.Ends=os.clock()+.5 return end end
  R.State="Returning" local all={} for p in pairs(R.Members) do table.insert(all,p) end for _,p in ipairs(all) do R.Leave(p) end R.State="Idle" R.Ends=os.clock()+R.C.Interval
 end
end
return R
