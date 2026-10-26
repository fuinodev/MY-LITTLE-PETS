-- Code-drawn icon HUD based on the user's colorful simulator toolbar reference.
local H={}
local Tween=game:GetService("TweenService")
local dark=Color3.fromRGB(35,36,67)
local colors={Pets=Color3.fromRGB(109,225,94),Index=Color3.fromRGB(79,207,255),Food=Color3.fromRGB(255,186,98),Shop=Color3.fromRGB(236,114,247),Inbox=Color3.fromRGB(255,207,65),Bats=Color3.fromRGB(164,129,250),Guide=Color3.fromRGB(107,168,249),Settings=Color3.fromRGB(173,191,199)}
local function radius(o,n) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,n) c.Parent=o end
local function outline(o,n,color) local s=Instance.new("UIStroke") s.Thickness=n or 2 s.Color=color or dark s.Transparency=0 s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.Parent=o end
local function shape(parent,x,y,w,h,c,round,rot)
 local f=Instance.new("Frame") f.Size=UDim2.fromScale(w,h) f.Position=UDim2.fromScale(x,y) f.BackgroundColor3=c f.BorderSizePixel=0 f.Rotation=rot or 0 f.Parent=parent if round then radius(f,round) end return f
end
local function text(parent,txt,size,pos,ts,color)
 local t=Instance.new("TextLabel") t.Size=size t.Position=pos t.BackgroundTransparency=1 t.Text=txt t.TextColor3=color or Color3.new(1,1,1) t.Font=Enum.Font.GothamBlack t.TextSize=ts or 15 t.TextStrokeColor3=dark t.TextStrokeTransparency=0 t.Parent=parent return t
end
local function gradient(o,col)
 local g=Instance.new("UIGradient") g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,col:Lerp(Color3.new(1,1,1),.42)),ColorSequenceKeypoint.new(.5,col),ColorSequenceKeypoint.new(1,col:Lerp(Color3.new(0,0,0),.2))}) g.Rotation=90 g.Parent=o
end
-- Set after uploading assets/menu-icons.png to the owning Roblox account.
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
local function tile(parent,name,pos,size,callback,color)
 local shadow=Instance.new("Frame") shadow.Name=name.."Shadow" shadow.Size=UDim2.fromOffset(size,size) shadow.Position=pos+UDim2.fromOffset(0,4) shadow.BackgroundColor3=dark shadow.BackgroundTransparency=.25 shadow.BorderSizePixel=0 shadow.Parent=parent radius(shadow,10)
 local b=Instance.new("ImageButton") b.Name=name.."Button" b.Image="" b.Size=UDim2.fromOffset(size,size) b.Position=pos b.BackgroundColor3=color or colors[name] or colors.Guide b.BorderSizePixel=0 b.Parent=parent b.AutoButtonColor=false radius(b,9) outline(b,2.5) gradient(b,b.BackgroundColor3)
 local inner=shape(b,.075,.075,.85,.85,Color3.new(1,1,1),6) inner.BackgroundTransparency=.8 outline(inner,1,Color3.fromRGB(255,255,255))
 H.Icon(b,name)
 local tooltip=text(b,name,UDim2.new(1.8,0,0,18),UDim2.new(-.4,0,0,-24),13) tooltip.Visible=false tooltip.ZIndex=6
 b.MouseEnter:Connect(function() tooltip.Visible=true Tween:Create(b,TweenInfo.new(.1),{Rotation=-4}):Play() end)
 b.MouseLeave:Connect(function() tooltip.Visible=false Tween:Create(b,TweenInfo.new(.1),{Rotation=0}):Play() end)
 b.Activated:Connect(function() callback(name) end) return b
end
function H.New(gui,callbacks)
 local out={}
 local bar=Instance.new("Frame") bar.Name="SimulatorToolbar" bar.Size=UDim2.fromOffset(426,73) bar.AnchorPoint=Vector2.new(.5,1) bar.Position=UDim2.new(.5,0,1,-7) bar.BackgroundTransparency=1 bar.Parent=gui
 local barScale=Instance.new("UIScale") barScale.Parent=bar
 for i,name in ipairs({"Pets","Shop","Index","Food","Bats","Guide"}) do local b=tile(bar,name,UDim2.fromOffset(12+(i-1)*69,5),54,function(n) callbacks.Open(n) end) text(b,name,UDim2.new(1.4,0,0,15),UDim2.new(-.2,0,1,5),10) end
 local top=Instance.new("Frame") top.Name="CurrencyPills" top.Size=UDim2.fromOffset(154,74) top.AnchorPoint=Vector2.new(.5,0) top.Position=UDim2.new(.5,0,0,5) top.BackgroundTransparency=1 top.Parent=gui
 local topScale=Instance.new("UIScale") topScale.Parent=top
 local function pill(name,index,color)
  local f=shape(top,0,0,1,1,color,11) f.Size=UDim2.fromOffset(154,31) f.Position=UDim2.fromOffset((index-1)*169,0) outline(f,2) gradient(f,color)
  local holder=shape(f,0,0,.23,1,color) holder.BackgroundTransparency=1 H.Icon(holder,name)
  local value=text(f,"0",UDim2.new(.7,0,1,0),UDim2.new(.27,0,0,0),18) value.TextXAlignment=Enum.TextXAlignment.Right
  local title=text(f,name=="Rate" and "Coins / sec" or name,UDim2.new(1,0,0,14),UDim2.new(0,0,1,1),10)
  return value
 end
 out.Coins=pill("Coins",1,Color3.fromRGB(255,199,45))
 out.Rate=text(gui,"0 Coins / sec",UDim2.fromOffset(170,24),UDim2.new(0,12,1,-115),15)
 out.Rate.Name="FarmingRate" out.Rate.TextXAlignment=Enum.TextXAlignment.Left
 local switch=Instance.new("TextButton") switch.Name="ForestSwitch" switch.Size=UDim2.fromOffset(100,23) switch.Position=UDim2.fromOffset(27,49) switch.Text="FOREST" switch.TextSize=12 switch.Font=Enum.Font.GothamBold switch.TextColor3=Color3.new(1,1,1) switch.BackgroundColor3=Color3.fromRGB(67,197,194) switch.Parent=top radius(switch,6) outline(switch,1.5) gradient(switch,switch.BackgroundColor3) switch.Activated:Connect(function() callbacks.Open("Index") end)
 local side=Instance.new("Frame") side.Name="UtilityButtons" side.Size=UDim2.fromOffset(52,236) side.AnchorPoint=Vector2.new(1,.5) side.Position=UDim2.new(1,-12,.5,0) side.BackgroundTransparency=1 side.Parent=gui
 for i,name in ipairs({"Shop","Pets","Index","Settings"}) do tile(side,name,UDim2.fromOffset(3,(i-1)*59),44,function(n) callbacks.Open(n) end,i==1 and Color3.fromRGB(255,109,122) or colors[name]) end
 local status=text(gui,"MY LITTLE PETS • FOREST",UDim2.new(.8,0,0,19),UDim2.new(.1,0,0,82),11) out.Status=status
 out.Help=text(gui,"Stand near treasure to farm",UDim2.new(.8,0,0,21),UDim2.new(.1,0,1,-105),12)
 local rush=Instance.new("TextButton") rush.Size=UDim2.fromOffset(122,31) rush.Position=UDim2.new(0,12,.5,-15) rush.Text="JOIN EGG RUSH" rush.TextColor3=Color3.new(1,1,1) rush.Font=Enum.Font.GothamBlack rush.TextSize=12 rush.BackgroundColor3=Color3.fromRGB(100,215,71) rush.Parent=gui radius(rush,8) outline(rush,2) gradient(rush,rush.BackgroundColor3) rush.Visible=false rush.Activated:Connect(callbacks.Rush) out.Rush=rush
 local boost=tile(gui,"Boosts",UDim2.new(0,12,1,-85),54,function() callbacks.Open("Shop") end,Color3.fromRGB(79,220,58))
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
 resize() if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) end return out
end
return H

