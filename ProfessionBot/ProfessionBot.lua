SLASH_PROFESSIONBOT1 = "/prof"
SlashCmdList["PROFESSIONBOT"] = function(msg)
	if msg == "help" then
		showHelp()
		return
	end

	local craftName, craftRank, _ = GetCraftDisplaySkillLine()
	local tsName, tsRank, _ = GetTradeSkillLine()
	if(craftRank > 0) then
		local text = ''
		local text2 = ''
		local text3 = ''
		local app = ''
		local recipeCount = 0
		for i = 1,GetNumCrafts() do
			local name, _, type, _, _, _, _ = GetCraftInfo(i)
			if (name and type ~= "header") then
				app = '\n' .. name .. "#" .. getItemId("craft", i)
				if i < 50 then 
					text = text .. app
				elseif i < 100 then
					text2 = text2 .. app
				else
					text3 = text3 .. app
				end
				recipeCount = recipeCount + 1
			end
		end
		openExporterWindow(craftName, craftRank, text, text2, text3, recipeCount)
	elseif(tsRank > 0) then
		local text = ''
		local text2 = ''
		local text3 = ''
		local app = ''
		local recipeCount = 0
		for i = 1,GetNumTradeSkills() do
			local name, type, _, _, _, _ = GetTradeSkillInfo(i)
			if (name and type ~= "header") then
				app = '\n' .. name .. "#" .. getItemId("trade", i)
				if i < 50 then 
					text = text .. app
				elseif i < 100 then
					text2 = text2 .. app
				else
					text3 = text3 .. app
				end
				recipeCount = recipeCount + 1
			end
		end
		openExporterWindow(tsName, tsRank, text, text2, text3, recipeCount)
	end
end

function showHelp()
	print("Profession Bot - Help")
	print("Type '/prof help' to show this message")
	print("Open a tradeskill window and type /prof to open the exporter")
end

function openExporterWindow(tradeskillName, rank, text, text2, text3, recipeCount)
	if not ProfessionBotExporterWindow then
		createExporterWindow()
	end
	local playerName = UnitName("player")
	
	ProfessionBotExporterWindow.title:SetText(tradeskillName .. " skill " .. rank .. " - " .. recipeCount .. " recipies - Press CTRL-C to copy.")
	local importString = "!profession import " .. encode64(playerName .. "|" .. tradeskillName .. "|" .. text )
	local editText = "\n\nCrafter: " .. playerName .. "\n"
	editText = editText .. "\nTradeskill: " .. tradeskillName .. "\n"
	editText = editText .. "\n"

	local hlLen = string.len(editText)
	editText =  editText .. importString

	local editText2 = "!profession import " .. encode64(playerName .. "|" .. tradeskillName .. "|" .. text2 )
	local editText3 = "!profession import " .. encode64(playerName .. "|" .. tradeskillName .. "|" .. text3 )
	
	ProfessionBotExporterWindow.editBox:SetText(editText .. '\n\n' .. editText2 .. '\n\n' .. editText3)
	ProfessionBotExporterWindow.editBox:HighlightText(hlLen, hlLen + string.len(importString))
	ProfessionBotExporterWindow:Show()
end

function createExporterWindow()
	local frame = CreateFrame("Frame", "ProfessionBotExporterWindow", UIParent, "BasicFrameTemplateWithInset")
	frame:SetSize(700, 600)
	frame:SetPoint("CENTER")
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetClampedToScreen(true)
	frame:SetFrameStrata("HIGH")
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame.title = frame:CreateFontString(nil, "OVERLAY")
	frame.title:SetFontObject("GameFontHighlight")
	frame.title:SetPoint("LEFT", frame.TitleBg, 5, 0)	
	frame.scrollFrame = CreateFrame("ScrollFrame", "ProfessionBotExporterScrollFrame", ProfessionBotExporterWindow	, "UIPanelScrollFrameTemplate")
	frame.scrollFrame:SetPoint("TOPLEFT", ProfessionBotExporterWindow.InsetBg, "TOPLEFT", 8, -8)
	frame.scrollFrame:SetPoint("BOTTOMRIGHT", ProfessionBotExporterWindow.InsetBg, "BOTTOMRIGHT", -3, 60)
	frame.scrollFrame.ScrollBar:SetPoint("TOPLEFT", frame.scrollFrame, "TOPRIGHT", -20, -22)
	frame.scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", frame.scrollFrame, "BOTTOMRIGHT", -15, 22)
	frame.editBox = CreateFrame("EditBox", "ProfessionBotExporterEditBox", TradeSkillExporterScrollFrame)
	frame.editBox:SetPoint("TOPLEFT", frame.scrollFrame, 5, -5)
	frame.editBox:SetFontObject(ChatFontNormal)
	frame.editBox:SetWidth(680)
	frame.editBox:SetAutoFocus(true)
	frame.editBox:SetMultiLine(true)
	frame.editBox:SetMaxLetters(99999)
	frame.editBox:SetScript("OnEscapePressed", function() frame:Hide() end)
	frame.scrollFrame:SetScrollChild(frame.editBox)	
end

function getItemId(prof_type, index)
  local itemLink, itemID
  if (prof_type == "trade") then
    itemLink = GetTradeSkillItemLink(index)
    if (not itemLink) then return end
    itemID = itemLink:match("item:(%d+)")
  elseif (prof_type == "craft") then
    itemLink = GetCraftItemLink(index)
    if (not itemLink) then return end
    itemID = itemLink:match("enchant:(%d+)")
  end
  return tonumber(itemID)
end

-- BASE 64 Codeing

local band, lshift, rshift = bit.band, bit.lshift, bit.rshift
local t = {}
local encode, decode = {}, { [strbyte("=")] = false }
for value = 0, 63 do
	local char = strsub('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/', value+1, value+1)
	encode[value] = char
	decode[strbyte(char)] = value
end

function encode64(str)
	local j = 1
	for i = 1, strlen(str), 3 do
		local a, b, c = strbyte(str, i, i+2)
		t[j] = encode[rshift(a, 2)]
		t[j+1] = encode[band(lshift(a, 4) + rshift(b or 0, 4), 0x3F)]
		t[j+2] = b and encode[band(lshift(b, 2) + rshift(c or 0, 6), 0x3F)] or "="
		t[j+3] = c and encode[band(c, 0x3F)] or "="
		j = j + 4
	end
	return table.concat(t, "", 1, j-1)
end

function decode64(str)
	local j = 1
	assert(strlen(str) % 4 == 0, format("%s: invalid data length: %d", MAJOR, strlen(str)))
	for i = 1, strlen(str), 4 do
		local ba, bb, bc, bd = strbyte(str, i, i+3)
		local a, b, c, d = decode[ba], decode[bb], decode[bc], decode[bd]
		assert(a ~= nil, format("%s: invalid data at position %d: '%s'", MAJOR, i, ba))
		assert(b ~= nil, format("%s: invalid data at position %d: '%s'", MAJOR, i+1, bb))
		assert(c ~= nil, format("%s: invalid data at position %d: '%s'", MAJOR, i+2, bc))
		assert(d ~= nil, format("%s: invalid data at position %d: '%s'", MAJOR, i+3, bd))
		t[j] = strchar(lshift(a, 2) + rshift(b, 4))
		t[j+1] = c and strchar(band(lshift(b, 4) + rshift(c, 2), 0xFF)) or ""
		t[j+2] = d and strchar(band(lshift(c, 6) + d, 0xFF)) or ""
		j = j + 3
	end
	return table.concat(t, "", 1, j-1)
end

