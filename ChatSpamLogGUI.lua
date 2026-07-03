local ADDON_NAME, addonNS = ...

-- ---------------------------------------------------------
-- STYLING CONSTANTS (Flat Dark Theme)
-- ---------------------------------------------------------
local STYLES = {
	bg = { 0.08, 0.08, 0.08, 0.95 },
	border = { 0.15, 0.15, 0.15, 1 },
	accent = { 0.20, 0.58, 0.78, 1 }, -- Sleek blue/cyan
	accentHover = { 0.30, 0.68, 0.88, 1 },
	
	panelBg = { 0.12, 0.12, 0.12, 1 },
	panelBorder = { 0.20, 0.20, 0.20, 1 },
	
	rowBg = { 0.14, 0.14, 0.14, 1 },
	rowBgAlt = { 0.17, 0.17, 0.17, 1 },
	rowBgHover = { 0.22, 0.22, 0.22, 1 },
	rowBgSelected = { 0.20, 0.58, 0.78, 0.25 },
	
	textMain = { 0.92, 0.92, 0.92, 1 },
	textMuted = { 0.60, 0.60, 0.60, 1 },
	textAccent = { 0.20, 0.70, 0.90, 1 },
}

-- Helper function to trim strings
local function trim(s)
	if not s then return "" end
	return s:match("^%s*(.-)%s*$")
end

-- Helper to check if a message key is currently filtered in BadBoy_CCleaner
local function IsFiltered(key)
	if not BADBOY_CCLEANER then return false end
	for _, filter in ipairs(BADBOY_CCLEANER) do
		if filter ~= "" and key:find(filter, 1, true) then
			return true
		end
	end
	return false
end

-- Helper to apply standard backdrop styling to a frame
local function ApplyBackdrop(frame, bg, border)
	frame:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8X8",
		edgeFile = "Interface\\Buttons\\WHITE8X8",
		edgeSize = 1,
		insets = { left = 1, right = 1, top = 1, bottom = 1 }
	})
	frame:SetBackdropColor(unpack(bg))
	frame:SetBackdropBorderColor(unpack(border))
end

-- Helper to enable/disable flat buttons cleanly
local function SetButtonEnabled(btn, enabled)
	if enabled then
		btn:Enable()
		btn:SetBackdropColor(unpack(STYLES.panelBg))
		btn:SetBackdropBorderColor(unpack(STYLES.panelBorder))
		btn.text:SetTextColor(unpack(STYLES.textMain))
	else
		btn:Disable()
		btn:SetBackdropColor(0.06, 0.06, 0.06, 1)
		btn:SetBackdropBorderColor(0.12, 0.12, 0.12, 1)
		btn.text:SetTextColor(unpack(STYLES.textMuted))
	end
end

-- Helper to enable/disable edit boxes cleanly
local function SetEditBoxEnabled(eb, enabled)
	if enabled then
		eb:Enable()
		eb:SetBackdropColor(0.05, 0.05, 0.05, 1)
		eb:SetBackdropBorderColor(unpack(STYLES.panelBorder))
		eb:SetTextColor(unpack(STYLES.textMain))
	else
		eb:ClearFocus()
		eb:Disable()
		eb:SetBackdropColor(0.04, 0.04, 0.04, 1)
		eb:SetBackdropBorderColor(0.10, 0.10, 0.10, 1)
		eb:SetTextColor(unpack(STYLES.textMuted))
	end
end

-- Helper to create a flat, styled button
local function CreateFlatButton(parent, width, height, text, anchor, relativeTo, relativeAnchor, x, y)
	local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
	btn:SetSize(width, height)
	btn:SetPoint(anchor, relativeTo, relativeAnchor, x, y)
	ApplyBackdrop(btn, STYLES.panelBg, STYLES.panelBorder)
	
	local fontString = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	fontString:SetPoint("CENTER")
	fontString:SetText(text)
	btn.text = fontString
	
	btn:SetScript("OnEnter", function(self)
		if self:IsEnabled() then
			self:SetBackdropColor(unpack(STYLES.rowBgHover))
			self:SetBackdropBorderColor(unpack(STYLES.accent))
		end
	end)
	btn:SetScript("OnLeave", function(self)
		if self:IsEnabled() then
			self:SetBackdropColor(unpack(STYLES.panelBg))
			self:SetBackdropBorderColor(unpack(STYLES.panelBorder))
		end
	end)
	
	return btn
end

-- ---------------------------------------------------------
-- MAIN GUI FRAME CREATION
-- ---------------------------------------------------------
local gui = CreateFrame("Frame", "ChatSpamLogGUI", UIParent, "BackdropTemplate")
gui:Hide()
gui:SetSize(700, 516)
gui:SetPoint("CENTER")
gui:SetFrameStrata("HIGH")
gui:SetClampedToScreen(true)
ApplyBackdrop(gui, STYLES.bg, STYLES.border)

-- Enable dragging / moving
gui:SetMovable(true)
gui:EnableMouse(true)

-- Add to special frames list so Escape closes it
tinsert(UISpecialFrames, "ChatSpamLogGUI")

-- ---------------------------------------------------------
-- TITLE BAR
-- ---------------------------------------------------------
local titleBar = CreateFrame("Frame", nil, gui, "BackdropTemplate")
titleBar:SetHeight(30)
titleBar:SetPoint("TOPLEFT", gui, "TOPLEFT", 0, 0)
titleBar:SetPoint("TOPRIGHT", gui, "TOPRIGHT", 0, 0)
ApplyBackdrop(titleBar, STYLES.panelBg, STYLES.border)

-- Drag handling
titleBar:EnableMouse(true)
titleBar:RegisterForDrag("LeftButton")
titleBar:SetScript("OnDragStart", function() gui:StartMoving() end)
titleBar:SetScript("OnDragStop", function() gui:StopMovingOrSizing() end)

-- Title text
local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
titleText:SetPoint("LEFT", titleBar, "LEFT", 10, 0)
titleText:SetText("ChatSpamLog |cff33ff99GUI|r")

-- Close Button (X)
local closeBtn = CreateFrame("Button", nil, titleBar, "BackdropTemplate")
closeBtn:SetSize(20, 20)
closeBtn:SetPoint("RIGHT", titleBar, "RIGHT", -6, 0)
ApplyBackdrop(closeBtn, STYLES.panelBg, STYLES.panelBorder)

local closeText = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
closeText:SetPoint("CENTER")
closeText:SetText("X")

closeBtn:SetScript("OnEnter", function(self)
	self:SetBackdropColor(0.60, 0.20, 0.20, 1)
	self:SetBackdropBorderColor(0.80, 0.30, 0.30, 1)
end)
closeBtn:SetScript("OnLeave", function(self)
	self:SetBackdropColor(unpack(STYLES.panelBg))
	self:SetBackdropBorderColor(unpack(STYLES.panelBorder))
end)
closeBtn:SetScript("OnClick", function()
	gui:Hide()
end)

-- LLM Prompt Button (opens the copyable curation-prompt dialog)
local promptBtn = CreateFlatButton(titleBar, 80, 20, "LLM Prompt", "RIGHT", closeBtn, "LEFT", -4, 0)
promptBtn:SetScript("OnClick", function()
	gui.promptOverlay:Show()
end)
titleBar.promptBtn = promptBtn

-- ---------------------------------------------------------
-- TOOLBAR
-- ---------------------------------------------------------
local toolbar = CreateFrame("Frame", nil, gui, "BackdropTemplate")
toolbar:SetHeight(45)
toolbar:SetPoint("TOPLEFT", gui, "TOPLEFT", 10, -35)
toolbar:SetPoint("TOPRIGHT", gui, "TOPRIGHT", -10, -35)
ApplyBackdrop(toolbar, STYLES.panelBg, STYLES.panelBorder)
gui.toolbar = toolbar

-- Counters String
local counterText = toolbar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
counterText:SetPoint("LEFT", toolbar, "LEFT", 8, 0)
counterText:SetWidth(125)
counterText:SetJustifyH("LEFT")
toolbar.counterText = counterText

-- Live Search Box
local searchBox = CreateFrame("EditBox", nil, toolbar, "BackdropTemplate")
searchBox:SetSize(155, 24)
searchBox:SetPoint("LEFT", counterText, "RIGHT", 10, 0)
searchBox:SetBackdrop({
	bgFile = "Interface\\Buttons\\WHITE8X8",
	edgeFile = "Interface\\Buttons\\WHITE8X8",
	edgeSize = 1,
	insets = { left = 1, right = 1, top = 1, bottom = 1 }
})
searchBox:SetBackdropColor(0.05, 0.05, 0.05, 1)
searchBox:SetBackdropBorderColor(unpack(STYLES.panelBorder))
searchBox:SetFontObject("GameFontHighlightSmall")
searchBox:SetTextInsets(6, 16, 0, 0)
searchBox:SetAutoFocus(false)

local searchPlaceholder = searchBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
searchPlaceholder:SetPoint("LEFT", searchBox, "LEFT", 6, 0)
searchPlaceholder:SetTextColor(unpack(STYLES.textMuted))
searchPlaceholder:SetText("Search messages...")
searchBox.placeholder = searchPlaceholder

local searchClearBtn = CreateFrame("Button", nil, searchBox)
searchClearBtn:SetSize(14, 14)
searchClearBtn:SetPoint("RIGHT", searchBox, "RIGHT", -4, 0)
searchClearBtn:Hide()

local searchClearText = searchClearBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
searchClearText:SetPoint("CENTER")
searchClearText:SetText("|cff888888x|r")

searchClearBtn:SetScript("OnEnter", function() searchClearText:SetText("|cffcc4444x|r") end)
searchClearBtn:SetScript("OnLeave", function() searchClearText:SetText("|cff888888x|r") end)
searchClearBtn:SetScript("OnClick", function()
	searchBox:SetText("")
	searchBox:ClearFocus()
end)
searchBox.clearBtn = searchClearBtn

searchBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
searchBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

searchBox:SetScript("OnEditFocusGained", function(self)
	self:SetBackdropBorderColor(unpack(STYLES.accent))
	searchPlaceholder:Hide()
end)
searchBox:SetScript("OnEditFocusLost", function(self)
	self:SetBackdropBorderColor(unpack(STYLES.panelBorder))
	if self:GetText() == "" then
		searchPlaceholder:Show()
	end
end)

searchBox:SetScript("OnTextChanged", function(self)
	local text = self:GetText():lower()
	if text ~= gui.filterText then
		gui.filterText = text
		gui:RefreshList()
	end
	if self:GetText() ~= "" then
		searchClearBtn:Show()
	else
		searchClearBtn:Hide()
	end
end)

toolbar.searchBox = searchBox

-- Sort Buttons Label
local sortLabel = toolbar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
sortLabel:SetPoint("LEFT", searchBox, "RIGHT", 12, 0)
sortLabel:SetTextColor(unpack(STYLES.textMuted))
sortLabel:SetText("Sort:")

-- Sort Buttons Function
local function UpdateSortButtons()
	local active = gui.sortBy or "count"
	
	gui.toolbar.sortCountBtn:SetBackdropColor(unpack(active == "count" and STYLES.accent or STYLES.panelBg))
	gui.toolbar.sortCountBtn:SetBackdropBorderColor(unpack(active == "count" and STYLES.accent or STYLES.panelBorder))
	gui.toolbar.sortCountBtn.text:SetTextColor(unpack(active == "count" and STYLES.textMain or STYLES.textMuted))
	
	gui.toolbar.sortSendersBtn:SetBackdropColor(unpack(active == "senders" and STYLES.accent or STYLES.panelBg))
	gui.toolbar.sortSendersBtn:SetBackdropBorderColor(unpack(active == "senders" and STYLES.accent or STYLES.panelBorder))
	gui.toolbar.sortSendersBtn.text:SetTextColor(unpack(active == "senders" and STYLES.textMain or STYLES.textMuted))
	
	gui.toolbar.sortNewestBtn:SetBackdropColor(unpack(active == "newest" and STYLES.accent or STYLES.panelBg))
	gui.toolbar.sortNewestBtn:SetBackdropBorderColor(unpack(active == "newest" and STYLES.accent or STYLES.panelBorder))
	gui.toolbar.sortNewestBtn.text:SetTextColor(unpack(active == "newest" and STYLES.textMain or STYLES.textMuted))
end

-- Sort: Count
local sortCountBtn = CreateFlatButton(toolbar, 48, 22, "Count", "LEFT", sortLabel, "RIGHT", 6, 0)
sortCountBtn:SetScript("OnClick", function()
	gui.sortBy = "count"
	UpdateSortButtons()
	gui:RefreshList()
end)
toolbar.sortCountBtn = sortCountBtn

-- Sort: Senders
local sortSendersBtn = CreateFlatButton(toolbar, 52, 22, "Senders", "LEFT", sortCountBtn, "RIGHT", 4, 0)
sortSendersBtn:SetScript("OnClick", function()
	gui.sortBy = "senders"
	UpdateSortButtons()
	gui:RefreshList()
end)
toolbar.sortSendersBtn = sortSendersBtn

-- Sort: Newest
local sortNewestBtn = CreateFlatButton(toolbar, 52, 22, "Newest", "LEFT", sortSendersBtn, "RIGHT", 4, 0)
sortNewestBtn:SetScript("OnClick", function()
	gui.sortBy = "newest"
	UpdateSortButtons()
	gui:RefreshList()
end)
toolbar.sortNewestBtn = sortNewestBtn

-- Action: Wipe
local wipeBtn = CreateFlatButton(toolbar, 48, 24, "Wipe", "RIGHT", toolbar, "RIGHT", -6, 0)
wipeBtn:SetScript("OnClick", function()
	gui.confirmOverlay:Show()
end)
toolbar.wipeBtn = wipeBtn

-- Action: Pause/Resume
local pauseBtn = CreateFlatButton(toolbar, 60, 24, "Pause", "RIGHT", wipeBtn, "LEFT", -6, 0)
pauseBtn:SetScript("OnClick", function()
	local db = CHATSPAMLOG_DB
	if not db then return end
	db.paused = not db.paused
	print("|cff33ff99ChatSpamLog|r: Capture " .. (db.paused and "paused." or "resumed."))
	gui:RefreshList()
end)
toolbar.pauseBtn = pauseBtn

-- ---------------------------------------------------------
-- MESSAGE LIST PANEL (LEFT ~60%, width 400, height 400)
-- ---------------------------------------------------------
local listPanel = CreateFrame("Frame", nil, gui, "BackdropTemplate")
listPanel:SetSize(400, 400)
listPanel:SetPoint("TOPLEFT", gui, "TOPLEFT", 10, -90)
ApplyBackdrop(listPanel, STYLES.panelBg, STYLES.panelBorder)
gui.listPanel = listPanel

-- Placeholder string when empty
local listPlaceholder = listPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
listPlaceholder:SetPoint("CENTER")
listPlaceholder:SetTextColor(unpack(STYLES.textMuted))
listPlaceholder:SetText("No spam messages logged.\n\nLog is clean!")
listPanel.placeholder = listPlaceholder

-- ScrollBox and ScrollBar Setup (WowScrollBoxList / MinimalScrollBar)
local scrollBox = CreateFrame("Frame", nil, listPanel, "WowScrollBoxList")
scrollBox:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 2, -2)
scrollBox:SetPoint("BOTTOMRIGHT", listPanel, "BOTTOMRIGHT", -22, 2)
gui.scrollBox = scrollBox

local scrollBar = CreateFrame("EventFrame", nil, listPanel, "MinimalScrollBar")
scrollBar:SetPoint("TOPLEFT", scrollBox, "TOPRIGHT", 2, 0)
scrollBar:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMRIGHT", 2, 0)

-- Linear view for scroll rows
local view = CreateScrollBoxListLinearView()
view:SetElementExtent(32)
view:SetElementInitializer("BackdropTemplate", function(frame, elementData)
	-- First time setup of sub-views
	if not frame.countText then
		ApplyBackdrop(frame, STYLES.rowBg, STYLES.panelBorder)
		
		-- Count + Senders count string
		frame.countText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		frame.countText:SetPoint("LEFT", frame, "LEFT", 8, 0)
		frame.countText:SetWidth(75)
		frame.countText:SetJustifyH("LEFT")
		
		-- Message Preview string
		frame.msgText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		frame.msgText:SetPoint("LEFT", frame.countText, "RIGHT", 4, 0)
		frame.msgText:SetPoint("RIGHT", frame, "RIGHT", -8, 0)
		frame.msgText:SetJustifyH("LEFT")
		frame.msgText:SetWordWrap(false)
		frame.msgText:SetMaxLines(1)
		
		frame:EnableMouse(true)
		
		frame:SetScript("OnEnter", function(self)
			self.isHovered = true
			if self.key ~= gui.selectedKey then
				self:SetBackdropColor(unpack(STYLES.rowBgHover))
			end
		end)
		
		frame:SetScript("OnLeave", function(self)
			self.isHovered = false
			if self.key == gui.selectedKey then
				self:SetBackdropColor(unpack(STYLES.rowBgSelected))
			else
				self:SetBackdropColor(unpack(self.isAlt and STYLES.rowBgAlt or STYLES.rowBg))
			end
		end)
		
		frame:SetScript("OnMouseDown", function(self)
			gui:SelectMessage(self.key)
		end)
	end
	
	-- Bind Data
	frame.key = elementData.key
	frame.isAlt = (elementData.index % 2 == 0)
	
	-- Update background selection state
	if frame.key == gui.selectedKey then
		frame:SetBackdropColor(unpack(STYLES.rowBgSelected))
		frame:SetBackdropBorderColor(unpack(STYLES.accent))
	else
		frame:SetBackdropColor(unpack(frame.isAlt and STYLES.rowBgAlt or STYLES.rowBg))
		frame:SetBackdropBorderColor(unpack(STYLES.panelBorder))
	end
	
	-- Format Text
	local filterPrefix = IsFiltered(elementData.key) and "|cffff4444[filtered]|r " or ""
	frame.countText:SetText(("|cff88aaee%dx|r (|cff44ccff%d|r)"):format(elementData.count, elementData.senderCount))
	frame.msgText:SetText(filterPrefix .. elementData.msg)
end)

ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, view)

-- ---------------------------------------------------------
-- DETAIL PANE (RIGHT ~40%, width 270, height 400)
-- ---------------------------------------------------------
local detailPanel = CreateFrame("Frame", nil, gui, "BackdropTemplate")
detailPanel:SetSize(270, 400)
detailPanel:SetPoint("TOPRIGHT", gui, "TOPRIGHT", -10, -90)
ApplyBackdrop(detailPanel, STYLES.panelBg, STYLES.panelBorder)
gui.detailPanel = detailPanel

-- Placeholder String
local detailPlaceholder = detailPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
detailPlaceholder:SetPoint("CENTER")
detailPlaceholder:SetWidth(240)
detailPlaceholder:SetTextColor(unpack(STYLES.textMuted))
detailPlaceholder:SetText("No message selected.\n\nSelect an entry from the list to view details, add CCleaner filters, or remove logs.")
detailPanel.placeholder = detailPlaceholder

-- Detail Headers/Controls
local detailHeader = detailPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
detailHeader:SetPoint("TOPLEFT", detailPanel, "TOPLEFT", 12, -12)
detailHeader:SetTextColor(unpack(STYLES.textAccent))
detailHeader:SetText("MESSAGE DETAIL")
detailPanel.header = detailHeader

-- Message Viewer Inner Panel
local msgPanel = CreateFrame("Frame", nil, detailPanel, "BackdropTemplate")
msgPanel:SetPoint("TOPLEFT", detailPanel, "TOPLEFT", 10, -32)
msgPanel:SetPoint("TOPRIGHT", detailPanel, "TOPRIGHT", -10, -32)
msgPanel:SetHeight(90)
ApplyBackdrop(msgPanel, { 0.05, 0.05, 0.05, 1 }, STYLES.panelBorder)
detailPanel.msgPanel = msgPanel

-- Scrollable, selectable message viewer. WoW has no clipboard API, so copy
-- works by selecting text in a focused EditBox and pressing Ctrl+C.
local msgScroll = CreateFrame("ScrollFrame", nil, msgPanel)
msgScroll:SetPoint("TOPLEFT", msgPanel, "TOPLEFT", 8, -8)
msgScroll:SetPoint("BOTTOMRIGHT", msgPanel, "BOTTOMRIGHT", -8, 8)
detailPanel.msgScroll = msgScroll

local copyBox = CreateFrame("EditBox", nil, msgScroll)
copyBox:SetMultiLine(true)
copyBox:SetAutoFocus(false)
copyBox:SetFontObject("GameFontHighlightSmall")
copyBox:SetJustifyH("LEFT")
copyBox:SetWidth(msgScroll:GetWidth())
copyBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
-- Read-only: revert any user edit to the canonical text.
copyBox:SetScript("OnTextChanged", function(self, userInput)
	if userInput and self.canonicalText and self:GetText() ~= self.canonicalText then
		self:SetText(self.canonicalText)
	end
end)
-- Keep the cursor visible while selecting with keyboard/drag.
copyBox:SetScript("OnCursorChanged", function(self, x, y, w, h)
	local offset = -y
	local cur = msgScroll:GetVerticalScroll()
	local viewH = msgScroll:GetHeight()
	if offset < cur then
		msgScroll:SetVerticalScroll(offset)
	elseif offset + h > cur + viewH then
		msgScroll:SetVerticalScroll(offset + h - viewH)
	end
end)
msgScroll:SetScrollChild(copyBox)
msgScroll:SetScript("OnSizeChanged", function(self, w)
	copyBox:SetWidth(w)
end)
msgScroll:EnableMouseWheel(true)
msgScroll:SetScript("OnMouseWheel", function(self, delta)
	local maxScroll = self:GetVerticalScrollRange()
	local new = self:GetVerticalScroll() - delta * 20
	self:SetVerticalScroll(math.max(0, math.min(maxScroll, new)))
end)
detailPanel.copyBox = copyBox

-- Copy All: selects the full message; the user presses Ctrl+C to copy
-- (no clipboard API exists in WoW Lua).
local copyAllBtn = CreateFlatButton(detailPanel, 70, 18, "Copy All", "TOPRIGHT", detailPanel, "TOPRIGHT", -10, -9)
copyAllBtn:SetScript("OnClick", function()
	local cb = detailPanel.copyBox
	cb:SetFocus()
	cb:HighlightText()
	print("|cff33ff99ChatSpamLog|r: Press Ctrl+C to copy.")
end)
detailPanel.copyAllBtn = copyAllBtn

-- Metadata Labels
local firstSeenText = detailPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
firstSeenText:SetPoint("TOPLEFT", msgPanel, "BOTTOMLEFT", 2, -10)
detailPanel.firstSeenText = firstSeenText

local lastSeenText = detailPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
lastSeenText:SetPoint("TOPLEFT", firstSeenText, "BOTTOMLEFT", 0, -4)
detailPanel.lastSeenText = lastSeenText

local channelsText = detailPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
channelsText:SetPoint("TOPLEFT", lastSeenText, "BOTTOMLEFT", 0, -4)
channelsText:SetPoint("RIGHT", detailPanel, "RIGHT", -10, 0)
channelsText:SetJustifyH("LEFT")
channelsText:SetWordWrap(true)
detailPanel.channelsText = channelsText

local sendersText = detailPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
sendersText:SetPoint("TOPLEFT", channelsText, "BOTTOMLEFT", 0, -4)
sendersText:SetPoint("RIGHT", detailPanel, "RIGHT", -10, 0)
sendersText:SetJustifyH("LEFT")
sendersText:SetWordWrap(true)
detailPanel.sendersText = sendersText

-- CCleaner Filter EditBox Label
local ebLabel = detailPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
ebLabel:SetTextColor(unpack(STYLES.textMuted))
ebLabel:SetText("CCleaner Substring Filter:")
detailPanel.ebLabel = ebLabel

-- CCleaner Substring EditBox
local editBox = CreateFrame("EditBox", nil, detailPanel, "BackdropTemplate")
editBox:SetHeight(26)
ApplyBackdrop(editBox, { 0.05, 0.05, 0.05, 1 }, STYLES.panelBorder)
editBox:SetFontObject("GameFontHighlightSmall")
editBox:SetTextInsets(8, 8, 0, 0)
-- EditBox text regions render past the frame edge on long prefills; clip them.
editBox:SetClipsChildren(true)
editBox:SetAutoFocus(false)
editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
editBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

editBox:SetScript("OnEditFocusGained", function(self)
	self:SetBackdropBorderColor(unpack(STYLES.accent))
end)
editBox:SetScript("OnEditFocusLost", function(self)
	self:SetBackdropBorderColor(unpack(STYLES.panelBorder))
end)
detailPanel.editBox = editBox

-- Align EditBox and Label relative to bottom buttons
editBox:SetPoint("BOTTOMLEFT", detailPanel, "BOTTOMLEFT", 10, 48)
editBox:SetPoint("BOTTOMRIGHT", detailPanel, "BOTTOMRIGHT", -10, 48)
ebLabel:SetPoint("BOTTOMLEFT", editBox, "TOPLEFT", 2, 4)

-- Remove from log Button
local removeBtn = CreateFlatButton(detailPanel, 120, 26, "Remove from log", "BOTTOMRIGHT", detailPanel, "BOTTOMRIGHT", -10, 10)
removeBtn:SetScript("OnClick", function()
	local db = CHATSPAMLOG_DB
	if not db or not gui.selectedKey then return end
	
	db.messages[gui.selectedKey] = nil
	db.uniqueCount = math.max(0, db.uniqueCount - 1)
	
	print("|cff33ff99ChatSpamLog|r: Removed message from log.")
	gui.selectedKey = nil
	gui:RefreshList()
end)
detailPanel.removeBtn = removeBtn

-- Add to CCleaner Button
local addBtn = CreateFlatButton(detailPanel, 120, 26, "Add to CCleaner", "BOTTOMLEFT", detailPanel, "BOTTOMLEFT", 10, 10)
addBtn:SetScript("OnClick", function()
	local text = editBox:GetText()
	text = trim(text):lower()
	if text == "" then return end
	
	-- Perform CCleaner Addition
	if not BADBOY_CCLEANER then return end
	
	-- Duplicate and substring checks
	for _, filter in ipairs(BADBOY_CCLEANER) do
		if filter == text then
			print(("|cff33ff99ChatSpamLog|r: Filter '%s' already exists in CCleaner."):format(text))
			return
		end
		if text:find(filter, 1, true) then
			print(("|cff33ff99ChatSpamLog|r: Existing filter '%s' already covers '%s'."):format(filter, text))
			return
		end
	end
	
	table.insert(BADBOY_CCLEANER, text)
	print(("|cff33ff99ChatSpamLog|r: Added filter '%s' to CCleaner."):format(text))
	
	-- Refresh list to mark filtered items
	gui:RefreshList()
end)

addBtn:SetScript("OnEnter", function(self)
	if not BADBOY_CCLEANER then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("BadBoy CCleaner Integration", 1, 1, 1)
		GameTooltip:AddLine("BadBoy_CCleaner is not loaded.\nEnsure the BadBoy CCleaner addon is active to use this feature.", 0.9, 0.3, 0.3, true)
		GameTooltip:Show()
	else
		if self:IsEnabled() then
			self:SetBackdropColor(unpack(STYLES.rowBgHover))
			self:SetBackdropBorderColor(unpack(STYLES.accent))
		end
	end
end)
addBtn:SetScript("OnLeave", function(self)
	GameTooltip:Hide()
	if BADBOY_CCLEANER and self:IsEnabled() then
		self:SetBackdropColor(unpack(STYLES.panelBg))
		self:SetBackdropBorderColor(unpack(STYLES.panelBorder))
	end
end)
addBtn:SetMotionScriptsWhileDisabled(true)
detailPanel.addBtn = addBtn

-- ---------------------------------------------------------
-- DETAIL PANE UPDATE FUNCTION
-- ---------------------------------------------------------
function gui:UpdateDetailPane()
	local db = CHATSPAMLOG_DB
	local msgKey = self.selectedKey
	local e = (db and msgKey) and db.messages[msgKey]
	
	if not e then
		self.selectedKey = nil
		-- Hide details, show placeholder
		detailPanel.placeholder:Show()
		detailPanel.header:Hide()
		detailPanel.msgPanel:Hide()
		detailPanel.copyAllBtn:Hide()
		detailPanel.firstSeenText:Hide()
		detailPanel.lastSeenText:Hide()
		detailPanel.channelsText:Hide()
		detailPanel.sendersText:Hide()
		detailPanel.ebLabel:Hide()
		detailPanel.editBox:Hide()
		detailPanel.addBtn:Hide()
		detailPanel.removeBtn:Hide()
		return
	end
	
	-- Show details, hide placeholder
	detailPanel.placeholder:Hide()
	detailPanel.header:Show()
	detailPanel.msgPanel:Show()
	detailPanel.copyAllBtn:Show()
	detailPanel.firstSeenText:Show()
	detailPanel.lastSeenText:Show()
	detailPanel.channelsText:Show()
	detailPanel.sendersText:Show()
	detailPanel.ebLabel:Show()
	detailPanel.editBox:Show()
	detailPanel.addBtn:Show()
	detailPanel.removeBtn:Show()
	detailPanel.header:SetText(("MESSAGE DETAIL  |cff667788#%s|r"):format(e.id or "?"))
	
	-- Escaped raw message view: replace "|" with "||". Only reset the copy box
	-- when the selection changes, so refreshes don't clobber a drag-selection.
	if detailPanel.copyBox.currentKey ~= msgKey then
		local escapedMsg = e.msg:gsub("|", "||")
		detailPanel.copyBox.currentKey = msgKey
		detailPanel.copyBox.canonicalText = escapedMsg
		detailPanel.copyBox:SetText(escapedMsg)
		detailPanel.copyBox:SetCursorPosition(0)
		detailPanel.msgScroll:SetVerticalScroll(0)
	end
	
	detailPanel.firstSeenText:SetText("|cffaabbffFirst:|r " .. e.first)
	detailPanel.lastSeenText:SetText("|cffaabbffLast:|r " .. e.last)
	
	-- Sort and format channels
	local channels = {}
	for ch in pairs(e.channels) do
		table.insert(channels, ch)
	end
	table.sort(channels)
	detailPanel.channelsText:SetText("|cffaabbffChannels:|r " .. table.concat(channels, ", "))
	
	-- Senders list
	detailPanel.sendersText:SetText(("|cffaabbffSenders (%d):|r %s"):format(e.senderCount, table.concat(e.senders, ", ")))
	
	-- Prefill lowercase EditBox only when selection changes (never clobber user edits)
	if detailPanel.editBox.currentKey ~= msgKey then
		detailPanel.editBox.currentKey = msgKey
		detailPanel.editBox:SetText(msgKey)
		detailPanel.editBox:SetCursorPosition(0)
	end
	
	-- CCleaner button state and text box state
	local hasBadBoy = (BADBOY_CCLEANER ~= nil)
	SetButtonEnabled(detailPanel.addBtn, hasBadBoy)
	SetEditBoxEnabled(detailPanel.editBox, true)
	SetButtonEnabled(detailPanel.removeBtn, true)
end

-- ---------------------------------------------------------
-- SELECTION HELPER
-- ---------------------------------------------------------
function gui:SelectMessage(key)
	self.selectedKey = key
	
	-- Update selection backdrop of active list items
	if self.scrollBox.ForEachFrame then
		self.scrollBox:ForEachFrame(function(frame)
			if frame.key then
				local isSel = (frame.key == self.selectedKey)
				if isSel then
					frame:SetBackdropColor(unpack(STYLES.rowBgSelected))
					frame:SetBackdropBorderColor(unpack(STYLES.accent))
				else
					frame:SetBackdropColor(unpack(frame.isAlt and STYLES.rowBgAlt or STYLES.rowBg))
					frame:SetBackdropBorderColor(unpack(STYLES.panelBorder))
				end
			end
		end)
	end
	
	self:UpdateDetailPane()
end

-- ---------------------------------------------------------
-- REFRESH LIST & REBUILD DATA PROVIDER
-- ---------------------------------------------------------
function gui:RefreshList()
	local db = CHATSPAMLOG_DB
	if not db or not db.messages then return end
	
	-- 1. Update counters & status
	self.toolbar.counterText:SetText(
		("Unique: |cff33ff99%d|r  /  Total: |cff33ff99%d|r"):format(db.uniqueCount, db.totalCount)
	)
	
	if db.paused then
		self.toolbar.pauseBtn.text:SetText("|cff00ff00Resume|r")
	else
		self.toolbar.pauseBtn.text:SetText("|cffff4444Pause|r")
	end
	
	-- 2. Gather matching entries
	local filterText = self.filterText or ""
	local items = {}
	for key, e in pairs(db.messages) do
		local matches = true
		if filterText ~= "" then
			if not key:find(filterText, 1, true) then
				matches = false
			end
		end
		
		if matches then
			table.insert(items, {
				key = key,
				msg = e.msg,
				count = e.count,
				first = e.first,
				last = e.last,
				senderCount = e.senderCount,
				senders = e.senders,
				channels = e.channels
			})
		end
	end
	
	-- 3. Sort entries
	local sortBy = self.sortBy or "count"
	if sortBy == "count" then
		table.sort(items, function(a, b)
			if a.count ~= b.count then
				return a.count > b.count
			end
			return a.last > b.last
		end)
	elseif sortBy == "senders" then
		table.sort(items, function(a, b)
			if a.senderCount ~= b.senderCount then
				return a.senderCount > b.senderCount
			end
			return a.last > b.last
		end)
	elseif sortBy == "newest" then
		table.sort(items, function(a, b)
			return a.last > b.last
		end)
	end
	
	-- 4. Apply index for alternating colors
	for i, item in ipairs(items) do
		item.index = i
	end
	
	-- 5. Rebuild DataProvider
	local dataProvider = CreateDataProvider()
	for _, item in ipairs(items) do
		dataProvider:Insert(item)
	end
	self.scrollBox:SetDataProvider(dataProvider)
	
	-- 6. Toggle list placeholders
	if db.uniqueCount == 0 then
		self.listPanel.placeholder:SetText("No spam messages logged.\n\nLog is clean!")
		self.listPanel.placeholder:Show()
	elseif #items == 0 then
		self.listPanel.placeholder:SetText("No matching messages found.")
		self.listPanel.placeholder:Show()
	else
		self.listPanel.placeholder:Hide()
	end
	
	-- 7. Sync selected element validity
	if self.selectedKey and not db.messages[self.selectedKey] then
		self.selectedKey = nil
	end
	self:UpdateDetailPane()
end

-- ---------------------------------------------------------
-- WIPE CONFIRMATION OVERLAY (MODAL DIALOG)
-- ---------------------------------------------------------
local confirmOverlay = CreateFrame("Frame", nil, gui, "BackdropTemplate")
confirmOverlay:SetAllPoints(gui)
confirmOverlay:SetFrameLevel(gui:GetFrameLevel() + 20)
confirmOverlay:EnableMouse(true)
confirmOverlay:SetBackdrop({
	bgFile = "Interface\\Buttons\\WHITE8X8"
})
confirmOverlay:SetBackdropColor(0, 0, 0, 0.75)
confirmOverlay:Hide()
gui.confirmOverlay = confirmOverlay

local confirmDialog = CreateFrame("Frame", nil, confirmOverlay, "BackdropTemplate")
confirmDialog:SetSize(320, 130)
confirmDialog:SetPoint("CENTER")
ApplyBackdrop(confirmDialog, STYLES.bg, STYLES.accent)

local confirmTitle = confirmDialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
confirmTitle:SetPoint("TOP", confirmDialog, "TOP", 0, -16)
confirmTitle:SetText("|cffff3333Wipe Spam Log|r")

local confirmText = confirmDialog:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
confirmText:SetPoint("TOP", confirmTitle, "BOTTOM", 0, -10)
confirmText:SetWidth(280)
confirmText:SetText("Are you sure you want to delete all logged spam messages? This cannot be undone.")

local confirmYesBtn = CreateFlatButton(confirmDialog, 100, 24, "Yes, Wipe", "BOTTOMLEFT", confirmDialog, "BOTTOMLEFT", 45, 14)
confirmYesBtn:SetScript("OnClick", function()
	local db = CHATSPAMLOG_DB
	if db then
		db.messages = {}
		db.uniqueCount = 0
		db.totalCount = 0
		db.nextId = 1
		print("|cff33ff99ChatSpamLog|r: Log wiped.")
	end
	gui.selectedKey = nil
	confirmOverlay:Hide()
	gui:RefreshList()
end)

local confirmNoBtn = CreateFlatButton(confirmDialog, 100, 24, "Cancel", "BOTTOMRIGHT", confirmDialog, "BOTTOMRIGHT", -45, 14)
confirmNoBtn:SetScript("OnClick", function()
	confirmOverlay:Hide()
end)

-- Footer hint pointing at the chat command help
local footerHint = gui:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
footerHint:SetPoint("BOTTOMLEFT", gui, "BOTTOMLEFT", 12, 7)
footerHint:SetTextColor(unpack(STYLES.textMuted))
footerHint:SetText("/csl help — chat commands")
gui.footerHint = footerHint

-- ---------------------------------------------------------
-- LLM PROMPT OVERLAY (MODAL DIALOG)
-- ---------------------------------------------------------
local LLM_PROMPT = [==[You are curating chat-spam filters for the WoW addon BadBoy_CCleaner.

Input: my SavedVariables file ChatSpamLog.lua (attached or pasted). Parse the CHATSPAMLOG_DB.messages table. Each entry has: msg (original text), count (times seen), senderCount (distinct senders), senders, channels, first/last timestamps, id.

Propose plain lowercase substrings for the BADBOY_CCLEANER list. Rules:
1. Matching is literal substring, case-insensitive (the list stores lowercase; BadBoy lowercases incoming messages). No Lua patterns, no wildcards.
2. Target commercial spam: sales, carries, boosts, gold selling, phishing. Strongest signals: high senderCount (same text from many senders), high count.
3. Every substring must be distinctive to spam - never a phrase a normal player might type in ordinary chat. Prefer 2+ word phrases ("vip raids", "best service/price"). Reject short or generic candidates ("wts", "cheap", "run").
4. Ignore item-link and formatting codes inside messages (sequences with Hitem:, Hachievement:, cff colors). Match on the human-readable words around them, never on link payloads.
5. Skip entries that are not commercial spam (addon whispers like "Gave item", guild recruitment) unless clearly abusive.

For each proposal, output: the substring, which message ids it catches, false-positive risk (low/med/high), and one example message. Finish with the final low-risk list formatted as a Lua array of quoted strings, ready to paste.

If I also paste my current BADBOY_CCLEANER list, exclude anything it already covers.]==]

local promptOverlay = CreateFrame("Frame", nil, gui, "BackdropTemplate")
promptOverlay:SetAllPoints(gui)
promptOverlay:SetFrameLevel(gui:GetFrameLevel() + 20)
promptOverlay:EnableMouse(true)
promptOverlay:SetBackdrop({
	bgFile = "Interface\\Buttons\\WHITE8X8"
})
promptOverlay:SetBackdropColor(0, 0, 0, 0.75)
promptOverlay:Hide()
gui.promptOverlay = promptOverlay

local promptDialog = CreateFrame("Frame", nil, promptOverlay, "BackdropTemplate")
promptDialog:SetSize(560, 400)
promptDialog:SetPoint("CENTER")
ApplyBackdrop(promptDialog, STYLES.bg, STYLES.accent)

local promptTitle = promptDialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
promptTitle:SetPoint("TOP", promptDialog, "TOP", 0, -12)
promptTitle:SetTextColor(unpack(STYLES.textAccent))
promptTitle:SetText("LLM Curation Prompt")

local promptHint = promptDialog:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
promptHint:SetPoint("TOP", promptTitle, "BOTTOM", 0, -4)
promptHint:SetTextColor(unpack(STYLES.textMuted))
promptHint:SetText("Copy this into any LLM and attach ChatSpamLog.lua from WTF\\...\\SavedVariables (flushed on /reload).")

local promptScrollBg = CreateFrame("Frame", nil, promptDialog, "BackdropTemplate")
promptScrollBg:SetPoint("TOPLEFT", promptDialog, "TOPLEFT", 12, -54)
promptScrollBg:SetPoint("BOTTOMRIGHT", promptDialog, "BOTTOMRIGHT", -12, 44)
ApplyBackdrop(promptScrollBg, { 0.05, 0.05, 0.05, 1 }, STYLES.panelBorder)

local promptScroll = CreateFrame("ScrollFrame", nil, promptScrollBg)
promptScroll:SetPoint("TOPLEFT", promptScrollBg, "TOPLEFT", 8, -8)
promptScroll:SetPoint("BOTTOMRIGHT", promptScrollBg, "BOTTOMRIGHT", -8, 8)

local promptBox = CreateFrame("EditBox", nil, promptScroll)
promptBox:SetMultiLine(true)
promptBox:SetAutoFocus(false)
promptBox:SetFontObject("GameFontHighlightSmall")
promptBox:SetJustifyH("LEFT")
promptBox:SetWidth(promptScroll:GetWidth())
promptBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
promptBox:SetScript("OnTextChanged", function(self, userInput)
	if userInput and self:GetText() ~= LLM_PROMPT then
		self:SetText(LLM_PROMPT)
	end
end)
promptScroll:SetScrollChild(promptBox)
promptScroll:SetScript("OnSizeChanged", function(self, w)
	promptBox:SetWidth(w)
end)
promptScroll:EnableMouseWheel(true)
promptScroll:SetScript("OnMouseWheel", function(self, delta)
	local maxScroll = self:GetVerticalScrollRange()
	local new = self:GetVerticalScroll() - delta * 20
	self:SetVerticalScroll(math.max(0, math.min(maxScroll, new)))
end)
promptBox:SetText(LLM_PROMPT)
promptBox:SetCursorPosition(0)

local promptCopyBtn = CreateFlatButton(promptDialog, 100, 24, "Copy All", "BOTTOMLEFT", promptDialog, "BOTTOMLEFT", 12, 10)
promptCopyBtn:SetScript("OnClick", function()
	promptBox:SetFocus()
	promptBox:HighlightText()
	print("|cff33ff99ChatSpamLog|r: Press Ctrl+C to copy.")
end)

local promptCloseBtn = CreateFlatButton(promptDialog, 100, 24, "Close", "BOTTOMRIGHT", promptDialog, "BOTTOMRIGHT", -12, 10)
promptCloseBtn:SetScript("OnClick", function()
	promptOverlay:Hide()
end)

-- ---------------------------------------------------------
-- EVENT HANDLING & INITIALIZATION
-- ---------------------------------------------------------
gui:SetScript("OnShow", function(self)
	self.sortBy = self.sortBy or "count"
	UpdateSortButtons()
	self:RefreshList()
end)

-- Real-time refresh when new messages are added
gui:RegisterEvent("CHAT_MSG_CHANNEL")
gui:RegisterEvent("CHAT_MSG_YELL")
gui:RegisterEvent("CHAT_MSG_WHISPER")
gui:SetScript("OnEvent", function(self, event, ...)
	if self:IsShown() then
		-- Delay a microsecond to let the core record the entry first
		C_Timer.After(0.01, function()
			if self:IsShown() then
				self:RefreshList()
			end
		end)
	end
end)

-- ---------------------------------------------------------
-- SLASH COMMAND HOOKING
-- ---------------------------------------------------------
local function HookSlashCommand()
	local originalSlashHandler = SlashCmdList.CHATSPAMLOG
	SlashCmdList.CHATSPAMLOG = function(input)
		local cmd = (input or ""):lower():match("^%s*(%S*)") or ""
		if cmd == "gui" or cmd == "" then
			if ChatSpamLogGUI:IsShown() then
				ChatSpamLogGUI:Hide()
			else
				ChatSpamLogGUI:Show()
			end
		else
			if originalSlashHandler then
				originalSlashHandler(input)
			else
				print("|cff33ff99ChatSpamLog|r: Core slash handler not found.")
			end
		end
	end
end

-- Execute Hook
HookSlashCommand()
