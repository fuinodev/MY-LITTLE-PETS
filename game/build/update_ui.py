from pathlib import Path
p=Path('game/HUD.luau'); s=p.read_text(encoding='utf-8-sig')
start=s.index('function H.Icon('); end=s.index('local function tile',start)
s=s[:start]+'''-- Set after uploading assets/menu-icons.png to the owning Roblox account.
H.Atlas = ""
local cells={Pets=0,Shop=1,Index=2,Food=3,Bats=4,Guide=5,Settings=6,Boosts=7,Coins=8}
function H.Icon(parent,name)
 local icon=Instance.new("ImageLabel") icon.Name=name.."Image" icon.BackgroundTransparency=1
 icon.Size=UDim2.fromScale(.92,.92) icon.Position=UDim2.fromScale(.04,.04)
 icon.Image=H.Atlas icon.ScaleType=Enum.ScaleType.Fit
 local cell=cells[name] or 5 local step=1280/3
 icon.ImageRectOffset=Vector2.new(math.floor(cell%3*step),math.floor(math.floor(cell/3)*step))
 icon.ImageRectSize=Vector2.new(math.floor(step),math.floor(step)) icon.Parent=parent
 return icon
end
'''+s[end:]
s=s.replace('Instance.new("TextButton") b.Name=name.."Button" b.Text=""','Instance.new("ImageButton") b.Name=name.."Button" b.Image=""')
s=s.replace('510,73','426,73').replace('{"Pets","Shop","Index","Food","Bats","Inbox","Guide"}','{"Pets","Shop","Index","Food","Bats","Guide"}').replace('(i-1)*71','(i-1)*69')
s=s.replace('500,74','154,74')
s=s.replace('out.Coins=pill("Coins",1,Color3.fromRGB(255,199,45)) out.Rate=pill("Rate",2,Color3.fromRGB(93,220,255)) out.Pets=pill("Pets",3,Color3.fromRGB(234,115,255))','''out.Coins=pill("Coins",1,Color3.fromRGB(255,199,45))
 out.Rate=text(gui,"0 Coins / sec",UDim2.fromOffset(170,24),UDim2.new(0,12,1,-115),15)
 out.Rate.Name="FarmingRate" out.Rate.TextXAlignment=Enum.TextXAlignment.Left''')
s=s.replace('UDim2.fromOffset(200,49)','UDim2.fromOffset(27,49)')
a=s.index(' local boost='); b=s.index(' resize()',a)
s=s[:a]+''' local boost=tile(gui,"Boosts",UDim2.new(0,12,1,-85),54,function() callbacks.Open("Shop") end,Color3.fromRGB(79,220,58))
 text(boost,"Boosts",UDim2.new(1.5,0,0,17),UDim2.new(-.25,0,1,3),11)
 local function resize()
  local cam=workspace.CurrentCamera if not cam then return end local w=cam.ViewportSize.X
  barScale.Scale=math.min(1,(w-26)/426) topScale.Scale=1
  local small=w<650
  bar.Position=UDim2.new(.5,0,1,-7)
  boost.Position=UDim2.new(0,12,1,small and -170 or -85)
  out.Rate.Position=boost.Position+UDim2.fromOffset(0,-30)
  side.Position=UDim2.new(1,-8,.5,0)
 end
'''+s[b:]
p.write_text(s,encoding='utf-8')
p=Path('game/Client.luau'); s=p.read_text(encoding='utf-8-sig')
s=s.replace('local lastRevision=-1','local petTab="Equipped" local lastRevision=-1')
s=s.replace('rate.Text=B.Format(data.Rate) hud.Pets.Text=tostring(#data.Pets)','rate.Text=B.Format(data.Rate).." Coins / sec"')
s=s.replace('view=name page=1','view=name=="Inbox" and "Pets" or name if name=="Inbox" then petTab="All pets" end page=1')
s=s.replace('  heading.Text="MY PETS', '  local shown={} for _,pet in ipairs(data.Pets) do if petTab=="All pets" or pet.Equipped then table.insert(shown,pet) end end\n  heading.Text="MY PETS')
s=s.replace('math.ceil(#data.Pets/24)', 'math.ceil(#shown/24)')
s=s.replace('extras.Visible=true button(extras,"Equip best",UDim2.fromOffset(110,29),UDim2.fromOffset(0,0)', '''extras.Visible=true
  for i,tab in ipairs({"Equipped","All pets"}) do button(extras,tab,UDim2.fromOffset(105,29),UDim2.fromOffset((i-1)*112,0),function() petTab=tab page=1 detailOpen=false render() end,petTab==tab and palette.Green or palette.Navy) end
  button(extras,"Equip best",UDim2.fromOffset(100,29),UDim2.fromOffset(224,0)''')
s=s.replace('UDim2.fromOffset(118,0)','UDim2.fromOffset(0,34)').replace('UDim2.fromOffset(222,0)','UDim2.fromOffset(104,34)')
s=s.replace('list.Size=UDim2.new(0,gridWidth,1,-40) list.Position=UDim2.fromOffset(0,40)','list.Size=UDim2.new(0,gridWidth,1,-76) list.Position=UDim2.fromOffset(0,76)')
s=s.replace('math.min(page*24,#data.Pets) do local pet=data.Pets[i]','math.min(page*24,#shown) do local pet=shown[i]')
a=s.index(' elseif view=="Inbox" then'); b=s.index(' elseif view=="Egg" then',a)
s=s[:a]+s[b:]
needle=' elseif view=="Index" then'
s=s.replace(needle,'''  if petTab=="All pets" and page==1 then
   for key,reward in pairs(data.Inbox or {}) do
    local rewardKey=key local f=card(Color3.fromRGB(255,228,154))
    label(f,"Egg Rush reward",UDim2.new(1,-12,0,80),UDim2.fromOffset(6,10),15)
    button(f,"Open egg",UDim2.new(1,-12,0,32),UDim2.fromOffset(6,110),function() send("Reward",{Key=rewardKey}) end,palette.Green)
   end
  end
'''+needle,1)
s=s.replace(' or view=="Inbox"','')
p.write_text(s,encoding='utf-8')
