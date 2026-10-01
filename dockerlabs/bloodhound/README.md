# bloodhound — BloodHound Community Edition (AD attack-path visualizer)

App + Neo4j + Postgres. Visualize the samba-ad lab (or any AD) as a graph.

## Start / login
```bash
dlab up bloodhound                 # UI -> http://localhost:8888
dlab logs bloodhound | grep -i 'Initial Password'   # first-run admin password
# login: admin / <that password>  (you set a new one on first login; it persists)
```

## Feed it your AD lab
```bash
dlab up samba-ad                   # make sure the DC is running
bhound 172.30.0.10 alice 'Spring2024!'   # collect -> makes a .zip
# then in the UI:  gear (Administration) > File Ingest > Upload the .zip
```

## Explore
In the UI search/pathfinding, try:
- "Shortest Paths to Domain Admins"
- Mark svc_sql / your cracked users as **Owned**, then "paths from Owned"
- Pre-built queries: Kerberoastable users, AS-REP roastable, etc.

Data persists in docker volumes across `dlab down/up`. Port set in `.env` (8888).
