--!strict
local TweenService = game:GetService("TweenService")

local animations: {
	open: { [string]: (door: Model) -> () },
	close: { [string]: (door: Model) -> () },
} = {
	open = {},
	close = {},
}

animations.open["SLIDING"] = function(door: Model): ()
	print("Sliding door open")
	local primaryPart: BasePart? = door.PrimaryPart
	local openPart: BasePart? = door:FindFirstChild("OpenPosition") :: BasePart

	if not primaryPart or not openPart then
		return
	end

	local tweenInfo: TweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine)

	local goal = {}
	goal.CFrame = openPart.CFrame

	local tween = TweenService:Create(primaryPart, tweenInfo, goal)

	tween:Play()
end

animations.close["SLIDING"] = function(door: Model): ()
	print("Sliding door closed")
	local primaryPart: BasePart? = door.PrimaryPart
	local closedPart: BasePart? = door:FindFirstChild("ClosedPosition") :: BasePart

	if not primaryPart or not closedPart then
		return
	end

	local tweenInfo: TweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine)

	local goal = {}
	goal.CFrame = closedPart.CFrame

	local tween = TweenService:Create(primaryPart, tweenInfo, goal)

	tween:Play()
end

return animations
