local ns = select( 2, ... );
function ns:initwmc()
	ns.wmc = {};
	local module = ns.wmc;

	local config = CreateFrame("Frame");
	local L = ns.L;
	local minimappointer;
	function module:init()
		WorldMapButton:HookScript("OnMouseDown",module.WorldMapClickHandler);
		config:init();
		minimappointer=CreateFrame("Button", nil,UIParent );
		minimappointer:SetWidth(18);
		minimappointer:SetHeight(18);
		minimappointer.icon = minimappointer:CreateTexture("ARTWORK");
		minimappointer.icon:SetAllPoints();
		minimappointer.icon:SetTexture("Interface\\MINIMAP\\TRACKING\\FlightMaster");
		minimappointer:SetFrameLevel(10000);
	end


	
	function module:GetCursorPos()
		local left, top = WorldMapDetailFrame:GetLeft(), WorldMapDetailFrame:GetTop()
		local width, height = WorldMapDetailFrame:GetWidth(), WorldMapDetailFrame:GetHeight()
		local scale = WorldMapDetailFrame:GetEffectiveScale()

		local x, y = GetCursorPosition()
		local cx = (x/scale - left) / width
		local cy = (top - y/scale) / height

		if cx < 0 or cx > 1 or cy < 0 or cy > 1 then
			return
		end

		return cx, cy
	end
	
	function module:FlightTaken()
		minimappointer:Hide();
	end
	
	function module:GetClosestForQuest(questLogIndex)
		--local mapID, floorNumber = GetQuestWorldMapAreaID(questID);
			
		local parent = ObjectiveTrackerFrame.BlocksFrame;
		local distSqr, onContinent = GetDistanceSqToQuest(questLogIndex);
		if(onContinent == false) then return end
		--local questID, title, _, numObjectives, requiredMoney, isComplete, startEvent, isAutoComplete, failureTime, timeElapsed, questType, isTask, isStory, isOnMap, hasLocalPOI = GetQuestWatchInfo(questLogIndex);
		
		local _, _, _, _, _, isComplete, _, questID = GetQuestLogTitle(questLogIndex);
		local mapID, floorNumber = GetQuestWorldMapAreaID(questID);
		
		if ( mapID ~= 0 ) then
			SetMapByID(mapID);
			local curcont = GetCurrentMapContinent();
			local curmapid=mapID;
			--print (questID)
			local _,togox,togoy = QuestPOIGetIconInfo(questID)
			--print (togox.."---"..togoy);
			local nextflight=FlightMapEnhanced_GetClosestFlightPath(curcont,curmapid,togox,togoy);		
			
			if(nextflight.name) then
				FlightMapEnhanced_SetNextFly(nextflight.name);
				if(FlightMapEnhanced_Config.vconf.module.wmc.minimap) then
				
					local curcont,curmapid,curmaplevel,posX,posY = ns:GetPlayerData();
					local closestfp = FlightMapEnhanced_GetClosestFlightPath(curcont,curmapid,posX,posY);
		
				
					if(closestfp.name) then
						ns.DragonPins:AddMinimapIconMF(ns,minimappointer, closestfp.mapid,curmaplevel, closestfp.x, closestfp.y );
						minimappointer:Show();
					end
				end
			end		
			
		else
			return;
		end
		
		
	end
	
	function module:QuestFrameAdd()
		local block = self.activeFrame;
		local questLogIndex = block.questLogIndex;
		local info = UIDropDownMenu_CreateInfo();
		info.notCheckable = 1;
		info.text = L.WMC_SET_QUEST_FLY;
		info.func = module.GetClosestForQuest;
		info.arg1 = questLogIndex;
		info.noClickSound = 1;
		info.checked = false;
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	end

	function module:WorldMapClickHandler(mouseButton)
		--need check if continent is same
		local modcheck="return true";
		if(FlightMapEnhanced_Config.vconf.module.wmc.MapModifierKey~="None") then
			modcheck = "return Is"..FlightMapEnhanced_Config.vconf.module.wmc.MapModifierKey.."KeyDown()";
		end	
		if (mouseButton == FlightMapEnhanced_Config.vconf.module.wmc.MapMouseButton and loadstring(modcheck)()) then
			local curcont = GetCurrentMapContinent();
			local curmapid=GetCurrentMapAreaID();
			local togox,togoy = module:GetCursorPos();
			local nextflight=FlightMapEnhanced_GetClosestFlightPath(curcont,curmapid,togox,togoy);		
			
			if(nextflight.name) then
				FlightMapEnhanced_SetNextFly(nextflight.name);
				if(FlightMapEnhanced_Config.vconf.module.wmc.minimap) then
				
					local curcont,curmapid,curmaplevel,posX,posY = ns:GetPlayerData();
					local closestfp = FlightMapEnhanced_GetClosestFlightPath(curcont,curmapid,posX,posY);
		
				
					if(closestfp.name) then
						ns.DragonPins:AddMinimapIconMF(ns, minimappointer, closestfp.mapid,curmaplevel, closestfp.x, closestfp.y );
						minimappointer:Show();
					end
				end
			end		
		end
	end
	
	function config:init()
		
		config.name = "World Map Click";
		config.parent = "Flight Map Enhanced";
		
		local WorlMapFeatureLabel = config:CreateFontString( nil, "ARTWORK", "GameFontHighlightSmall" );
		config.WorlMapFeatureLabel = WorlMapFeatureLabel;
		WorlMapFeatureLabel:SetPoint( "TOPLEFT", 16, -16);
		
		WorlMapFeatureLabel:SetWidth(InterfaceOptionsFramePanelContainer:GetRight() - InterfaceOptionsFramePanelContainer:GetLeft() - 30);
		WorlMapFeatureLabel:SetHeight(0);
		WorlMapFeatureLabel:SetJustifyH("LEFT");
		
		WorlMapFeatureLabel:SetText( L.WMC_MODIFIER_SETTINGS );
		WorlMapFeatureLabel:Show();
		
		
		local MapModifierKeyLabel = config:CreateFontString( nil, "ARTWORK", "GameFontHighlight" );
		config.MapModifierKeyLabel = MapModifierKeyLabel;
		MapModifierKeyLabel:SetPoint( "BOTTOMLEFT" , WorlMapFeatureLabel,0,-25);
		MapModifierKeyLabel:SetText(L.MODIFIER_KEY);
		MapModifierKeyLabel:Show();
		
		local MapModifierKey = CreateFrame("Frame", "FlightMapEnhancedMapModifierKeyFrame", config, "UIDropDownMenuTemplate")
		config.MapModifierKey = MapModifierKey;
		MapModifierKey:SetPoint("RIGHT", MapModifierKeyLabel,30, 0)
		MapModifierKey.initialize = function () 
			local info;
			info = UIDropDownMenu_CreateInfo()
			info.text = L.ALT_KEY;
			info.func = config.ChangeModifierKey
			info.value = "Alt";
			UIDropDownMenu_AddButton(info)
			
			info = UIDropDownMenu_CreateInfo()
			info.text = L.CTRL_KEY;
			info.func = config.ChangeModifierKey
			info.value = "Control";
			UIDropDownMenu_AddButton(info)
			
			info = UIDropDownMenu_CreateInfo()
			info.text = L.SHIFT_KEY;
			info.func = config.ChangeModifierKey
			info.value = "Shift";
			UIDropDownMenu_AddButton(info)
			
			info = UIDropDownMenu_CreateInfo()
			info.text = L.NONE;
			info.func = config.ChangeModifierKey
			info.value = "None";
			UIDropDownMenu_AddButton(info)
		
		end;
						
		local MapMouseButtonLabel = config:CreateFontString( nil, "ARTWORK", "GameFontHighlight" );
		config.MapMouseButtonLabel = MapMouseButtonLabel;
		MapMouseButtonLabel:SetPoint( "RIGHT" , MapModifierKeyLabel,0,-16);
		MapMouseButtonLabel:SetText( L.MOUSEBUTTON );
		MapMouseButtonLabel:Show();
		
		local MapMouseButton = CreateFrame("Frame", "FlightMapEnhancedMapMapMouseButtonFrame", config, "UIDropDownMenuTemplate")
		config.MapMouseButton = MapMouseButton;
		MapMouseButton:SetPoint("RIGHT", MapMouseButtonLabel,30, 0)
		MapMouseButton.initialize = function () 
			local info;
			info = UIDropDownMenu_CreateInfo()
			info.text = L.LEFT_BUTTON;
			info.func = config.ChangeMouseButton
			info.value = "LeftButton";
			UIDropDownMenu_AddButton(info)
			
			info = UIDropDownMenu_CreateInfo()
			info.text = L.RIGHT_BUTTON;
			info.func = config.ChangeMouseButton
			info.value = "RightButton";
			UIDropDownMenu_AddButton(info)
			
			info = UIDropDownMenu_CreateInfo()
			info.text = L.MIDDLE_BUTTON;
			info.func = config.ChangeMouseButton
			info.value = "MiddleButton";
			UIDropDownMenu_AddButton(info)
		end;
		
		
		local showminimap = CreateFrame( "CheckButton", "FlightMapEnhanced_Module_wmc_minimap", config, "InterfaceOptionsCheckButtonTemplate" );
		config.showminimap = showminimap;
		showminimap.id = "minimap";
		showminimap:SetPoint( "TOPLEFT", MapMouseButtonLabel, "BOTTOMLEFT", 0, -16);
		showminimap:SetScript("onClick",config.ChangeState);
		_G[ showminimap:GetName().."Text" ]:SetText( L.WMC_SHOW_ON_MINIMAP );
		_G[ showminimap:GetName().."Text" ]:SetWidth(InterfaceOptionsFramePanelContainer:GetRight() - InterfaceOptionsFramePanelContainer:GetLeft() - 30);
		_G[ showminimap:GetName().."Text" ]:SetJustifyH("LEFT");
		
		local questfly = CreateFrame( "CheckButton", "FlightMapEnhanced_Module_wmc_questfly", config, "InterfaceOptionsCheckButtonTemplate" );
		config.questfly = questfly;
		questfly.id = "questfly";
		questfly:SetPoint( "TOPLEFT", showminimap, "BOTTOMLEFT", 0, -16);
		questfly:SetScript("onClick",config.ChangeState);
		_G[ questfly:GetName().."Text" ]:SetText( L.WMC_QUEST_FLY );
		_G[ questfly:GetName().."Text" ]:SetWidth(InterfaceOptionsFramePanelContainer:GetRight() - InterfaceOptionsFramePanelContainer:GetLeft() - 30);
		_G[ questfly:GetName().."Text" ]:SetJustifyH("LEFT");
		
		--local questflyexplain = config:CreateFontString( nil, "OVERLAY", "GameFontHighlight" );
		--moduleconfig.Modulewmcexplain = Modulewmcexplain;
		--questflyexplain:SetPoint("TOPLEFT", questfly,"TOPLEFT", 0, -16)
		--questflyexplain:SetWidth(InterfaceOptionsFramePanelContainer:GetRight() - InterfaceOptionsFramePanelContainer:GetLeft() - 30);
		--questfly:SetHeight(questflyexplain:GetHeight() + 15);
		--questflyexplain:SetJustifyH("LEFT");
		--questflyexplain:SetText( L.WMC_QUEST_FLY_EXPLAIN);
		
		InterfaceOptions_AddCategory(config);
		
		if not (FlightMapEnhanced_Config.vconf.module.wmc) then
			FlightMapEnhanced_Config.vconf.module.wmc = {};
			config:SetDefaultConfig();
		end
		if(FlightMapEnhanced_Config.vconf.module.wmc.questfly == nil) then
			FlightMapEnhanced_Config.vconf.module.wmc.questfly = true;
		end
		config:InitDropDowns();
		showminimap:SetChecked(FlightMapEnhanced_Config.vconf.module.wmc.minimap);
		questfly:SetChecked(FlightMapEnhanced_Config.vconf.module.wmc.questfly);
		--QuestObjectiveTracker_OnOpenDropDown
		hooksecurefunc("QuestObjectiveTracker_OnOpenDropDown",module.QuestFrameAdd);
		
	end
	
	function config:ChangeState()
		FlightMapEnhanced_Config.vconf.module.wmc[self.id] = self:GetChecked();
	end

	function config:ChangeModifierKey()
		FlightMapEnhanced_Config.vconf.module.wmc.MapModifierKey=self.value;
		UIDropDownMenu_SetSelectedValue(config.MapModifierKey,self.value,self.text);
	end

	function config:ChangeMouseButton()
		FlightMapEnhanced_Config.vconf.module.wmc.MapMouseButton=self.value;
		UIDropDownMenu_SetSelectedValue(config.MapMouseButton,self.value,self.text);
	end
	

	function config:SetDefaultConfig()
		FlightMapEnhanced_Config.vconf.module.wmc = {["MapMouseButton"]="LeftButton",["MapModifierKey"]="Control",["minimap"]=1};
	end
	
	function config:InitDropDowns()
		UIDropDownMenu_Initialize(config.MapModifierKey, config.MapModifierKey.initialize)
		UIDropDownMenu_SetSelectedValue(config.MapModifierKey,FlightMapEnhanced_Config.vconf.module.wmc.MapModifierKey);
		UIDropDownMenu_Initialize(config.MapMouseButton, config.MapMouseButton.initialize)
		UIDropDownMenu_SetSelectedValue(config.MapMouseButton,FlightMapEnhanced_Config.vconf.module.wmc.MapMouseButton);	
	end
	
	module:init();
end

