--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DoorAnimations = require(script.Animations)
local doorQuery = require(ReplicatedStorage.Shared.DoorQuery)

local DoorController = {}

function DoorController:OnStart(): () end

local function handleDoorAnimation(door: Instance, action: string): ()
	local settingsModule = door:FindFirstChild("Settings")
	if not settingsModule or not settingsModule:IsA("ModuleScript") then
		return
	end
	local settings = require(settingsModule) :: { [any]: any }

	local doorType = settings["DoorType"]
	local animationTable = DoorAnimations[action]

	if animationTable and animationTable[doorType] then
		animationTable[doorType](door)
	end
end

function DoorController:OnOpen(door: Instance): ()
	if door:IsA("Model") then
		local model = door :: Model
		handleDoorAnimation(model, "open")
	end
end

function DoorController:OnClose(door: Instance): ()
	if door:IsA("Model") then
		local model = door :: Model
		handleDoorAnimation(model, "close")
	end
end

doorQuery.packets.Open.listen(function(data: { door: Instance }): ()
	DoorController:OnOpen(data["door"])
end)

doorQuery.packets.Close.listen(function(data: { door: Instance }): ()
	DoorController:OnClose(data["door"])
end)

doorQuery.packets.Sync.listen(function(data: { Instance }): ()
	for _, door in pairs(data) do
		local doorOpen = door:GetAttribute("OPEN")
		if doorOpen then
			DoorController:OnOpen(door)
		else
			DoorController:OnClose(door)
		end
	end
end)

return DoorController
