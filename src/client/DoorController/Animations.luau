--!strict
local TweenService = game:GetService("TweenService")

local animations: {
	open: { [string]: (data: any) -> () },
	close: { [string]: (data: any) -> () },
} = {
	open = {},
	close = {},
}

animations.open["SLIDING"] = function(data: any): ()
	print("Sliding door open")
	local primary: BasePart = data["door"].PrimaryPart

	local tweenInfo: TweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine)

	local goal = {}
	goal.CFrame = primary.CFrame * CFrame.new(0, 0, -primary.Size.Z)

	local tween = TweenService:Create(primary, tweenInfo, goal)

	tween:Play()
end

animations.close["SLIDING"] = function(data: any): ()
	print("Sliding door closed")
	local primary: BasePart = data["door"].PrimaryPart

	local tweenInfo: TweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine)

	local goal = {}
	goal.CFrame = primary.CFrame * CFrame.new(0, 0, primary.Size.Z)

	local tween = TweenService:Create(primary, tweenInfo, goal)

	tween:Play()
end

return animations
