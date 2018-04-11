local frame = CreateFrame("FRAME", "LastRepAddonFrame");
frame:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE");
frame:RegisterEvent("ADDON_LOADED");

-- TODO: Add options for wantClear, Time, MakeExhaltedInactive, SkipInactive, show increase, show decrease
-- Need the following options:
--  wantClear - Auto-clear once set
--  clearTime - How long to wait to auto-clear
--  makeExhaltedInactive - Move completed reps to inactive
--  skipInactive - Skip inactive reps
--  showIncreases - Show increases
--  showDecrease  - Show decreases
-- Fix Guild.  Got to next time.

LastRep_STANDING_STRINGS = {"Hated","Hostile","Unfriendly","Neutral","Friendly","Honored","Revered","Exalted"};
LastRep_FRIENDSHIP_STRINGS = {"Stranger","Acquaintance","Buddy", "Friend", "Good Friend", "Best Friend"};
LastRep_BODYGUARD_STRINGS = {"Level 1","Level 2","Level 3"};

local function LastRep_eventHandler(self, event, arg1, ...)
	if (event == "ADDON_LOADED" and arg1 == "LastRep") then
		if (LastRep_Pref_Verbose == nil) then
			LastRep_Pref_Verbose = true;
			print("LastRep: Setting Verbose to default (TRUE)");
		end
		if (LastRep_Pref_SwitchBar == nil) then
			LastRep_Pref_SwitchBar = true;
			print("LastRep: Setting Switch Bar to default (TRUE)");
		end
		if (LastRep_Pref_Timeout == nil) then
			LastRep_Pref_Timeout = true;
			print("LastRep: Setting Timeout to default (TRUE)");			
		end
		if (LastRep_Pref_TimeoutSeconds == nil) then
			LastRep_Pref_TimeoutSeconds = 60;
			print("LastRep: Setting Timeout Delay to default (60)");			
		end
		print("LastRep loaded.");
	end -- ADDON_LOADED
	
	if event == ("CHAT_MSG_COMBAT_FACTION_CHANGE") then
		local faction = select(3, string.find(arg1, "Reputation with (.+) increased by "));
	
		-- ExpandAllFactionHeaders();
		-- The built-in function appears to have a bug.  Any faction in a subheader disappears from the 
		--  listing. This can be uncommented out in the future if the function begins to work as
		--  expected.  Until then, this is a workaround:
		local factionCount = GetNumFactions();
		local j = 1;
		
		while (j <= factionCount) do
			local name, _, standingID, barMin, barMax, barValue, 
				_, _, isHeader, isCollapsed, hasRep, isWatched, _ = GetFactionInfo(j);
			if(isHeader and isCollapsed) then
				ExpandFactionHeader(j);
				factionCount = GetNumFactions();
			end
			j = j + 1;
		end
		
		-- End of the workaround
		
		local i = 1;
		local numFactions = GetNumFactions();

		for i = 1, numFactions, 1 do
			local name, _, standingID, barMin, barMax, barValue, 
				_, _, isHeader, _, hasRep, isWatched, _ = GetFactionInfo(i);
		
			if( faction == name and not isHeader ) then
				if( LastRep_Pref_SwitchBar and not isWatched) then
					SetWatchedFactionIndex(i);
				end
				if( LastRep_Pref_Timeout ) then
					if( LastRep_Timer ) then 
						LastRep_Timer:Cancel();
					end
					LastRep_Timer = C_Timer.NewTimer(LastRep_Pref_TimeoutSeconds, function() SetWatchedFactionIndex(0) end);
					-- C_Timer.After(LastRep_Pref_TimeoutSeconds, function() SetWatchedFactionIndex(0) end);
				end
				if (LastRep_Pref_Verbose == true) then
					print( "Reputation: " .. faction .. " - " .. 
						getglobal("FACTION_STANDING_LABEL"..standingID) .. ":(" ..
						(barValue-barMin) .. "/" .. (barMax-barMin) .. ")" );
				end;
				break;
			end -- if
		end -- for
		
		CollapseAllFactionHeaders();
		
	end -- CHAT_MSG_COMBAT_FACTION_CHANGE

end -- eventHandler()

local function isFriendshipNPC(Name)
	if Name == "Chee Chee" then return true end;
	if Name == "Old Hillpaw" then return true end;
	if Name == "Ella" then return true end;
	if Name == "Fish Fellreed" then return true end;
	if Name == "Jogu the Drunk" then return true end;
	if Name == "Sho" then return true end;
	if Name == "Farmer Fung" then return true end;
	if Name == "Gina Mudclaw" then return true end;
	if Name == "Haohan Mudclaw" then return true end;
	if Name == "Tina Mudclaw" then return true end;
	return false;
end

frame:SetScript("OnEvent", LastRep_eventHandler);

