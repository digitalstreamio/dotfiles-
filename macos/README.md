# macOS Setup

## System Configuration

Based on https://inteltechniques.com/ventura.html

x Bluetooth > Bluetooth = Disabled
- Network > Firewall > Firewall = Enabled
- General > Date & Time > Source = pool.ntp.org
- General > Sharing > Each app = Disabled
- Notifications > // Show Previews = Never
- Notifications > // Each app = Disabled
- Siri & Spotlight > Ask Siri = Disabled
- Siri & Spotlight > Spotlight > Each app = Disabled
- Privacy & Security > Analytics > Disable all
- Privacy & Security > Apple Advertising > Personalized Ads = Disabled
- Game Center > Game Center = Disabled

## Keyboard Shortcuts     

- Spotlight
    - Show Spotlight search = Ctrl-Opt-Space
- Mission Control
    - Move left a space = Ctrl-Cmd-Down
    - Move right a space = Ctrl-Cmd-Up
    - Switch to Desktop 1-4 = Opt-1-4
- Modifier Keys
    - Control key = Globe
    - Globe key = Control

## Firefox

- Config
    - browser.discovery.enabled = false
    - browser.newtabpage.enabled = false
    - browser.cache.disk.enable = false
    - browser.cache.memory.capacity = 65536
    - dom.ipc.processCount = 2
    - dom.ipc.processCount.webIsolated = 6
    - dom.ipc.processPrelaunch.enabled = false
    - extensions.pocket.enabled = false
    - gfx.webrender.all = true
    - media.av1.enabled = false
    - media.hardware-video-decoding.force-enabled = true
    - media.webm.enabled = false
- Extensions
    - Command Palette
    - Firefox Multi-Account Container
    - uBlock Origin
