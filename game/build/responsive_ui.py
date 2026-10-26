from pathlib import Path
p=Path('game/HUD.luau'); s=p.read_text(encoding='utf-8-sig')
s=s.replace('function H.New(gui,callbacks)\n local out={}','''function H.New(screen,callbacks)
 local gui=Instance.new("Frame") gui.Name="GameHUD" gui.Size=UDim2.fromScale(1,1) gui.BackgroundTransparency=1 gui.Parent=screen
 local out={Root=gui}''')
a=s.index(' local function resize()'); b=s.index('\n gui:GetPropertyChangedSignal',a)
s=s[:a]+''' local function resize()
  local w,h=gui.AbsoluteSize.X,gui.AbsoluteSize.Y if w<1 or h<1 then return end
  local margin=12 local size=h<500 and 44 or 48 local gap=12 local caption=18
  local pitch=size+caption+gap
  local footer=76 local header=size+margin*2
  local maxRows=math.max(1,math.floor((h-header-footer)/pitch))
  local cols=math.clamp(math.ceil(6/maxRows),1,3) local rows=math.ceil(6/cols)
  barScale.Scale=1 topScale.Scale=1
  bar.Size=UDim2.fromOffset(cols*size+(cols-1)*gap,rows*pitch-gap)
  bar.Position=UDim2.new(1,-margin,1,-footer)
  local function place(parent,name,pos)
   local button=parent[name.."Button"] button.Size=UDim2.fromOffset(size,size) button.Position=pos
   local shadow=parent[name.."Shadow"] shadow.Size=button.Size shadow.Position=pos+UDim2.fromOffset(0,4)
  end
  for i,name in ipairs({"Pets","Shop","Index","Food","Bats","Guide"}) do
   place(bar,name,UDim2.fromOffset(((i-1)%cols)*(size+gap),math.floor((i-1)/cols)*pitch))
  end
  side.Size=UDim2.fromOffset(size,size) side.Position=UDim2.new(1,-margin,0,margin)
  place(side,"Settings",UDim2.new())
  place(gui,"Boosts",UDim2.new(0,margin,.5,-size/2))
  rush.Position=UDim2.new(0,margin,.5,size/2+caption+gap) rush.Size=UDim2.fromOffset(122,44)
  top.Position=UDim2.new(0,margin,1,-margin)
  out.Rate.Position=top.Position+UDim2.fromOffset(0,-55)
  out.Rate.Size=UDim2.fromOffset(math.min(170,w*.46),24) out.Rate.TextSize=w<400 and 13 or 15
  out.Help.Size=UDim2.fromOffset(math.min(210,w*.46),64)
  out.Help.Position=UDim2.new(1,-margin,1,-margin) out.Help.TextSize=w<400 and 13 or 16
  location.Position=UDim2.new(.5,0,0,margin) location.TextSize=18
 end'''+s[b:]
p.write_text(s,encoding='utf-8')
p=Path('game/Client.luau'); s=p.read_text(encoding='utf-8-sig')
s=s.replace('panel.AnchorPoint=Vector2.new(.5,0) panel.Position=UDim2.fromScale(.5,.16)','''panel.AnchorPoint=Vector2.new(.5,.5) panel.Position=UDim2.fromScale(.5,.5)
local function resizePanel()
 local size=gui.AbsoluteSize
 panel.Size=UDim2.fromOffset(math.min(1050,size.X-24),math.min(650,size.Y-24))
end
resizePanel() gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resizePanel) task.defer(resizePanel)
panel:GetPropertyChangedSignal("Visible"):Connect(function() hud.Root.Visible=not panel.Visible end)''')
s=s.replace('UDim2.fromOffset(36,32),UDim2.new(1,-44,0,7)','UDim2.fromOffset(44,44),UDim2.new(1,-46,0,1)')
s=s.replace('UDim2.fromOffset(105,29),UDim2.fromOffset((i-1)*112,0)','UDim2.new(1/3,-8,0,44),UDim2.new((i-1)/3,0,0,0)')
s=s.replace('UDim2.fromOffset(100,29),UDim2.fromOffset(224,0)','UDim2.new(1/3,-8,0,44),UDim2.new(2/3,0,0,0)')
s=s.replace('UDim2.fromOffset(96,29),UDim2.fromOffset(0,34)','UDim2.fromOffset(104,44),UDim2.fromOffset(0,52)').replace('UDim2.fromOffset(80,29),UDim2.fromOffset(104,34)','UDim2.fromOffset(104,44),UDim2.fromOffset(116,52)')
s=s.replace('list.Size=UDim2.new(0,gridWidth,1,-76) list.Position=UDim2.fromOffset(0,76)','list.Size=UDim2.new(0,gridWidth,1,-104) list.Position=UDim2.fromOffset(0,104)')
s=s.replace('configureGrid(gridWidth,114,164,5)','configureGrid(gridWidth,114,190,5)').replace('UDim2.new(1,-10,0,23),UDim2.fromOffset(5,137)','UDim2.new(1,-10,0,44),UDim2.fromOffset(5,137)')
p.write_text(s,encoding='utf-8')
