--> Services
local TweenService = game:GetService("TweenService")

--> Mirror
local Tween = {}

---- EXPOSED API -------------------------------------------------------------------------------------------------------

Tween.GlobalEasingStyle = Enum.EasingStyle.Quint

function Tween:Create(Instance: Instance, tweenInfo: TweenInfo, Properties: any): Tween
	return TweenService:Create(Instance, tweenInfo or TweenInfo.new(), Properties)
end

function Tween:Play(Instance: Instance, tweenInfo: TweenInfo, Properties: any): Tween
	local NewTween = self:Create(Instance, tweenInfo, Properties)
	NewTween:Play()
	
	return NewTween
end

----

return Tween
