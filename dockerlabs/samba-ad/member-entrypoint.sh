#!/bin/bash
set -e
REALM="LAB.LOCAL"; DOMAIN="LAB"; DCIP="172.30.0.10"; DCPASS="Password123!"
echo "nameserver $DCIP" > /etc/resolv.conf; echo "search lab.local" >> /etc/resolv.conf
echo "[*] member waiting for DC ($DCIP) ..."
until nc -z "$DCIP" 445 2>/dev/null && nc -z "$DCIP" 88 2>/dev/null; do sleep 2; done
sleep 5
cat > /etc/krb5.conf <<KRB
[libdefaults]
  default_realm = $REALM
  dns_lookup_realm = false
  dns_lookup_kdc = true
KRB
cat > /etc/samba/smb.conf <<SMB
[global]
  workgroup = $DOMAIN
  realm = $REALM
  security = ADS
  winbind use default domain = yes
  winbind refresh tickets = yes
  template shell = /bin/bash
  idmap config * : backend = tdb
  idmap config * : range = 3000-7999
  idmap config $DOMAIN : backend = rid
  idmap config $DOMAIN : range = 10000-999999

[data]
  path = /srv/data
  read only = no
  valid users = @"$DOMAIN\\Domain Users"
SMB
mkdir -p /srv/data
echo "FLAG{domain_user_can_read_the_member_share}" > /srv/data/secret.txt
echo "backup creds: svc_backup / Backup2023!  (try these elsewhere)" > /srv/data/notes.txt
chmod 0777 /srv/data
if [ ! -f /var/lib/samba/.joined ]; then
  echo "[*] joining $REALM ..."
  net ads join -U "Administrator%$DCPASS" && touch /var/lib/samba/.joined && echo "[+] joined domain as member MEMBER01"
fi
echo "[*] starting winbindd + smbd (share //MEMBER01/data)"
winbindd
exec smbd -i -s /etc/samba/smb.conf
