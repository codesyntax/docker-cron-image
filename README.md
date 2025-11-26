# docker-cron-image

A lightweight and adaptable Docker image designed to run scheduled tasks (cron jobs) inside a container.

This image is based on **Alpine Linux** and comes with the following tools pre-installed to simplify automation scripts:
*   `cronie` (Cron manager)
*   `bash`
*   `curl`
*   `docker-cli` (To manage other Docker containers from within Docker)

If run without any configuration, the image will display a warning message in the logs every minute, reminding the user to mount their own configuration.

---

## Usage Guide

You can download this image from the GitHub Container Registry (GHCR).

### Versioning Nomenclature (Tags)

The image follows this *tag* structure for version management:

*   **`latest`**: The current, most recent stable version.
*   **`YYYYMMDD-sha`** (e.g., `20251126-a1b2c3d`): A fixed version that includes the date and commit hash. This ensures that you always run the same image, even if `latest` is updated.

### Docker Compose Example

To run your cron jobs, **you must mount your `crontab` file** to the `/etc/crontabs/root` path inside the container.

Here is an example of a `docker-compose.yml` file:

```yaml
version: '3.8'

services:
  cron-worker:
    image: ghcr.io/codesyntax/docker-cron-image:latest
    container_name: my-cron-job
    restart: unless-stopped
    volumes:
      # Mount the file with your cron jobs (overwrite)
      - ./my-crontab.txt:/crontab.txt:ro

      # Mount the Docker socket (to use Docker commands)
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
