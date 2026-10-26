-- Integration checks are opt-in through the Studio-only MLP_RunTests workspace attribute.
local T={}
function T.Run(G,R,V,Shop)
 local Players=game:GetService("Players") local Http=game:GetService("HttpService")
 local p=Players:GetPlayers()[1] or Players.PlayerAdded:Wait() local deadline=os.clock()+20
 while (not G.D.Get(p) or not G.Root(p)) and os.clock()<deadline do task.wait(.1) end
 local s=G.D.Get(p) assert(s,"Test player profile missing") local saved=G.D.Copy(s.Data) local rt=G.RuntimeFor(p) local start=G.Root(p).CFrame
 local results={} local failures={}
 local function test(name,fn)
  s.Data=G.NewProfile() rt.Cooldown={} rt.InRush=false G.Root(p).Anchored=true
  local ok,err=pcall(fn) table.insert(results,{Name=name,Passed=ok,Error=not ok and tostring(err) or nil})
  if ok then print("PASS • "..name) else table.insert(failures,name) warn("FAIL • "..name.." • "..tostring(err)) end
 end
 local B=G.B local C=G.C
 test("Exact balances beyond floating-point integer range",function()
  assert(B.Add("9007199254740992","1")=="9007199254740993")
  assert(B.Sub("1000000000000000000000","1")=="999999999999999999999")
  assert(B.Mul("12345678901234567890","10")=="123456789012345678900")
  local q,r=B.Div("123456789012345678901","97") assert(B.Add(B.Mul(q,"97"),r)=="123456789012345678901")
 end)
 test("Forest roster, approved odds, prices and geometry",function()
  C.Validate() assert(#G.World.Targets==60 and #G.World.Boxes==10 and #G.World.Eggs==9)
  for i,box in ipairs(G.World.Boxes) do assert(box.Number==i and box.Prompt.HoldDuration==.75) end
 end)
 test("One free starter with discovery and 10K base rate",function() assert(#s.Data.Pets==1 and s.Data.Pets[1].Equipped and G.Team(s.Data)=="10000" and s.Data.Discovered[C.Species[1].Id]) end)
 test("Proportional farming conservation on a final tick",function()
  local shares,left=G.Allocate("100000",{{Amount="50000"},{Amount="100000"}})
  assert(left=="0" and B.Add(shares[1],shares[2])=="100000" and B.Cmp(shares[1],"50000")<=0)
  local a,b=G.Allocate("100000",{{Amount="10000"}}) assert(a[1]=="10000" and b=="90000")
 end)
 test("Atomic hatch and request replay",function()
  s.Data.Coins="1000000" p.Character:PivotTo(CFrame.new(0,5,-132)) local req={Id=Http:GenerateGUID(false),Time=os.time()}
  local ok,res=G.Hatch(p,req) assert(ok and #s.Data.Pets==2 and s.Data.Coins=="750000")
  local again,result,replayed=G.Hatch(p,req) assert(again and replayed and result.Uid==res.Uid and #s.Data.Pets==2 and s.Data.Coins=="750000")
 end)
 test("Full and unaffordable eggs never spend",function()
  p.Character:PivotTo(CFrame.new(0,5,-132)) s.Data.Coins="0"
  local ok=G.Hatch(p,{Id=Http:GenerateGUID(false),Time=os.time()}) assert(not ok and #s.Data.Pets==1 and s.Data.Coins=="0")
  for _=2,200 do table.insert(s.Data.Pets,G.NewPet(1)) end s.Data.Coins="1000000" rt.Cooldown.Hatch=0
  assert(not G.Hatch(p,{Id=Http:GenerateGUID(false),Time=os.time()})) assert(s.Data.Coins=="1000000" and #s.Data.Pets==200)
 end)
 test("Normal rewards exclude Divine and EXCLUSIVE",function() for _=1,5000 do assert(C.Species[G.Roll()].Rarity<9) end end)
 test("Equipment ownership and slot limits",function()
  for i=2,4 do G.GrantPet(s.Data,G.NewPet(i)) end
  assert(not G.Equip(p,"not-owned")) assert(G.Equip(p,s.Data.Pets[2].Uid)) assert(G.Equip(p,s.Data.Pets[3].Uid)) assert(not G.Equip(p,s.Data.Pets[4].Uid))
 end)
 test("Food costs, consumption and capped-pet protection",function()
  s.Data.Coins="1000000" assert(G.BuyFood(p,"Apple")) assert(s.Data.Coins=="900000" and s.Data.Food.Apple==1)
  assert(G.Feed(p,s.Data.Pets[1].Uid,"Apple")) assert(s.Data.Pets[1].Level==2 and s.Data.Food.Apple==0)
  s.Data.Pets[1].Level=100 s.Data.Food.Apple=1 assert(not G.Feed(p,s.Data.Pets[1].Uid,"Apple")) assert(s.Data.Food.Apple==1)
 end)
 test("Sequential gates and duplicate charging protection",function()
  s.Data.Coins="5000000000" p.Character:PivotTo(CFrame.new(0,4,58)) assert(G.Unlock(p,2)) assert(s.Data.Sector==2 and s.Data.Coins=="4998000000")
  assert(not G.Unlock(p,2) and s.Data.Coins=="4998000000") p.Character:PivotTo(CFrame.new(0,4,298)) assert(not G.Unlock(p,4))
 end)
 test("Mutation stacking, failed rolls and duplicate strike protection",function()
  p.Character:PivotTo(CFrame.new(20,4,0)) local uid=s.Data.Pets[1].Uid
  local ok,res=G.Mutate(p,uid,C.Weather[1],"failed",.99) assert(ok and not res.Success and #s.Data.Pets[1].Mutations==0)
  for i,w in ipairs(C.Weather) do assert(G.Mutate(p,uid,w,"strike_"..i,0)) end
  assert(#s.Data.Pets[1].Mutations==6 and C.MutationFactor(s.Data.Pets[1])==47 and G.Team(s.Data)=="470000")
  G.Mutate(p,uid,C.Weather[1],"strike_1",0) assert(#s.Data.Pets[1].Mutations==6)
 end)
 test("All variants and Huge are independent from rarity",function()
  local pet=s.Data.Pets[1] pet.Variant="Rainbow" pet.Size="Huge" assert(C.Power(pet,0,B)=="300000")
  pet.Level=100 assert(C.Power(pet,0,B)=="597000") assert(C.Species[pet.Species].Rarity==1)
 end)
 test("Collection bat rewards use permanent discoveries",function()
  for i=2,5 do G.GrantPet(s.Data,G.NewPet(i)) end assert(s.Data.Bats["1"])
  table.remove(s.Data.Pets,2) G.Rewards(s.Data) assert(s.Data.Bats["1"] and s.Data.Discovered[C.Species[2].Id])
 end)
 test("Full-inventory Egg Rush claim stays durable in inbox",function()
  for _=2,200 do table.insert(s.Data.Pets,G.NewPet(1)) end local pet=G.NewPet(7)
  assert(G.InboxGrant(p,"test_round_box",pet)) assert(s.Data.Inbox.test_round_box)
  assert(G.InboxGrant(p,"test_round_box",G.NewPet(8))) assert(s.Data.Inbox.test_round_box.Pet.Uid==pet.Uid)
  assert(not G.OpenReward(p,"test_round_box")) table.remove(s.Data.Pets,200)
  assert(G.OpenReward(p,"test_round_box")) assert(#s.Data.Pets==200 and not s.Data.Inbox.test_round_box) assert(not G.OpenReward(p,"test_round_box"))
 end)
 test("Booster single-use, no overlap, absolute expiry",function()
  s.Data.Boosters.Basic=2 assert(G.Boost(p,"Basic")) assert(s.Data.Boosters.Basic==1 and s.Data.ActiveBooster.Expires>os.time()+290)
  assert(not G.Boost(p,"Basic") and s.Data.Boosters.Basic==1) s.Data.ActiveBooster.Expires=os.time()-1 assert(G.Boost(p,"Basic")) assert(s.Data.Boosters.Basic==0)
 end)
 test("Arena claim requires active participation and a completed hold",function()
  assert(not R.StartHold(p,G.World.Boxes[1])) assert(not R.Claim(p,G.World.Boxes[1])) assert(not R.Swing(p))
 end)
 test("Complete Egg Rush countdown, durable claim, and safe return",function()
  local before=G.Root(p).CFrame
  assert(R.Begin(true)) assert(R.Join(p))
  R.Ends=0 R.Tick(.1) assert(R.State=="Countdown" and G.Root(p).Anchored)
  assert(not R.Claim(p,G.World.Boxes[1]))
  R.Ends=0 R.Tick(.1) assert(R.State=="Running" and G.Humanoid(p).WalkSpeed==16)
  local box=G.World.Boxes[1]
  p.Character:PivotTo(CFrame.new(box.Part.Position+Vector3.new(0,1,-4))) G.Root(p).Anchored=true
  R.Members[p].LastPosition=G.Root(p).Position
  assert(R.StartHold(p,box)) R.Members[p].Hold.Start=os.clock()-1
  assert(R.Claim(p,box)) assert(not R.Claim(p,box))
  task.wait(.15)
  assert(box.Claimed and R.Members[p].Claimed)
  local count=0 for _ in pairs(s.Data.Inbox) do count+=1 end assert(count==1)
  R.Ends=0 R.Tick(.1) if R.State=="Running" then R.Ends=0 R.Tick(.1) end
  R.Ends=0 R.Tick(.1)
  assert(R.State=="Idle" and not R.Members[p] and not rt.InRush and not G.Root(p).Anchored)
  assert((G.Root(p).Position-before.Position).Magnitude<1)
 end)
 test("Studio cannot launch real checkout or grant unverified ownership",function() local before=s.Data.Tier assert(not Shop.Purchase(p,1)) assert(s.Data.Tier==before) end)
 s.Data=saved G.D.Save(s,false) rt.InRush=false G.Root(p).Anchored=false p.Character:PivotTo(start) G.Rebuild(p)
 workspace:SetAttribute("MLP_TestPassed",#results-#failures) workspace:SetAttribute("MLP_TestFailed",#failures)
 workspace:SetAttribute("MLP_TestReport",Http:JSONEncode(results))
 print(string.format("MY LITTLE PETS TESTS: %d passed, %d failed",#results-#failures,#failures))
end
return T
