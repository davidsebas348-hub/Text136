--// DESYNC + TELEPORT OBJETOS

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- CONFIGURACIÓN
local TELEPORT_INTERVAL = 0.5 -- cada 0.5s que se teletransportan los objetos
local OBJECT_NAMES = {"Touch"} -- los nombres de los objetos que quieres teletransportar
local PARENT_PATTERN = "^WinPart Z" -- patrón del padre (WinPart Z1, Z2...)

-- VARIABLES DESYNC
local invisOn = false
local savedPos = nil
local espPart = nil
local seat = nil

-- =========================
-- FUNCIONES DESYNC
-- =========================
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

-- =========================
-- FUNCIONES TELETRANSPORT OBJETOS
-- =========================
local function getHRP()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:WaitForChild("HumanoidRootPart")
end

local function getObjectsToTeleport()
	local objects = {}
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and table.find(OBJECT_NAMES, obj.Name)
		   and obj.Parent and obj.Parent.Name:match(PARENT_PATTERN) then
			table.insert(objects, obj)
		end
	end
	return objects
end

local function teleportObjects()
	local hrp = getHRP()
	local objects = getObjectsToTeleport()
	for _, obj in ipairs(objects) do
		if obj and obj.Parent then
			obj.Anchored = false
			obj.CanCollide = false
			obj.CFrame = hrp.CFrame * CFrame.new(0, 3, 0)
		end
	end
end

-- =========================
-- LOOP TELETRANSPORTE
-- =========================
local function startTeleportLoop()
	task.spawn(function()
		while true do
			teleportObjects()
			task.wait(TELEPORT_INTERVAL)
		end
	end)
end

-- =========================
-- EJECUTAR TODO
-- =========================
task.spawn(function()
	activateDesync()      -- Paso 1: activar desync
	task.wait(0.5)        -- Espera 0.5s
	startTeleportLoop()   -- Paso 2: iniciar teleport de objetos
end)

-- OPCIONAL: mantener desync al reaparecer
player.CharacterAdded:Connect(function(char)
	task.wait(1)
	if invisOn then
		activateDesync()
	end
end)
