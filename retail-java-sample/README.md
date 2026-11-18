# Retail API sample (Java 21 / Spring Boot)

A small retail product catalogue API demonstrating secure defaults, database efficiency,
and operational observability. It is a starter sample, not a production-ready commerce system.

## Features
- REST endpoints to list, fetch, and create products.
- Bean Validation on incoming product data.
- Stateless OAuth2/JWT resource-server security with read/write scopes.
- Bounded pagination (maximum 100 rows), read-only transactions, database indexes,
  optimistic locking, and a configurable Hikari connection pool.
- Actuator health, metrics, and Prometheus endpoint.
- Correlation ID response header and MDC logging context; untrusted IDs are validated.
- Centralized error responses that do not expose stack traces.

## Run
Requirements: JDK 21, Maven, PostgreSQL.

Create a database and a database user, then apply `src/main/resources/db/migration/V1__create_products.sql`.
Set environment variables:
- `DB_URL`
- `DB_USERNAME`
- `DB_PASSWORD`
- `JWT_ISSUER_URI` (issuer that publishes a valid OIDC discovery/JWKS endpoint)

Run:
```bash
mvn test
mvn spring-boot:run
```

The API expects a valid bearer JWT from the configured issuer. Tokens need `products.read`
for GET endpoints and `products.write` for POST. Configure your identity provider to issue
these scopes. Do not disable authentication outside local isolated tests.

## Endpoints
- `GET /api/v1/products?page=0&size=25`
- `GET /api/v1/products/{uuid}`
- `POST /api/v1/products`
- `GET /actuator/health`
- `GET /actuator/prometheus` (protect this endpoint at the network/platform layer)

Example create body:
```json
{"sku":"SKU-100","name":"Coffee","price":12.50,"stock":20}
```

## Production hardening checklist
1. Store secrets in a secret manager; never commit credentials or signing keys.
2. Restrict actuator/Prometheus access to an internal network and authenticated monitoring.
3. Add rate limiting, request-size limits, CORS allow-list, and audit events for writes.
4. Use Flyway/Liquibase migrations in the deployment pipeline; keep schema validation enabled.
5. Add database unique constraints and handle concurrent duplicate-SKU inserts (the DB constraint
   is authoritative; translate its violation to HTTP 409 in a production implementation).
6. Add distributed tracing/export (OTLP), dashboards, alerts, and SLOs.
7. Add integration tests against PostgreSQL and security tests for missing/invalid scopes.
8. Add idempotency keys for order/payment creation; never log payment card data or access tokens.
9. Use least-privilege DB credentials, TLS, backups, and dependency/image vulnerability scanning.

## Performance notes
- Page size is bounded to avoid unbounded result sets.
- `open-in-view` is disabled to avoid lazy database work during response serialization.
- Read paths use read-only transactions.
- Indexes support SKU lookup/uniqueness and active catalogue sorting/filtering.
- Pool size is configurable; tune from load-test evidence rather than increasing blindly.
