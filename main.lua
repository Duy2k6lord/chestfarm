local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

-------------------------------------------------
-- FLAGS
-------------------------------------------------
local autoFarm = true

-------------------------------------------------
-- GUI
-------------------------------------------------
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "ChestFarmGUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(240, 170)
frame.Position = UDim2.fromOffset(100, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Chest Farmer"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 14

local countLabel = Instance.new("TextLabel", frame)
countLabel.Size = UDim2.new(1, 0, 0, 25)
countLabel.Position = UDim2.fromOffset(0, 30)
countLabel.Text = "Chests: 0"
countLabel.TextColor3 = Color3.fromRGB(200,200,200)
countLabel.BackgroundTransparency = 1
countLabel.Font = Enum.Font.Gotham
countLabel.TextSize = 12

local farmBtn = Instance.new("TextButton", frame)
farmBtn.Size = UDim2.fromOffset(200, 35)
farmBtn.Position = UDim2.fromOffset(20, 60)
farmBtn.Text = "AUTO FARM: ON"
farmBtn.Font = Enum.Font.GothamBold
farmBtn.TextSize = 13
farmBtn.TextColor3 = Color3.new(1,1,1)
farmBtn.BackgroundColor3 = Color3.fromRGB(40,120,60)
Instance.new("UICorner", farmBtn)

local hopBtn = Instance.new("TextButton", frame)
hopBtn.Size = UDim2.fromOffset(200, 35)
hopBtn.Position = UDim2.fromOffset(20, 105)
hopBtn.Text = "SERVER HOP"
hopBtn.Font = Enum.Font.GothamBold
hopBtn.TextSize = 13
hopBtn.TextColor3 = Color3.new(1,1,1)
hopBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 120)
Instance.new("UICorner", hopBtn)

farmBtn.MouseButton1Click:Connect(function()
	autoFarm = not autoFarm
	farmBtn.Text = autoFarm and "AUTO FARM: ON" or "AUTO FARM: OFF"
	farmBtn.BackgroundColor3 = autoFarm and Color3.fromRGB(40,120,60) or Color3.fromRGB(80,80,80)
end)

-------------------------------------------------
-- SERVER HOP
-------------------------------------------------
local function serverHop()
	local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
	local data = HttpService:JSONDecode(game:HttpGet(url))
	if not data or not data.data then return end

	for _, server in ipairs(data.data) do
		if server.id ~= game.JobId and server.playing < server.maxPlayers then
			TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, player)
			break
		end
	end
end

hopBtn.MouseButton1Click:Connect(serverHop)

-------------------------------------------------
-- TÌM RƯƠNG
-------------------------------------------------
local function getChests()
	local list = {}
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and string.find(obj.Name, "Ö") then
			local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
			if prompt and prompt.Enabled then
				table.insert(list, { model = obj, prompt = prompt })
			end
		end
	end
	return list
end

-------------------------------------------------
-- TELEPORT
-------------------------------------------------
local function teleportTo(model)
	if model.PrimaryPart then
		root.CFrame = model.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
	else
		local part = model:FindFirstChildWhichIsA("BasePart")
		if part then
			root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
		end
	end
end

-------------------------------------------------
-- FARM LOOP
-------------------------------------------------
task.spawn(function()
	while true do
		local chests = getChests()
		countLabel.Text = "Chests: " .. tostring(#chests)

		if autoFarm then
			for _, chest in ipairs(chests) do
				if not autoFarm then break end

				teleportTo(chest.model)
				task.wait(0.2)

				fireproximityprompt(chest.prompt)
				task.wait(0.05)

				chest.prompt.Enabled = false
				task.wait(0.1)
			end
		end

		task.wait(0.4)
	end
end)
