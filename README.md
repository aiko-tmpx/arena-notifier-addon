# AikoArenaNotifier

Minimal, standalone World of Warcraft retail addon (compatible with current Retail and WoW Midnight) that functions as a passive visual indicator (pixel bridge) for external desktop scripts and notifications.

## Repository
- **GitHub:** [https://github.com/aiko-tmpx/arena-notifier](https://github.com/aiko-tmpx/arena-notifier)

## Overview
When an Arena, Solo Shuffle, or Battleground queue pop confirmation dialog appears, the addon renders a small 5x5 static purple square (`#A330C9`) at the top-left corner of the screen (`UIParent` TOPLEFT `0, 0` on `TOOLTIP` strata) for **3 seconds** (or until the arena loading screen). This gives external desktop scripts a clean, reliable detection window without keeping any UI elements stuck on screen.

## Pixel Bridge Specifications
- **Position:** `TOPLEFT` (0, 0) relative to `UIParent`
- **Size:** 5x5 pixels
- **Color:** Purple (`#A330C9`, RGB: `163/255, 48/255, 201/255` ~ `0.639, 0.188, 0.788`)
- **Frame Strata:** `TOOLTIP` (ensures rendering over all game UI and frames)
- **Duration:** 3 seconds (clean auto-hide)
- **Mouse Interaction:** Disabled (click-through, zero gameplay obstruction)

## Slash Commands
- `/aan` - Display the test pixel for 3 seconds to calibrate your desktop screen capture / pixel detector script (or type `/aan` while shown to hide).
- `/aan <seconds>` - Display the test pixel for custom seconds (e.g. `/aan 5`).
- `/aan hide` - Hide the test pixel immediately.
- `/aan help` - Display available commands.
