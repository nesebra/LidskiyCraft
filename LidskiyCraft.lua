LidskiyCraft = {};
LidskiyCraft.fully_loaded = false;
LidskiyCraft.default_options = {

	-- main frame position
	frameRef = "CENTER",
	frameX = 0,
	frameY = 0,
	hide = false,
};

local addonName = "LidskiyCraft"
local LibDataBroker = LibStub("LibDataBroker-1.1")
local LibDBIcon = LibStub("LibDBIcon-1.0")

local checkboxes = 0

local prefix = "ldskcr"

local settings = {
    {
        settingText = "Forward to Officer",
        settingKey = "isForwarderEnabled"
    },
    {
        settingText = "Listen Forwarder",
        settingKey = "isListenForwarder"
    },
    {
        settingText = "Пыткакалом (ткань + посох/оффхенд)",
        settingKey = "isCraftsForKal"
    },
    {
        settingText = "Пыткакалом (трактаты)",
        settingKey = "isTractatCraftsForKal"
    },
    {
        settingText = "Есдэдди (инструменты)",
        settingKey = "isInstrumentsCraftsForDaddy"
    },
    {
        settingText = "Есдэдди (бижа)",
        settingKey = "isRingsCraftsForDaddy"
    },
    {
        settingText = "Пивнойвлэд (кожа)",
        settingKey = "isCraftsForBeerVlad"
    },
    {
        settingText = "Блэтвлэд (кузнечное + инженерное)",
        settingKey = "isCraftsForBlyatVlad"
    },
    {
        settingText = "Сообщить, что перезайду",
        settingKey = "isNeedToRelogin"
    }
}

function LidskiyCraft.OnReady()

	_G.LidskiyPrefs = _G.LidskiyPrefs or {};
    _G.LidskiyPrefs.isShown = _G.LidskiyPrefs.isShown or false;

	for k,v in pairs(LidskiyCraft.default_options) do
		if (not _G.LidskiyPrefs[k]) then
			_G.LidskiyPrefs[k] = v;
		end
	end

	LidskiyCraft.CreateUIFrame();

    if (not _G.LidskiyPrefs.isShown) then
        LidskiyCraft.UIFrame:Hide()
    end

    local WKLDB = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject(addonName, {
    type = "launcher",
    icon = "Interface/AddOns/LidskiyCraft/Images/icon.blp",
    OnClick = function(clickedframe, button)
        LidskiyCraft.SwitchView();
    end,
    })

    _G.LidskiyPrefs.minimap = _G.LidskiyPrefs.minimap or { hide = false }  

    LibDBIcon:Register(addonName, WKLDB, _G.LidskiyPrefs.minimap)
    LibDBIcon:AddButtonToCompartment(addonName)
end

function LidskiyCraft.SwitchView()
        if LidskiyCraft.UIFrame:IsShown() then
            LidskiyCraft.UIFrame:Hide()
            _G.LidskiyPrefs.isShown = false; 
        else
            LidskiyCraft.UIFrame:Show()
            _G.LidskiyPrefs.isShown = true;  
        end
end

function LidskiyCraft.CreateUIFrame()

	-- create the UI frame
	LidskiyCraft.UIFrame = CreateFrame("Frame",nil,UIParent,"BasicFrameTemplateWithInset");
	LidskiyCraft.UIFrame:SetSize(270,310);
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
    	LidskiyCraft.SwitchView()
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
		
		local isForwarderEnabled = LidskiyPrefs.settingsKeys["isForwarderEnabled"]
		local isListenForwarder = LidskiyPrefs.settingsKeys["isListenForwarder"]
		local target = string.gsub(playerName, "%-[^||||]+", "")		

		if (isForwarderEnabled == true) then
			LidskiyCraft.ForwardMessage(target, text)			
		end

		if (isListenForwarder == false) then
			if (LidskiyCraft.IsMessageUsefull(text)) then
				LidskiyCraft.AnalyzeMessage(target, text)
			end						
		end				
    end

	if (event == 'CHAT_MSG_ADDON') then
		local prefix, text, channel, sender, target = ... 

		local isForwarderEnabled = LidskiyPrefs.settingsKeys["isForwarderEnabled"]
		local isListenForwarder = LidskiyPrefs.settingsKeys["isListenForwarder"]

		if (isListenForwarder == true) then

			local targetIndex = string.find(text, '->')

			if (targetIndex ~= nil) then
				local target = string.sub(text, 1, targetIndex - 2)
				local targetText = string.sub(text, targetIndex - 2, string.len(text))				
				LidskiyCraft.AnalyzeMessage(target, targetText)
			end

		end			      
	end

end


function LidskiyCraft.ForwardMessage(target, text)
	
	if (LidskiyCraft.IsMessageUsefull(text)) then
		SendChatMessage(target .. " -> " .. text, "OFFICER")
		C_ChatInfo.SendAddonMessage(prefix, target .. " -> " .. text, "OFFICER")
    end

end 

function LidskiyCraft.AnalyzeMessage(target, text)

        local isCloth = LidskiyCraft.IsCloth(text)
        local isInstrumentCloth = LidskiyCraft.IsInstrumentCloth(text)
        local isStaff = LidskiyCraft.IsStaff(text)
        local isInstrument = LidskiyCraft.IsInstrument(text)
        local isLeather = LidskiyCraft.IsLeather(text)
        local isWeapons = LidskiyCraft.IsWeapons(text)
        local isEngineering = LidskiyCraft.IsEngineering(text)
        local isJewerly = LidskiyCraft.IsJewerly(text)
        local isPvPJewerly = LidskiyCraft.IsPvPJewerly(text)
        local isTraktat = LidskiyCraft.IsTraktat(text)

        local Is590 = LidskiyCraft.Is590(text)
        local Is606 = LidskiyCraft.Is606(text)
		local Is619 = LidskiyCraft.Is619(text)
		local Is636 = LidskiyCraft.Is636(text)

		if (LidskiyPrefs.settingsKeys["isCraftsForKal"]) then

            if (isCloth) then
            	LidskiyCraft.SendCraftMessage("3k", target, "Пыткакалом", text)
        	end

        	if (isStaff) then
            	LidskiyCraft.SendCraftMessage("1к", target, "Пыткакалом", text)
        	end

            if (isInstrumentCloth) then               
                LidskiyCraft.SendCraftMessage("2k", target, "Пыткакалом", text)
            end

		end

		if (LidskiyPrefs.settingsKeys["isTractatCraftsForKal"]) then

			if (isTraktat) then
                LidskiyCraft.SendTraktatCraftMessage("500g", target, "Пыткакалом", text)
            end        	
				
		end

		if (LidskiyPrefs.settingsKeys["isInstrumentsCraftsForDaddy"]) then

			if (isInstrument) then
                LidskiyCraft.SendCraftMessage("2k", target, "Есдэдди", text)
            end

		end

		if (LidskiyPrefs.settingsKeys["isRingsCraftsForDaddy"]) then

			if (isJewerly) then
            	LidskiyCraft.SendCraftMessage("2k", target, "Есдэдди", text)
        	end

            if (isPvPJewerly) then
            	LidskiyCraft.SendCraftMessage("1k", target, "Есдэдди", text)
            end	
        end            

		if (LidskiyPrefs.settingsKeys["isCraftsForBeerVlad"]) then

			if (isLeather) then
            	LidskiyCraft.SendVladCraftMessage("1к", target, "Пивнойвлэд", text)
            end	

		end

		if (LidskiyPrefs.settingsKeys["isCraftsForBlyatVlad"]) then

			if (isWeapons) then
				if (Is636) then
                	LidskiyCraft.SendVladCraftMessage("1к", target, "Блэтвлэд", text)
                else
                	LidskiyCraft.SendVladCraftMessage("1к", target, "Блэтвлэд", text)
            	end            	
            end	

            if (isEngineering) then
            	LidskiyCraft.SendVladCraftMessage("1к", target, "Блэтвлэд", text)
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

end

-------------------------------------------------------------------

function LidskiyCraft.IsCloth(message)    
    
    local text = string.lower(message)

    local isCloth = string.find(text, "освященн") ~= nil
    or string.find(text, "плащ") ~= nil
    and string.find(text, "шаги") == nil        
        
    local isPvpCloth = string.find(text, "ткане") ~= nil  
    and string.find(text, "бойца") ~= nil
        
    local isUncrafted = string.find(text, "мундир") ~= nil
    or string.find(text, "одеяние") ~= nil
    or string.find(text, "поножи") ~= nil
    
    return (isCloth or isPvpCloth) and isUncrafted == false
    
end

function LidskiyCraft.IsInstrumentCloth(message)    
    
    local text = string.lower(message)

    local isInstrumentCloth = string.find(text, "шляпа садовника") ~= nil
    or string.find(text, "рыбацкая шляпа") ~= nil
    or string.find(text, "шляпа зачаровывателя") ~= nil
    
    return (isInstrumentCloth)
    
end

function LidskiyCraft.IsStaff(message)    
    
    local text = string.lower(message)

	local isStaff = string.find(text, "аккуратная трость бродяги") ~= nil
    or string.find(text, "ограничивающий жезл бродяги") ~= nil
    or string.find(text, "факел бродяги") ~= nil
    or string.find(text, "посох") ~= nil
    or string.find(text, "факел") ~= nil
    or string.find(text, "оффхенд") ~= nil
        
    local isPvpStaff = string.find(text, "посох алгарийского бойца") ~= nil
    or string.find(text, "столп алгарийского бойца") ~= nil
    or string.find(text, "фонарь алгарийского бойца") ~= nil

    return (isStaff or isPvpStaff)
end

function LidskiyCraft.IsInstrument(message)    

	local text = string.lower(message)
    
    local isInstrument = string.find(text, "кирка ремесленника") ~= nil
    or string.find(text, "серп ремесленника") ~= nil
    or string.find(text, "кузнечный молот ремесленника") ~= nil
    or string.find(text, "нож ремесленника для снятия шкур") ~= nil
	or string.find(text, "набор кузнеца") ~= nil
	or string.find(text, "нож кожевника") ~= nil
    or string.find(text, "кристалл зачарователя") ~= nil
    or string.find(text, "набор игл ремесленника") ~= nil
    and string.find(text, "бойца") == nil

    return (isInstrument)
    
end 

function LidskiyCraft.IsTraktat(message)    
    
    local text = string.lower(message)

    local isTraktat = string.find(text, "трактат") ~= nil

    return isTraktat
    
end 

function LidskiyCraft.IsJewerly(message)    
    
    local text = string.lower(message)

    local isJewerly = string.find(text, "кольцо мастерства земельников") ~= nil
    or string.find(text, "амулет мастерства земельников") ~= nil
    or string.find(text, "медальон с растрескавшимися самоцветами") ~= nil
    or string.find(text, "узы связи") ~= nil

    return isJewerly
    
end

function LidskiyCraft.IsPvPJewerly(message)    
    
    local text = string.lower(message)

    local isPvPJewerly = string.find(text, "печатка алгарийского бойца") ~= nil
    or string.find(text, "амулет алгарийского бойца") ~= nil
    or string.find(text, "пвп колец") ~= nil
    or string.find(text, "пвп кольца") ~= nil

    return isPvPJewerly
    
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
    or string.find(message, "Заряженные рукавицы мастера-утилизатора") ~= nil 
    or string.find(message, "Комбинезон аратийского кожевника") ~= nil 
    or string.find(message, "Рюкзак каменного травника") ~= nil 
    or string.find(message, "Фартук земельника") ~= nil 
    or string.find(message, "Шляпа нерубского алхимика") ~= nil 
    or string.find(message, "Рюкзак глубинного следопыта") ~= nil 
    or string.find(message, "Шапка глубинного следопыта") ~= nil 
    or string.find(message, "Рунический жезл из нуль") ~= nil 
    or string.find(message, "Скипетр сияющей магии") ~= nil 
    or string.find(message, "Гравированные символами тяжелые наручи") ~= nil 
    or string.find(message, "Кольчужные манжеты алгарийского бойца") ~= nil 
    or string.find(message, "Оплечье с руническим клеймом") ~= nil 
    or string.find(message, "Гравированная символами обвязка") ~= nil 
    or string.find(message, "Гравированные символами высокие ботинки") ~= nil 
    or string.find(message, "Гравированные символами рукавицы") ~= nil 
    or string.find(message, "Кольчужные ботфорты алгарийского бойца") ~= nil 
    or string.find(message, "Кольчужные рукавицы алгарийского бойца") ~= nil 
    or string.find(message, "Кольчужный ремень алгарийского бойца") ~= nil 
    or string.find(message, "Гравированные символами шоссы") ~= nil 
    or string.find(message, "Гравированная символами полумаска") ~= nil 
    or string.find(message, "Кольчужный клобук алгарийского бойца") ~= nil 
    or string.find(message, "Кольчужные поножи алгарийского бойца") ~= nil 
    or string.find(message, "Гравированные символами эполеты") ~= nil 
    or string.find(message, "Кольчужные эполеты алгарийского бойца") ~= nil 
    or string.find(message, "Гравированная символами кираса") ~= nil 
    or string.find(message, "Кольчужный доспех алгарийского бойца") ~= nil
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
    or string.find(message, "Выкованный навеки защитник") ~= nil 
    or string.find(message, "Бастион Беледар") ~= nil 
    or string.find(message, "Заряженный заклинатель") ~= nil 
    or string.find(message, "Вытягивающий стилет") ~= nil 
    or string.find(message, "Выкованные навеки тяжелые наручи") ~= nil 
    or string.find(message, "Выкованный навеки шлем") ~= nil 
    or string.find(message, "Большой меч алгарийского бойца") ~= nil 
    or string.find(message, "Вертел алгарийского бойца") ~= nil 
    or string.find(message, "Кинжал алгарийского бойца") ~= nil 
    or string.find(message, "Кирка алгарийского бойца") ~= nil 
    or string.find(message, "Латные нарукавники алгарийского бойца") ~= nil 
    or string.find(message, "Меч алгарийского бойца") ~= nil 
    or string.find(message, "Скипетр алгарийского бойца") ~= nil 
    or string.find(message, "Топор алгарийского бойца") ~= nil 
    or string.find(message, "Щит алгарийского бойца") ~= nil 
    or string.find(message, "Латный шлем алгарийского бойца") ~= nil 
    or string.find(message, "Выкованные навеки башмаки") ~= nil 
    or string.find(message, "Освященные шаги") ~= nil 
    or string.find(message, "Латные башмаки алгарийского бойца") ~= nil 
    or string.find(message, "Выкованный навеки большой пояс") ~= nil 
    or string.find(message, "Латный воинский пояс алгарийского бойца") ~= nil 
    or string.find(message, "Выкованные навеки рукавицы") ~= nil 
    or string.find(message, "Латные рукавицы алгарийского бойца") ~= nil 
    or string.find(message, "Выкованное навеки наплечье") ~= nil 
    or string.find(message, "Латные наголенники алгарийского бойца") ~= nil 
    or string.find(message, "Латное наплечье алгарийского бойца") ~= nil 
    or string.find(message, "Выкованные навеки ножные латы") ~= nil 
    or string.find(message, "Кирка ремесленника") ~= nil 
    or string.find(message, "Набор кузнеца") ~= nil 
    or string.find(message, "Нож кожевника") ~= nil 
    or string.find(message, "Нож ремесленника") ~= nil 
    or string.find(message, "Серп ремесленника") ~= nil 
    return isWeapons 
       
end

function LidskiyCraft.IsEngineering(message)    
    
    local isEngineering = string.find(message, "ПИФ") ~= nil
    or string.find(message, "Взрывные наручи") ~= nil
    or string.find(message, "Дышащие тяжелые наручи") ~= nil
    or string.find(message, "Жужжащие напульсники") ~= nil
    or string.find(message, "Лязгающие манжеты") ~= nil 
    or string.find(message, "Ружье алгарийского бойца") ~= nil 
    or string.find(message, "Тканевые наручи алгарийского бойца") ~= nil 
    or string.find(message, "Кожаные наручи алгарийского бойца") ~= nil 
    or string.find(message, "Латные наручи алгарийского бойца") ~= nil 
    or string.find(message, "Кольчужные наручи алгарийского бойца") ~= nil 
    or string.find(message, "Акиритовая каска шахтера") ~= nil
    or string.find(message, "Акиритовое сокровище шахтера") ~= nil
    or string.find(message, "Акиритовые зажимы резчика") ~= nil
    or string.find(message, "Акиритовый друг рыболова") ~= nil
    or string.find(message, "Акиритовый проектор мозговых волн") ~= nil
    or string.find(message, "Заряженный акиритом самофланж") ~= nil
    or string.find(message, "Пружинные портновские ножницы") ~= nil
    or string.find(message, "Заряженный усилитель мышления") ~= nil
    or string.find(message, "Опасный ингибитор отвлечения") ~= nil
    or string.find(message, "Перегруженный генератор идей") ~= nil
    or string.find(message, "Ускоритель мыслительного процесса") ~= nil
    or string.find(message, "Кожаные очки алгарийского бойца") ~= nil
    or string.find(message, "Кольчужные очки алгарийского бойца") ~= nil
    or string.find(message, "Латные очки алгарийского бойца") ~= nil
    or string.find(message, "Тканевые очки алгарийского бойца") ~= nil

    return isEngineering 
       
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

function LidskiyCraft.IsMessageUsefull(message)

	local text = string.lower(message)
    
    local isInSearch = string.find(text, "ищ") ~= nil
    or string.find(text, "лф") ~= nil
    or string.find(text, "lf") ~= nil
    or string.find(text, "куплю") ~= nil
    or string.find(text, "зака") ~= nil
    or string.find(text, "сделает") ~= nil
    or string.find(text, "сделать") ~= nil
    or string.find(text, "нид") ~= nil
    or string.find(text, "скрафтит") ~= nil   
	or string.find(text, "каз алгара") ~= nil   

    local isSpam = string.find(text, "ансурек") ~= nil 
    or string.find(text, "дворец") ~= nil
    or string.find(text, "прокачк") ~= nil
    or string.find(text, "лвлинг") ~= nil
    or string.find(text, "оденем") ~= nil
        
    local isCrafter = (string.find(text, "портняжное дело") ~= nil
    or string.find(text, "начертание") ~= nil
    or string.find(text, "кожевничество") ~= nil
    or string.find(text, "кузнечное дело") ~= nil
    or string.find(text, "инженерное дело") ~= nil
    or string.find(text, "ювелирное дело") ~= nil
    or string.find(text, "наложение чар") ~= nil)

    or string.find(text, "делаю") ~= nil
    or string.find(text, "крафчу") ~= nil
    or string.find(text, "всех") ~= nil
    or string.find(text, "колец") ~= nil
    or string.find(text, "оружее") ~= nil
    or string.find(text, "инструментов") ~= nil  
        
    local isOther = string.find(text, "ключ") ~= nil
    or string.find(text, "кей") ~= nil
    or string.find(text, "кх") ~= nil 
    or string.find(text, "гильди") ~= nil
    or string.find(text, "статик") ~= nil        
    or string.find(text, "афк") ~= nil
    or string.find(text, "зеленк") ~= nil
    or string.find(text, "-70") ~= nil
    or string.find(text, "-80") ~= nil
    or string.find(text, "костюм") ~= nil
    or string.find(text, "герб") ~= nil
    or string.find(text, "хил") ~= nil
    or string.find(text, "дд") ~= nil
    or string.find(text, "танк") ~= nil  
    or string.find(text, "изначальн") ~= nil 
    or string.find(text, "освоение") ~= nil        
    or string.find(text, "tww") ~= nil
    or string.find(text, "гер") ~= nil  
    or string.find(text, "продам") ~= nil
	----      
    
    return (isInSearch and not isSpam and not isCrafter and not isOther)    
end

function LidskiyCraft.SendCraftMessage(price, target, character, targetText) 
    local text = "ку! " .. price .. ", ник: " .. character
    LidskiyCraft.SendMessage(target, text, targetText)

    local player = UnitName("player")

    if (player ~= character and LidskiyPrefs.settingsKeys["isNeedToRelogin"]) then
        LidskiyCraft.SendReloginMessage(target)
    end

end 

function LidskiyCraft.SendTraktatCraftMessage(price, target, character, targetText)
    local text = "ку! крафчу все тракты по ".. price.. " за штуку (25% перепроизводства, можно получить несколько трактатов), заказ на " .. character
    LidskiyCraft.SendMessage(target, text, targetText)
end

function LidskiyCraft.SendVladCraftMessage(price, target, character, targetText)
    local text = "Привет :) Крафчу за " .. price .. ". т3 реги для т5. Заказ на " .. character
    LidskiyCraft.SendMessage(target, text, targetText)
end

function LidskiyCraft.SendReloginMessage(target)
    local text = "если разместишь заказ, то маякни, я перезайду"

    C_Timer.After(3, function()
    SendChatMessage(text, "WHISPER", nil, target)
    end) 
end  

function LidskiyCraft.SendMessage(target, text, targetText)
	C_Timer.After(1, function()
	print(target .. ": " .. targetText)
	SendChatMessage(text, "WHISPER", nil, target)
    PlaySoundFile("Interface\\AddOns\\LidskiyCraft\\Sounds\\message-notification.mp3", "master")
	end)    
end

local waitTable = {}
local waitFrame = nil

function LidskiyCraft.RunWithDelay(delay, func, ...)
  if(type(delay) ~= "number" or type(func) ~= "function") then
    return false
  end
  if not waitFrame then
    waitFrame = CreateFrame("Frame", nil, UIParent)
    waitFrame:SetScript("OnUpdate", function (self, elapse)
      for i = 1, #waitTable do
        local waitRecord = tremove(waitTable, i)
        local d = tremove(waitRecord, 1)
        local f = tremove(waitRecord, 1)
        local p = tremove(waitRecord, 1)
        if d > elapse then
          tinsert(waitTable, i, {d - elapse, f, p})
          i = i + 1
        else
          count = count - 1
          f(unpack(p))
        end
      end
    end)
  end
  tinsert(waitTable, {delay, func, {...}})
  return true
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
LidskiyCraft.EventFrame:RegisterEvent("CHAT_MSG_ADDON");
C_ChatInfo.RegisterAddonMessagePrefix(prefix)
