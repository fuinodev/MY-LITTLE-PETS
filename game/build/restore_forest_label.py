from pathlib import Path
p=Path('game/HUD.luau'); s=p.read_text(encoding='utf-8-sig')
a=s.index(' local badge='); b=s.index(' local side=',a)
s=s[:a]+''' -- Forest artwork is reserved for the completion reward, not the location HUD.
 local location=text(gui,"Forest",UDim2.fromOffset(140,24),UDim2.new(.5,0,0,2),18)
 location.Name="LocationLabel" location.AnchorPoint=Vector2.new(.5,0)
 location.TextStrokeTransparency=.4 location.Active=false
'''+s[b:]
p.write_text(s,encoding='utf-8')
