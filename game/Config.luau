local C={Version=2,MaxPets=200,EquipSlots=3,StudioUseDataStore=false,DataStoreName="MyLittlePets_Profile_v2",InventoryRevision=2}
C.Rarities={"Common","Uncommon","Rare","Epic","Legendary","Mythic","Eternal","Heroic","Divine","EXCLUSIVE"}
C.Colors={Color3.fromRGB(188,207,220),Color3.fromRGB(73,207,111),Color3.fromRGB(48,164,249),Color3.fromRGB(165,79,239),Color3.fromRGB(255,169,44),Color3.fromRGB(238,63,75),Color3.fromRGB(101,44,210),Color3.fromRGB(250,232,192),Color3.fromRGB(255,211,39),Color3.fromRGB(90,240,211)}
C.Rates={"10000","50000","250000","1000000","5000000","25000000","125000000","600000000","1700000000","20000000000"}
C.Weights={45,30,15,7,2,.8,.15,.05,0,0}
C.Sectors={"Forest Entrance","Green Clearing","Deep Woods","Ancient Grove","Forest Gateway"}
C.Gates={"0","2000000","20000000","200000000","2000000000"}
C.EggCost="250000"
C.Biomes={"Forest","River","Desert","Ice","Volcanic"}
C.Origin={Forest=1,River=2,Desert=4,Ice=8,Volcanic=16}
C.Variants={Normal=1,Silver=3,Gold=7,Diamond=15,Rainbow=30}
C.Foods={{Id="Apple",Name="Apple",Cost="100000",XP=100},{Id="Fish",Name="Fish",Cost="500000",XP=500},{Id="GoldenFruit",Name="Golden Fruit",Cost="2500000",XP=2500},{Id="MysticTreat",Name="Mystic Treat",Cost="10000000",XP=10000}}
C.Weather={{Name="Rainy",Mutation="Soaked",Factor=1.5,Weight=40,Color=Color3.fromRGB(86,176,238)},{Name="Snowstorm",Mutation="Frozen",Factor=2.5,Weight=25,Color=Color3.fromRGB(190,237,255)},{Name="Thunderstorm",Mutation="Thunderstruck",Factor=4,Weight=18,Color=Color3.fromRGB(174,102,255)},{Name="Rage",Mutation="Enraged",Factor=7,Weight=10,Color=Color3.fromRGB(255,95,46)},{Name="Meteor Shower",Mutation="Celestial",Factor=12,Weight=5,Color=Color3.fromRGB(107,148,240)},{Name="Aurora",Mutation="Astral",Factor=25,Weight=2,Color=Color3.fromRGB(110,249,207)}}
C.Boosters={{Id="Basic",Name="Basic Lucky",Bonus=.05,ProductId=0},{Id="Super",Name="Super Lucky",Bonus=.15,ProductId=0},{Id="Ultra",Name="Ultra Lucky",Bonus=.25,ProductId=0}}
C.Targets={{Name="Small Coin Pile",Work="100000",Respawn=3,Count=6},{Name="Large Coin Pile",Work="500000",Respawn=5,Count=11},{Name="Giant Coin Hoard",Work="2000000",Respawn=8,Count=18},{Name="Wooden Chest",Work="10000000",Respawn=12,Count=0}}
C.Upgrades={} for i,price in ipairs({2,5,9,15,25,39,59,89,129,179,249,349}) do C.Upgrades[i]={Tier=i,Multiplier=2^i,TargetPrice=price,PassId=0} end
C.FutureCaps={Forest=4096,River=16384,Desert=65536,Ice=262144,Volcanic=1048576}
-- Product decisions without approved values stay disabled. Never invent checkout IDs or paid prices.
C.Divine={Enabled=false,DailyLimit=0}
C.Weekly={Enabled=false,Weekday=1,HourUTC=0,Chance=0}
C.PremiumProducts={}
C.Rush={Interval=1200,Registration=30,Countdown=5,Duration=60,Results=5,Speed=16,Range=6,Cooldown=.8,Grace=.5,Hold=.75}
C.Species={}
local groups={{"Forest Fox","Meadow Bunny","Acorn Mouse","Moss Chick","Twig Pup"},{"Leaf Cat","Clover Deer","Fern Frog","Sprout Owl","Hedgehog Scout"},{"Azure Jay","Crystal Badger","Riverbank Otter","Sapphire Squirrel"},{"Mystic Owl","Mooncap Cat","Orchid Moth","Rune Wolf"},{"Amber Griffin","Suncrest Lion","Ancient Stag"},{"Ember Imp","Crimson Drake","Thorn Phoenix"},{"Twilight Lynx","Void Raven"},{"Halo Hound","Pearl Pegasus"},{"Golden Dragon","Crowned Seraph"}}
for r,names in ipairs(groups) do for _,name in ipairs(names) do
 local i=#C.Species+1 local base=C.Colors[r]
 if r==1 then base=({Color3.fromRGB(224,126,63),Color3.fromRGB(233,223,216),Color3.fromRGB(173,142,116),Color3.fromRGB(235,207,92),Color3.fromRGB(162,114,77)})[i] end
 table.insert(C.Species,{Id=string.format("forest_%02d",i),Name=name,Rarity=r,Color=base,Rate=C.Rates[r],Biome="Forest"})
end end
function C.MutationFactor(pet)
 local factor=1 for _,id in ipairs(pet.Mutations or {}) do for _,w in ipairs(C.Weather) do if w.Mutation==id then factor+=w.Factor-1 end end end return factor
end
function C.Power(pet,tier,B)
 local s=C.Species[pet.Species] local n=s.Rate
 n=B.MulSmall(n,C.Origin[pet.Origin or s.Biome] or 1) n=B.MulSmall(n,C.Variants[pet.Variant or "Normal"] or 1)
 n=B.Div(B.MulSmall(n,math.floor(C.MutationFactor(pet)*100)),"100")
 n=B.Div(B.MulSmall(n,99+pet.Level),"100")
 for _=1,tier or 0 do n=B.MulSmall(n,2) end return n
end
function C.Validate()
 assert(#C.Species==30,"Forest roster") local counts={} local sum=0 local prices=0 local ids={}
 for _,s in ipairs(C.Species) do counts[s.Rarity]=(counts[s.Rarity] or 0)+1 assert(not ids[s.Id],"Species IDs") ids[s.Id]=true end
 for i,n in ipairs({5,5,4,4,3,3,2,2,2}) do assert(counts[i]==n,"Rarity distribution") end
 for _,v in ipairs(C.Weights) do assert(v>=0) sum+=v end assert(math.abs(sum-100)<.000001 and C.Weights[9]==0 and C.Weights[10]==0)
 for i,u in ipairs(C.Upgrades) do assert(u.Multiplier==2^i) prices+=u.TargetPrice end assert(prices==1149)
end
C.Validate()
return C
