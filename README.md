# Tooltip Module for Roblox

A simple tooltip system for Roblox UI that actually feels nice to use.

This module shows a tooltip when the player hovers their mouse over a UI element for a short moment. It follows the cursor, fades in and out smoothly, and stays inside the screen without clipping.

Built for desktop players only. Touch devices are automatically ignored.

## Features

* Smooth fade in and fade out animation
* Follows the mouse in real time
* Smart positioning that avoids going off screen
* Hover delay so it does not pop instantly
* Lightweight and easy to reuse
* No external dependencies

## Setup

1. Create a ModuleScript called `TooltipModule`
2. Paste the Tooltip code into it
3. Put the ModuleScript inside `ReplicatedStorage`

That is it. The module handles its own ScreenGui and cleanup.

## Basic Usage

Put this **LocalScript** inside any UI object like a TextButton or ImageButton.

```lua
local Tooltip = require(game.ReplicatedStorage:WaitForChild("TooltipModule"))

local button = script.Parent
local TOOL_TIP_TEXT = "YOUR_TEXT_HERE"

local tip = Tooltip.new(TOOL_TIP_TEXT)

if not tip then
	return
end

tip:AttachTo(button)
```

When the player hovers the button without moving the mouse for a moment, the tooltip will appear.

## How It Works

* The tooltip waits for a small hover delay before showing
* If the mouse moves too much, the timer resets
* The tooltip follows the cursor using RenderStepped
* Position is clamped to the viewport so it never goes off screen
* Everything is cleaned up automatically when the mouse leaves

## Customization

You can tweak these values after creating the tooltip:

```lua
tip.HoverTime = 1.3
tip.Offset = Vector2.new(8, 4)
```

You can also modify the visuals directly inside `CreateGui` if you want different colors, fonts, or padding.

## Notes

* This only works for mouse and keyboard users
* Mobile and console players will not see tooltips
* Designed to be simple, readable, and easy to extend

## License

Use it however you want.
No credit required, but always appreciated.
This repository is licensed under MIT license.

Have fun building cool UI.
