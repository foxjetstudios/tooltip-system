-- Put this inside of your your UI Button and replace the TOOL_TIP_TEXT with your actual text, don't forget to make sure that the tooltip module is in replicatedstorage

local Tooltip = require(game.ReplicatedStorage:WaitForChild("TooltipModule"))

local button = script.Parent
local TOOL_TIP_TEXT = "YOUR_TEXT_HERE")

local tip = Tooltip.new(TOOL_TIP_TEXT)

if not tip then
	return
end

tip:AttachTo(button)
