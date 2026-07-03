local ADDON_NAME = ...
local MAX_UNIQUE = 5000
local MAX_SENDERS = 10

local issecretvalue = issecretvalue or function() return false end

local db -- assigned in initDB on ADDON_LOADED

local function initDB()
	if type(CHATSPAMLOG_DB) ~= "table" then CHATSPAMLOG_DB = {} end
	db = CHATSPAMLOG_DB
	if type(db.version) ~= "number" then db.version = 1 end
	if type(db.messages) ~= "table" then db.messages = {} end
	if type(db.paused) ~= "boolean" then db.paused = false end
	if type(db.uniqueCount) ~= "number" then
		local n = 0
		for _ in pairs(db.messages) do n = n + 1 end
		db.uniqueCount = n
	end
	if type(db.totalCount) ~= "number" then db.totalCount = 0 end
	if type(db.nextId) ~= "number" then db.nextId = 1 end
	-- Backfill ids for entries created before ids existed (stable order:
	-- first-seen timestamp, ties by key). Runs once; no-op afterwards.
	local missing = {}
	for key, e in pairs(db.messages) do
		if type(e.id) ~= "number" then
			missing[#missing + 1] = { key = key, e = e }
		end
	end
	if #missing > 0 then
		table.sort(missing, function(a, b)
			if a.e.first ~= b.e.first then return a.e.first < b.e.first end
			return a.key < b.key
		end)
		for _, m in ipairs(missing) do
			m.e.id = db.nextId
			db.nextId = db.nextId + 1
		end
	end
end

local function evictOne()
	-- Prefer the oldest entry with count == 1; fall back to oldest overall.
	-- Timestamps are "%Y-%m-%d %H:%M" so lexicographic compare = chronological.
	local victimKey, victimLast
	for key, e in pairs(db.messages) do
		if e.count == 1 and (victimLast == nil or e.last < victimLast) then
			victimKey, victimLast = key, e.last
		end
	end
	if not victimKey then
		for key, e in pairs(db.messages) do
			if victimLast == nil or e.last < victimLast then
				victimKey, victimLast = key, e.last
			end
		end
	end
	if victimKey then
		db.messages[victimKey] = nil
		db.uniqueCount = db.uniqueCount - 1
	end
end

local function record(msg, sender, channelLabel)
	local key = msg:lower()
	local now = date("%Y-%m-%d %H:%M")
	local e = db.messages[key]
	if not e then
		if db.uniqueCount >= MAX_UNIQUE then evictOne() end
		e = { msg = msg, count = 0, first = now, senders = {}, seen = {}, senderCount = 0, channels = {}, id = db.nextId }
		db.nextId = db.nextId + 1
		db.messages[key] = e
		db.uniqueCount = db.uniqueCount + 1
	end
	e.count = e.count + 1
	e.last = now
	e.channels[channelLabel] = true
	db.totalCount = db.totalCount + 1
	if not e.seen[sender] then
		e.seen[sender] = true
		e.senderCount = e.senderCount + 1
		if #e.senders < MAX_SENDERS then
			e.senders[#e.senders + 1] = sender
		end
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, event, ...)
	if event == "ADDON_LOADED" then
		local addon = ...
		if addon ~= ADDON_NAME then return end
		initDB()
		f:UnregisterEvent("ADDON_LOADED")
		f:RegisterEvent("CHAT_MSG_CHANNEL")
		f:RegisterEvent("CHAT_MSG_YELL")
		f:RegisterEvent("CHAT_MSG_WHISPER")
		return
	end
	if not db or db.paused then return end
	local msg, sender = ...
	if issecretvalue(msg) or issecretvalue(sender) then return end
	if type(msg) ~= "string" or msg == "" or type(sender) ~= "string" or sender == "" then return end

	local channelLabel
	if event == "CHAT_MSG_CHANNEL" then
		-- arg 7 = zoneChannelID: nonzero for zone channels (General/Trade/Services),
		-- 0 for custom user channels. Same gate BadBoy uses.
		local zoneChannelID = select(7, ...)
		if type(zoneChannelID) ~= "number" or zoneChannelID == 0 then return end
		local channelBaseName = select(9, ...)
		channelLabel = (type(channelBaseName) == "string" and channelBaseName ~= "")
			and channelBaseName or ("Zone" .. zoneChannelID)
	elseif event == "CHAT_MSG_YELL" then
		channelLabel = "YELL"
	else
		channelLabel = "WHISPER"
	end

	local trimmedSender = Ambiguate(sender, "none")
	if BadBoyIsFriendly then
		local flag = select(6, ...)
		local lineId = select(11, ...)
		local guid = select(12, ...)
		if BadBoyIsFriendly(trimmedSender, flag, lineId, guid) then return end
	end

	record(msg, trimmedSender, channelLabel)
end)

local PREFIX = "|cff33ff99ChatSpamLog|r: "

SLASH_CHATSPAMLOG1 = "/csl"
SLASH_CHATSPAMLOG2 = "/chatspamlog"
local function printSummary()
	print(("%s%d unique / %d total messages%s"):format(
		PREFIX, db.uniqueCount, db.totalCount, db.paused and " (PAUSED)" or ""))
end

SlashCmdList.CHATSPAMLOG = function(input)
	if not db then return end
	local cmd = (input or ""):lower():match("^%s*(%S*)") or ""
	if cmd == "stats" then
		printSummary()
		local top = {}
		for _, e in pairs(db.messages) do top[#top + 1] = e end
		table.sort(top, function(a, b) return a.count > b.count end)
		for i = 1, math.min(5, #top) do
			local e = top[i]
			print(("  %dx (%d senders): %s"):format(e.count, e.senderCount, e.msg:sub(1, 80)))
		end
	elseif cmd == "wipe" then
		db.messages, db.uniqueCount, db.totalCount = {}, 0, 0
		db.nextId = 1
		print(PREFIX .. "log wiped.")
	elseif cmd == "pause" then
		db.paused = true
		print(PREFIX .. "capture paused.")
	elseif cmd == "resume" then
		db.paused = false
		print(PREFIX .. "capture resumed.")
	else
		-- "help", "?", unknown, or bare input (bare normally intercepted by the
		-- GUI hook to open the GUI; reaching here means the GUI didn't load).
		printSummary()
		print(PREFIX .. "usage: /csl (opens GUI) | stats | wipe | pause | resume | help")
	end
end
