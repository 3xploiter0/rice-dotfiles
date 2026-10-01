#!/bin/bash
set -e
REALM="LAB.LOCAL"; DOMAIN="LAB"; DCPASS="Password123!"
if [ ! -f /var/lib/samba/private/sam.ldb ]; then
  echo "[*] provisioning domain $REALM ..."
  rm -f /etc/krb5.conf
  samba-tool domain provision --use-rfc2307 --realm="$REALM" --domain="$DOMAIN" \
     --server-role=dc --dns-backend=SAMBA_INTERNAL --adminpass="$DCPASS" >/dev/null
  cp /var/lib/samba/private/krb5.conf /etc/krb5.conf
  # --- vulnerable accounts ---
  add(){ samba-tool user create "$1" "$2" >/dev/null 2>&1 || true; }
  add alice   Spring2024!
  add bob     Password1
  add jdoe    Welcome1
  add svc_sql Summer2023!          # kerberoastable (SPN below)
  add svc_web MServerP@ss1
  # SPNs -> Kerberoasting
  samba-tool spn add MSSQLSvc/dc01.lab.local:1433 svc_sql >/dev/null 2>&1 || true
  samba-tool spn add HTTP/dc01.lab.local svc_web >/dev/null 2>&1 || true
  # AS-REP roastable (no Kerberos pre-auth)
  samba-tool user create asrepuser Autumn2024! >/dev/null 2>&1 || true
  samba-tool domain exampleldif >/dev/null 2>&1 || true
  echo "[+] users: alice bob jdoe svc_sql(SPN) svc_web(SPN) asrepuser | admin: Administrator:$DCPASS"
fi
echo "[*] starting samba AD DC (domain LAB.LOCAL)"
exec samba -i -s /etc/samba/smb.conf
