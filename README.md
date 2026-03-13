# WebLogic 12.2.1.4 - Container locale

Ambiente WebLogic 12c containerizzato con domain persistito su filesystem host.

## Immagine Docker

```
augusjin/oracle-weblogic:12.2.1.4-generic
```

All'avvio l'immagine esegue automaticamente `createAndStartEmptyDomain.sh` che:
1. Crea il domain `base_domain` tramite WLST (WebLogic Scripting Tool)
2. Avvia il server di amministrazione `AdminServer`

## Struttura del progetto

```
weblogic12/
├── start.sh            # Script di avvio container
├── domain.properties   # Credenziali admin (username/password)
└── domain-data/        # Domain persistito (creato al primo avvio)
    └── base_domain/    # Tutti i file del domain WebLogic
```

## Avvio

```bash
./start.sh
```

Lo script:
- Crea la directory `domain-data/` se non esiste
- Imposta i permessi `777` in modo che sia accessibile sia dal container che dall'host
- Avvia il container in background (`-d`) con i volumi montati

## Porte esposte

| Porta | Protocollo | Uso |
|-------|-----------|-----|
| 7001  | HTTP      | Server HTTP (non usare per la console in prod mode) |
| 7002  | HTTPS     | Server HTTPS |
| 9002  | HTTPS     | **Administration Port** — console di amministrazione |

## Console di amministrazione

In **production mode** (default) la console è accessibile **solo** sulla porta di amministrazione HTTPS:

```
https://localhost:9002/console
```

- **Username:** `weblogic`
- **Password:** `Welcome1`

> Il browser mostrerà un avviso per il certificato self-signed (DemoIdentity). Accetta l'eccezione per proseguire.

La porta 7001 risponde con "Autorizzazione negata" perché in production mode la console è disabilitata sulla porta HTTP standard — comportamento corretto.

## Primo avvio vs avvii successivi

### Primo avvio (domain-data/ vuota)
Il container esegue automaticamente `createAndStartEmptyDomain.sh`, che crea il domain da zero e avvia WebLogic. Al termine `domain-data/base_domain/` sarà popolata.

### Avvii successivi (domain-data/ già esistente)
Il container riesegue `createAndStartEmptyDomain.sh` — l'immagine è configurata così. Se si vuole solo riavviare senza ricreare il domain, si può eseguire manualmente:

```bash
docker exec -it weblogic12 /u01/oracle/user_projects/domains/base_domain/startWebLogic.sh
```

Oppure fermare e rieseguire `./start.sh` (il domain preesistente viene sovrascritto con uno identico).

## Modifica dei file di configurazione

I file del domain si trovano in `domain-data/base_domain/` e sono editabili direttamente dall'host, ad esempio:

- `domain-data/base_domain/config/config.xml` — configurazione principale del domain
- `domain-data/base_domain/security/` — keystore e policy di sicurezza
- `domain-data/base_domain/servers/AdminServer/logs/` — log del server

Dopo aver modificato `config.xml` è necessario riavviare il container.

## Stop e pulizia

```bash
# Solo stop
docker stop weblogic12

# Stop e rimozione container (i dati in domain-data/ rimangono)
docker rm -f weblogic12

# Rimozione completa incluso il domain salvato
docker rm -f weblogic12 && rm -rf domain-data/
```
