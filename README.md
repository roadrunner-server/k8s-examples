# k8s-examples

Kubernetes deployment examples for RoadRunner, including Helm chart templates and Argo CD manifests.

<img width="3234" height="1428" alt="image" src="https://github.com/user-attachments/assets/ca17a0a2-998e-4018-b99f-cd5c554afbe4" />


## Included Assets

- `deploy/charts/roadrunner`: Helm chart for RoadRunner deployment.
- `deploy/argocd`: Argo CD Application and values example.
- `examples/php-worker`: Minimal RR PHP worker app, Dockerfile, and local run guide.
- `.github/workflows/charts.yml`: CI validation for chart rendering and Gateway/Ingress checks.
- `.github/workflows/example-image.yml`: CI build/publish of multi-arch RR PHP worker example image.

## Kubernetes and Argo CD

This repository includes a Helm chart and Argo CD example manifests for GitOps-based deployments.

- Chart: `deploy/charts/roadrunner`
- Argo CD example: `deploy/argocd`
- PHP worker image source: `examples/php-worker`

### Prerequisites

- Kubernetes `>= 1.26`
- Gateway API CRDs installed
- Cilium Gateway controller with `GatewayClass` `cilium`
- Argo CD installed (if using Argo)
- A container image that includes:
  - your PHP application code
  - required PHP extensions
  - RoadRunner binary (`rr`)

### Example image

This repo includes a minimal example image at `examples/php-worker`:

- Worker routes:
  - `GET /` -> `hello from roadrunner`
  - `GET /health` -> `{"status":"ok"}`
  - all other routes -> `404`
- Default RR config in the image: `/etc/rr/.rr.yaml`
- CI publish target: `ghcr.io/roadrunner-server/rr-php-worker-example`

Build locally:

```bash
docker build -t rr-php-worker-example:local ./examples/php-worker
```

Run locally:

```bash
docker run --rm -p 8080:8080 -p 2114:2114 rr-php-worker-example:local
curl -sS http://127.0.0.1:8080/
curl -sS http://127.0.0.1:8080/health
curl -sS 'http://127.0.0.1:2114/ready?plugin=http'
curl -sS 'http://127.0.0.1:2114/health?plugin=http'
```

### Helm install

```bash
helm upgrade --install roadrunner ./deploy/charts/roadrunner -n roadrunner --create-namespace
```

### Argo CD sync

1. Edit `deploy/argocd/application.yaml` (`repoURL`, `targetRevision`) if needed.
2. Edit `deploy/argocd/values.yaml` (image, worker command, exposure mode, metrics settings).
3. Apply:

```bash
kubectl apply -f deploy/argocd/application.yaml
```

The Argo CD example values are preconfigured for:

- image: `ghcr.io/roadrunner-server/rr-php-worker-example:latest`
- Service type: `LoadBalancer` (MetalLB-friendly)
- `gateway.enabled: false`
- `ingress.enabled: false`

### MetalLB profile (no Gateway controller)

If your cluster uses MetalLB and does not run a Gateway API controller, use:

```yaml
service:
  type: LoadBalancer

gateway:
  enabled: false

ingress:
  enabled: false
```

Then sync ArgoCD and check:

```bash
kubectl -n roadrunner get svc roadrunner -w
curl -sS http://<external-ip>/
curl -sS http://<external-ip>/health
```

### Probe and metrics defaults

- Command: `rr serve -c /etc/rr/.rr.yaml -w /app`
- Readiness probe: `/ready?plugin=http` on status port
- Liveness probe: `/health?plugin=http` on status port
- Config file is mounted at `/etc/rr/.rr.yaml`
- Config changes trigger pod rollout via checksum annotation

The chart mounts `/etc/rr/.rr.yaml` from a ConfigMap by default. This can override the image-baked RR config at runtime.

### Gateway API default

- Gateway API is the default north-south exposure model.
- Default `GatewayClass` is `cilium`.
- The chart renders `Gateway` and `HTTPRoute` by default.
- Ingress remains available as fallback (`ingress.enabled=true` with `gateway.enabled=false`).

### Troubleshooting

- ArgoCD `Progressing` with health details `Waiting for controller` means Gateway resources are enabled but no Gateway controller is reconciling them.
- `kubectl get gatewayclass` returning no resources indicates Gateway API objects will not become `Healthy` until a controller/GatewayClass is installed.
- If ArgoCD still applies old values after local edits, ensure changes are committed and pushed to the revision ArgoCD tracks.
