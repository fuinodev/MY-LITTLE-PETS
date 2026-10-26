from pathlib import Path
p=Path('game/HUD.luau'); s=p.read_text(encoding='utf-8-sig')
s=s.replace('{"Pets","Shop","Index","Food","Bats","Guide"}','{"Pets","Shop","Index","Food","Bats","Guide","Settings"}')
a=s.index(' local side='); b=s.index(' local status=',a); s=s[:a]+s[b:]
s=s.replace('math.ceil(6/maxRows)','math.ceil(7/maxRows)').replace('math.ceil(6/cols)','math.ceil(7/cols)')
s=s.replace('  bar.Position=UDim2.new(1,-margin,1,-footer)','''  bar.AnchorPoint=Vector2.new(1,touch and .5 or 1)
  bar.Position=touch and UDim2.new(1,-margin,.5,0) or UDim2.new(1,-margin,1,-footer)''')
s=s.replace('  side.Size=UDim2.fromOffset(size,size) side.Position=UDim2.new(1,-margin,0,margin)\n  place(side,"Settings",UDim2.new())\n','')
p.write_text(s,encoding='utf-8')
