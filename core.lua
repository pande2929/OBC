-- core.lua

local addonName, ns = ...
NextUp = ns
NextUp.name = "NextUp"

-- TODO:
-- Dim abilities that are not ready yet.

------------------------------------------------------------
-- Function: Initialize the addon
------------------------------------------------------------
function NextUp:OnInitialize()
	-- Initialize the UI
	NextUp:InitializeUI()

	-- Event handlers and hooks
	NextUp:RegisterEvents()

	-- Let timer know that we're ready.
	NextUp.initialized = true
end