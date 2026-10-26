from pathlib import Path
p=Path('game/HUD.luau'); s=p.read_text(encoding='utf-8-sig'); a=s.index(' local bar=Instance.new'); b=s.index(' local barScale=',a)
s=s[:a]+''' local bar=Instance.new("Frame") bar.Name="SimulatorToolbar" bar.Size=UDim2.fromOffset(124,192) bar.AnchorPoint=Vector2.new(1,1) bar.Position=UDim2.new(1,-8,1,-78) bar.BackgroundTransparency=1 bar.Parent=gui
'''+s[b:]; p.write_text(s,encoding='utf-8')
