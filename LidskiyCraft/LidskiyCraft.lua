LidskiyCraft = {};
LidskiyCraft.fully_loaded = false;
LidskiyCraft.default_options = {

	-- main frame position
	frameRef = "CENTER",
	frameX = 0,
	frameY = 0,
	hide = false,

	--custom
	isForwarderActive = false
};

local checkboxes = 0

local settings = {
    {
        settingText = "Officer Trade Forwarder",
        settingKey = "isForwarderEnabled"
    },
    {
        settingText = "Заказы на Пыткакалом (ткань + посох/оффхенд)",
        settingKey = "isCraftsForKal"
    },
    {
        settingText = "Заказы на Есдэдди (кузнечные инструменты)",
        settingKey = "isCraftsForDaddy"
    },
    {
        settingText = "Заказы на Пивнойвлэд (кожа)",
        settingKey = "isCraftsForBeerVlad"
    },
    {
        settingText = "Заказы на Блэтвлэд (кузнечное оружее)",
        settingKey = "isCraftsForBlyatVlad"
    },
}

function LidskiyCraft.OnReady()

	-- set up default options
	_G.LidskiyPrefs = _G.LidskiyPrefs or {};

	for k,v in pairs(LidskiyCraft.default_options) do
		if (not _G.LidskiyPrefs[k]) then
			_G.LidskiyPrefs[k] = v;
		end
	end

	LidskiyCraft.CreateUIFrame();
end

function LidskiyCraft.CreateUIFrame()

	-- create the UI frame
	LidskiyCraft.UIFrame = CreateFrame("Frame",nil,UIParent,"BasicFrameTemplateWithInset");
	LidskiyCraft.UIFrame:SetSize(325,200);
	LidskiyCraft.UIFrame:SetPoint(_G.LidskiyPrefs.frameRef, _G.LidskiyPrefs.frameX, _G.LidskiyPrefs.frameY);
	LidskiyCraft.UIFrame.TitleBg:SetHeight(30);
	LidskiyCraft.UIFrame.title = LidskiyCraft.UIFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	LidskiyCraft.UIFrame.title:SetPoint("CENTER", LidskiyCraft.UIFrame.TitleBg, "CENTER", 0, 3);
	LidskiyCraft.UIFrame.title:SetText("Лидский Крафт");

    LidskiyCraft.UIFrame:EnableMouse(true)
	LidskiyCraft.UIFrame:SetMovable(true)
	LidskiyCraft.UIFrame:RegisterForDrag("LeftButton")

	LidskiyCraft.UIFrame:SetScript("OnDragStart", function(self)
		self:StartMoving()
	end)

	LidskiyCraft.UIFrame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
	end)

	--LidskiyCraft.UIFrame:Hide()

	SLASH_LIDSKIYCRAFT1 = "/lc"
	SlashCmdList["LIDSKIYCRAFT"] = function()
    	if LidskiyCraft.UIFrame:IsShown() then
        	LidskiyCraft.UIFrame:Hide()
    	else
        	LidskiyCraft.UIFrame:Show()
    	end
	end

	table.insert(UISpecialFrames, "Frame")

	-------

	if not LidskiyPrefs.settingsKeys then
   	    LidskiyPrefs.settingsKeys = {}
   	end

    for _, setting in pairs(settings) do
     	CreateCheckbox(setting.settingText, setting.settingKey, setting.settingTooltip)
    end
end

function CreateCheckbox(checkboxText, key, checkboxTooltip)
    local checkbox = CreateFrame("CheckButton", "LidskiyCraftCheckboxID" .. checkboxes, LidskiyCraft.UIFrame, "UICheckButtonTemplate")
    checkbox.Text:SetText(checkboxText)
    checkbox:SetPoint("TOPLEFT", LidskiyCraft.UIFrame, "TOPLEFT", 10, -30 + (checkboxes * -30))

    if LidskiyPrefs.settingsKeys[key] == nil then
        LidskiyPrefs.settingsKeys[key] = false
    end

    checkbox:SetChecked(LidskiyPrefs.settingsKeys[key])

    checkbox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(checkboxTooltip, nil, nil, nil, nil, true)
    end)

    checkbox:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    checkbox:SetScript("OnClick", function(self)
        LidskiyPrefs.settingsKeys[key] = self:GetChecked()
    end)

    checkboxes = checkboxes + 1

    return checkbox
end

function LidskiyCraft.OnSaving()

	if (LidskiyCraft.UIFrame) then
		local point, relativeTo, relativePoint, xOfs, yOfs = LidskiyCraft.UIFrame:GetPoint()
		_G.LidskiyPrefs.frameRef = relativePoint;
		_G.LidskiyPrefs.frameX = xOfs;
		_G.LidskiyPrefs.frameY = yOfs;
	end
end

function LidskiyCraft.OnUpdate()
	if (not LidskiyCraft.fully_loaded) then
		return;
	end

	if (LidskiyPrefs.hide) then 
		return;
	end

	LidskiyCraft.UpdateFrame();
end

function LidskiyCraft.OnEvent(frame, event, ...)

	if (event == 'ADDON_LOADED') then
		local name = ...;
		if name == 'LidskiyCraft' then
			LidskiyCraft.OnReady();
		end
		return;
	end

	if (event == 'PLAYER_LOGIN') then

		LidskiyCraft.fully_loaded = true;
		return;
	end

	if (event == 'PLAYER_LOGOUT') then
		LidskiyCraft.OnSaving();
		return;
	end

	if (event == "CHAT_MSG_CHANNEL") then      
		local text, playerName, _, channelName = ... 

		local player = UnitName("player") 
		local sender = string.gsub(playerName, "%-[^||||]+", "")
		local isInSearch = LidskiyCraft.IsInSearch(text)

		if (LidskiyPrefs.settingsKeys["isForwarderEnabled"]) then
			LidskiyCraft.TryToForwardMessage(sender, text)
		end
        
        if sender ~= player and isInSearch == true then
            
            local isCloth = LidskiyCraft.IsCloth(text)
            local isStaff = LidskiyCraft.IsStaff(text)
            local isInstrument = LidskiyCraft.IsInstrument(text)
            local isLeather = LidskiyCraft.IsLeather(text)
            local isWeapons = LidskiyCraft.IsWeapons(text)

            local Is590 = LidskiyCraft.Is590(text)
            local Is606 = LidskiyCraft.Is606(text)
			local Is619 = LidskiyCraft.Is619(text)
			local Is636 = LidskiyCraft.Is636(text)

			if (LidskiyPrefs.settingsKeys["isCraftsForKal"]) then

            if (isCloth) then
            	if (Is636) then
                	LidskiyCraft.SendCraftMessage("6k", sender, "Пыткакалом")
                else
                	LidskiyCraft.SendCraftMessage("4.5k", sender, "Пыткакалом")
            	end
        	end

        	if (isStaff) then
            	if (Is636) then
                	LidskiyCraft.SendCraftMessage("6k", sender, "Пыткакалом")
                else
                	LidskiyCraft.SendCraftMessage("4.5k", sender, "Пыткакалом")
            	end
        	end

			end

			if (LidskiyPrefs.settingsKeys["isCraftsForDaddy"]) then

				if (isInstrument) then
                	LidskiyCraft.SendCraftMessage("4k", sender, "Есдэдди")
            	end	

			end

			if (LidskiyPrefs.settingsKeys["isCraftsForBeerVlad"]) then

				if (isLeather) then
                	LidskiyCraft.SendVladCraftMessage("5k", sender, "Пивнойвлэд")
            	end	

			end

			if (LidskiyPrefs.settingsKeys["isCraftsForBlyatVlad"]) then

				if (isWeapons) then
                	LidskiyCraft.SendVladCraftMessageFree(sender, "Блэтвлэд")
            	end	

			end

        end
    end
end

function LidskiyCraft.SetFontSize(string, size)

	local Font, Height, Flags = string:GetFont()
	if (not (Height == size)) then
		string:SetFont(Font, size, Flags)
	end
end

function LidskiyCraft.OnDragStart(frame)
	LidskiyCraft.UIFrame:StartMoving();
	LidskiyCraft.UIFrame.isMoving = true;
	GameTooltip:Hide()
end

function LidskiyCraft.OnDragStop(frame)
	LidskiyCraft.UIFrame:StopMovingOrSizing();
	LidskiyCraft.UIFrame.isMoving = false;
end

function LidskiyCraft.OnClick(self, aButton)
	if (aButton == "RightButton") then
		print("show menu here!");
	end
end

function LidskiyCraft.UpdateFrame()

	-- update the main frame state here
	-- LidskiyCraft.Label:SetText(string.format("%d", GetTime()));
end

-------------------------------------------------------------------

function LidskiyCraft.IsCloth(message)    
    
    local isCloth = string.find(message, "Освященн") ~= nil
    or string.find(message, "плащ") ~= nil
    or string.find(message, "Плащ") ~= nil
    or string.find(message, "ПЛАЩ") ~= nil
    and string.find(message, "шаги") == nil        
        
    local isPvpCloth = string.find(message, "Ткане") ~= nil  
    and string.find(message, "бойца") ~= nil
        
    local isUncrafted = string.find(message, "мундир") ~= nil
    or string.find(message, "одеяние") ~= nil
    or string.find(message, "поножи") ~= nil
    
    return (isCloth or isPvpCloth) and isUncrafted == false
    
end

function LidskiyCraft.IsStaff(message)    
    
	local isStaff = string.find(message, "Аккуратная трость бродяги") ~= nil
    or string.find(message, "Ограничивающий жезл бродяги") ~= nil
    or string.find(message, "Факел бродяги") ~= nil
    or string.find(message, "осох") ~= nil
    or string.find(message, "акел") ~= nil
        
    local isPvpStaff = string.find(message, "Посох алгарийского бойца") ~= nil
    or string.find(message, "Столп алгарийского бойца") ~= nil
    or string.find(message, "Фонарь алгарийского бойца") ~= nil

    return (isStaff or isPvpStaff)
end

function LidskiyCraft.IsInstrument(message)    
    
    local isInstrument = string.find(message, "Кирка ремесленника") ~= nil
    or string.find(message, "Кузнечный молот ремесленника") ~= nil
    or string.find(message, "Нож ремесленника для снятия шкур") ~= nil

    return isInstrument
    
end 

function LidskiyCraft.IsLeather(message)    
    
    local isLeather = string.find(message, "Боевой пояс с руническим клеймом") ~= nil
    or string.find(message, "Бриджи с руническим клеймом") ~= nil
    or string.find(message, "Захваты с руническим клеймом") ~= nil
    or string.find(message, "Капюшон с руническим клеймом") ~= nil
    or string.find(message, "Мундир с руническим клеймом") ~= nil
    or string.find(message, "Поручи с руническим клеймом") ~= nil 
    or string.find(message, "Тяжелые ботинки с руническим клеймом") ~= nil 
    or string.find(message, "Кожаная маска алгарийского бойца") ~= nil 
    or string.find(message, "Кожаные брюки алгарийского бойца") ~= nil 
    or string.find(message, "Кожаные напульсники алгарийского бойца") ~= nil 
    or string.find(message, "Кожаные перчатки алгарийского бойца") ~= nil 
    or string.find(message, "Кожаные сапоги алгарийского бойца") ~= nil 
    or string.find(message, "Кожаный нагрудник алгарийского бойца") ~= nil 
    or string.find(message, "Кожаный пояс алгарийского бойца") ~= nil 

    return isLeather 

end 

function LidskiyCraft.IsWeapons(message)    
    
    local isWeapons = string.find(message, "Выкованная навеки булава") ~= nil
    or string.find(message, "Выкованный навеки боевой клинок") ~= nil
    or string.find(message, "Выкованный навеки большой топор") ~= nil
    or string.find(message, "Выкованный навеки длинный меч") ~= nil
    or string.find(message, "Выкованный навеки кинжал") ~= nil
    or string.find(message, "Выкованный навеки пронзатель") ~= nil 
    or string.find(message, "Заряженная алебарда") ~= nil 
    or string.find(message, "Заряженный заклинатель") ~= nil 
    or string.find(message, "Заряженный клеймор") ~= nil 
    or string.find(message, "Заряженный колдовской меч") ~= nil 
    or string.find(message, "Заряженный разбиватель шлемов") ~= nil 
    or string.find(message, "Заряженный рассекатель") ~= nil 
    or string.find(message, "Заряженный рунический топор") ~= nil 

    return isWeapons 
       
end 

function LidskiyCraft.Is636(message) 	
    return string.find(message, "636") ~= nil    
end        

function LidskiyCraft.Is619(message) 	
    return string.find(message, "619") ~= nil    
end  

function LidskiyCraft.Is606(message) 	
    return string.find(message, "619") ~= nil    
end 

function LidskiyCraft.Is590(message) 	
    return string.find(message, "590") ~= nil    
end

function LidskiyCraft.IsInSearch(message)    
    
    local isInSearch = string.find(message, "ищ") ~= nil
    or string.find(message, "Ищ") ~= nil
    or string.find(message, "ИЩ") ~= nil
    or string.find(message, "лф") ~= nil
    or string.find(message, "lf") ~= nil
    or string.find(message, "LF") ~= nil
    or string.find(message, "уплю") ~= nil
    or string.find(message, "КУПЛЮ") ~= nil
    or string.find(message, "зака") ~= nil
    or string.find(message, "ЗАКА") ~= nil
    or string.find(message, "Сделает") ~= nil
    or string.find(message, "сделает") ~= nil
    or string.find(message, "СДЕЛАЕТ") ~= nil
    or string.find(message, "Сделать") ~= nil
    or string.find(message, "сделать") ~= nil
    or string.find(message, "СДЕЛАТЬ") ~= nil
    or string.find(message, "нид") ~= nil
    or string.find(message, "НИД") ~= nil  
    or string.find(message, "КТО") ~= nil  
    or string.find(message, "кто") ~= nil  
    or string.find(message, "Кто") ~= nil
    or string.find(message, "Скрафтит") ~= nil  
    or string.find(message, "скрафтит") ~= nil   
	or string.find(message, "СКРАФТИТ") ~= nil  

    return isInSearch
    
end

function LidskiyCraft.IsMessageShallBeForwarded(message)    
    
    local isSpam = string.find(message, "нсурек") ~= nil 
    or string.find(message, "ворец") ~= nil
    or string.find(message, "рокач") ~= nil
    or string.find(message, "влинг") ~= nil
    or string.find(message, "оденем") ~= nil
        
    local isCrafter = (string.find(message, "Портняжное дело") ~= nil
    or string.find(message, "Начертание") ~= nil
    or string.find(message, "Кожевничество") ~= nil
    or string.find(message, "Кузнечное дело") ~= nil
    or string.find(message, "Инженерное дело") ~= nil
    or string.find(message, "Ювелирное дело") ~= nil
    or string.find(message, "Наложение чар") ~= nil)
    and string.find(message, "Каз Алгара") == nil      
        
    local isOther = string.find(message, "ключ") ~= nil
    or string.find(message, "кей") ~= nil
    or string.find(message, "кх") ~= nil 
    or string.find(message, "КХ") ~= nil 
    or string.find(message, "ильди") ~= nil
    or string.find(message, "статик") ~= nil        
    or string.find(message, "афк") ~= nil
    or string.find(message, "АФК") ~= nil
    or string.find(message, "еленк") ~= nil
    or string.find(message, "-70") ~= nil
    or string.find(message, "-80") ~= nil
    or string.find(message, "Костюм") ~= nil
    or string.find(message, "герб") ~= nil
    or string.find(message, "Герб") ~= nil
    or string.find(message, "ГЕРБ") ~= nil
    or string.find(message, "рактат") ~= nil
    or string.find(message, "хил") ~= nil
    or string.find(message, "дд") ~= nil
    or string.find(message, "танк") ~= nil  
    or string.find(message, "изначальн") ~= nil 
    or string.find(message, "освоение") ~= nil        
    or string.find(message, "TWW") ~= nil
    or string.find(message, "tww") ~= nil
    or string.find(message, "гер") ~= nil  
    or string.find(message, "родам") ~= nil
    or string.find(message, "ПРОДАМ") ~= nil     
    or string.find(message, "татик") ~= nil
	----
    or string.find(message, "елаю") ~= nil
    or string.find(message, "ДЕЛАЮ") ~= nil
    or string.find(message, "рафчу") ~= nil
    or string.find(message, "КРАФЧУ") ~= nil
    or string.find(message, "всех") ~= nil
    or string.find(message, "Всех") ~= nil
    or string.find(message, "ВСЕ") ~= nil
    or string.find(message, "олец") ~= nil
    or string.find(message, "ружее") ~= nil
    or string.find(message, "619/636") ~= nil
    or string.find(message, "нструменто") ~= nil    
    or string.find(message, "некли") ~= nil       
    
    return (not isSpam and not isCrafter and not isOther)
    
end

function LidskiyCraft.SendCraftMessage(price, target, character)  
    SendChatMessage("ку! " .. price .. ". t3 реги, заказ на " .. character, "WHISPER", nil, target)
    PlaySoundFile("Interface\\AddOns\\LidskiyCraft\\Sounds\\message-notification.mp3", "master")
end 

function LidskiyCraft.SendCraftMessageFree(target, character)  
    SendChatMessage("ку! скрафчу за вознаграждение на твое усмотрение :) заказ на " .. character, "WHISPER", nil, target)
    PlaySoundFile("Interface\\AddOns\\LidskiyCraft\\Sounds\\message-notification.mp3", "master")
end

function LidskiyCraft.SendVladCraftMessage(price, target, character)  
    SendChatMessage("Привет :) Крафчу за " .. price .. ". t3 реги, т3 реги для т5. Заказ на " .. character, "WHISPER", nil, target)
    PlaySoundFile("Interface\\AddOns\\LidskiyCraft\\Sounds\\message-notification.mp3", "master")
end 

function LidskiyCraft.SendVladCraftMessageFree(target, character)  
    SendChatMessage("Привет :) Крафчу за сколько не жалко, т3 реги для т5. Заказ на " .. character, "WHISPER", nil, target)
    PlaySoundFile("Interface\\AddOns\\LidskiyCraft\\Sounds\\message-notification.mp3", "master")
end  

function LidskiyCraft.TryToForwardMessage(sender, message)
	if (LidskiyCraft.IsMessageShallBeForwarded(message)) then   
    	SendChatMessage(sender .. " -> " .. message , "OFFICER")
    end
end 


-------------------------------------------------------------------

LidskiyCraft.EventFrame = CreateFrame("Frame");
LidskiyCraft.EventFrame:Show();
LidskiyCraft.EventFrame:SetScript("OnEvent", LidskiyCraft.OnEvent);
LidskiyCraft.EventFrame:SetScript("OnUpdate", LidskiyCraft.OnUpdate);
LidskiyCraft.EventFrame:RegisterEvent("ADDON_LOADED");
LidskiyCraft.EventFrame:RegisterEvent("PLAYER_LOGIN");
LidskiyCraft.EventFrame:RegisterEvent("PLAYER_LOGOUT");
LidskiyCraft.EventFrame:RegisterEvent("CHAT_MSG_CHANNEL");