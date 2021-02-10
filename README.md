# Certbot Container
This container build opon the Cerbot container.
It add the [certbot-dns-transip](https://certbot-dns-transip.readthedocs.io/en/stable/installation.html) plugin.
For further documentation read the [official docs](https://certbot.eff.org/docs/install.html#running-with-docker).

## Storage
You can save the data from the Certbot outside of the container:

- `/etc/letsencrypt` = Configuration
- `/var/lib/letsencrypt` = Libs

Is the general config directory is not mounted, a default is placed.
If the directory is mounted the data is not copied so to not overwrite your config.

## Usage
You can use this image with docker run and docker-compose.
Below are examples for both.

### Docker run
The most basic docker run config is:
```
docker run baskraai/certbot-dns-transip certonly
```
