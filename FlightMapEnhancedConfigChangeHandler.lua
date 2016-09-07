--this file is just to handle any standard config changes between versions, easier to seperate it

local ns = select( 2, ... );
function ns:configchange(version,newversion)
		if(version<3) then
			if(FlightMapEnhanced_Config.vconf.MapModifierKey) then
				FlightMapEnhanced_Config.vconf.MapModifierKey = nil;
			end
			if(FlightMapEnhanced_Config.vconf.MapMouseButton) then
				FlightMapEnhanced_Config.vconf.MapMouseButton = nil;
			end
		end
		if(version<4) then
			if not(FlightMapEnhanced_Config.vconf.module.wmc.minimap) then
				FlightMapEnhanced_Config.vconf.module.wmc.minimap = 1;
				FlightMapEnhanced_Module_wmc_minimap:SetChecked(1);
			end
		end
		
		--if(version<6) then
		--	FlightMapEnhanced_FlightTimes = {};
		--end
		if(version<7) then
			if(FlightMapEnhanced_Config.TaxiFramePoints and FlightMapEnhanced_Config.TaxiFramePoints[2]~=nil) then
				FlightMapEnhanced_Config.TaxiFramePoints = nil;
			end
			if(FlightMapEnhanced_Config.FlightMapEnhancedTaxiChoicePoints and FlightMapEnhanced_Config.FlightMapEnhancedTaxiChoicePoints[2]~=nil) then
				FlightMapEnhanced_Config.FlightMapEnhancedTaxiChoicePoints = nil;
			end
			if(FlightMapEnhanced_Config.vconf.module.ft.points and FlightMapEnhanced_Config.vconf.module.ft.points[2]~=nil) then
				FlightMapEnhanced_Config.vconf.module.ft.points = nil;
			end
		end
		
		if(version<10) then
			FlightMapEnhanced_Config["discovery"]["count"][6] = 0;
		end
		if(version<11) then
			FlightMapEnhanced_Config["discovery"]["count"][6] = 0;
			FlightMapEnhanced_Config["fps"][6]=nil;
			for i,_ in pairs(FlightMapEnhanced_Config["discovery"]) do
				if(i ~= "count") then
					if(i > 60000) then
						FlightMapEnhanced_Config["discovery"][i] = nil;
					end
				end
			
			end
		
		end
		if(version<12) then
			if not(FlightMapEnhanced_Config["discovery"]["count"][7]) then
				FlightMapEnhanced_Config["discovery"]["count"][7] =0;
			
			end
			
		
		end
		
		if(version<13) then
			FlightMapEnhanced_Config["discovery"]["count"][8] = 0;
		end
			
		if(version<14) then
			FlightMapEnhanced_Config["discovery"] = nil;
		end
		
		FlightMapEnhanced_Config.vconf.version = newversion;
end

function ns:gconfigchange(newversion)
		if(ns.gconf.version<2) then
			FlightMapEnhanced_FlightTimes = {};
		end
		if(ns.gconf.version<3) then
			for i,_ in pairs (FlightMapEnhanced_FlightTimes) do
				if(string.find(i, "-")~=nil) then
					FlightMapEnhanced_FlightTimes[i] = nil;
				end
			end
		end
		if(ns.gconf.version<4) then
			if(FlightMapEnhanced_FlightTimes[""]) then
				FlightMapEnhanced_FlightTimes[""] = nil;
			end
		end
		if(ns.gconf.version<5) then
			FlightMapEnhanced_FlightTimes = {};
			ns.gconf.id = time();
		end
		if(ns.gconf.version<6) then
			FlightMapEnhanced_FlightNames["count"][6] = 0;
			
		end
		if(ns.gconf.version<7) then
			FlightMapEnhanced_FlightNames["count"][6] = 0;
			FlightMapEnhanced_FlightLocations = {}
			FlightMapEnhanced_FlightTimes = {}
			for i,_ in pairs(FlightMapEnhanced_FlightNames) do
				if(i ~= "count") then
					if(i > 60000) then
						FlightMapEnhanced_FlightNames[i] = nil;
					end
				end
			
			end
		end
		if(ns.gconf.version<8) then
			FlightMapEnhanced_FlightNames["count"][7] = 0;
			
		end
		if(ns.gconf.version<9) then
			for k,v in pairs(FlightMapEnhanced_FlightTimes) do
				if(type(v) == "table") then
					FlightMapEnhanced_FlightTimes[k] = nil;
				end
			end
			
		end
		if(ns.gconf.version<10) then
			FlightMapEnhanced_FlightTimes = {};
		end
		if(ns.gconf.version<11) then
			ns.gconf.id = nil;
		end
		if(ns.gconf.version<13) then
			FlightMapEnhanced_FlightNames["count"][8] = 0;
		end
		
		if(ns.gconf.version<14) then
			FlightMapEnhanced_FlightLocations = nil;
			FlightMapEnhanced_FlightNames = nil;
			FlightMapEnhanced_FlightTimes = nil;
		end
		
		ns.gconf.version = newversion;
end