# ThinkPad T420 - i3wm Dotfiles 💻⚙️

> **Philosophy:** *An operating system should not be a barrier; it should be a seamless brain-computer interface. These configurations are the result of years of manual tweaking, reading documentation, and relentless optimization to achieve a frictionless, keyboard-driven workflow.*

This repository contains my personal `dotfiles` and configurations for the **i3 window manager (i3wm)**, specifically tailored and battle-tested on my Lenovo ThinkPad T420. 

## 🧠 The Concept

Before the era of AI-assisted coding and automated setups, these configurations were built from the ground up by diving deep into Linux documentation. The primary goal was to eliminate reliance on a mouse, minimize system resource overhead, and create a perfectly clean, distraction-free environment. 

Every shortcut, workspace behavior, and UI element has been intentionally placed to match instinctive usage patterns, turning the ThinkPad keyboard into a highly efficient extension of thought.

## 🛠️ Key Highlights

* **Window Manager:** `i3-gaps` / `i3wm` (Tiled, highly efficient window management)
* **Terminal Emulator:** (Buraya kullandığın terminali yaz, örn: `Alacritty` veya `urxvt`)
* **App Launcher:** (Buraya kullandığın launcher'ı yaz, örn: `rofi` veya `dmenu`)
* **Status Bar:** (Buraya kullandığın bar'ı yaz, örn: `polybar` veya `i3status`)
* **Hardware Optimization:** Specifically mapped keys and resource management designed to keep the legacy T420 running exceptionally fast and cool.

## ⚙️ Structure

* `.config/i3/config`: Core window manager behavior, keybindings, and workspace logic.
* (Varsa diğer config dosyalarını buraya listeleyebilirsin, örn: `.bashrc`, `.Xresources` vb.)

## 🚀 Installation (For Archive Purposes)

*Note: Dotfiles are highly personal. While you are welcome to fork and adapt these configurations, they are strictly mapped to my specific workflow and the ThinkPad T420 physical keyboard layout.*

```bash
# Example symbolic link setup
ln -sf ~/dotfiles/.config/i3/config ~/.config/i3/config
```
