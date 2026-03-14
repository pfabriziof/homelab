# homelab
Self-hosted services for my personal use, running on Docker Compose with automatic HTTPS and Tailscale-based private access.

## Architecture

All services are exposed exclusively through a **Tailscale** VPN tunnel. **Traefik** acts as the reverse proxy, running inside the Tailscale network namespace, and issues TLS certificates via Let's Encrypt DNS challenge against **AWS Route 53**. **CoreDNS** resolves the local domain to the Traefik IP for all clients on the Tailnet.

```
Client (on Tailnet)
  └─► CoreDNS (resolves *.yourdomain → Traefik IP)
        └─► Traefik (TLS termination, reverse proxy)
              └─► Services (homepage, komodo, it-tools, stirling-pdf, …)
```

## Services

### Networking (`networking/`)
| Service | Description |
|---|---|
| **Traefik** | Reverse proxy with automatic HTTPS (Let's Encrypt via Route 53 DNS challenge). Runs inside the Tailscale network namespace. |
| **Tailscale** | VPN sidecar. All inbound traffic must come through the Tailnet. |
| **CoreDNS** | Local DNS server that resolves the homelab domain to the Traefik container IP. Also runs inside the Tailscale network namespace. |

### Monitoring (`monitoring/`)
| Service | Description |
|---|---|
| **Komodo** | Container & infrastructure management platform (core + periphery agents). Backed by FerretDB on PostgreSQL. |
| **Dozzle** | Real-time Docker log viewer *(currently disabled)*. |

### Dashboard (`homepage/`)
| Service | Description |
|---|---|
| **Homepage** | Customisable start page that aggregates service status, Docker stats, bookmarks, and widgets. |

### Utilities (`utilities/`)
| Service | Description |
|---|---|
| **IT-Tools** | Collection of handy developer/sysadmin tools (encoders, converters, generators, …). |
| **Stirling PDF** | Self-hosted PDF manipulation suite (merge, split, convert, OCR, …). |

## Prerequisites

- Docker & Docker Compose v2
- A domain managed in **AWS Route 53**
- A **Tailscale** account and auth key
- A `proxy-tier` Docker network created on the host:
  ```bash
  docker network create proxy-tier
  ```

## Configuration

Each stack has its own `.env` file. Copy the examples and fill in the values:

```bash
cp networking/.env.example networking/.env
cp monitoring/.env.example monitoring/.env
```

### `networking/.env`

| Variable | Description |
|---|---|
| `MAIN_DOMAIN` | Your base domain (e.g. `home.example.com`) |
| `TS_AUTHKEY` | Tailscale auth key |
| `ADMIN_EMAIL` | Email for Let's Encrypt notifications |
| `AWS_REGION` | AWS region of the Route 53 hosted zone |
| `AWS_HOSTED_ZONE_ID` | Route 53 hosted zone ID |
| `AWS_ACCESS_KEY_ID` | AWS access key with Route 53 permissions |
| `AWS_SECRET_ACCESS_KEY` | Corresponding AWS secret key |

### `monitoring/.env`

| Variable | Description |
|---|---|
| `MAIN_DOMAIN` | Your base domain |
| `KOMODO_DB_USERNAME` | FerretDB/PostgreSQL username for Komodo |
| `KOMODO_DB_PASSWORD` | FerretDB/PostgreSQL password for Komodo |
| `COMPOSE_COMODO_BACKUPS_PATH` | Host path for Komodo backups |
| `FERRETDB_IMAGE_TAG` | FerretDB image tag |
| `FERRETDB_POSTGRESQL_IMAGE_TAG` | FerretDB PostgreSQL image tag |
| `PERIPHERY_PASSKEYS` | Passkey(s) for Komodo periphery agents |

### Komodo config

Copy `monitoring/komodo/config/core.config.toml.example` to `monitoring/komodo/config/core.config.toml` and adjust the values (admin credentials, JWT TTL, OAuth, etc.).

### CoreDNS

Copy `networking/coredns/Corefile.example` to `networking/coredns/Corefile` and replace the placeholders with your domain and Traefik container IP.

## Usage

A `Makefile` is provided for convenience:

```bash
make help          # List all available targets

make networking ARGS="up -d"   # Start networking stack
make monitoring ARGS="up -d"   # Start monitoring stack

make all-up        # Start all stacks
make all-down      # Stop all stacks
```

> The homepage and utilities stacks can be started directly with `docker compose` from their respective directories.

## Service URLs

Once running, services are available at (replace `yourdomain` with `MAIN_DOMAIN`):

| URL | Service |
|---|---|
| `https://homepage.yourdomain` | Homepage dashboard |
| `https://traefik.yourdomain` | Traefik dashboard |
| `https://komodo.yourdomain` | Komodo |
| `https://it-tools.yourdomain` | IT-Tools |
| `https://stirling-pdf.yourdomain` | Stirling PDF |

> All URLs are only reachable from within the Tailnet.
