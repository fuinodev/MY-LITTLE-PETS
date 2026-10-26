from pathlib import Path
p=Path('game/HUD.luau'); s=p.read_text(encoding='utf-8-sig')
s=s.replace('  return value','  title.Visible=false\n  return value')
a=s.index(' local switch='); b=s.index(' out.Help=',a)
s=s[:a]+''' local badge=Instance.new("ImageLabel") badge.Name="ForestBadge" badge.Size=UDim2.fromOffset(58,58)
 badge.AnchorPoint=Vector2.new(.5,0) badge.Position=UDim2.new(.5,0,0,2) badge.BackgroundTransparency=1
 badge.Image="rbxassetid://134480627423865" badge.ScaleType=Enum.ScaleType.Fit badge.Active=false badge.Parent=gui
 local side=Instance.new("Frame") side.Name="UtilityButtons" side.Size=UDim2.fromOffset(52,52) side.AnchorPoint=Vector2.new(1,0) side.Position=UDim2.new(1,-8,0,8) side.BackgroundTransparency=1 side.Parent=gui
 tile(side,"Settings",UDim2.fromOffset(3,0),44,function(n) callbacks.Open(n) end)
 local status=text(gui,"",UDim2.new(.7,0,0,34),UDim2.new(.15,0,0,64),14) status.Visible=false status.TextWrapped=true out.Status=status
'''+s[b:]
s=s.replace('54,function() callbacks.Open("Shop") end,Color3.fromRGB(79,220,58)','54,function() callbacks.Open("Boosts") end,Color3.fromRGB(79,220,58)')
s=s.replace('out.Rate.Position=boost.Position+UDim2.fromOffset(0,-30)','out.Rate.Position=top.Position+UDim2.fromOffset(0,-55)')
s=s.replace('side.Position=UDim2.new(1,-8,.5,0)','side.Position=UDim2.new(1,-8,0,8)')
p.write_text(s,encoding='utf-8')
p=Path('game/Client.luau'); s=p.read_text(encoding='utf-8-sig')
s=s.replace('  small.Text=C.Sectors[data.CurrentSector].." • "..data.Weather.." • "..2^data.Tier.."× • "..data.Mode','  small.Visible=data.SaveError~=nil and data.SaveError~=false')
s=s.replace(' elseif view=="Shop" then',' elseif view=="Shop" or view=="Boosts" then')
s=s.replace('  for i,u in ipairs(C.Upgrades) do','  if view=="Shop" then\n  for i,u in ipairs(C.Upgrades) do')
s=s.replace('  for _,b in ipairs(C.Boosters) do','  end\n  if view=="Boosts" then\n  heading.Text="BOOSTS" subtitle.Text="Your weather mutation boosters"\n  for _,b in ipairs(C.Boosters) do')
s=s.replace('  for _,info in ipairs({"EXCLUSIVE PETS','  end\n  if view=="Shop" then\n  for _,info in ipairs({"EXCLUSIVE PETS')
s=s.replace('\n else\n  heading.Text="YOUR LITTLE ADVENTURE"','\n  end\n else\n  heading.Text="YOUR LITTLE ADVENTURE"')
p.write_text(s,encoding='utf-8')
