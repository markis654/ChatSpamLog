# Usage: curating spam filters with an LLM

ChatSpamLog logs spam into a database file. You hand that file to an LLM (Claude,
ChatGPT, whatever), and it proposes filter substrings for BadBoy_CCleaner. This
page walks the full loop.

## 1. Capture

Just play. The addon logs zone-channel/yell/whisper spam automatically,
deduplicated. A few days of city time gives the LLM plenty of signal (repeat
counts and distinct-sender counts are what make a filter proposal trustworthy).

## 2. Flush the log to disk

SavedVariables only hit disk on `/reload` or logout. Do one of those, then grab:

```
World of Warcraft\_retail_\WTF\Account\<ACCOUNT>\SavedVariables\ChatSpamLog.lua
```

## 3. Hand it to an LLM

Attach the file (or paste its contents) along with the prompt below. In-game you
can also click **LLM Prompt** in the GUI title bar and copy the same prompt.

The prompt teaches the LLM the database shape and the matching rules, and asks
for a risk-rated proposal list plus a ready-to-paste final list.

### The prompt

```
You are curating chat-spam filters for the WoW addon BadBoy_CCleaner.

Input: my SavedVariables file ChatSpamLog.lua (attached or pasted). Parse the
CHATSPAMLOG_DB.messages table. Each entry has: msg (original text), count
(times seen), senderCount (distinct senders), senders, channels, first/last
timestamps, id.

Propose plain lowercase substrings for the BADBOY_CCLEANER list. Rules:

1. Matching is literal substring, case-insensitive (the list stores lowercase;
   BadBoy lowercases incoming messages). No Lua patterns, no wildcards.
2. Target commercial spam: sales, carries, boosts, gold selling, phishing.
   Strongest signals: high senderCount (same text from many senders), high count.
3. Every substring must be distinctive to spam — never a phrase a normal player
   might type in ordinary chat. Prefer 2+ word phrases ("vip raids",
   "best service/price"). Reject short or generic candidates ("wts", "cheap",
   "run") — they will eat legitimate messages.
4. Ignore item-link and formatting codes inside messages (|Hitem:...|h,
   |Hachievement:...|h, |cffxxxxxx, |r). Match on the human-readable words
   around them, never on link payloads.
5. Skip entries that are not commercial spam (addon whispers like
   "Gave [item]", guild recruitment) unless clearly abusive.

For each proposal, output: the substring, which message ids it catches,
false-positive risk (low/med/high), and one example message. Finish with the
final low-risk list formatted as a Lua array of quoted strings, ready to paste.

If I also paste my current BADBOY_CCLEANER list, exclude anything it already
covers.
```

## 4. Apply the filters

Two safe paths — **pick by whether WoW is running**:

### In-game (WoW running) — always safe

Add each substring via the GUI (select a matching entry → filter box → **Add to
CCleaner**) or BadBoy's own options. Changes are live immediately. Then `/reload`
to persist them — a crash before the next flush loses in-game additions.

### File edit (WoW closed) — for batch pastes

`WTF\Account\<ACCOUNT>\SavedVariables\BadBoy_CCleaner.lua` holds
`BADBOY_CCLEANER = { "substring", ... }` — a plain array of lowercase strings.

**Caveats — SavedVariables lifecycle:**

1. **Never edit the file while WoW is running.** The game loaded it at login and
   rewrites the whole file from memory on `/reload`/logout/exit — your edits are
   silently overwritten. Character-select still counts as running; the client
   process must be gone.
2. **A Lua syntax error wipes the list.** WoW discards an unparseable
   SavedVariables file at load and the addon starts empty. Validate after editing
   (`luajit -bl BadBoy_CCleaner.lua NUL`, expect exit 0) or at minimum re-read
   your commas and quotes.
3. **Back up the file first.** There is no undo.

## 5. Reset and repeat

`/csl wipe` (or the GUI Wipe button) clears the log so the next cycle only shows
spam your filters didn't catch. Message ids reset too.

## Using a filter other than BadBoy_CCleaner

The logger is filter-agnostic; only the "Add to CCleaner" button is BadBoy-bound.
The proposed strings port to any **plain substring** filter as-is. For
**Lua-pattern** filters, escape magic characters first (`mythic+ carry` →
`mythic%+ carry`; same for `- ? ( ) [ ] % . * ^ $`), and check whether the filter
lowercases input — these strings assume case-insensitive matching.
