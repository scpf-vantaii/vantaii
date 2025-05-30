--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerScripts = player:WaitForChild("PlayerScripts")

local loader = require(ReplicatedStorage.Packages.loader)
local controllers = loader.LoadDescendants(playerScripts.Client, loader.MatchesName("Controller$"))
loader.SpawnAll(controllers, "OnStart")
