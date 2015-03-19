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
	local flystart = 0;
	local flyend = 0;
	local missingidshown = false;

	local function CalcFlId(x,y,z)
		local flid=tonumber(z..ceil(x*100)..ceil(y*100));
		--print(flid);
		if(remapid[flid]) then
			return remapid[flid];
		else
			return flid;
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
	
	--gonna need overwork for now just ripped of the taketaxinode hook
	function module:buildflyroutes(button)
			
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
			--		flid = CalcFlId(sX,sY,GetCurrentMapContinent())
			--		print(flid);
				
			--	end
					
					sX = TaxiGetSrcX(wn, i);
					sY = TaxiGetSrcY(wn, i);
					flid = CalcFlId(sX,sY,GetCurrentMapContinent())
					if(ns.flocn[flid] ~= nil) then
						
						local accuid = module:getid(flid);
						if(accuid>-1) then
							flight_route_accurate = GetCurrentMapContinent().."-"..accuid;
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
				flid = CalcFlId(dX,dY,GetCurrentMapContinent());
				
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
		
		if(oldid>0) then
			print("Flight Map Enhanced: "..string.format(L.FT_CANNOT_FIND_ID_NEW,nodename,oldid,newid))
		end
		
	end
	
	function module:taketaxinode(wn)
		flyend=0;
		
		dotracking = false;
		--if(options.fasttrack) then
			local numroutes = GetNumRoutes(wn);
			local dX,dY,flid,sX,sY;

			
			local aflidgen = true;
			flight_route_accurate = '';
			for i=1, numroutes do
				if(i==1) then
					sX = TaxiGetSrcX(wn, i);
					sY = TaxiGetSrcY(wn, i);
					flid = CalcFlId(sX,sY,GetCurrentMapContinent())
					startname = FlightMapEnhanced_FlightNames[flid];
					if(ns.flocn[flid] ~= nil) then
						
						local accuid = module:getid(flid);
						if(accuid>-1) then
							flight_route_accurate = GetCurrentMapContinent().."-"..accuid;
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
				flid = CalcFlId(dX,dY,GetCurrentMapContinent());
				
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
				
				if(i==numroutes) then
					endname = FlightMapEnhanced_FlightNames[flid]
				end
			end
				
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
		
		module:removefromsv();
		s_f_times = FlightMapEnhanced_FlightTimes;
		f_times = ns.ftracks;
		
		module.frame = CreateFrame("Frame");
		module.frame:SetScript("OnEvent",module.onevent);
				
		
		local f = CreateFrame("Frame",nil,UIParent)
		module.tframe = f;
		f:SetFrameStrata("LOW")
		
		f:SetHeight(70) -- for your Texture
		f:SetBackdrop( { 
		  bgFile = "Interface\\Addons\\FlightMapEnhanced\\images\\ftimes_frame", 
		
		  insets = { left = 0, right = 0, top = 0, bottom = 0 }
		});
		
		local t = f:CreateTexture(nil,"BACKGROUND")
		t:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background-Dark")
		
		t:SetHeight(55);
		
		t:SetPoint("CENTER",f);
		f.texture = t

		local curwidth = 0;
					
		
		local font1 = f:CreateFontString( nil, "OVERLAY", "GameFontNormalSmall" );
		font1:SetPoint("TOPLEFT", f,"TOPLEFT", 14, -15)
		
		f.flightpath = font1;
		
		local font2 = f:CreateFontString( nil, "OVERLAY", "GameFontNormal" );
		font2:SetPoint("TOPLEFT",font1,"TOPLEFT", 0, -20)
		
		font2:SetTextHeight(14);
		f.timeleft = font2;
		
		local font3 = f:CreateFontString( nil, "OVERLAY", "GameFontNormalSmall" );
		font3:SetPoint("TOPLEFT", font2,"TOPLEFT", 0, -25)
		f.modus = font3;
		
	
		f:RegisterForDrag("LeftButton");
		f:SetMovable(true);
		f:SetScript("OnDragStart", function(self) if IsShiftKeyDown() then self:StartMoving() end end)
		f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing(); local a,b,c,d,e = self:GetPoint(); if(b~=nil) then b=b:GetName(); end; options.points = {a,b,c,d,e} end);
		f:SetScript("OnEnter", function (self) GameTooltip:SetOwner(self, "ANCHOR_TOP");GameTooltip:SetText(L.FT_MOVE, nil, nil, nil, nil, 1); end);
		f:SetScript("OnLeave",function() GameTooltip:Hide(); end); 
		f:Hide();
		hooksecurefunc('TaxiNodeOnButtonEnter',module.buildflyroutes);
		if not FlightMapEnhanced_Config.vconf.module.ft then FlightMapEnhanced_Config.vconf.module.ft = {}; end
		options = FlightMapEnhanced_Config.vconf.module.ft;
	end
	
	
	
	function module:delaytimer()
		
		module.frame:SetScript("OnUpdate",function (self,elapsed)
				module:saveaccurate();
				module.frame:UnregisterEvent("PLAYER_ENTERING_WORLD");
				module.frame:SetScript("OnUpdate",nil);
			
		end);
	end
	
	function module:stoptracking()
		
				
		module.frame:UnregisterEvent("PLAYER_CONTROL_LOST");
		module.frame:UnregisterEvent("UNIT_FLAGS");
	
		module.frame:UnregisterEvent("PLAYER_ENTERING_WORLD");
		--flight_route = {};
	end
	
	function module:timeroff()
		
		module.frame:SetScript("OnUpdate",nil);
	end
	

	function module:onevent2(event,...)
		tinsert(FlightMapEnhanced_FlightTimes,event);
		
	end

	function module:saveaccurate()

		
			if(flight_route_accurate=='') then return; end
				local curcont,curmapid,curmaplevel,posX,posY = ns:GetPlayerData();
				local closestfp = FlightMapEnhanced_GetClosestFlightPath(curcont,curmapid,posX,posY);	
				--dirty hack for now to check if the flightmaster is the right one
			if(closestfp.name and closestfp.name==endname ) then				
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
			module:FlightTimerOff()
			module:timeroff();
			module:delaytimer();
			flyend = time();
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
		return minutes,seconds;
	end
	
	function module:UpdateTimer(elapsed)
		
		lasttimer = lasttimer + elapsed;
		if(lasttimer>=0.5) then
			local displaytext = '';
			if (recordingmode==false) then
				timeleft=timeleft-lasttimer;
				
				displaytext = L.FT_TIME_LEFT;
			else
				timeleft=time()-flystart;
				displaytext = L.FT_RECORDING;
			end
			local minutes,seconds = module:CalcTime(floor(timeleft));
			module.tframe.timeleft:SetText("|cFFFFFFFF"..displaytext..": |r"..minutes..L.FT_MINUTE_SHORT..seconds..L.FT_SECOND_SHORT);
			lasttimer = 0;
		end
	end
	
	function module:FlightTimerOff()
		module.tframe:SetScript("OnUpdate",nil);
		module.tframe:Hide();	
	end
	
	function module:SetTimerWidth()
		local curwidth = module.tframe.flightpath:GetWidth();
		if(module.tframe.timeleft:GetWidth() > curwidth) then
			curwidth = module.tframe.timeleft:GetWidth();
		end
		
		if(module.tframe.modus:GetWidth() > curwidth) then
			curwidth = module.tframe.modus:GetWidth();
		end
		
		
		module.tframe:SetWidth(curwidth+46);
		module.tframe.texture:SetWidth(curwidth+30);
	
	end
	
	function module:ShowFlightTime(ttime)
		if (recordingmode == true) then
			displaytext = L.FT_RECORDING;			
		else
			displaytext = L.FT_TIME_LEFT;			
		end
		timeleft = ttime;
		module.tframe.flightpath:SetText("|cFFFFFFFF"..startname.."->"..endname);
		local minutes,seconds=module:CalcTime(ttime);
		module.tframe.timeleft:SetText("|cFFFFFFFF"..displaytext..": |r"..minutes..L.FT_MINUTE_SHORT..seconds..L.FT_SECOND_SHORT);
		lasttimer = 0;
		module.tframe:SetScript("OnUpdate",module.UpdateTimer);
		module:SetTimerWidth();
		if(options.points) then
			module.tframe:SetPoint(unpack(options.points));
		else
			module.tframe:SetPoint("CENTER",0,0);
		end
		module.tframe:Show();
	end
	
		
	
	module:init();
end