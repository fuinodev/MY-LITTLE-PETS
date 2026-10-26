local V={Name="Sunny",Ends=os.clock()+600,Definition=nil,NextStrike=0}
local Http=game:GetService("HttpService") local rng=Random.new()
function V.Init(G) V.G=G V.Ends=os.clock()+rng:NextInteger(480,720) end
function V.Start(index)
 local w=V.G.C.Weather[index] if not w then return false end
 V.Name=w.Name V.Definition=w V.Ends=os.clock()+120 V.NextStrike=os.clock()+10
 local lighting=game:GetService("Lighting") lighting.Ambient=w.Color:Lerp(Color3.fromRGB(115,128,143),.65) lighting.Brightness=1.6
 local atmosphere=lighting:FindFirstChild("MLPAtmosphere") if atmosphere then atmosphere.Color=w.Color:Lerp(Color3.new(1,1,1),.65) end
 for _,p in ipairs(game.Players:GetPlayers()) do V.G.Tell(p,w.Name.." has arrived! Only direct hits can mutate equipped pets.") end return true
end
function V.Tick()
 if os.clock()>=V.Ends then
  if V.Definition then
   V.Name="Sunny" V.Definition=nil V.Ends=os.clock()+rng:NextInteger(480,720)
   local lighting=game:GetService("Lighting") lighting.Ambient=Color3.fromRGB(149,169,143) lighting.Brightness=2.5
   local a=lighting:FindFirstChild("MLPAtmosphere") if a then a.Color=Color3.fromRGB(201,230,247) end
  else local n=rng:NextNumber(0,100) local total=0 for i,w in ipairs(V.G.C.Weather) do total+=w.Weight if n<total then V.Start(i) break end end end
 end
 if not V.Definition or os.clock()<V.NextStrike then return end V.NextStrike=os.clock()+10
 local eligible={}
 for p,s in pairs(V.G.D.All()) do local r=V.G.Root(p) local rt=V.G.RuntimeFor(p)
  if V.G.Ready(p) and r and not rt.InRush and math.abs(r.Position.X)<62 and r.Position.Z> -60 and r.Position.Z<540 and (rt.CurrentSector or 1)<=s.Data.Sector then
   for _,pet in ipairs(s.Data.Pets) do if pet.Equipped and not table.find(pet.Mutations,V.Definition.Mutation) then table.insert(eligible,{Player=p,Uid=pet.Uid}) end end
  end
 end
 for _=1,math.min(3,#eligible) do
  local chosen=table.remove(eligible,rng:NextInteger(1,#eligible)) local strike=Http:GenerateGUID(false) local definition=V.Definition
  V.G.Remote:FireAllClients("Strike",{Owner=chosen.Player.UserId,Uid=chosen.Uid,Weather=definition.Name,Color=definition.Color,Id=strike})
  task.delay(.3,function()
   if V.Definition~=definition then return end
   local ok,result=V.G.Mutate(chosen.Player,chosen.Uid,definition,strike,rng:NextNumber())
   if ok and result.Success then V.G.Rebuild(chosen.Player) V.G.Tell(chosen.Player,result.Name.." gained "..result.Mutation.." permanently!")
   elseif ok and chosen.Player.Parent then V.G.Tell(chosen.Player,"Direct hit — mutation roll missed this time.") end
  end)
 end
end
return V
