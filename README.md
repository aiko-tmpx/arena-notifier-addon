# AikoArenaNotifier

Minimal, standalone World of Warcraft retail addon (compatible with current Retail and WoW Midnight) that functions as a passive visual indicator (pixel bridge) for external desktop scripts and notifications.

## Repository
- **GitHub:** [https://github.com/aiko-tmpx/arena-notifier](https://github.com/aiko-tmpx/arena-notifier)

## Overview
When an Arena, Solo Shuffle, or Rated Battleground queue pop confirmation dialog appears, the addon renders a small 5x5 static magenta square (`#FF00FF`) at the top-left corner of the screen (`UIParent` TOPLEFT `0, 0` on `TOOLTIP` strata). When the confirmation dialog closes or queue status changes, the square immediately hides.

## Pixel Bridge Specifications
- **Position:** `TOPLEFT` (0, 0) relative to `UIParent`
- **Size:** 5x5 pixels
- **Color:** Magenta (`#FF00FF`, RGB: `1.0, 0.0, 1.0, 1.0`)
- **Frame Strata:** `TOOLTIP` (ensures rendering over all game UI and frames)
- **Mouse Interaction:** Disabled (click-through, zero gameplay obstruction)

## Slash Commands
- `/aan test` or `/aikonotifier test` - Display the test pixel for 10 seconds (or toggle off) to calibrate your desktop screen capture / pixel detector script.
- `/aan status` - Print current queue confirmation status to chat.
