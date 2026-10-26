-- All critical grants pass through an owned profile transaction. No production fallback to empty data.
local D={}
local DS=game:GetService("DataStoreService") local Http=game:GetService("HttpService") local Run=game:GetService("RunService")
local C=require(game.ReplicatedStorage.MyLittlePets.Config) local B=require(game.ReplicatedStorage.MyLittlePets.BigNum)
local store=DS:GetDataStore(C.DataStoreName) local memory={} local sessions={}
local token=(game.JobId~="" and game.JobId or "studio")..":"..Http:GenerateGUID(false)
local function copy(v) if type(v)~="table" then return v end local t={} for k,x in pairs(v) do t[k]=copy(x) end return t end D.Copy=copy
local function retry(fn)
 local last for i=1,3 do local ok,result=pcall(fn) if ok then return true,result end last=result if i<3 then task.wait(2^(i-1)) end end return false,last
end
function D.Validate(d)
 assert(type(d)=="table" and d.Version==C.Version,"Unsupported profile schema; migration required")
 d.Coins=B.N(d.Coins) assert(type(d.Pets)=="table" and #d.Pets<=C.MaxPets,"Invalid inventory")
 assert(type(d.Sector)=="number" and d.Sector%1==0 and d.Sector>=1 and d.Sector<=5,"Invalid sectors")
 local ids={} local count=0
 for _,pet in ipairs(d.Pets) do
  assert(type(pet.Uid)=="string" and not ids[pet.Uid] and C.Species[pet.Species],"Invalid pet") ids[pet.Uid]=true
  assert(type(pet.Level)=="number" and pet.Level%1==0 and pet.Level>=1 and pet.Level<=100,"Invalid level")
  assert(type(pet.XP)=="number" and pet.XP>=0 and pet.XP==pet.XP,"Invalid XP")
  assert(C.Variants[pet.Variant] and C.Origin[pet.Origin],"Invalid pet variant/origin")
  assert(pet.Size=="Normal" or pet.Size=="Huge","Invalid size")
  local seen={} for _,id in ipairs(pet.Mutations) do local found=false for _,w in ipairs(C.Weather) do if w.Mutation==id then found=true end end assert(found and not seen[id],"Invalid mutation") seen[id]=true end
  if pet.Equipped then count+=1 end
 end assert(count<=C.EquipSlots,"Too many equipped pets")
 for _,key in ipairs({"Discovered","Bats","Food","Boosters","Inbox","Receipts","Transactions","TransactionOrder"}) do assert(type(d[key])=="table","Missing "..key) end
 assert(d.Tier>=0 and d.Tier%1==0 and d.Tier<=30,"Invalid tier")
 return d
end
function D.Open(p,factory)
 local mode=Run:IsStudio() and not C.StudioUseDataStore and "Studio session" or "Cloud saved"
 local s={Player=p,Mode=mode,Busy=false,Closed=false,LastSave=os.clock(),Lease=os.time()+180,Revision=0}
 local initial=factory()
 if mode=="Studio session" then
  s.Data=copy(memory[p.UserId] or initial) D.Validate(s.Data) sessions[p]=s return s
 end
 local ok,result=retry(function()
  return store:UpdateAsync("p_"..p.UserId,function(old)
   if old then
    D.Validate(old)
    if old.Session and old.Session.Token~=token and old.Session.Expires>os.time() then return nil end
   end
   local d=copy(old or initial) d.Session={Token=token,Expires=os.time()+180} return d,{p.UserId}
  end)
 end)
 if not ok or not result or not result.Session or result.Session.Token~=token then return nil,"Your saved profile is unavailable or active on another server. Please rejoin; no progress was overwritten." end
 s.Data=D.Validate(result) sessions[p]=s return s
end
local function persist(s,d,release)
 if s.Mode=="Studio session" then memory[s.Player.UserId]=copy(d) return true end
 local proposed=copy(d) proposed.LastWrite=Http:GenerateGUID(false) if release then proposed.Session=nil else proposed.Session={Token=token,Expires=os.time()+180} end
 local ok,result=retry(function()
  return store:UpdateAsync("p_"..s.Player.UserId,function(old)
   if not old or not old.Session or old.Session.Token~=token then return nil end
   return proposed,{s.Player.UserId}
  end)
 end)
 if not ok or not result then s.Uncertain=true s.Error="Saving unavailable. Critical changes are paused; retry shortly." return false end
 s.Error=nil s.Lease=os.time()+180 s.LastSave=os.clock() return true
end
function D.Active(s) return s and not s.Closed and not s.Uncertain and (s.Mode=="Studio session" or os.time()<s.Lease-10) end
function D.Commit(s,fn,tx)
 if not D.Active(s) or s.Busy then return false,"Profile busy or unavailable. Please retry." end
 if tx and s.Data.Transactions[tx] then return true,copy(s.Data.Transactions[tx]),true end
 s.Busy=true local draft=copy(s.Data)
 local ok,allowed,result=pcall(fn,draft)
 if not ok or not allowed then s.Busy=false return false,ok and result or "The change could not be validated." end
 if tx then
  draft.Transactions[tx]=result or true table.insert(draft.TransactionOrder,tx)
  while #draft.TransactionOrder>160 do local id=table.remove(draft.TransactionOrder,1) draft.Transactions[id]=nil end
 end
 local valid,err=pcall(D.Validate,draft)
 if not valid then s.Busy=false warn("Profile validation rejected transaction: "..tostring(err)) return false,"Invalid profile change rejected." end
 if not persist(s,draft,false) then s.Busy=false return false,s.Error end
 s.Data=draft s.Revision+=1 s.Busy=false return true,result,false
end
-- A timed-out write may already have committed. Reload authoritative data before another write.
function D.Resolve(s)
 if not s or not s.Uncertain or s.Closed then return not (s and s.Uncertain) end
 if s.Busy then return false end s.Busy=true
 local ok,result=retry(function()
  return store:UpdateAsync("p_"..s.Player.UserId,function(old)
   if not old or not old.Session or old.Session.Token~=token then return nil end
   return old,{s.Player.UserId}
  end)
 end)
 if ok and result and result.Session and result.Session.Token==token then
  local valid=pcall(D.Validate,result)
  if valid then s.Data=result s.Uncertain=false s.Error=nil s.Lease=result.Session.Expires s.Revision+=1 end
 end
 s.Busy=false return not s.Uncertain
end
function D.Save(s,release)
 if not s or s.Closed or s.Busy then return false end
 if s.Uncertain and not D.Resolve(s) then return false end
 s.Busy=true local ok=persist(s,s.Data,release)
 if ok and release then s.Closed=true sessions[s.Player]=nil end s.Busy=false return ok
end
function D.Close(s)
 if not s or s.Closed then return end
 local deadline=os.clock()+20 while s.Busy and os.clock()<deadline do task.wait(.1) end
 D.Save(s,true)
end
function D.Get(p) return sessions[p] end
function D.All() return sessions end
return D




