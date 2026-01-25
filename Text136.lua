--// DESYNC + TELEPORT AUTOMÁTICO

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- CONFIGURACIÓN
local TELEPORT_POS = Vector3.new(1204.29, 355.53, -3143.72)
local TELEPORT_INTERVAL = 0.5 -- cada 0.5s

-- VARIABLES
local invisOn = false
local savedPos = nil
local espPart = nil
local seat = nil

-- FUNCIONES
local function setTransparency(char, val)
	for _, p in ipairs(char:GetDescendants()) do
		if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
			p.Transparency = val
		end
	end
end

local function createESP(position)
	espPart = Instance.new("Part")
	espPart.Size = Vector3.new(2,2,2)
	espPart.Position = position
	espPart.Anchored = true
	espPart.CanCollide = false
	espPart.Transparency = 0.3
	espPart.BrickColor = BrickColor.new("Bright yellow")
	espPart.Material = Enum.Material.Neon
	espPart.Name = "InvisESP"
	espPart.Parent = Workspace
end

local function removeESP()
	if espPart and espPart.Parent then
		espPart:Destroy()
		espPart = nil
	end
end

local function activateDesync()
	local char = player.Character or player.CharacterAdded:Wait()
	if not char then return end

	invisOn = true
	setTransparency(char, 0.5)

	-- Guarda la posición actual
	savedPos = char.HumanoidRootPart.Position

	-- Crear silla invisible y weld
	seat = Instance.new("Seat")
	seat.Anchored = false
	seat.CanCollide = false
	seat.Transparency = 1
	seat.Name = "invischair"
	seat.Position = savedPos
	seat.Parent = Workspace

	local weld = Instance.new("Weld")
	weld.Part0 = seat
	weld.Part1 = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
	weld.Parent = seat

	-- Crear ESP visual
	createESP(savedPos)
end

-- TELEPORT AUTOMÁTICO
local function teleportLoop()
	local char = player.Character or player.CharacterAdded:Wait()
	if not char then return end
	local hrp = char:WaitForChild("HumanoidRootPart")

	while true do
		hrp.CFrame = CFrame.new(TELEPORT_POS)
		task.wait(TELEPORT_INTERVAL)
	end
end

-- EJECUTAR DESYNC + TELEPORT
task.spawn(function()
	activateDesync()        -- Paso 1: activar desync/invisible
	task.wait(0.5)          -- Espera 0.5s
	teleportLoop()           -- Paso 2: iniciar teleport cada 0.5s
end)

-- OPCIONAL: mantener invisible al reaparecer
player.CharacterAdded:Connect(function(char)
	task.wait(1)
	if invisOn then
		activateDesync()
	end
end)
