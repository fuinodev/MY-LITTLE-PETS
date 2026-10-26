-- Appended to GameServer only during an isolated Studio smoke-test run.
task.spawn(function()
 local p=Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
 while not profiles[p] or not root(p) do task.wait(.1) end
 task.wait(1)
 local d=profiles[p] local r=root(p) r.Anchored=true
 local function check(ok,msg) assert(ok,"SMOKE FAIL: "..msg) print("SMOKE PASS: "..msg) end
 check(#C.Species==30 and #W.Targets==40 and #W.Boxes==10,"World and species counts")
 check(#d.Pets==1 and d.Pets[1].Equipped and team(d)==10000,"Starter pet and base income")
 d.Coins=1000000 p.Character:PivotTo(CFrame.new(-28,4,-80))
 hatch(p)
 check(#d.Pets==2 and d.Coins==750000,"Hatch debits exactly 250K and grants one pet")
 hatch(p)
 check(#d.Pets==2 and d.Coins==750000,"Hatch cooldown prevents duplicate spend")
 d.LastHatch=0 d.Coins=0 hatch(p)
 check(#d.Pets==2 and d.Coins==0,"Unaffordable hatch preserves inventory and wallet")
 for i=1,1000 do assert(C.Species[roll()].Rarity<9,"Roll must exclude Divine") if i%100==0 then task.wait() end end
 d.Coins=50000000 p.Character:PivotTo(CFrame.new(0,4,55)) unlock(p,2)
 check(d.Sector==2 and d.Coins==48000000,"Sequential gate unlock and exact price")
 unlock(p,2) check(d.Coins==48000000,"Owned gate never charges twice")
 local pet=d.Pets[1] xp(pet,350)
 check(pet.Level==3 and pet.XP==50,"Leveling carries XP across multiple levels")
 local hits=0 for _,t in ipairs(W.Targets) do if t.Sector==1 then hits+=1 end end check(hits==8,"Eight farming targets in first sector")
 p.Character:PivotTo(CFrame.new(0,4,-96)) r.Anchored=false
 print("MY LITTLE PETS SMOKE TESTS COMPLETE")
end)

