--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DoorAnimations = require(script.Animations)
local doorQuery = require(ReplicatedStorage.Shared.DoorQuery)

local DoorController = {}

function DoorController:OnStart(): () end

local function handleDoorAnimation(data: any, action: string): ()
	local settingsModule = data["door"]:FindFirstChild("Settings")
	if not settingsModule or not settingsModule:IsA("ModuleScript") then
		return
	end
	local settings = require(settingsModule) :: { [any]: any }

	local doorType = settings["DoorType"]
	local animationTable = DoorAnimations[action]

	if animationTable and animationTable[doorType] then
		animationTable[doorType](data)
	end
end

function DoorController:OnOpen(data: any): ()
	handleDoorAnimation(data, "open")
end

function DoorController:OnClose(data: any): ()
	handleDoorAnimation(data, "close")
end

doorQuery.packets.Open.listen(function(data: any): ()
	DoorController:OnOpen(data)
end)

doorQuery.packets.Close.listen(function(data: any): ()
	DoorController:OnClose(data)
end)

return DoorController
