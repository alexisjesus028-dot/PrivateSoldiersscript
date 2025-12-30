--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

--// RAYFIELD
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "CollectDrop ULTRA",
	LoadingTitle = "CollectDrop ULTRA",
	LoadingSubtitle = "Auto Detect ID",
	ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("Main", 4483362458)

--// VARIABLES
local isRunning = false
local callsPerSecond = 60
local currentId = nil
local lastIdTime = 0
local accumulator = 0
local connection = nil

--// REMOTE
local CollectDrop = ReplicatedStorage:WaitForChild("Events"):WaitForChild("CollectDrop")

--// STATUS LABEL
local StatusLabel = Tab:CreateLabel("ID: Detectando...")

--// SPEED SLIDER
Tab:CreateSlider({
	Name = "Velocidad (Calls por segundo)",
	Range = {1, 20000},
	Increment = 1,
	Suffix = "CPS",
	CurrentValue = 60,
	Flag = "SpeedSlider",
	Callback = function(Value)
		callsPerSecond = Value
	end
})

--// TOGGLE
Tab:CreateToggle({
	Name = "RUN",
	CurrentValue = false,
	Flag = "RunToggle",
	Callback = function(Value)
		isRunning = Value

		if isRunning and not connection then
			connection = RunService.Heartbeat:Connect(function(dt)
				accumulator += dt
				local interval = 1 / callsPerSecond

				-- borrar ID después de 10s
				if currentId and (os.clock() - lastIdTime >= 10) then
					currentId = nil
					StatusLabel:Set("ID: Detectando...")
				end

				while accumulator >= interval do
					accumulator -= interval
					if currentId then
						CollectDrop:FireServer(currentId)
					end
				end
			end)
		elseif not isRunning and connection then
			connection:Disconnect()
			connection = nil
			accumulator = 0
		end
	end
})

--// AUTO DETECT ID (HOOK)
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
	local args = {...}
	local method = getnamecallmethod()

	if method == "FireServer" and self == CollectDrop then
		if typeof(args[1]) == "string" then
			currentId = args[1]
			lastIdTime = os.clock()
			StatusLabel:Set("ID activo: " .. currentId)
		end
	end

	return old(self, ...)
end)

setreadonly(mt, true)