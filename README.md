# docker-cron-image

Docker irudi arin eta moldagarria, programatutako atazak (cron jobs) edukiontzi barruan exekutatzeko diseinatua.

Irudi hau **Alpine Linux**-en oinarrituta dago eta honako tresna hauek dakartza aurrez instalatuta, automatizazio script-ak errazteko:
* `cronie` (Cron kudeatzailea)
* `bash`
* `curl`
* `docker-cli` (Docker barruan beste Docker edukiontzi batzuk kudeatu ahal izateko)

Besterik gabe exekutatzen bada, irudiak abisu-mezu bat bistaratuko du logetan minuturo, erabiltzaileari bere konfigurazio propioa muntatu behar duela gogorarazteko.

---

## Erabilera gida

Irudi hau GitHub Container Registry-tik (GHCR) deskargatu dezakezu.

### Bertsioen Nomenklatura (Tags)

Irudiak honako *tag* egitura hau jarraitzen du bertsioak kudeatzeko:

* **`latest`**: Uneko bertsio egonkor eta berriena.
* **`YYYYMMDD-sha`** (Adibidez: `20251126-a1b2c3d`): Data eta commit-aren hash-a barne hartzen dituen bertsio finkoa. Honek bermatzen du beti irudi berbera exekutatuko dela, nahiz eta `latest` eguneratu.

### Docker Compose Adibidea

Zure cron lanak exekutatzeko, **zure `crontab` fitxategia muntatu behar duzu** edukiontziaren `/etc/crontabs/root` bidean.

Hona hemen `docker-compose.yml` fitxategi baten adibidea:

```yaml
version: '3.8'

services:
  cron-worker:
    image: ghcr.io/codesyntax/docker-cron-image:latest
    container_name: nire-cron-lana
    restart: unless-stopped
    volumes:
      # Zure cron lanak dituen fitxategia muntatu (overwrite)
      - ./nire-crontab.txt:/etc/crontabs/root:ro
      
      # Docker socket-a muntatu (Docker komandoak erabili ahal izateko)
      - /var/run/docker.sock:/var/run/docker.sock
```

### ⚠️ Ohar garrantzitsuak konfigurazioari buruz

Zure `crontab.txt` fitxategia sortzean, kontuan izan hiru puntu hauek:

1.  **Irteera desbideratu:** Docker-ek logak irakurri ahal izateko, komandoen irteera `/proc/1/fd/1`-era bideratu behar da.
2.  **Lerro hutsa:** Fitxategiaren amaieran beti lerro huts bat utzi (bestela cron-ek ez du irakurriko).
3.  **Docker Socket-a:** `docker-compose` fitxategian `/var/run/docker.sock` muntatzea ezinbestekoa da zure cron lanek `docker` komandoak exekutatu behar badituzte (adibidez: `docker restart nginx`). Honek edukiontziari baimena ematen dio "Host" makinako Docker motorra kontrolatzeko.

Adibidea (`crontab.txt`):
```text
# Adibidea: Nginx edukiontzia berrabiarazi egunero 03:00etan
0 3 * * * docker restart nire-nginx > /proc/1/fd/1 2>&1
```

## Garapen gida

Proiektu honek **CI/CD** (Continuous Integration / Continuous Deployment) sistema bat du integratuta GitHub Actions erabiliz.

### GitHub Actions Workflow-a

Errepositorioan aldaketak egiten diren bakoitzean, `.github/workflows/docker-publish.yml` fitxategian definitutako prozesua abiarazten da.

Workflow honen urratsak honako hauek dira:

1.  **Aktibazioa:** `main` adarrera *push* bat egiten denean aktibatzen da automatikoki.
2.  **Build:** Docker irudia eraikitzen du `Dockerfile` erabiliz.
3.  **Tagging:** Irudiari bi etiketa jartzen dizkio:
    * `latest`
    * Data eta commit hash-a daraman etiketa bakarra.
4.  **Publish:** Irudia **GitHub Container Registry (GHCR)**-ra igotzen du.

Ez da eskuzko `docker push` komandorik behar; kodea igotzearekin batera irudiaren bertsio berria eskuragarri egongo da minutu gutxiren buruan.
