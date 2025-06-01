--!strict
local IDManager = {}

local assignedIDs: { [string]: { number } } = {}

local function contains(table: {}, value: number): boolean
	local match: boolean = false

	for _, v in pairs(table) do
		if v == value then
			match = true
		end
	end

	return match
end

function IDManager:GetUniqueID(category: string): number
	if assignedIDs[category] == nil then
		assignedIDs[category] = {}
	end

	local newID: number

	repeat
		newID = math.random(10000, 99999)
	until not contains(assignedIDs[category], newID)

	table.insert(assignedIDs[category], newID)

	return newID
end

return IDManager
