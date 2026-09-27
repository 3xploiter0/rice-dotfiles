# 3xploiter0 rice dotfiles
Kali XFCE Tokyo Night rice + hacking workflow. Backup made by `rice-backup`.

Restore on a fresh box:
1. `sudo apt install $(cat packages.txt)`
2. Copy dirs back into `$HOME` (`.zshrc`, `.tmux.conf`, `.config/*`, `.local/*`).
3. Reload xfconf from `xfconf/*.txt` if needed (panel/theme settings).
