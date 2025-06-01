local ReplicatedStorage = game:GetService("ReplicatedStorage")
local bytenet = require(ReplicatedStorage.Packages["bytenet"])

return bytenet.defineNamespace("Door", function()
	return {
		packets = {
			Open = bytenet.definePacket({
				value = bytenet.struct({
					door = bytenet.inst,
				}),
			}),
			Close = bytenet.definePacket({
				value = bytenet.struct({
					door = bytenet.inst,
				}),
			}),
		},
	}
end)
