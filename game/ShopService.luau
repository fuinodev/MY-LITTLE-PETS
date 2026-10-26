local S={Metadata={},Pending={}}
local M=game:GetService("MarketplaceService") local Players=game:GetService("Players") local Run=game:GetService("RunService")
local C=require(game.ReplicatedStorage.MyLittlePets.Config) local D=require(script.Parent.Profiles)
function S.Init(G)
 S.G=G
 for i,u in ipairs(C.Upgrades) do
  S.Metadata[i]={Tier=i,Multiplier=u.Multiplier,TargetPrice=u.TargetPrice,Available=false,Reason="Product not configured"}
  if u.PassId>0 then task.spawn(function()
   local ok,info=pcall(function() return M:GetProductInfoAsync(u.PassId,Enum.InfoType.GamePass) end)
   if ok and info and info.IsForSale and type(info.PriceInRobux)=="number" then S.Metadata[i]={Tier=i,Multiplier=u.Multiplier,TargetPrice=u.TargetPrice,Price=info.PriceInRobux,Available=not Run:IsStudio(),PassId=u.PassId,Reason=Run:IsStudio() and "Live purchases are disabled in Studio" or nil} end
  end) end
 end
 M.PromptGamePassPurchaseFinished:Connect(function(p,_,purchased)
  S.Pending[p]=nil G.Remote:FireClient(p,"PurchaseClosed",purchased)
  if purchased then task.spawn(function() S.Reconcile(p) end) end
 end)
 M.ProcessReceipt=function(receipt)
  local p=Players:GetPlayerByUserId(receipt.PlayerId) local session=p and D.Get(p)
  if not session or session.Mode~="Cloud saved" then return Enum.ProductPurchaseDecision.NotProcessedYet end
  local product
  for _,b in ipairs(C.Boosters) do if b.ProductId>0 and b.ProductId==receipt.ProductId then product={Kind="Booster",Id=b.Id} end end
  for _,v in ipairs(C.PremiumProducts) do if v.ProductId==receipt.ProductId and v.Enabled then product=v end end
  if not product then return Enum.ProductPurchaseDecision.NotProcessedYet end
  local key="receipt:"..receipt.PurchaseId
  local pet=product.Kind=="Pet" and C.Species[product.Species] and G.NewPet(product.Species) or nil
  local ok=D.Commit(session,function(d)
   if d.Receipts[key] then return true,true end
   if product.Kind=="Booster" then d.Boosters[product.Id]=(d.Boosters[product.Id] or 0)+1
   elseif pet then d.Inbox[key]={Pet=pet,At=os.time(),Source="Premium purchase"}
   else return false,"Product grant unavailable." end
   d.Receipts[key]=true return true,true
  end)
  return ok and Enum.ProductPurchaseDecision.PurchaseGranted or Enum.ProductPurchaseDecision.NotProcessedYet
 end
end
function S.Reconcile(p)
 local s=D.Get(p) if not D.Active(s) or s.Mode~="Cloud saved" then return end local highest=s.Data.Tier
 for i,u in ipairs(C.Upgrades) do if u.PassId>0 then local ok,owns=pcall(function() return M:UserOwnsGamePassAsync(p.UserId,u.PassId) end) if ok and owns then highest=math.max(highest,i) end end end
 if highest>s.Data.Tier then
  for _=1,3 do
   local ok=D.Commit(s,function(d) d.Tier=math.max(d.Tier,highest) return true,true end)
   if ok then S.G.Tell(p,"Permanent farming multiplier verified: "..2^highest.."×") return end task.wait(2)
  end
 end
end
function S.Purchase(p,tier)
 local s=D.Get(p) local meta=S.Metadata[tier]
 if not D.Active(s) or s.Mode~="Cloud saved" then return false,"Purchases require a live server with a saved profile." end
 if not meta or not meta.Available then return false,"This product is not configured for sale yet." end
 if tier~=s.Data.Tier+1 then return false,"Only the next permanent tier can be purchased." end
 if S.Pending[p] and os.clock()-S.Pending[p]<90 then return false,"A purchase is already pending." end
 S.Pending[p]=os.clock() local ok=pcall(function() M:PromptGamePassPurchase(p,meta.PassId) end)
 if not ok then S.Pending[p]=nil return false,"Roblox checkout is unavailable. Please retry later." end return true,"Purchase pending in Roblox checkout."
end
return S
