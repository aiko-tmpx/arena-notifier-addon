# AikoArenaNotifier

Minimal, standalone World of Warcraft retail addon (compatible with current Retail and WoW Midnight) that acts as a passive visual indicator for PvP queue pops.

## Repository
- **GitHub:** [https://github.com/aiko-tmpx/arena-notifier](https://github.com/aiko-tmpx/arena-notifier)

## Overview
When an Arena, Solo Shuffle, or Battleground queue pop confirmation dialog appears, the addon renders a small 5x5 static pure magenta square (`#FF00FF`) at the top-left corner of the screen (`UIParent` TOPLEFT `0, 0` on `TOOLTIP` strata) for **3 seconds** (or until the loading screen).

## Specifications
- **Position:** `TOPLEFT` (0, 0) relative to `UIParent`
- **Size:** 5x5 pixels
- **Color:** Pure Magenta (`#FF00FF`, RGB: `1.0, 0.0, 1.0, 1.0`)
- **Frame Strata:** `TOOLTIP` (ensures rendering over all game UI and frames)
- **Duration:** 3 seconds (clean auto-hide)
- **Mouse Interaction:** Disabled (click-through, zero gameplay obstruction)

## Slash Commands
- `/aan test` - Flash the indicator for 3 seconds.
- `/aan about` - Information about the addon.
- `/aan help` - Show available commands.
