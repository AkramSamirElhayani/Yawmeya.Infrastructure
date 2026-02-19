# Yawmeya Observability Stack

Complete observability solution for the Yawmeya application using the LGTM stack (Loki, Grafana, Tempo, Mimir/Prometheus).

## Components

| Service | Port | Description |
|---------|------|-------------|
| **Grafana** | 3000 | Visualization and dashboards |
| **Prometheus** | 9090 | Metrics collection and storage |
| **Loki** | 3100 | Log aggregation |
| **Tempo** | 3200, 4317, 4318 | Distributed tracing |
| **OTEL Collector** | 4316 (gRPC), 4319 (HTTP) | OpenTelemetry data collection |
| **Node Exporter** | 9100 | Host/VPS metrics |

## Quick Start (Local Development)

### 1. Start the Observability Stack

```bash
cd infrastructure/observability
docker-compose up -d
```

### 2. Start the Backend Applications

The AppHost is already configured to send telemetry to the local OTEL Collector:

```bash
cd backend/src/Yawmeya.AppHost
dotnet run
```

### 3. Access Grafana

Open http://localhost:3000 in your browser.

- **Default credentials**: admin / admin
- **Pre-configured dashboards**:
  - VPS / Host Metrics
  - Docker Containers
  - .NET Application Metrics
  - Logs Explorer

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         .NET Applications                            │
│                    (yawmeya-api, yawmeya-admin-api)                 │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ OTLP (gRPC/HTTP)
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        OTEL Collector                                │
│                   (Receives, processes, exports)                     │
└─────────────────────────────────────────────────────────────────────┘
           │                        │                        │
           │ Metrics                │ Logs                   │ Traces
           ▼                        ▼                        ▼
    ┌──────────────┐        ┌──────────────┐        ┌──────────────┐
    │  Prometheus  │        │     Loki     │        │    Tempo     │
    │   (Metrics)  │        │    (Logs)    │        │   (Traces)   │
    └──────────────┘        └──────────────┘        └──────────────┘
           │                        │                        │
           └────────────────────────┼────────────────────────┘
                                    │
                                    ▼
                          ┌──────────────────┐
                          │     Grafana      │
                          │  (Visualization) │
                          └──────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                     Infrastructure Monitoring                        │
├─────────────────────────────────────────────────────────────────────┤
│  Node Exporter ──────────────────────────────────────► Prometheus   │
│  (Host metrics: CPU, Memory, Disk, Network)                         │
└─────────────────────────────────────────────────────────────────────┘
```

## Pre-built Dashboards

### 1. VPS / Host Metrics
- CPU usage (overall and by mode)
- Memory usage
- Disk usage and I/O
- Network traffic
- System load

### 2. .NET Application Metrics
- Request rate by service
- Request latency percentiles (P50, P95, P99)
- Error rate (5xx responses)
- Memory usage and GC metrics
- Thread pool statistics
- Database connection pool

### 3. Logs Explorer
- Log volume by level
- Full-text log search
- Filter by service and log level
- Trace correlation

## Configuration

### Environment Variables

Copy `.env.example` to `.env` and customize:

```bash
cp .env.example .env
```

| Variable | Default | Description |
|----------|---------|-------------|
| `GRAFANA_ADMIN_USER` | admin | Grafana admin username |
| `GRAFANA_ADMIN_PASSWORD` | admin | Grafana admin password |
| `GRAFANA_ROOT_URL` | http://localhost:3000 | Grafana public URL |
| `GRAFANA_ANONYMOUS_ENABLED` | true | Allow anonymous access |

### .NET Application Configuration

The AppHost automatically configures:

```csharp
.WithEnvironment("OTEL_EXPORTER_OTLP_ENDPOINT", "http://localhost:4316")
.WithEnvironment("OTEL_SERVICE_NAME", "yawmeya-api")
```

For production, set these environment variables in your deployment configuration.

## Production Deployment (Coolify)

### 1. Deploy the Stack

1. Create a new Docker Compose service in Coolify
2. Point to `infrastructure/observability/docker-compose.yml`
3. Set environment variables in Coolify UI

### 2. Configure Backend Applications

Add these environment variables to your backend services:

```
OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317
OTEL_SERVICE_NAME=yawmeya-api
```

### 3. Secure Grafana

For production, update `.env`:

```
GRAFANA_ADMIN_PASSWORD=<strong-password>
GRAFANA_ANONYMOUS_ENABLED=false
GRAFANA_ROOT_URL=https://grafana.yourdomain.com
```

## Data Retention

| Component | Retention | Storage |
|-----------|-----------|---------|
| Prometheus | 15 days | Docker volume |
| Loki | 31 days | Docker volume |
| Tempo | 31 days | Docker volume |
| Grafana | Persistent | Docker volume |

## Troubleshooting

### No metrics appearing

1. Check OTEL Collector is running: `docker logs otel-collector`
2. Verify endpoint: `curl http://localhost:8888/metrics`
3. Check Prometheus targets: http://localhost:9090/targets

### No logs appearing

1. Check Loki is healthy: `curl http://localhost:3100/ready`
2. Check OTEL Collector logs: `docker logs otel-collector`
3. Verify log pipeline in Grafana Explore

### No traces appearing

1. Check Tempo is healthy: `curl http://localhost:3200/ready`
2. Verify trace export in OTEL Collector logs
3. Check Tempo data source in Grafana

## Useful Commands

```bash
# View all logs
docker-compose logs -f

# Restart a specific service
docker-compose restart grafana

# Check service health
docker-compose ps

# Stop all services
docker-compose down

# Stop and remove volumes (CAUTION: deletes all data)
docker-compose down -v
```
