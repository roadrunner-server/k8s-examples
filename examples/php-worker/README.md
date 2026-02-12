# RoadRunner PHP Worker Example

Minimal PHP worker application for RoadRunner, designed for Kubernetes and ArgoCD examples.

## Endpoints

- `GET /` -> `hello from roadrunner`
- `GET /health` -> `{"status":"ok"}`
- unknown routes -> `404`

## Build

```bash
docker build -t rr-php-worker-example:local .
```

## Run

```bash
docker run --rm -p 8080:8080 -p 2112:2112 -p 2114:2114 rr-php-worker-example:local
```

## Verify

```bash
curl -sS http://127.0.0.1:8080/
curl -sS http://127.0.0.1:8080/health
curl -sS 'http://127.0.0.1:2114/ready?plugin=http'
curl -sS 'http://127.0.0.1:2114/health?plugin=http'
```

## Notes

- The image includes a default RR config at `/etc/rr/.rr.yaml`.
- In Kubernetes, the Helm chart mounts `/etc/rr/.rr.yaml` from ConfigMap by default.
- The default command is:

```bash
rr serve -c /etc/rr/.rr.yaml -w /app
```
