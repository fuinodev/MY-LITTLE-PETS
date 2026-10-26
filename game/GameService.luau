local G={Runtime={}}
local RS=game:GetService("ReplicatedStorage") local Http=game:GetService("HttpService")
local C=require(RS.MyLittlePets.Config) local B=require(RS.MyLittlePets.BigNum) local A=require(RS.MyLittlePets.Assets) local D=require(script.Parent.Profiles)
G.C=C G.B=B G.D=D
local rng=Random.new()
function G.NewPet(id,opts)
 opts=opts or {} return {Uid=Http:GenerateGUID(false),Species=id,Level=1,XP=0,Variant=opts.Variant or "Normal",Origin=C.Species[id].Biome,Size=opts.Size or "Normal",Equipped=false,Mutations={},AcquiredAt=os.time()}
end
function G.NewProfile()
 local p=G.NewPet(1) p.Equipped=true
 return {Version=C.Version,Coins="0",Pets={p},Discovered={[C.Species[1].Id]=true},Bats={},Skin=0,Sector=1,Tier=0,Food={Apple=0,Fish=0,GoldenFruit=0,MysticTreat=0},Boosters={Basic=0,Super=0,Ultra=0},ActiveBooster={Id="",Expires=0},Inbox={},Receipts={},Transactions={},TransactionOrder={},LastSafe={0,4,-88},Daily={},Weekly={}}
end
function G.Rewards(d)
 for r=1,9 do local all=true for _,s in ipairs(C.Species) do if s.Rarity==r and not d.Discovered[s.Id] then all=false break end end if all then d.Bats[tostring(r)]=true end end
end
function G.GrantPet(d,pet)
 if #d.Pets>=C.MaxPets then return false,"Pet inventory full (200)." end
 table.insert(d.Pets,pet) d.Discovered[C.Species[pet.Species].Id]=true G.Rewards(d) return true
end
function G.XP(pet,amount)
 if pet.Level>=100 then return end pet.XP+=amount
 while pet.Level<100 and pet.XP>=100*pet.Level do pet.XP-=100*pet.Level pet.Level+=1 end
 if pet.Level==100 then pet.XP=0 end
end
function G.Team(d)
 local total="0" for _,p in ipairs(d.Pets) do if p.Equipped then total=B.Add(total,C.Power(p,d.Tier,B)) end end return total
end
function G.Speed(d)
 local best=1 for _,p in ipairs(d.Pets) do if p.Equipped then best=math.max(best,C.Species[p.Species].Rarity) end end return 16*(1+(best==10 and .3 or (best-1)*.03))
end
function G.Roll(weights)
 weights=weights or C.Weights local n=rng:NextNumber(0,100) local sum=0 local rarity=1
 for i,v in ipairs(weights) do sum+=v if n<sum then rarity=i break end end
 assert(rarity<9,"Gated rarities cannot enter normal rolls")
 local pool={} for i,s in ipairs(C.Species) do if s.Rarity==rarity then table.insert(pool,i) end end return pool[rng:NextInteger(1,#pool)]
end
function G.Root(p) return p.Character and p.Character:FindFirstChild("HumanoidRootPart") end
function G.Humanoid(p) return p.Character and p.Character:FindFirstChildOfClass("Humanoid") end
function G.Ready(p)
 local s=D.Get(p) local h=G.Humanoid(p) return D.Active(s) and not s.Busy and h and h.Health>0
end
function G.Tell(p,msg) G.Remote:FireClient(p,"Toast",msg) end
function G.SetWorld(world,remote) G.World=world G.Remote=remote end
function G.RuntimeFor(p)
 if not G.Runtime[p] then G.Runtime[p]={Models={},Cooldown={},Assigned=nil,LastBroadcast=0} end return G.Runtime[p]
end
function G.Rebuild(p)
 local s=D.Get(p) if not s then return end local rt=G.RuntimeFor(p)
 if rt.Visual then rt.Visual:Destroy() end
 local folder=Instance.new("Folder") folder.Name="Pets_"..p.UserId folder.Parent=G.World.Root rt.Visual=folder rt.Models={}
 local index=0
 for _,pet in ipairs(s.Data.Pets) do if pet.Equipped then index+=1
  local model=A.Pet(C.Species[pet.Species],pet,C) model:SetAttribute("Owner",p.UserId) model:SetAttribute("Uid",pet.Uid) model:SetAttribute("Slot",index)
  local root=G.Root(p) model:PivotTo(root and root.CFrame*CFrame.new((index-2)*3,0,5) or CFrame.new(0,2,-88)) model.Parent=folder
  A.Label(model.PrimaryPart,C.Species[pet.Species].Name,120,24,2.8,28) rt.Models[pet.Uid]=model
 end end
end
function G.Find(d,uid) for _,pet in ipairs(d.Pets) do if pet.Uid==uid then return pet end end end
function G.Snapshot(p,arena,weather,shop)
 local s=D.Get(p) if not s then return end local d=s.Data local rt=G.RuntimeFor(p)
 G.Remote:FireClient(p,"State",{Coins=d.Coins,Pets=d.Pets,Discovered=d.Discovered,Bats=d.Bats,Skin=d.Skin,Sector=d.Sector,CurrentSector=rt.CurrentSector or 1,Tier=d.Tier,Rate=G.Team(d),Food=d.Food,Boosters=d.Boosters,ActiveBooster=d.ActiveBooster,Inbox=d.Inbox,Revision=s.Revision,Mode=s.Mode,SaveError=s.Error,Loading=s.Busy,Rush=arena and arena.State or "Idle",RushTime=arena and math.max(0,math.ceil(arena.Ends-os.clock())) or 0,InRush=rt.InRush or false,BoxesLeft=arena and arena.BoxesLeft or 10,ClaimProgress=rt.ClaimProgress or 0,Weather=weather and weather.Name or "Sunny",WeatherTime=weather and math.max(0,math.ceil(weather.Ends-os.clock())) or 0,Shop=shop or {},ExactCoins=d.Coins,DailyEnabled=C.Divine.Enabled,WeeklyEnabled=C.Weekly.Enabled})
end
function G.RequestId(arg)
 return type(arg)=="table" and type(arg.Id)=="string" and #arg.Id<=64 and #arg.Id>=8 and type(arg.Time)=="number" and math.abs(os.time()-arg.Time)<=120
end
function G.Hatch(p,arg)
 local s=D.Get(p) local r=G.Root(p) local rt=G.RuntimeFor(p)
 if not s or not r or rt.InRush then return false,"Leave Egg Rush before hatching." end
 if not G.RequestId(arg) then return false,"Invalid hatch request. Please try again." end
 local tx="hatch:"..arg.Id if s.Data.Transactions[tx] then return true,s.Data.Transactions[tx],true end
 if not G.Ready(p) then return false,"Profile busy. Please retry." end
 if (r.Position-G.World.Egg.Position).Magnitude>19 then return false,"Visit the giant clover egg at the plaza." end
 if os.clock()-(rt.Cooldown.Hatch or 0)<1.5 then return false,"Let the previous egg finish hatching." end rt.Cooldown.Hatch=os.clock()
 local id=G.Roll() local pet=G.NewPet(id)
 return D.Commit(s,function(d)
  if #d.Pets>=C.MaxPets then return false,"Your inventory is full." end
  if B.Cmp(d.Coins,C.EggCost)<0 then return false,"You need 250K Coins. Stand near treasure to farm." end
  local equipped=0 for _,v in ipairs(d.Pets) do if v.Equipped then equipped+=1 end end pet.Equipped=equipped<C.EquipSlots
  d.Coins=B.Sub(d.Coins,C.EggCost) G.GrantPet(d,pet) return true,{Species=id,Uid=pet.Uid}
 end,tx)
end
function G.Equip(p,uid)
 local s=D.Get(p) if not s then return false,"Profile unavailable." end
 return D.Commit(s,function(d)
  local pet=G.Find(d,uid) if not pet then return false,"Pet not owned." end
  local n=0 for _,v in ipairs(d.Pets) do if v.Equipped then n+=1 end end
  if not pet.Equipped and n>=C.EquipSlots then return false,"Three pets maximum. Unequip one first." end
  pet.Equipped=not pet.Equipped return true,true
 end)
end
function G.EquipBest(p)
 return D.Commit(D.Get(p),function(d)
  local order={} for _,pet in ipairs(d.Pets) do table.insert(order,pet) pet.Equipped=false end
  table.sort(order,function(a,b) return B.Cmp(C.Power(a,d.Tier,B),C.Power(b,d.Tier,B))>0 end)
  for i=1,math.min(3,#order) do order[i].Equipped=true end return true,true
 end)
end
function G.BuyFood(p,id)
 local food for _,f in ipairs(C.Foods) do if f.Id==id then food=f end end if not food then return false,"Unknown food." end
 return D.Commit(D.Get(p),function(d) if B.Cmp(d.Coins,food.Cost)<0 then return false,"Not enough Coins." end d.Coins=B.Sub(d.Coins,food.Cost) d.Food[id]+=1 return true,"Bought "..food.Name end)
end
function G.Feed(p,uid,id)
 local food for _,f in ipairs(C.Foods) do if f.Id==id then food=f end end if not food then return false,"Unknown food." end
 return D.Commit(D.Get(p),function(d)
  local pet=G.Find(d,uid) if not pet then return false,"Pet not owned." end
  if pet.Level==100 then return false,"This pet is already level 100." end
  if (d.Food[id] or 0)<=0 then return false,"Buy "..food.Name.." in the Food shop first." end
  d.Food[id]-=1 G.XP(pet,food.XP) return true,"Fed "..food.Name.." • +"..food.XP.." XP"
 end)
end
function G.Unlock(p,sector)
 local s=D.Get(p) local r=G.Root(p) local gate=G.World.Gates[sector]
 if not gate or not r or (r.Position-gate.Part.Position).Magnitude>18 then return false,"Visit this sector's gate." end
 return D.Commit(s,function(d)
  if d.Sector>=sector then return false,"This sector is already unlocked." end
  if d.Sector~=sector-1 then return false,"Unlock the previous sector first." end
  if B.Cmp(d.Coins,C.Gates[sector])<0 then return false,"You need "..B.Format(C.Gates[sector]).." Coins." end
  d.Coins=B.Sub(d.Coins,C.Gates[sector]) d.Sector=sector return true,C.Sectors[sector].." unlocked!"
 end)
end
function G.InboxGrant(p,key,pet)
 return D.Commit(D.Get(p),function(d)
  if d.Receipts[key] then return true,true end
  d.Receipts[key]=true d.Inbox[key]={Pet=pet,At=os.time(),Source="Egg Rush"} return true,true
 end)
end
function G.OpenReward(p,key)
 return D.Commit(D.Get(p),function(d)
  local reward=d.Inbox[key] if not reward then return false,"Reward already opened or unavailable." end
  if #d.Pets>=C.MaxPets then return false,"Inventory full. Your reward will stay in the inbox." end
  G.GrantPet(d,reward.Pet) d.Inbox[key]=nil return true,{Species=reward.Pet.Species,Uid=reward.Pet.Uid}
 end)
end
function G.Boost(p,id)
 local booster for _,v in ipairs(C.Boosters) do if v.Id==id then booster=v end end if not booster then return false,"Unknown booster." end
 return D.Commit(D.Get(p),function(d)
  if d.ActiveBooster.Expires>os.time() then return false,"A booster is already active. Its timer continues offline." end
  if (d.Boosters[id] or 0)<1 then return false,"No booster owned. Purchases are Coming Soon." end
  d.Boosters[id]-=1 d.ActiveBooster={Id=id,Expires=os.time()+300} return true,"Lucky booster active for 5 minutes. Direct weather hits are required."
 end)
end
function G.Mutate(p,uid,weather,strike,roll)
 local rt=G.RuntimeFor(p) if rt.InRush or not G.Ready(p) then return false,"Not eligible." end
 return D.Commit(D.Get(p),function(d)
  local pet=G.Find(d,uid) if not pet or not pet.Equipped or table.find(pet.Mutations,weather.Mutation) then return false,"Pet not eligible." end
  local chance=.05 if d.ActiveBooster.Expires>os.time() then for _,b in ipairs(C.Boosters) do if b.Id==d.ActiveBooster.Id then chance+=b.Bonus end end end
  if roll<math.min(chance,1) then table.insert(pet.Mutations,weather.Mutation) return true,{Success=true,Name=C.Species[pet.Species].Name,Mutation=weather.Mutation} end
  return true,{Success=false}
 end,"strike:"..strike)
end
-- Fixed-value target work is shared proportionally; the deterministic remainder never overpays.
function G.Allocate(left,requests)
 local total="0" for _,q in ipairs(requests) do total=B.Add(total,q.Amount) end
 if total=="0" then return {},left end
 local available=B.Min(left,total) local used="0" local result={}
 for i,q in ipairs(requests) do local share=B.Div(B.Mul(available,q.Amount),total) result[i]=share used=B.Add(used,share) end
 local remainder=B.Sub(available,used)
 for i,q in ipairs(requests) do if remainder=="0" then break end if B.Cmp(result[i],q.Amount)<0 then result[i]=B.Add(result[i],"1") remainder=B.Sub(remainder,"1") end end
 return result,B.Sub(left,available)
end
return G
