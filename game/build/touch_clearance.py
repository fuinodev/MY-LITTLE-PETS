from pathlib import Path
p=Path('game/HUD.luau'); s=p.read_text(encoding='utf-8-sig')
s=s.replace('local footer=68 local header=size+margin*2','''local touch=game:GetService("UserInputService").TouchEnabled
  local touchPortrait=touch and w<h
  local footer=touchPortrait and 180 or touch and 104 or 68
  local header=size+margin*2''')
s=s.replace('out.Help.Position=UDim2.new(1,-margin,1,-margin) out.Help.TextSize=w<400 and 13 or 16','''out.Help.Position=UDim2.new(1,-margin,1,-margin) out.Help.TextSize=w<400 and 13 or 16
  if touch then
   if touchPortrait or w<600 then
    top.Position=UDim2.new(0,margin,1,-116)
    out.Help.Position=UDim2.new(1,-margin,1,-116)
   else
    top.Position=UDim2.new(0,128,1,-margin)
    out.Help.Position=UDim2.new(1,-128,1,-margin)
    out.Help.Size=UDim2.fromOffset(math.min(170,w-444),64) out.Help.TextSize=13
   end
   out.Rate.Position=top.Position+UDim2.fromOffset(0,-55)
  end''')
p.write_text(s,encoding='utf-8')
p=Path('game/Client.luau'); s=p.read_text(encoding='utf-8-sig').replace('gui.ResetOnSpawn=false','gui.ScreenInsets=Enum.ScreenInsets.DeviceSafeInsets gui.ResetOnSpawn=false'); p.write_text(s,encoding='utf-8')
