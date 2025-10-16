-- core.lua

local addonName, ns = ...
OBC = ns
OBC.name = "OBC"

------------------------------------------------------------
-- Function: Initialize the addon
------------------------------------------------------------
function OBC:OnInitialize()
	-- Initialize the variables
	--InitVariables()
	OBC.suggestedSpell = 0
	OBC.keybind = ""

	-- Create the highlight frame
	OBC:CreateHighlightFrame()

	-- Show/hide action bars
	OBC:UpdateActionBars()
	
	-- Create the Settings Frame
	OBC:CreateSettingsFrame()

	-- Create cooldown overlay
	OBC:CreateCooldownOverlay()

	-- Event handlers and hooks
	OBC:RegisterEvents()
end