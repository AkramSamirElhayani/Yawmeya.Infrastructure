# Keycloak with custom theme and realm configuration
FROM quay.io/keycloak/keycloak:26.0 AS builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_DB=postgres

WORKDIR /opt/keycloak

# Copy custom theme
COPY themes/yawmeya /opt/keycloak/themes/yawmeya

# Copy realm configuration for import.
COPY yawmeya-realm.json /opt/keycloak/data/import/yawmeya-realm.json

# Build optimized Keycloak
RUN /opt/keycloak/bin/kc.sh build

# Production stage
FROM quay.io/keycloak/keycloak:26.0

# Copy built artifacts from builder
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Environment variables (can be overridden at runtime)
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_DB=postgres

# Expose ports
EXPOSE 8080
EXPOSE 8443

# Note: Health check disabled in Dockerfile - configure in Coolify UI instead
# Coolify will handle health checks via external monitoring

# Default entrypoint with import
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized", "--import-realm"]
