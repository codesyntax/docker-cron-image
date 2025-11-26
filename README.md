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
services:
  cron-worker:
    image: ghcr.io/codesyntax/docker-cron-image:latest
    container_name: cron-worker
    restart: unless-stopped
    volumes:
      - ./crontab.txt:/crontab.txt:ro
      - /var/run/docker.sock:/var/run/docker.sock
```

### ⚠️ Important configuration notes

When creating your `crontab.txt` file, keep these three points in mind:

1.  **Redirect output:** In order for Docker to read the logs, command output must be redirected to `/proc/1/fd/1`.
2.  **Empty line:** Always leave an empty line at the end of the file (otherwise cron will not read it).
3.  **Docker Socket:** Mounting `/var/run/docker.sock` in the `docker-compose` file is essential if your cron jobs need to execute `docker` commands (e.g., `docker restart nginx`). This grants the container permission to control the Host machine's Docker engine.

Example (`crontab.txt`):
```text
# Example: Restart Nginx container every day at 03:00
0 3 * * * docker restart my-nginx > /proc/1/fd/1 2>&1
```

## Development Guide

This project features an integrated **CI/CD** (Continuous Integration / Continuous Deployment) system using GitHub Actions.

### GitHub Actions Workflow

Whenever changes are made to the repository, the process defined in the `.github/workflows/docker-publish.yml` file is triggered.

The steps of this workflow are as follows:

1.  **Trigger:** Automatically activated when a *push* is made to the `main` branch.
2.  **Build:** Builds the Docker image using the `Dockerfile`.
3.  **Tagging:** Applies two tags to the image:
    * `latest`
    * A unique tag containing the date and commit hash.
4.  **Publish:** Uploads the image to the **GitHub Container Registry (GHCR)**.

No manual `docker push` command is required; simply pushing the code will make the new version of the image available within a few minutes.
