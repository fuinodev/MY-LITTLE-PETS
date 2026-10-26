from pathlib import Path
p=Path('game/tests/Tests.luau')
s=p.read_text(encoding='utf-8-sig')
marker=' test("Studio cannot launch real checkout or grant unverified ownership"'
pos=s.index(marker)
s=s[:pos]+''' test("Complete Egg Rush countdown, durable claim, and safe return",function()
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
'''+s[pos:]
p.write_text(s,encoding='utf-8')
p=Path('game/LeaderboardService.luau')
s=p.read_text(encoding='utf-8-sig').replace('local L={Server={},Global={},','local L={Cache={},Refreshing=false,Server={},Global={},')
s=s.replace('function L.RefreshGlobal()','function L.RefreshGlobal()\n if L.Refreshing then return end')
s=s.replace(' local ok,err=pcall(function()',' L.Refreshing=true\n local ok,err=pcall(function()')
s=s.replace('ordered:GetSortedAsync(false,100)','ordered:GetSortedAsync(false,20)')
s=s.replace('    local row=summaries:GetAsync(entry.key)','''    local cached=L.Cache[entry.key]
    local row=cached and os.time()-cached.At<65 and cached.Row or nil
    if not row then
     assert(DS:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync)>5,"Waiting for read budget")
     row=summaries:GetAsync(entry.key) if row then L.Cache[entry.key]={At=os.time(),Row=row} end
    end''')
s=s.replace(' if not ok then L.GlobalStatus=', ' L.Refreshing=false\n if not ok then L.GlobalStatus=')
p.write_text(s,encoding='utf-8')
