--!strict
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IDManager = require(script.Parent.IDManager)
local PermissionService = require(script.Parent.PermissionService)
local doorQuery = require(ReplicatedStorage.Shared.DoorQuery)

local defaultColor = Color3.fromRGB(255, 255, 255)
local successColor = Color3.fromRGB(0, 255, 0)
local deniedColor = Color3.fromRGB(255, 0, 0)

local DoorService = {}

local function blinkLight(door: Model, color: Color3, time: number?)
	local interfaces = door:FindFirstChild("Interfaces")
	if interfaces and interfaces:IsA("Folder") then
		for _, interface in pairs(interfaces:GetChildren()) do
			if interface:IsA("Model") then
				local light: Instance? = interface:FindFirstChild("Light")
				if light and light:IsA("BasePart") then
					light.Color = color
					task.delay(time or 1, function(): ()
						light.Color = defaultColor
					end)
				end
			end
		end
	end
end

function DoorService:OnStart(): ()
	self._connections = {} :: { [number]: { [string]: RBXScriptConnection } }

	local doors: { Model } = DoorService:GetDoors()

	if doors and #doors > 0 then
		for _, door: Model in pairs(doors) do
			self:SetupDoor(door)

			local id: number? = self:GetIDFromDoor(door)

			if id == nil then
				return
			end

			local debounce: boolean = false

			self:BindProximityPrompt(id, function(player: Player): ()
				local openAttr: any = door:GetAttribute("OPEN")
				local isOpen: boolean = typeof(openAttr) == "boolean" and openAttr or false

				local canOpen: boolean = DoorService:AuthenticateUser(player, id)

				local settingsModule = door:FindFirstChild("Settings")
				if not settingsModule or not settingsModule:IsA("ModuleScript") then
					return false
				end
				local settings = require(settingsModule) :: { [any]: any }

				-- First handle blinking the lights
				if not debounce then
					-- Then open the door and play sounds etc.
					if canOpen then
						if not isOpen then
							debounce = true
							blinkLight(door, successColor)
							self:OpenDoor(id)
							task.delay(settings["AnimationTime"], function(): ()
								debounce = false
							end)
							return
						else
							debounce = true
							blinkLight(door, successColor)
							self:CloseDoor(id)
							task.delay(settings["AnimationTime"], function(): ()
								debounce = false
							end)
							return
						end
					end
				end

				blinkLight(door, deniedColor)
			end)
		end
	end
end

function DoorService:GetDoors(): { Model }
	local doors: { Model } = {}

	local collection: { Instance } = CollectionService:GetTagged("DOOR")
	for _, value: Instance in pairs(collection) do
		if not value:IsA("Model") then
			continue
		end

		table.insert(doors, value)
	end

	return doors
end

function DoorService:SetupDoor(door: Model): ()
	-- Generate unique ID
	local id: number = IDManager:GetUniqueID("door")

	door:SetAttribute("ID", id)
	door:SetAttribute("OPEN", false)
end

function DoorService:GetDoorFromID(id: number): Model?
	local door: Model?

	-- Go through all doors
	local doors: { Model } = DoorService:GetDoors()

	for _, value: Model in pairs(doors) do
		if not value:IsA("Model") then
			continue
		end

		-- Check if ID match
		if self:GetIDFromDoor(value) == id then
			door = value
		end
	end

	if door then
		return door
	end

	return nil
end

function DoorService:GetIDFromDoor(door: Model): number?
	local id: unknown? = door:GetAttribute("ID")

	if id and typeof(id) == "number" then
		return id
	end

	return nil
end

function DoorService:OpenDoor(id: number): ()
	local door: Model? = self:GetDoorFromID(id)

	if door then
		doorQuery.packets.Open.sendToAll({ door = door })
		door:SetAttribute("OPEN", true)
	end
end

function DoorService:CloseDoor(id: number): ()
	local door: Model? = self:GetDoorFromID(id)

	if door then
		doorQuery.packets.Close.sendToAll({ door = door })
		door:SetAttribute("OPEN", false)
	end
end

function DoorService:BindProximityPrompt(id: number, callback: () -> ()): ()
	local door: Model? = self:GetDoorFromID(id)

	if door then
		local interfaces = door:FindFirstChild("Interfaces")
		if interfaces and interfaces:IsA("Folder") then
			for _, interface: Instance in pairs(interfaces:GetChildren()) do
				local promptHolder = interface:FindFirstChild("Prompt")
				local proximityPrompt = promptHolder and promptHolder:FindFirstChildWhichIsA("ProximityPrompt")

				if proximityPrompt then
					if self._connections[id] == nil then
						self._connections[id] = {}
					end

					if not (self._connections[id] and self._connections[id][interface.Name]) then
						self._connections[id] = self._connections[id] or {}
						self._connections[id][interface.Name] = proximityPrompt.Triggered:Connect(callback)
					end
				end
			end
		end
	end
end

function DoorService:Sync(player: Player): ()
	local doors: { Model } = DoorService:GetDoors()

	-- Tell the client to sync all doors with the server
	doorQuery.packets.Sync.sendTo(doors, player)
end

function DoorService:AuthenticateUser(player: Player, id: number): boolean
	-- Go through the door's permission and check if the player can open it
	local door: Model? = self:GetDoorFromID(id)

	if door then
		local settingsModule = door:FindFirstChild("Settings")
		if not settingsModule or not settingsModule:IsA("ModuleScript") then
			return false
		end
		local settings = require(settingsModule) :: { [any]: any }

		local permissions = settings["Permissions"]

		-- Check if player has the right rank in group
		for groupName: string, value: any in pairs(permissions["Group"]) do
			if typeof(value) == "boolean" then
				if PermissionService:IsInGroup(player, groupName) then
					return true
				end
			elseif typeof(value) == "table" then
				for rankName: string, _ in pairs(value) do
					if PermissionService:HasRankInGroup(player, groupName, rankName) then
						return true
					end
				end
			end
		end
	end

	return false
end

Players.PlayerAdded:Connect(function(player: Player): ()
	local function onCharacterAdded(_character): ()
		-- Sync the door
		DoorService:Sync(player)
	end

	player.CharacterAdded:Connect(onCharacterAdded)

	if player.Character then
		onCharacterAdded(player.Character)
	end
end)

return DoorService
