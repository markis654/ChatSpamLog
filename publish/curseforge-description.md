# CurseForge listing content (paste into project page)

## Name

ChatSpamLog

## Summary (one sentence)

Logs deduplicated chat spam to SavedVariables so you can curate BadBoy_CCleaner filter lists offline — by hand or with an LLM.

## Description

**ChatSpamLog** is a lightweight spam *observer* for filter-list curation. It never
filters, modifies, or blocks chat — it just remembers the spam, so you can build
better filter lists for [BadBoy_CCleaner](https://www.curseforge.com/wow/addons/badboy-ccleaner)
(or any substring-based filter) outside the game.

### What it captures

- Zone channels (General, Trade, Trade (Services)) — custom user channels ignored
- Yells
- Incoming whispers

Friends and guildmates are skipped when [BadBoy](https://www.curseforge.com/wow/addons/bad-boy)
is installed (optional dependency — ChatSpamLog works without it).

### How it stores

Every unique message (case-insensitive) becomes one entry: times seen, distinct
senders (same text from many senders = strongest spam signal), channels, first/last
timestamps, and a stable reference id. Capped at 5000 unique messages; oldest
one-off entries evicted first. Everything persists in SavedVariables.

### The GUI

`/csl` opens a curation window:

- Searchable, sortable message list (by count, senders, newest)
- Detail pane: selectable message text (drag-select or **Copy All** + Ctrl+C),
  per-entry `#id`, timestamps, channels, senders
- Filter box that adds substrings **directly into BadBoy_CCleaner's live list** —
  no reload needed
- **LLM Prompt** button: a ready-made, copyable prompt for handing your log file
  to any LLM (Claude, ChatGPT, …) to get risk-rated filter suggestions
- Pause/resume capture, wipe with confirmation

### Commands

| Command | Effect |
|---|---|
| `/csl` | Toggle the GUI |
| `/csl help` | Status + command list |
| `/csl stats` | Counts + top 5 messages |
| `/csl wipe` | Clear the log |
| `/csl pause` / `resume` | Toggle capture |

### The workflow

1. Play. Spam accumulates, deduplicated.
2. `/reload` or log out (flushes SavedVariables).
3. Curate: in-game via the GUI, or hand
   `WTF\Account\<ACCOUNT>\SavedVariables\ChatSpamLog.lua` to an LLM with the
   bundled prompt (see USAGE.md in the addon folder).
4. Add the substrings to BadBoy_CCleaner. Wipe. Repeat — each cycle only shows
   what your filters didn't catch.

### Privacy note

The log stays in your local SavedVariables file. Nothing is transmitted anywhere;
sharing it with an LLM is a manual step you take yourself.

---

Source & issues: https://github.com/markis654/ChatSpamLog

## Upload metadata

- License: MIT
- Category: Chat & Communication
- Optional dependency: BadBoy (relation type "optional dependency"); mention BadBoy_CCleaner as companion
- Game versions: match `## Interface: 120100, 120005, 120007` (12.1.0, 12.0.5, 12.0.7)
- Gallery: GUI screenshot (list + detail pane), LLM Prompt dialog screenshot
- Avatar: publish/avatar.png (400x400, original flat-dark art, no Blizzard imagery)

## Packaging (zip for upload)

From repo root (PowerShell) — stages only runtime + doc files, zips with correct
top-level folder:

    Remove-Item publish\stage -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Force publish\stage\ChatSpamLog | Out-Null
    Copy-Item ChatSpamLog.toc, ChatSpamLog.lua, ChatSpamLogGUI.lua, LICENSE, README.md, USAGE.md publish\stage\ChatSpamLog\
    Compress-Archive -Path publish\stage\ChatSpamLog -DestinationPath publish\ChatSpamLog-v1.0.0.zip -Force

Bump `## Version` in the .toc before each release; zip name should match.
