from pathlib import Path
p=Path('game/HUD.luau'); s=p.read_text(encoding='utf-8-sig')
s=s.replace('bar.AnchorPoint=Vector2.new(.5,1)','bar.AnchorPoint=Vector2.new(1,1)')
s=s.replace('barScale.Scale=math.min(1,(w-26)/426) topScale.Scale=1','barScale.Scale=1 topScale.Scale=1')
s=s.replace('out.Help.Position=UDim2.new(1,-12,1,w<900 and -90 or -8)','out.Help.Position=UDim2.new(1,-12,1,-8)')
s=s.replace('bar.Position=UDim2.new(.5,0,1,-7)','''local columns=gui.AbsoluteSize.Y<540 and 2 or 1
  local rows=math.ceil(6/columns)
  bar.Size=UDim2.fromOffset(columns*62,rows*64)
  bar.Position=UDim2.new(1,-8,1,-78)
  for i,name in ipairs({"Pets","Shop","Index","Food","Bats","Guide"}) do
   local position=UDim2.fromOffset(((i-1)%columns)*62+9,math.floor((i-1)/columns)*64)
   local button=bar[name.."Button"] button.Size=UDim2.fromOffset(44,44) button.Position=position
   local shadow=bar[name.."Shadow"] shadow.Size=button.Size shadow.Position=position+UDim2.fromOffset(0,4)
  end''')
p.write_text(s,encoding='utf-8')
