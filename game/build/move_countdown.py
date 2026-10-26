from pathlib import Path
p=Path('game/HUD.luau'); s=p.read_text(encoding='utf-8-sig').replace('Enum.Font.GothamBlack','Enum.Font.GothamBold')
s=s.replace('out.Help=text(gui,"Stand near treasure to farm",UDim2.new(.8,0,0,21),UDim2.new(.1,0,1,-105),12)','''out.Help=text(gui,"EGG RUSH\\n20:00",UDim2.fromOffset(210,64),UDim2.new(1,-12,1,-8),16)
 out.Help.Name="EggRushCountdown" out.Help.AnchorPoint=Vector2.new(1,1)
 out.Help.TextXAlignment=Enum.TextXAlignment.Right out.Help.TextYAlignment=Enum.TextYAlignment.Bottom
 out.Help.TextWrapped=true out.Help.TextStrokeTransparency=.35''')
s=s.replace('local small=w<650','local small=w<650\n  out.Help.Position=UDim2.new(1,-12,1,w<900 and -90 or -8)')
p.write_text(s,encoding='utf-8')
p=Path('game/Client.luau'); s=p.read_text(encoding='utf-8-sig'); a=s.index('  help.Text=data.InRush'); b=s.index('\n',a)
s=s[:a]+'''  local rushTime=string.format("%02d:%02d",math.floor(data.RushTime/60),data.RushTime%60)
  help.Text=data.InRush and ("EGG RUSH • "..data.Rush.."\\n"..rushTime.." • "..data.BoxesLeft.." boxes\\nHold "..math.floor(data.ClaimProgress*100).."%") or ((data.Rush=="Registration" and "EGG RUSH • JOIN NOW" or "NEXT EGG RUSH").."\\n"..rushTime)'''+s[b:]
p.write_text(s,encoding='utf-8')
