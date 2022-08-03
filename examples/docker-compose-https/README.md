# Setup TLS with docker-compose

## Upload config files

Open `Caddyfile` and replace `example.com` with your domain.

Upload `Caddyfile` and `docker-compose.yml`:

```bash
scp Caddyfile root@<ip-address>:Caddyfile
scp docker-compose.yml root@<ip-address>:docker-compose.yml
```

## SSH to your server

```bash
ssh root@<ip-address>
```

## Start docker

```bash
docker-compose up -d
```
