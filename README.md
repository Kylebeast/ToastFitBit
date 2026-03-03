# 🧠 ToastFitBit

Fitbit item with NUI alerts, custom notification support, and funny death messages.

---

## ✨ Features

- 📱 Clean smartwatch-style NUI
- ❤️ Health monitoring
- 🍔 Hunger alerts
- 💧 Thirst alerts
- 🔔 Configurable notification system
- 😂 death messages
- ⚙ Fully configurable thresholds
- 💾 Player specific saved settings

---

## 🔧 Supported Notification Systems

Set inside `config.lua`:

- qb
- ox
- mythic
- okok
- custom
- none

---

## 📦 Installation

1. Drag into your `resources/` folder
2. Add to `server.cfg`:

3. Add this to your item.lua of your choose:

```lua
fitbit = { name = 'fitbit', label = 'Fitbit', weight = 100, type = 'item', image = 'fitbit.png', unique = true, useable = true, shouldClose = true, description = 'A wrist Fitbit that alerts you when stats get low.' },    
```
## ⚙ Configuration
- All configuration is located inside: config.lua

You can customize:

- Notification type
- Default alert thresholds
- Alert step intervals
- death messages
- Status update interval
- Inventory compatibility


## ⚠ IMPORTANT
- You must provide your own Fitbit inventory image.
- Place your fitbit.png inside your inventory of choice.
- This script does NOT include an inventory image by default.
  



