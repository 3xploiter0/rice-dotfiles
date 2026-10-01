# ~/cyber/dockerlabs — self-hosted practice labs

Each folder is one lab with its own `docker-compose.yml`. Manage with `dlab`.

```
dlab              list labs + up/down status
dlab up dvwa      start DVWA        -> http://localhost:8081
dlab up juice-shop                  -> http://localhost:3001
dlab up webgoat                     -> http://localhost:8082/WebGoat
dlab up bwapp                       -> http://localhost:8083/install.php
dlab up mutillidae                  -> http://localhost:8084

vulhub log4j      # pick & run 1 of ~333 CVE scenarios (vulhub down to stop)
adlab             # how to build an Active Directory lab (GOAD / Ludus)
dlab down <name>  stop it
dlab open <name>  open in browser
dlab ps           running lab containers
dlab add <name> <image> [host:cont]   add your own
dlab clean        prune dangling images (--all also stopped containers)
```

Ports are chosen to avoid clashes. Add any image: `dlab add bwapp raesene/bwapp 8083:80`.
Your custom labs (e.g. mitm-lab) can live here too — drop a docker-compose.yml in a folder.
