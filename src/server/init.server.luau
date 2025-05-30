--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local loader = require(ReplicatedStorage.Packages.loader)
local services = loader.LoadDescendants(ServerScriptService.Server, loader.MatchesName("Service$"))
loader.SpawnAll(services, "OnStart")
