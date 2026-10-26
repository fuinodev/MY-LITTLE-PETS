from pathlib import Path
p=Path('game/HUD.luau'); s=p.read_text(encoding='utf-8-sig')
s=s.replace('top.AnchorPoint=Vector2.new(.5,0) top.Position=UDim2.new(.5,0,0,5)','top.AnchorPoint=Vector2.new(0,1) top.Position=UDim2.new(0,12,1,-16)')
s=s.replace('switch.Position=UDim2.fromOffset(27,49)','switch.AnchorPoint=Vector2.new(.5,0) switch.Position=UDim2.new(.5,0,0,54)').replace('switch.Parent=top','switch.Parent=gui')
s=s.replace('rush.Position=UDim2.new(0,12,.5,-15)','rush.Position=UDim2.new(0,12,.5,55)')
s=s.replace('tile(gui,"Boosts",UDim2.new(0,12,1,-85)','tile(gui,"Boosts",UDim2.new(0,12,.5,-27)')
s=s.replace('boost.Position=UDim2.new(0,12,1,small and -170 or -85)','boost.Position=UDim2.new(0,12,.5,-27)\n  gui.BoostsShadow.Position=boost.Position+UDim2.fromOffset(0,4)\n  top.Position=UDim2.new(0,12,1,small and -90 or -16)')
p.write_text(s,encoding='utf-8')
