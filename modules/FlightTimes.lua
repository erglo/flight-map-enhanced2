local ns = select( 2, ... );

function ns:initft()
	ns.ft = {};
	local module = ns.ft;
	local config = CreateFrame("Frame");
	local config_gui = CreateFrame("Frame");
	local L = ns.L;
	local curtaxinode;
    --local orig_taketaxinode;
	local f_times,s_f_times;
	local flight_route={};
	local timer,totaltimer,flight_route_accurate,startname,endname,lasttimer,timeleft,nosaving,recordingmode,endlocation;
	local remapid = {[45665]=45664,[76678]=76679}; --argent van guard --everbloom overlook
	local options;
	local dotracking;
	local ticker;
	local flystart = 0;
	local flyend = 0;
	local missingidshown = false;
	local timerFrameValuesDefault = {
		["statusBarChoice"] = "Blizzard Character Skills Bar",
		["showTimer"] = true,
		["fontColor"] = {
			0.862745098039216, -- [1]
			0.87843137254902, -- [2]
			1, -- [3]
			1, -- [4]
		},
		["colorRecording"] = {
			1, -- [1]
			0, -- [2]
			0.125490196078431, -- [3]
			0.689911127090454, -- [4]
		},
		["timerValue"] = true,
		["fontChoice"] = "Skurri",
		["showEndPoint"] = true,
		["showStartPoint"] = true,
		["borderChoice"] = "Blizzard Achievement Wood",
		["backgroundChoice"] = "Blizzard Tabard Background",
		["fontSize"] = 13,
		["colorFlight"] = {
			0.133333333333333, -- [1]
			1, -- [2]
			0.333333333333333, -- [3]
			0.65430274605751, -- [4]
		},
		["depleteStatusBar"] = false,
		["reverseStatusBar"] = false,
	}
	local timerConfig;
	local metatable = {};
	local timerFrame = CreateFrame("frame",nil,UIParent);
	local media = LibStub("LibSharedMedia-3.0")	
	local timerString1, timerString2, totalTime

	metatable.__index = function( inTable, inKey )
		value = defaultconf[inKey];
		inTable[ inKey ] = value;
		return value;
	end



	local function CalcFlId(slotIndex)
		local taxiNodes = GetAllTaxiNodes();
			for i, taxiNodeData in ipairs(taxiNodes) do
				if(slotIndex == taxiNodeData.slotIndex) then
					return taxiNodeData.nodeID;
				end				
			end	
		
	end
	
	local function CalcFlIdCurrent()
	local taxiNodes = GetAllTaxiNodes();
			for i, taxiNodeData in ipairs(taxiNodes) do
				if(1 == taxiNodeData.type) then
					return taxiNodeData.nodeID;
				end				
			end	

end
	
	local function round(num, idp)
		local mult = 10^(idp or 0)
		return math.floor(num * mult + 0.5) / mult
	end
	
	function module:getid(uid)
		for _,v in pairs(ns.floc) do
			for i,v2 in pairs(v) do
				if(i==uid) then
					if(v2.id~=nil) then
						return v2.id;
					else
						return -1;
					end
				end
			end
		end
		return -1;
	end
	
	--removing from saved variables the flight times which are in the addon db
	--if not in db add it to it to have all times in 1 place for usage
	--using now the self tracked one over the one in db
	function module:removefromsv()
		for i,v in pairs (FlightMapEnhanced_FlightTimes) do
			
			ns.ftracks[i] = v;
			
		end
	end
	
	function module:getCurrentContinent()
		local oldmapid = GetCurrentMapAreaID();
		local oldlevel = GetCurrentMapDungeonLevel();
		SetMapToCurrentZone();
		local cont = GetCurrentMapContinent();
		SetMapByID(oldmapid);
		SetDungeonMapLevel(oldlevel);
		return cont;
	end
	
	
	--gonna need overwork for now just ripped of the taketaxinode hook | not used for now, not needed anymore???
	function module:buildflyroutes(button)
			--print("building");
			local wn = self:GetID();
	
			
			local numroutes = GetNumRoutes(wn);
			
			local dX,dY,flid,sX,sY;
			local aflidgen = true;
			flight_route_accurate = '';
			for i=1, numroutes do
				--print(TaxiNodeName(wn));
				
				if(i==1) then
				--	if(TaxiNodeName(wn)=="Socrethar's Rise, Shadowmoon Valley") then
				--	
				--	sX = TaxiGetSrcX(wn, i);
			--		sY = TaxiGetSrcY(wn, i);
			--		flid = CalcFlId(sX,sY,getCurrentContinent())
			--		print(flid);
				
			--	end
					
					sX = TaxiGetSrcX(wn, i);
					sY = TaxiGetSrcY(wn, i);
					flid = CalcFlId(sX,sY,module:getCurrentContinent())
					if(ns.flocn[flid] ~= nil) then
						
						local accuid = module:getid(flid);
						if(accuid>-1) then
							flight_route_accurate = module:getCurrentContinent().."-"..accuid;
						else
							
							aflidgen = false;
						end
					else
						--not having the flid so insert -1
						aflidgen = false;
						if(missingidshown==false) then
							missingidshown = true;
							
							
							module:printchangeid(flid,TaxiNodeName(wn));
						end
			
					end
				end
				
				dX = TaxiGetDestX(wn, i);
				dY = TaxiGetDestY(wn, i);
				flid = CalcFlId(dX,dY,module:getCurrentContinent());
				
				--currently The Argent Vanguard flight path fucks, maybe more
				if ns.flocn[flid] ~= nil then
				
					local accuid = module:getid(flid);
					
					if(accuid>-1) then
						flight_route_accurate = flight_route_accurate.."-"..accuid;
					else
						
						aflidgen = false;
					end
					
				else
				
					if(missingidshown==false) then
					
						missingidshown = true;
						module:printchangeid(flid,TaxiNodeName(wn));
					end
					aflidgen = false;
				end
			
				
			end
		--accurate
		if(f_times[flight_route_accurate] and aflidgen==true) then 
			local mins,secs = module:CalcTime(f_times[flight_route_accurate])
			GameTooltip:AddLine("Flight time: "..mins.."m"..secs.."s", 1.0, 1.0, 1.0);
			GameTooltip:Show();
		end	
			
	end
	
	function module:printchangeid(newid,nodename)
		local match1,_ = strmatch(nodename,"^(.*),(.*)");
		
		local oldid = 0;
		for k,v in pairs(ns.flocn) do
			if v == match1 then
				oldid = k;
				break
			end
		end
		
		--if(oldid>0) then
		--	print("Flight Map Enhanced: "..string.format(L.FT_CANNOT_FIND_ID_NEW,nodename,oldid,newid))
		--end
		
	end
	
	function module:taketaxinode(wn)
		flyend=0;
		--print(CalcFlId(wn));
		dotracking = false;
		--if(options.fasttrack) then
			local numroutes = GetNumRoutes(wn);
			local dX,dY,flid,sX,sY;

			
			local aflidgen = true;
			flight_route_accurate = '';
			
					flid = CalcFlIdCurrent();
					startname = ns.flocn[flid];
					flight_route_accurate = flid..'-';
					
			
				
					flid = CalcFlId(wn);
					endname = ns.flocn[flid]
					flight_route_accurate = flight_route_accurate..flid;
			
				
		if( aflidgen == true) then
				
				dotracking=true;
			
		else
			flight_route_accurate = '';
		end
		
		
		--register events we need
		module.frame:RegisterEvent("PLAYER_CONTROL_LOST");
		
	end
	
	
	
	function module:init()
		--prehook so the flight path can be calculated before the flight start
		if not(FlightMapEnhanced_FlightTimes) then FlightMapEnhanced_FlightTimes = {}; end
		config:init();
		module:removefromsv();
		s_f_times = FlightMapEnhanced_FlightTimes;
		f_times = ns.ftracks;
		
		module.frame = CreateFrame("Frame");
		module.frame:SetScript("OnEvent",module.onevent);
		
		
		--hooksecurefunc('TaxiNodeOnButtonEnter',module.buildflyroutes);
		if not FlightMapEnhanced_Config.vconf.module.ft then FlightMapEnhanced_Config.vconf.module.ft = {}; end
		options = FlightMapEnhanced_Config.vconf.module.ft;
	end
	
	
	
	function module:delaytimer()
		
		--module.frame:SetScript("OnUpdate",function (self,elapsed)
				module:saveaccurate();
				module.frame:UnregisterEvent("PLAYER_ENTERING_WORLD");
			--	module.frame:SetScript("OnUpdate",nil);
			
		--end);
	end
	
	function module:stoptracking()
		
				
		module.frame:UnregisterEvent("PLAYER_CONTROL_LOST");
		module.frame:UnregisterEvent("UNIT_FLAGS");
	
		module.frame:UnregisterEvent("PLAYER_ENTERING_WORLD");
		--flight_route = {};
	end
	
	function module:timeroff()
		ticker:Cancel();
		--module.frame:SetScript("OnUpdate",nil);
	end
	

	function module:onevent2(event,...)
		tinsert(FlightMapEnhanced_FlightTimes,event);
		
	end

	function module:saveaccurate()
			--print('pup');
			--print (flight_route_accurate);
		
			if(flight_route_accurate=='') then return; end
				local curcont,curmapid,curmaplevel,posX,posY = ns:GetPlayerData();
				local closestfp = FlightMapEnhanced_GetClosestFlightPath(curcont,curmapid,posX,posY);	
				--dirty hack for now to check if the flightmaster is the right one
				--print("try to save");
				--print(endname);
				--print(closestfp.name);
			if(closestfp.name and closestfp.name==endname ) then				
			--print("saving");
				--print (flyend.."-"..flystart)
				local timetook = flyend - flystart;		
				--print("saving accurate"..timetook);
				s_f_times[flight_route_accurate] = timetook;
				f_times[flight_route_accurate] = timetook;
			end
		
	end
	
	
	
	function module:onevent(event,...)
		
		--print(event);
		if(event=="PLAYER_CONTROL_LOST") then
			self:UnregisterEvent("PLAYER_CONTROL_LOST");
			self:RegisterEvent("UNIT_FLAGS");
		elseif(event=="PLAYER_CONTROL_GAINED") then
			--print("gelandet");
			flyend = time();
			module:FlightTimerOff()
			module:timeroff();
			module:delaytimer();
			
			self:UnregisterEvent("PLAYER_CONTROL_GAINED");
			
			
			--self:UnregisterEvent("PLAYER_ENTERING_WORLD");
		elseif(event=="UNIT_FLAGS") then
			if(UnitOnTaxi("player")) then
				--print("ontaxt");
				flystart = time();
				local timetoshow = 0;
				if(f_times[flight_route_accurate]) then --if accurate on and we have a timer
					
					recordingmode = false;
					timetoshow = f_times[flight_route_accurate];
				else
					recordingmode=true;
				end
				module:ShowFlightTime(timetoshow);
				self:RegisterEvent("PLAYER_CONTROL_GAINED");
				
			else
				--print("not on taxi");
			end
			
			self:UnregisterEvent("UNIT_FLAGS");
		
		elseif(event=="PLAYER_ENTERING_WORLD") then
			--print("ja2");
			nosaving = true;
			self:UnregisterEvent("PLAYER_ENTERING_WORLD");
		end
	end
	
	function module:CalcTime(seconds)
		local minutes = floor(seconds/60);
		local seconds = mod(seconds,60);
		if(seconds < 10 ) then seconds = "0"..seconds end
		return minutes,seconds;
	end
	
	function module:UpdateTimer(elapsed)
		--print("update");
		--return;
		
			local displaytext = '';
			local datacolor;
			if (recordingmode==false) then
				timeleft=totalTime - (time()-flystart);
				
			    datacolor = "|cFF00FF00";
				displaytext = L.FT_TIME_LEFT;
			else
				timeleft=time()-flystart;
				displaytext = L.FT_RECORDING;
				datacolor = "|cFFFF0000";
			end
			local minutes,seconds = module:CalcTime(floor(timeleft));
			if (recordingmode==false) then
				local percent
				if timerConfig.depleteStatusBar == true then
					percent = timeleft/totalTime * 100
				else
					percent = 100 - timeleft/totalTime * 100
				end
				timerFrame.statusBar:SetValue(percent);
			end
			timerString2 = " "..minutes..":"..seconds
			timerFrame.statusBar.text:SetText(timerString1..timerString2);
			
			ns.databroker.text = endname..": "..datacolor..minutes..L.FT_MINUTE_SHORT..seconds..L.FT_SECOND_SHORT;
		
		
	end
	
	function module:FlightTimerOff()
		--timerFrame:SetScript("OnUpdate",nil);
		ticker:Cancel();
		timerFrame:Hide();	
		--ns.databroker.label = "";
		ns.databroker.text = "";
	end
	
	
	
	function module:ShowFlightTime(ttime)
		--print(flight_route_accurate);
		if(timerConfig.showTimer == false) then 
		
		return 
		end
		totalTime = ttime;
		module:BuildTimerStatusBar(startname,endname,ttime,recordingmode)
		if (recordingmode == true) then
			displaytext = L.FT_RECORDING;
			timerFrame.statusBar:SetValue(100)			
		else
			displaytext = L.FT_TIME_LEFT;	
			if timerConfig.depleteStatusBar == true then
				timerFrame.statusBar:SetValue(100)
			else
				timerFrame.statusBar:SetValue(0)
			end
						
		end
		timeleft = ttime;
	
		local minutes,seconds=module:CalcTime(ttime);
		
		lasttimer = 0;
		--timerFrame:SetScript("OnUpdate",module.UpdateTimer);
		ticker = C_Timer.NewTicker(0.5, module.UpdateTimer)
		if(options.points) then
			timerFrame:SetPoint(unpack(options.points));
		else
			timerFrame:SetPoint("CENTER",0,0);
		end
		timerFrame:Show();
	end
	
	function config:init()
		if not (FlightMapEnhanced_GlobalConf.timerFrameConfig) then
			FlightMapEnhanced_GlobalConf.timerFrameConfig = {};
			FlightMapEnhanced_GlobalConf.timerFrameConfig = timerFrameValuesDefault
			setmetatable(FlightMapEnhanced_GlobalConf,metatable);
			
		end
		timerConfig = FlightMapEnhanced_GlobalConf.timerFrameConfig
	
		config.name = "Flight Times";
		config.parent = "Flight Map Enhanced";
		
		
		
		
		local AceGUI = LibStub("AceGUI-3.0")	

		local showTimer = AceGUI:Create("CheckBox")
		showTimer.frame:SetParent(config);
		showTimer:SetLabel(L.FT_SHOW_TIMER);
		showTimer:SetPoint( "TOPLEFT", 16, -16);
		showTimer:SetValue(timerConfig.showTimer)
		showTimer.frame:Show(true)
		showTimer:SetCallback("OnValueChanged",function(self,event,value)
			showTimer:SetValue(value);
			timerConfig.showTimer = value;		
			end)

		
		local fontChoice = AceGUI:Create("LSM30_Font")
		fontChoice.frame:SetParent(config);		
		fontChoice:SetLabel(L.FT_FONT);
		fontChoice:SetList(media:HashTable("font"))
		fontChoice:SetPoint(  "TOP" , showTimer.frame,"BOTTOM",0,-5);
		fontChoice:SetValue(timerConfig.fontChoice)
		fontChoice:SetCallback("OnValueChanged",function(self,event,value)
			fontChoice:SetValue(value);
			timerConfig.fontChoice = value;		
			end)
		
		local fontSize = AceGUI:Create("Slider")
		fontSize.frame:SetParent(config);		
		fontSize:SetLabel(L.FT_FONT_SIZE);
		fontSize:SetPoint( "LEFT",fontChoice.frame,"RIGHT", 5, 0);	
		fontSize:SetValue(timerConfig.fontSize)
		fontSize:SetCallback("OnValueChanged",function(self,event,value)
			fontSize:SetValue(value);
			timerConfig.fontSize = value;		
			end)
		
		local fontColor = AceGUI:Create("ColorPicker")
		fontColor.frame:SetParent(config);
		fontColor:SetLabel(L.FT_TEXT_COLOR);
		fontColor:SetHasAlpha(true);
		fontColor:SetPoint( "LEFT" , fontSize.frame,"RIGHT",5,0);
		fontColor.frame:Show(true)
		fontColor:SetColor(unpack(timerConfig.fontColor));
		fontColor:SetCallback("OnValueConfirmed",function(self,event,r,g,b,a)
			timerConfig.fontColor = {r,g,b,a}
		end)
		
		local statusBarChoice = AceGUI:Create("LSM30_Statusbar")
		statusBarChoice.frame:SetParent(config);		
		statusBarChoice:SetLabel(L.FT_TEXTURE);
		statusBarChoice:SetList(media:HashTable("statusbar"))
		statusBarChoice:SetPoint( "TOP" , fontChoice.frame,"BOTTOM",0,-5);
		statusBarChoice:SetValue(timerConfig.statusBarChoice)
		statusBarChoice:SetCallback("OnValueChanged",function(self,event,value)
			statusBarChoice:SetValue(value);
			timerConfig.statusBarChoice = value;		
			end)
		
		local backgroundChoice = AceGUI:Create("LSM30_Background")
		backgroundChoice.frame:SetParent(config);		
		backgroundChoice:SetLabel(L.FT_BACKGROUND);
		backgroundChoice:SetList(media:HashTable("background"))
		backgroundChoice:SetPoint( "LEFT" , statusBarChoice.frame,"RIGHT",5,0);
		backgroundChoice:SetValue(timerConfig.backgroundChoice)
		backgroundChoice:SetCallback("OnValueChanged",function(self,event,value)
			backgroundChoice:SetValue(value);
			timerConfig.backgroundChoice = value;		
			end)
		
		
		local borderChoice = AceGUI:Create("LSM30_Border")
		borderChoice.frame:SetParent(config);		
		borderChoice:SetLabel(L.FT_BORDER);
		borderChoice:SetList(media:HashTable("border"))
		borderChoice:SetPoint( "TOP" , statusBarChoice.frame,"BOTTOM",0,-5);
		borderChoice:SetValue(timerConfig.borderChoice)
		borderChoice:SetCallback("OnValueChanged",function(self,event,value)
			borderChoice:SetValue(value);
			timerConfig.borderChoice = value;		
			end)
		
		local colorFlight = AceGUI:Create("ColorPicker")
		colorFlight.frame:SetParent(config);
		colorFlight:SetLabel(L.FT_COLOR);
		colorFlight:SetHasAlpha(true);
		colorFlight:SetPoint( "TOP" , borderChoice.frame,"BOTTOM",0,-5);
		colorFlight.frame:Show(true)
		colorFlight:SetColor(unpack(timerConfig.colorFlight));
		colorFlight:SetCallback("OnValueConfirmed",function(self,event,r,g,b,a)
			timerConfig.colorFlight = {r,g,b,a}
		end)
		
		local colorRecording = AceGUI:Create("ColorPicker")
		colorRecording.frame:SetParent(config);
		colorRecording:SetLabel(L.FT_COLOR_RECORDING);
		colorRecording:SetHasAlpha(true);
		colorRecording:SetPoint( "LEFT" , colorFlight.frame,"RIGHT",0,0);
		colorRecording.frame:Show(true)
		colorRecording:SetColor(unpack(timerConfig.colorRecording));
		colorRecording:SetCallback("OnValueConfirmed",function(self,event,r,g,b,a)
			timerConfig.colorRecording = {r,g,b,a}
		end)
		
		local showStartPoint = AceGUI:Create("CheckBox")
		showStartPoint.frame:SetParent(config);
		showStartPoint:SetLabel(L.FT_START_POINT);
		showStartPoint:SetPoint( "TOP" , colorFlight.frame,"BOTTOM",0,-5);
		showStartPoint.frame:Show(true)
		showStartPoint:SetValue(timerConfig.showStartPoint)
		showStartPoint:SetCallback("OnValueChanged",function(self,event,value)
			showStartPoint:SetValue(value);
			timerConfig.showStartPoint = value;		
			end)
		
		local showEndPoint = AceGUI:Create("CheckBox")
		showEndPoint.frame:SetParent(config);
		showEndPoint:SetLabel(L.FT_END_POINT);
		showEndPoint:SetPoint( "LEFT" , showStartPoint.frame,"RIGHT",0,0);
		showEndPoint.frame:Show(true)
		showEndPoint:SetValue(timerConfig.showEndPoint)
		showEndPoint:SetCallback("OnValueChanged",function(self,event,value)
			showEndPoint:SetValue(value);
			timerConfig.showEndPoint = value;		
			end)
		
		local timerValue = AceGUI:Create("CheckBox")
		timerValue.frame:SetParent(config);
		timerValue:SetLabel(L.FT_SHOW_TIME);
		timerValue:SetPoint( "LEFT" , showEndPoint.frame,"RIGHT",0,0);
		timerValue.frame:Show(true)
		timerValue:SetValue(timerConfig.timerValue)
		timerValue:SetCallback("OnValueChanged",function(self,event,value)
			timerValue:SetValue(value);
			timerConfig.timerValue = value;		
			end)
			
			
			
		local depleteStatusBar = AceGUI:Create("CheckBox")
		depleteStatusBar.frame:SetParent(config);
		depleteStatusBar:SetLabel(L.FT_DEPLETE_BAR);
		depleteStatusBar:SetPoint( "TOP" , showStartPoint.frame,"BOTTOM",0,-5);
		depleteStatusBar.frame:Show(true)
		--depleteStatusBar:SetWidth(250)
		depleteStatusBar:SetValue(timerConfig.depleteStatusBar)
		depleteStatusBar:SetCallback("OnValueChanged",function(self,event,value)
			depleteStatusBar:SetValue(value);
			timerConfig.depleteStatusBar = value;		
			end)


		local reverseStatusBar = AceGUI:Create("CheckBox")
		reverseStatusBar.frame:SetParent(config);
		reverseStatusBar:SetLabel(L.FT_REVERSE_BAR);
		reverseStatusBar:SetPoint( "TOP" , depleteStatusBar.frame,"BOTTOM",0,-5);
		reverseStatusBar.frame:Show(true)
		reverseStatusBar:SetValue(timerConfig.reverseStatusBar)
		reverseStatusBar:SetCallback("OnValueChanged",function(self,event,value)
			reverseStatusBar:SetValue(value);
			timerConfig.reverseStatusBar = value;		
			end)
		
		--fa:Show(true);
		 InterfaceOptions_AddCategory(config);
		--print_r(fa);
		--StaticPopupDialogs["WorldMaDebug"].text = printr_string 
		--StaticPopup_Show ("WorldMaDebug");
		
		local timerStatusBar = CreateFrame("StatusBar",nil,timerFrame)
				

		
		timerStatusBar:SetOrientation("HORIZONTAL")
		timerStatusBar:SetMinMaxValues(0,100)
		timerStatusBar:SetValue(50)
		
		timerStatusBar:SetPoint("CENTER",timerFrame,"CENTER",0,0);
		timerStatusBar:Show(true)
		timerStatusBar.text = timerStatusBar:CreateFontString(nil, "OVERLAY", "TextStatusBarText");		
		timerStatusBar.text:SetPoint("CENTER",timerStatusBar,"CENTER",0,0);
		--timerStatusBar:SetReverseFill(true); 
		timerFrame:SetPoint("CENTER",UIParent,"CENTER",0,0);		
		
		timerFrame:Show(true)
		timerFrame.statusBar = timerStatusBar;
		
		timerFrame.border = CreateFrame("Frame", nil, timerFrame.statusBar)
		
		timerFrame:RegisterForDrag("LeftButton");
		timerFrame:SetMovable(true);
		timerFrame:EnableMouse(true)
		timerFrame:SetScript("OnDragStart", function(self) if IsShiftKeyDown() then self:StartMoving() end end)
		timerFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing(); local a,b,c,d,e = self:GetPoint(); if(b~=nil) then b=b:GetName(); end; options.points = {a,b,c,d,e} end);
		timerFrame:SetScript("OnEnter", function (self) GameTooltip:SetOwner(self, "ANCHOR_TOP");GameTooltip:SetText(L.FT_MOVE, nil, nil, nil, nil, 1); end);
		timerFrame:SetScript("OnLeave",function() GameTooltip:Hide(); end); 
		timerFrame:Hide();	
		
	
	end
	


	
	function module:BuildTimerStatusBar(startPoint,endPoint, timerValue, recording)
		if timerConfig.showTimer == false then return end
		if timerConfig.reverseStatusBar == true then
			timerFrame.statusBar:SetReverseFill(true); 
		else
			timerFrame.statusBar:SetReverseFill(false);
		end
		timerString1=""
		timerString2=""
		local minute,second
		if(timerConfig.showStartPoint) then
			timerString1 = startPoint
		end
		if(timerConfig.showEndPoint) then
			if timerString1 ~= "" then
				timerString1 = timerString1 .. " > " .. endPoint
			else
				timerString1 = timerString1 .. endPoint
			end
		end
		if(timerConfig.timerValue) then
			minute,second = module:CalcTime(timerValue);			
			timerString2 = " "..minute..":"..second
		end
		
	    timerFrame.border:SetPoint("TOPLEFT", timerFrame.statusBar, "TOPLEFT", -5, 5)
		timerFrame.border:SetPoint("BOTTOMRIGHT", timerFrame.statusBar, "BOTTOMRIGHT", 5, -5)
		timerFrame.border:SetBackdrop({
		edgeFile = media:Fetch("border",timerConfig.borderChoice),
		bgFile= media:Fetch("background",timerConfig.backgroundChoice),
		tile = false, tileSize = 0, edgeSize = 16, 
		insets = { left = 0, right = 0, top = 0, bottom = 0}
		})
		timerFrame.border:SetFrameLevel(timerFrame.statusBar:GetFrameLevel())
		local textWidth,textHeight;
		timerFrame.statusBar.text:SetTextColor(unpack(timerConfig.fontColor))
		timerFrame.statusBar.text:SetText(timerString1..timerString2)		
		timerFrame.statusBar.text:SetFont(media:Fetch("font",timerConfig.fontChoice),timerConfig.fontSize)
		textWidth = timerFrame.statusBar.text:GetWidth()
		textHeight = timerFrame.statusBar.text:GetHeight()
		timerFrame:SetWidth(textWidth+30)
		timerFrame:SetHeight(textHeight+10)
		timerFrame.statusBar:SetAllPoints();		
		
		--timerFrame.statusBar:SetValue(50)		
		timerFrame.statusBar:SetStatusBarTexture(media:Fetch("statusbar",timerConfig.statusBarChoice))
		if(recording == true) then
			timerFrame.statusBar:SetStatusBarColor(unpack(timerConfig.colorRecording))
		else
			timerFrame.statusBar:SetStatusBarColor(unpack(timerConfig.colorFlight))
		end
		
	end
	
	module:init();
end