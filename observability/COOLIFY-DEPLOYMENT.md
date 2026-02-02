# Coolify Deployment Guide

## Changes Made for Coolify Compatibility

### 1. Configuration Files Embedded in Images
Coolify doesn't support Docker Compose `configs` or relative path bind mounts. All configuration files are now baked into custom Docker images:

- **Grafana**: `Dockerfile.grafana` - includes datasources, dashboards, and provisioning
- **Prometheus**: `Dockerfile.prometheus` - includes prometheus.yml
- **Loki**: `Dockerfile.loki` - includes loki-config.yml
- **Tempo**: `Dockerfile.tempo` - includes tempo-config.yml
- **OTEL Collector**: `Dockerfile.otel` - includes otel-collector-config.yml

### 2. Known Issues

#### cAdvisor (Container Metrics)
**Status**: May fail in Coolify (12x restarts)

**Reason**: cAdvisor requires:
- `privileged: true` mode
- Access to `/dev/kmsg`
- Docker socket access

Coolify often restricts these for security. The service is configured with `restart: on-failure:3` to prevent infinite restart loops.

**Impact**: You won't see container-level metrics (CPU/memory per container) in Grafana.

**Solution**: This is optional. The rest of the stack works without it.

#### Node Exporter (Host Metrics)
**Status**: Should work, but may have limited metrics

**Reason**: Requires host filesystem access (`/proc`, `/sys`, `/`)

**Impact**: Host metrics may be incomplete in containerized environments.

## Deployment Steps

### 1. In Coolify UI
1. Create new "Docker Compose" service
2. Connect to your Git repository
3. Set the compose file path: `observability/docker-compose.yml`
4. Set base directory: `observability`

### 2. Environment Variables
Set these in Coolify's environment section:

#### Required (for Coolify reverse proxy):
```env
SERVICE_URL_GRAFANA_3000=https://grafana.yourdomain.com:3000
COOLIFY_FQDN=grafana.yourdomain.com
COOLIFY_URL=https://grafana.yourdomain.com
```

#### Optional (Grafana configuration):
```env
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=<your-secure-password>
GRAFANA_ANONYMOUS_ENABLED=false
GRAFANA_ROOT_URL=https://grafana.yourdomain.com
```

**Note**: Replace `yourdomain.com` with your actual domain for each deployment/server.

### 3. Deploy
Click "Deploy" - Coolify will:
1. Build all custom images with embedded configs
2. Create volumes for data persistence
3. Start all services

### 4. Verify Deployment

#### Check Grafana Datasources
1. Open Grafana (should be accessible via Coolify's proxy)
2. Go to **Configuration** → **Data Sources**
3. You should see:
   - ✅ Prometheus (default)
   - ✅ Loki
   - ✅ Tempo

If datasources are missing, the Grafana image didn't build correctly.

#### Check Service Health
In Coolify, verify these services are running:
- ✅ grafana
- ✅ prometheus
- ✅ loki
- ✅ tempo
- ✅ otel-collector
- ✅ node-exporter
- ⚠️ cadvisor (may fail - this is OK)

## Troubleshooting

### Datasources Not Appearing
**Cause**: Grafana provisioning files not embedded in image

**Fix**: 
1. Check `Dockerfile.grafana` exists
2. Verify build logs in Coolify
3. Rebuild the service

### Service Keeps Restarting
**Likely culprit**: cAdvisor

**Check**: Look at service logs in Coolify
- If it's cAdvisor: Safe to ignore, it's optional
- If it's another service: Check the logs for errors

### Can't Access Grafana
**Check**:
1. Coolify proxy configuration
2. Domain/FQDN settings
3. Port 3000 is exposed

### No Metrics/Logs/Traces
**Verify**:
1. Your .NET apps are sending to correct OTEL endpoint
2. OTEL Collector is running
3. Check OTEL Collector logs for errors

## Service Endpoints (Internal)

These are accessible within the Docker network:

| Service | Endpoint | Purpose |
|---------|----------|---------|
| Grafana | `http://grafana:3000` | UI |
| Prometheus | `http://prometheus:9090` | Metrics API |
| Loki | `http://loki:3100` | Logs API |
| Tempo | `http://tempo:3200` | Traces API |
| OTEL Collector | `http://otel-collector:4317` | OTLP gRPC |
| OTEL Collector | `http://otel-collector:4318` | OTLP HTTP |

## Connecting Your .NET Apps

Set these environment variables in your backend services:

```env
OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317
OTEL_SERVICE_NAME=yawmeya-api
```

Make sure your apps are on the same Docker network or can reach the OTEL Collector.

## Data Persistence

All data is stored in Docker volumes managed by Coolify:
- `grafana_data` - Dashboards, users, settings
- `prometheus_data` - Metrics (15 days retention)
- `loki_data` - Logs (31 days retention)
- `tempo_data` - Traces (31 days retention)

These persist across deployments unless you explicitly delete them.
