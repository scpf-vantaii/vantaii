--!strict
local GroupService = game:GetService("GroupService")
local Players = game:GetService("Players")

local groups = require(script.Groups)
local ranks = require(script.Ranks)

local PermissionService = {}

local playerRanks: { [Player]: { [string]: number } } = {}

function PermissionService:OnStart(): () end

function PermissionService:GetRankInGroup(player: Player, group: string, returnAsName: boolean?): number | string
	returnAsName = returnAsName or false

	if groups[group] and playerRanks[player][group] then
		if returnAsName then
			for name, id in pairs(ranks[group]) do
				if id == playerRanks[player][group] then
					return name
				end
			end
		else
			return playerRanks[player][group]
		end
	end

	if returnAsName then
		return "Guest"
	end

	return 0
end

function PermissionService:HasRankInGroup(player: Player, group: string, rank: string): boolean
	if groups[group] and playerRanks[player][group] then
		if ranks[group][rank] == playerRanks[player][group] then
			return true
		end
	end

	return false
end

function PermissionService:IsInGroup(player: Player, group: string): boolean
	if groups[group] and playerRanks[player][group] then
		return true
	end

	return false
end

Players.PlayerAdded:Connect(function(player: Player): ()
	local allPlayerRanks = {}

	for index, _value in pairs(groups) do
		if player:IsInGroup(groups[index]) then
			local groupInfo = GroupService:GetGroupInfoAsync(groups[index])

			for _, role in pairs(groupInfo.Roles) do
				if player:GetRankInGroup(groups[index]) == role.Rank then
					allPlayerRanks[index] = role.Rank
				end
			end
		end
	end

	playerRanks[player] = allPlayerRanks
end)

return PermissionService
