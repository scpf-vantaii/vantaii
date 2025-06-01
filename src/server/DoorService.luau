--!strict
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IDManager = require(script.Parent.IDManager)
local doorQuery = require(ReplicatedStorage.Shared.DoorQuery)

local DoorService = {}

local doors: { Instance } = CollectionService:GetTagged("DOOR")

function DoorService:OnStart(): ()
	self._connections = {} :: { [number]: { [string]: RBXScriptConnection } }

	for _, door: Instance in pairs(doors) do
		if not door:IsA("Model") then
			continue
		end

		self:SetupDoor(door)

		local id: number? = self:GetIDFromDoor(door)

		if id == nil then
			return
		end

		self:BindProximityPrompt(id, function()
			local openAttr: any = door:GetAttribute("OPEN")
			local isOpen: boolean = typeof(openAttr) == "boolean" and openAttr or false

			if not isOpen then
				self:OpenDoor(id)
			else
				self:CloseDoor(id)
			end
		end)
	end
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
	for _, value: Instance in pairs(doors) do
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

return DoorService
