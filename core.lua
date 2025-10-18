-- core.lua

local addonName, ns = ...
OBC = ns
OBC.name = "OBC"

-- TODO:
-- Dim abilities that are not ready yet.

------------------------------------------------------------
-- Function: Initialize the addon
------------------------------------------------------------
function OBC:OnInitialize()
	-- Initialize the UI
	OBC:InitializeUI()

	-- Event handlers and hooks
	OBC:RegisterEvents()
end