# 3xploiter0 rice — Tokyo Night Kali

One-command setup of a Tokyo Night Kali (XFCE) rice + hacking workflow.

## Install
```bash
git clone https://github.com/3xploiter0/rice-dotfiles ~/rice
cd ~/rice
./install.sh
```
Run as your normal user (it uses `sudo` when needed). Existing configs are
backed up to `~/.rice-restore-<date>/`. Log out and back in when it finishes,
then open a terminal and run `cheat`.

Safe install: desktop look + terminals + hacking toolkit. It does **not** touch
GRUB, the boot splash, or the login screen.

## What you get
- Tokyo Night everything: xfwm theme, GTK, Papirus icons, JetBrainsMono Nerd Font
- Alacritty / QTerminal themed, tmux (Tokyo Night, auto-logging), starship prompt
- macOS feels: bottom dock, Launchpad (F4), Mission Control (F3), hot corners
- Eye candy: `livewp` video wallpaper, `wal-cycle` auto-theming, conky HUD
- Hacking toolkit: `htb`, `recon`, `recon-web`, `vpn`, `addhost`, `serve`,
  `gettools`, `note`, `loot`, `status`, `crack`, `revshell`, `report`, `arsenal`
- Self-maintaining: weekly `update` timer + unattended apt security upgrades

Full command list: run `cheat` (or open `cheatsheet/rice-card.html`).
