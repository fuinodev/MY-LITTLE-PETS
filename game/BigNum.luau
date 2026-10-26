-- Non-negative arbitrary precision integer arithmetic; wallet and rate wire format is decimal text.
local B={}
function B.N(v)
 local s=type(v)=="number" and string.format("%.0f",v) or tostring(v)
 assert(s:match("^%d+$") and #s<=400,"Invalid unsigned decimal")
 return s:gsub("^0+","")=="" and "0" or (s:gsub("^0+",""))
end
function B.Cmp(a,b) a=B.N(a) b=B.N(b) if #a~=#b then return #a>#b and 1 or -1 end if a==b then return 0 end return a>b and 1 or -1 end
function B.Add(a,b)
 a=B.N(a) b=B.N(b) local out={} local carry=0 local i=#a local j=#b
 while i>0 or j>0 or carry>0 do local n=(i>0 and tonumber(a:sub(i,i)) or 0)+(j>0 and tonumber(b:sub(j,j)) or 0)+carry table.insert(out,1,tostring(n%10)) carry=math.floor(n/10) i-=1 j-=1 end
 return table.concat(out)
end
function B.Sub(a,b)
 a=B.N(a) b=B.N(b) assert(B.Cmp(a,b)>=0,"Negative balance") local out={} local borrow=0 local j=#b
 for i=#a,1,-1 do local n=tonumber(a:sub(i,i))-(j>0 and tonumber(b:sub(j,j)) or 0)-borrow borrow=0 if n<0 then n+=10 borrow=1 end table.insert(out,1,tostring(n)) j-=1 end return B.N(table.concat(out))
end
function B.MulSmall(a,n)
 assert(n>=0 and n%1==0 and n<=1e9) a=B.N(a) if n==0 then return "0" end local carry=0 local out={}
 for i=#a,1,-1 do local v=tonumber(a:sub(i,i))*n+carry table.insert(out,1,tostring(v%10)) carry=math.floor(v/10) end
 while carry>0 do table.insert(out,1,tostring(carry%10)) carry=math.floor(carry/10) end return B.N(table.concat(out))
end
function B.Mul(a,b)
 a=B.N(a) b=B.N(b) local result="0"
 for i=1,#b do result=B.Add(result.."0",B.MulSmall(a,tonumber(b:sub(i,i)))) end return B.N(result)
end
function B.Div(a,b)
 a=B.N(a) b=B.N(b) assert(b~="0","Division by zero") local rem="0" local out={}
 for i=1,#a do
  rem=B.N(rem..a:sub(i,i)) local lo,hi=0,9
  while lo<hi do local mid=math.ceil((lo+hi)/2) if B.Cmp(B.MulSmall(b,mid),rem)<=0 then lo=mid else hi=mid-1 end end
  table.insert(out,tostring(lo)) rem=B.Sub(rem,B.MulSmall(b,lo))
 end return B.N(table.concat(out)),rem
end
function B.Min(a,b) return B.Cmp(a,b)<=0 and a or b end
function B.Format(n)
 n=B.N(n) local suffix={"","K","M","B","T","Qa","Qi","Sx","Sp","Oc","No","Dc"} local tier=math.floor((#n-1)/3)
 if tier==0 then return n end if tier>=#suffix then return n:sub(1,1).."."..n:sub(2,3).."e"..(#n-1) end
 local len=#n-tier*3 local decimal=n:sub(len+1,len+1) return n:sub(1,len)..(decimal~="0" and "."..decimal or "")..suffix[tier+1]
end
function B.Score(n) n=B.N(n) if n=="0" then return 0 end return #n*1000000+math.floor(tonumber(n:sub(1,6)..string.rep("0",math.max(0,6-#n)))) end
return B
