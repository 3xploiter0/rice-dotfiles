# Command Reference

Every custom command in the rice, with a real example for each.
In the terminal, `cheat` shows the quick list and `ex <command>` prints just one example.

---

## 🎯 Platforms & workspaces

### `htb` / `thm` / `pg` / `vh` / `ctf`
Create a box workspace (folders + tmux + sets target) under `~/cyber/labs/<platform>/`.
```bash
htb 10.10.11.5 blocky        # HackTheBox box "blocky"
thm 10.10.50.12 mountaineer  # TryHackMe
pg  192.168.120.40 hunit     # Proving Grounds
vh  192.168.56.10 kioptrix   # VulnHub
ctf 10.0.0.5 crypto-01       # CTF
```

### `lab`
The engine behind the wrappers (rarely called directly).
```bash
lab htb 10.10.11.5 blocky
```

### `boxes`
Progress across every platform (user/root flags, dates).
```bash
boxes            # all platforms
boxes htb        # only HTB
```

### `map`
Show where everything lives (`~/cyber` layout).
```bash
map
```

---

## 🎯 Target & VPN

### `vpn`
Connect/disconnect a `.ovpn` (files in `~/cyber/vpn/`).
```bash
vpn htb          # connect ~/cyber/vpn/htb.ovpn
vpn thm          # TryHackMe
vpn status       # show tunnel + IP
vpn down         # disconnect
```

### `target`
Set/show the active target (shows red in bar, prompt, tmux). `$TARGET` / `$LHOST` auto-fill.
```bash
target 10.10.11.5
target                       # show it
target clear                 # remove
nmap -sCV $TARGET            # use it anywhere
```

### `addhost`
Add/remove an `/etc/hosts` entry.
```bash
addhost 10.10.11.5 blocky.htb
addhost blocky.htb           # remove
```

### `status`
One glance: VPN, target, current box, listeners, tmux.
```bash
status
```

---

## 🔍 Recon & scanning

### `ports`
Fast "what's open" triage scan.
```bash
ports 10.10.11.5
ports                        # uses current target
```

### `recon`
Full port scan, then auto service-enum (web/smb/ftp…) into the box folder.
```bash
recon 10.10.11.5
recon                        # uses current target
```

### `fuzz`
Directory brute-force. Add `FUZZ` to the URL for a custom point (ffuf).
```bash
fuzz http://10.10.11.5
fuzz http://10.10.11.5/FUZZ /usr/share/seclists/Discovery/Web-Content/common.txt
```

### `vhost`
Virtual-host / subdomain fuzzing (Host header).
```bash
vhost blocky.htb 10.10.11.5
```

### `smb`
Quick SMB share enum (null + guest + nxc).
```bash
smb 10.10.11.5
```

### `dns`
DNS records + zone-transfer attempt.
```bash
dns example.com
dns internal.htb 10.10.11.5  # against a specific nameserver
```

### `crt`
Passive subdomains via crt.sh (no touching the target).
```bash
crt example.com
```

### `sweep`
Find live hosts on a subnet (great after a pivot).
```bash
sweep 10.10.11.0/24
```

### `recon-web`
Bug-bounty pipeline: subfinder → httpx → nuclei (authorized scope only).
```bash
recon-web example.com
```

### `search`
Exploit-DB lookup (searchsploit).
```bash
search apache 2.4
search -m 50383              # copy an exploit to cwd
```

---

## 💣 Exploitation & shells

### `payload`
Generate a reverse-shell payload with msfvenom (uses your VPN IP).
```bash
payload windows 4444         # shell.exe
payload php                  # shell.php
payload elf 9001             # linux ELF on port 9001
```

### `webshell`
Drop a cmd webshell into the serve folder.
```bash
webshell php                 # then: serve  -> upload -> curl 'http://t/shell.php?c=id'
```

### `listen`
Catch a reverse shell (pwncat auto-TTY, else rlwrap nc).
```bash
listen                       # port 4444
listen 9001
```

### `revshell`
Print reverse-shell one-liners (copies the first to clipboard).
```bash
revshell                     # bash, using $LHOST:4444
revshell 10.10.14.9 443 python3
```

### `spawn`
Print + copy the TTY-stabilization steps.
```bash
spawn
```

### `serve` / `www`
HTTP server with paste-ready download lines. `serve` uses `~/cyber/tools/serve`; `www` serves the current folder.
```bash
serve                        # serve the tools folder
www 8080                     # serve $PWD on port 8080
```

### `gettools` / `peas`
Stage post-exploitation tools / serve linpeas with the target one-liner.
```bash
gettools                     # download linpeas, winpeas, pspy, chisel…
peas                         # serve linpeas + print the curl|sh command
peas win                     # winpeas version
```

### `tunnel`
One-command pivot (prints the target-side command).
```bash
tunnel chisel 9001
tunnel ligolo
```

---

## 🔑 Cracking & encoding

### `crack`
Auto-detect a hash type and run hashcat vs rockyou.
```bash
crack '5f4dcc3b5aa765d61d8327deb882cf99'
crack hashes.txt
```

### `crackzip`
Crack a protected zip/rar/pdf/ssh-key with john.
```bash
crackzip secret.zip
crackzip id_rsa
```

### `enc` / `dec`
Encode/decode base64, hex, url, rot13.
```bash
enc b64 "hello"              # aGVsbG8=
dec b64 aGVsbG8=            # hello
echo "flag" | enc hex
```

### `magic`
Auto-try decodings and show what's readable.
```bash
magic ZmxhZ3t0ZXN0fQ==
echo "<blob>" | magic
```

### `rocky`
Grep rockyou for a pattern.
```bash
rocky '^admin'
```

### `sshkey`
Generate an SSH keypair to drop into `authorized_keys`.
```bash
sshkey pwn                   # creates pwn + pwn.pub
```

### `qr`
Decode a QR/barcode from an image.
```bash
qr secret.png
```

### `steg` / `extract`
Forensics gauntlet on a file / universal archive extractor.
```bash
steg suspicious.jpg
extract backup.tar.gz
```

---

## 📝 Notes, loot & tracking

### `note`
Timestamped line into the current box's notes.md.
```bash
note "foothold via CVE-2021-41773"
note                         # show the notes
```

### `flag`
Record a flag into the box (makes `boxes` show ✓).
```bash
flag user 2a3b4c5d6e7f...
flag root 9f8e7d...
flag                         # show this box's flags
```

### `loot`
Copy a file into the box's loot/ folder.
```bash
loot id_rsa
loot                         # list loot
```

### `creds`
Credential vault (chmod 600).
```bash
creds add blocky admin P@ssw0rd "web login"
creds admin                  # search
creds                        # list all
```

### `todo` / `shot`
Per-box task list / screenshot into loot.
```bash
todo "check SMB shares"
todo done 1
shot login-panel            # region screenshot -> box loot/
```

### `report` / `writeup`
Build a markdown report / blog-ready writeup from a box's notes.
```bash
report blocky
writeup blocky
```

### `logs` / `logclean`
List today's terminal logs / strip colors for a report.
```bash
logs
logclean ~/cyber/logs/2026-10-01/htb-blocky_w1p1_120000.log
```

---

## 📚 Learning & reference

### `cheat`
The quick reference. Sections + example-lookup.
```bash
cheat                        # everything
cheat quick                  # fast verbs
cheat enum                   # methodology
cheat ad                     # active directory
cheat windows                # windows enum
ex listen                    # one example for a command (see below)
```

### `ex`
Print the example(s) for a single command (from this file).
```bash
ex payload
ex vpn
```

### `brief`
Daily cyber news + actively-exploited CVEs.
```bash
brief
```

### `pay`
Offline, fuzzy-searchable payloads (PayloadsAllTheThings + GTFOBins).
```bash
pay sqli
pay --update                 # first run clones the repos
```

### `cve`
Quick CVE lookup.
```bash
cve CVE-2021-4034
```

### `kb` / `journal` / `roadmap`
Personal knowledge base / learning log + streak / study path.
```bash
kb add "nmap -p- is slow; use ports first"
kb nmap                      # search
journal "rooted Blocky, learned wp-config leak"
roadmap                      # open the path
roadmap -s                   # progress
```

### `genpass`
Random password.
```bash
genpass 24
```

---

## 🎨 Desktop & system

### `rice`
fastfetch + btop + visualizer showcase layout.
```bash
rice
```

### `livewp` / `wal-cycle`
Animated video wallpaper / recolor terminals from the wallpaper.
```bash
livewp on
livewp off
wal-cycle                    # next wallpaper + recolor
wal-cycle reset              # back to Tokyo Night
```

### `arsenal` / `update`
Install/update tools / full maintenance (runs weekly automatically).
```bash
arsenal                      # install missing + update
update                       # apt + tools + templates + backup & push
```

### `rice-backup`
Snapshot all configs to the dotfiles repo.
```bash
rice-backup
rice-backup git@github.com:you/dotfiles.git   # set remote + push
```

### `burpchrome` / `burpcert`
Chrome through Burp / trust Burp's CA.
```bash
burpchrome                   # Chrome routed through 127.0.0.1:8080
burpcert                     # run once with Burp open
```
