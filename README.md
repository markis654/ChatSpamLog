# ChatSpamLog

A World of Warcraft (retail) addon that logs spam-relevant chat into a deduplicated
SavedVariables database, so you can curate filter entries for
[BadBoy_CCleaner](https://www.curseforge.com/wow/addons/badboy-ccleaner) offline —
including feeding the log to an LLM to propose filter substrings.

## What it captures

- Zone channels (General, Trade, Trade (Services)) — custom user channels are ignored
- Yells
- Incoming whispers

Messages from friends and guildmates are skipped when [BadBoy](https://www.curseforge.com/wow/addons/bad-boy)
is installed. The addon is a pure observer: it never filters, modifies, or blocks chat.

## How it stores

Each unique message (case-insensitive) becomes one entry with:

- `id` — stable reference number (shown in the GUI; never reused)
- `count` — times seen
- `first` / `last` — timestamps
- `senders` / `senderCount` — distinct senders (a strong spam signal: same text from many senders)
- `channels` — where it appeared

Capped at 5000 unique messages; the oldest single-occurrence entries are evicted first.

## Commands

| Command | Effect |
|---|---|
| `/csl` (or `/csl gui`) | Toggle the GUI |
| `/csl help` (or `/csl ?`) | Status summary + command list |
| `/csl stats` | Counts + top 5 messages by occurrence |
| `/csl wipe` | Clear the log (also resets message ids) |
| `/csl pause` / `/csl resume` | Toggle capture (persists across reloads) |

## GUI

`/csl` opens a curation window: searchable/sortable message list, detail pane with
selectable message text (drag-select or **Copy All**, then Ctrl+C), per-entry `#id`,
and a filter box that adds substrings straight into BadBoy_CCleaner's live list.
**LLM Prompt** in the title bar shows a copyable prompt for LLM-assisted curation —
see [USAGE.md](USAGE.md) for the full workflow and SavedVariables safety caveats.

## Workflow

1. Play. The addon accumulates deduplicated spam.
2. `/reload` or log out (flushes SavedVariables to disk).
3. Pull `WTF\Account\<ACCOUNT>\SavedVariables\ChatSpamLog.lua`.
4. Curate filter substrings from high-count / high-sender entries (by hand or with an LLM).
5. Add them to BadBoy_CCleaner. `/csl wipe`. Repeat.

## Install

Copy the `ChatSpamLog` folder into `Interface\AddOns\`.
