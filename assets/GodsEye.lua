-- // God's Eye v13.8 — EclipseOps Edition 🌒👁️

if getgenv().GodEye_Loaded then
	return EO.Notify("EclipseOps", "👁️ God's Eye ทำงานอยู่แล้ว!", 3)
end
getgenv().GodEye_Loaded = true
getgenv().GodEye_Active = false

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ui = nil
local screen = nil
local connections = {}
local glowTween = nil

--// [DESTROY ALL]
local function destroyEverything()
	getgenv().GodEye_Active = false
	getgenv().GodEye_Loaded = false

	if screen and screen.Parent then screen:Destroy() end
	if ui and ui.Parent then ui:Destroy() end

	for i = #connections, 1, -1 do
		local conn = connections[i]
		if conn and typeof(conn) == "RBXScriptConnection" then
			if conn.Connected then conn:Disconnect() end
		end
		connections[i] = nil
	end
	connections = {}

	if glowTween and glowTween.Play then
		glowTween:Cancel()
		glowTween = nil
	end

	screen = nil
	ui = nil
	EO.Notify("EclipseOps", "🌒 God's Eye ปิดแล้ว!", 3)
end

--// [MAIN UI]
ui = Instance.new("ScreenGui")
ui.Name = "GodEye_Controller"
ui.ResetOnSpawn = false
ui.DisplayOrder = 999999
ui.Parent = CoreGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 230, 0, 125)
main.Position = UDim2.new(0.02, 0, 0.65, 0)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = ui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(80, 0, 180)
stroke.Thickness = 2
stroke.Transparency = 0.2

--// [TITLE BAR]
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 15, 35)
titleBar.BorderSizePixel = 0
titleBar.Parent = main
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1, -45, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🌒 GOD'S EYE"
title.TextColor3 = Color3.fromRGB(120, 0, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left

--// [CLOSE BUTTON]
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -36, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 15
closeBtn.AutoButtonColor = false
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

--// [STATUS]
local status = Instance.new("TextLabel", main)
status.Size = UDim2.new(1, -24, 0, 22)
status.Position = UDim2.new(0, 12, 0, 42)
status.BackgroundTransparency = 1
status.Text = "⚫ ปิดอยู่"
status.TextColor3 = Color3.fromRGB(100, 100, 100)
status.Font = Enum.Font.GothamBold
status.TextSize = 14
status.TextXAlignment = Enum.TextXAlignment.Left

--// [TOGGLE BUTTON]
local toggleBtn = Instance.new("TextButton", main)
toggleBtn.Size = UDim2.new(0.88, 0, 0, 32)
toggleBtn.Position = UDim2.new(0.06, 0, 0, 82)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 130)
toggleBtn.Text = "👁️ เปิดดวงตา"
toggleBtn.TextColor3 = Color3.fromRGB(200, 150, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 15
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = main
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 10)
local toggleStroke = Instance.new("UIStroke", toggleBtn)
toggleStroke.Color = Color3.fromRGB(80, 0, 180)
toggleStroke.Thickness = 1

--// [GLOW]
local function startGlow()
	if glowTween then glowTween:Cancel() end
	glowTween = TweenService:Create(stroke, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.85})
	glowTween:Play()
end

local function stopGlow()
	if glowTween then
		glowTween:Cancel()
		glowTween = nil
	end
	stroke.Transparency = 0.2
end

--// [GOD'S EYE CORE]
local function startGodEye()
	if screen then return end
	screen = Instance.new("ScreenGui")
	screen.Name = "GodsEye_ActiveScreen"
	screen.ResetOnSpawn = false
	screen.Parent = CoreGui

	local function age(d)
		local y = math.floor(d/365)
		local m = math.floor((d%365)/30)
		return y.."ปี "..m.."เดือน"
	end

	local function createESP(plr)
		if plr == LocalPlayer or not getgenv().GodEye_Active then return end
		if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return end

		local root = plr.Character.HumanoidRootPart
		local hum = plr.Character:FindFirstChildOfClass("Humanoid")
		if not hum then return end

		local bill = Instance.new("BillboardGui", screen)
		bill.Name = "GE_"..plr.Name
		bill.Adornee = root
		bill.Size = UDim2.new(0, 270, 0, 230)
		bill.StudsOffset = Vector3.new(5, 2.4, 0)
		bill.AlwaysOnTop = true
		bill.LightInfluence = 0

		local camConn
		camConn = RunService.Heartbeat:Connect(function()
			if not bill.Parent or not getgenv().GodEye_Active or not camConn then
				if camConn and camConn.Connected then camConn:Disconnect() end
				return
			end
			local cam = workspace.CurrentCamera
			local dir = (cam.CFrame.Position - root.Position).unit
			bill.StudsOffset = Vector3.new(5, 2.4, 0) + dir * 0.8
		end)
		table.insert(connections, camConn)

		local frame = Instance.new("Frame", bill)
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.BackgroundTransparency = 0.2
		frame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

		local glow = Instance.new("UIStroke", frame)
		glow.Color = Color3.fromRGB(80, 0, 180)
		glow.Thickness = 2
		glow.Transparency = 0.15

		task.spawn(function()
			while getgenv().GodEye_Active and bill and bill.Parent do
				local t = TweenService:Create(glow, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.9})
				t:Play()
				task.wait(1.2)
			end
		end)

		local ava = Instance.new("ImageLabel", frame)
		ava.Size = UDim2.new(0, 66, 0, 66)
		ava.Position = UDim2.new(0, 12, 0, 12)
		ava.BackgroundTransparency = 1
		ava.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
		Instance.new("UICorner", ava).CornerRadius = UDim.new(1, 0)
		local avaStroke = Instance.new("UIStroke", ava)
		avaStroke.Color = Color3.fromRGB(120, 0, 255)
		avaStroke.Thickness = 2

		local label = Instance.new("TextLabel", frame)
		label.Size = UDim2.new(1, -94, 1, -16)
		label.Position = UDim2.new(0, 88, 0, 8)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.fromRGB(200, 150, 255)
		label.Font = Enum.Font.GothamBold
		label.TextSize = 12
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Top
		label.RichText = true

		local data = {m="N/A", h="N/A", t="N/A", d="N/A", hp=0, max=100}

		local function updateText()
			local hpText = data.hp > 0 and data.hp.."/"..data.max.." ❤️" or "ตายแล้ว ☠️"
			label.Text = string.format(
				'<font color="#CC66FF"><b>%s</b></font>\n'..
				'<font color="#0099FF">@%s</font>\n'..
				'<font color="#9966CC">ID:</font> %d\n'..
				'<font color="#7744AA">อายุ:</font> %s\n'..
				'<font color="#FFD700">เงิน:</font> %s 💰\n'..
				'<font color="#FF6633">หิว:</font> %s%% 🍔\n'..
				'<font color="#3399FF">กระหาย:</font> %s%% 💧\n'..
				'<font color="#00CC66">อุปกรณ์:</font> %s 📱\n'..
				'<font color="#FF3366">เลือด:</font> %s',
				plr.DisplayName, plr.Name, plr.UserId, age(plr.AccountAge),
				data.m, data.h, data.t, data.d or "???", hpText
			)
		end

		task.spawn(function()
			pcall(function()
				local ls = plr:WaitForChild("leaderstats", 6)
				if ls then
					local money = ls:FindFirstChild("Baht") or ls:FindFirstChild("Money") or ls:FindFirstChild("Cash")
					if money then
						data.m = money.Value
						local c = money:GetPropertyChangedSignal("Value"):Connect(function() data.m = money.Value updateText() end)
						table.insert(connections, c)
					end
				end
			end)

			pcall(function()
				local hun = plr:FindFirstChild("Hungry") or plr:FindFirstChild("Hunger")
				if hun then
					data.h = hun.Value
					local c = hun:GetPropertyChangedSignal("Value"):Connect(function() data.h = hun.Value updateText() end)
					table.insert(connections, c)
				end
				local thi = plr:FindFirstChild("Thirsty") or plr:FindFirstChild("Thirst")
				if thi then
					data.t = thi.Value
					local c = thi:GetPropertyChangedSignal("Value"):Connect(function() data.t = thi.Value updateText() end)
					table.insert(connections, c)
				end
			end)

			pcall(function()
				local dev = plr:FindFirstChild("ServerDevice")
				if dev then
					data.d = dev.Value
					local c = dev:GetPropertyChangedSignal("Value"):Connect(function() data.d = dev.Value updateText() end)
					table.insert(connections, c)
				end
			end)

			data.hp = math.floor(hum.Health)
			data.max = math.floor(hum.MaxHealth)
			local c1 = hum.HealthChanged:Connect(function(v) data.hp = math.floor(v) updateText() end)
			local c2 = hum.Died:Connect(function() data.hp = 0 updateText() end)
			local c3 = hum:GetPropertyChangedSignal("MaxHealth"):Connect(function() data.max = math.floor(hum.MaxHealth) updateText() end)
			table.insert(connections, c1)
			table.insert(connections, c2)
			table.insert(connections, c3)

			updateText()
		end)
	end

	for _, p in Players:GetPlayers() do
		if p ~= LocalPlayer then task.spawn(createESP, p) end
	end

	local playerAddedConn = Players.PlayerAdded:Connect(function(p)
		p.CharacterAdded:Connect(function()
			task.wait(2)
			if getgenv().GodEye_Active then createESP(p) end
		end)
	end)
	table.insert(connections, playerAddedConn)
end

--// [TOGGLE EVENT]
toggleBtn.Activated:Connect(function()
	getgenv().GodEye_Active = not getgenv().GodEye_Active
	if getgenv().GodEye_Active then
		status.Text = "🟣 เปิดแล้ว"
		status.TextColor3 = Color3.fromRGB(120, 0, 255)
		toggleBtn.Text = "🌒 ปิดดวงตา"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 80)
		toggleBtn.TextColor3 = Color3.fromRGB(150, 100, 200)
		startGlow()
		startGodEye()
	else
		status.Text = "⚫ ปิดอยู่"
		status.TextColor3 = Color3.fromRGB(100, 100, 100)
		toggleBtn.Text = "👁️ เปิดดวงตา"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 130)
		toggleBtn.TextColor3 = Color3.fromRGB(200, 150, 255)
		stopGlow()
		if screen then screen:Destroy() screen = nil end
	end
end)

--// [CLOSE EVENT]
closeBtn.Activated:Connect(destroyEverything)

EO.Notify("EclipseOps", "🌒 God's Eye โหลดสำเร็จ!", 3)
