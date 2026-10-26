local L={Cache={},Refreshing=false,Server={},Global={},GlobalStatus="Loading global rankings",Updated=0}
local DS=game:GetService("DataStoreService") local ordered local summaries
function L.Init(G) L.G=G if not game:GetService("RunService"):IsStudio() or G.C.StudioUseDataStore then ordered=DS:GetOrderedDataStore("MLP_RateRank_v2") summaries=DS:GetDataStore("MLP_RateSummary_v2") end end
local function compare(a,b) local c=L.G.B.Cmp(a.Rate,b.Rate) return c==0 and a.UserId<b.UserId or c>0 end
local function text(title,rows,status)
 local lines={title,"#  PLAYER     COINS/SEC     COINS"}
 for i,v in ipairs(rows) do table.insert(lines,string.format("%d  %s   %s/s   %s",i,v.Name:sub(1,14),L.G.B.Format(v.Rate),L.G.B.Format(v.Coins))) if i==10 then break end end
 table.insert(lines,status) return table.concat(lines,"\n")
end
function L.RefreshServer()
 local rows={} for p,s in pairs(L.G.D.All()) do if L.G.D.Active(s) then table.insert(rows,{Name=p.DisplayName,UserId=p.UserId,Rate=L.G.Team(s.Data),Coins=s.Data.Coins,At=os.time()}) end end
 table.sort(rows,compare) L.Server=rows
 L.G.World.ServerText.Text=text("SERVER LEADERBOARD",rows,"Updated "..os.date("!%H:%M:%S").." UTC • every 5s")
end
function L.RefreshGlobal()
 if L.Refreshing then return end
 local anyCloud=false
 for _,s in pairs(L.G.D.All()) do if s.Mode=="Cloud saved" and L.G.D.Active(s) then anyCloud=true end end
 if not anyCloud then L.GlobalStatus="Global rankings require cloud storage • Studio session" L.G.World.GlobalText.Text=text("GLOBAL LEADERBOARD",{},L.GlobalStatus) return end
 L.Refreshing=true
 local ok,err=pcall(function()
  local rows={} local pages=ordered:GetSortedAsync(false,20) local boundary=nil
  for page=1,5 do
   local entries=pages:GetCurrentPage()
   for _,entry in ipairs(entries) do
    local cached=L.Cache[entry.key]
    local row=cached and os.time()-cached.At<65 and cached.Row or nil
    if not row then
     assert(DS:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync)>5,"Waiting for read budget")
     row=summaries:GetAsync(entry.key) if row then L.Cache[entry.key]={At=os.time(),Row=row} end
    end
    if row and type(row.Rate)=="string" and type(row.Coins)=="string" then table.insert(rows,row) end
   end
   table.sort(rows,compare)
   boundary=rows[10] and L.G.B.Score(rows[10].Rate) or nil
   if pages.IsFinished or (boundary and entries[#entries] and entries[#entries].value<boundary) then break end
   assert(page<5,"Too many tied rankings; retry later") pages:AdvanceToNextPageAsync()
  end
  table.sort(rows,compare) L.Global=rows L.Updated=os.time() L.GlobalStatus="Updated "..os.date("!%H:%M:%S").." UTC • cached"
 end)
 L.Refreshing=false
 if not ok then L.GlobalStatus="Global service unavailable • retrying" warn("Global leaderboard unavailable: "..tostring(err)) end
 L.G.World.GlobalText.Text=text("GLOBAL LEADERBOARD",L.Global,L.GlobalStatus)
end
function L.Publish()
 for p,s in pairs(L.G.D.All()) do if s.Mode=="Cloud saved" and L.G.D.Active(s) then
  local row={Name=p.DisplayName,UserId=p.UserId,Rate=L.G.Team(s.Data),Coins=s.Data.Coins,At=os.time()}
  pcall(function() summaries:SetAsync(tostring(p.UserId),row) ordered:SetAsync(tostring(p.UserId),L.G.B.Score(row.Rate)) end)
 end end
end
return L
