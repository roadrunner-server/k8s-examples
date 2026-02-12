# Argo CD Example

This folder provides a ready-to-sync Argo CD application for the in-repo Helm chart.

## Files

- `application.yaml`: Argo CD `Application` definition.
- `values.yaml`: Example value overrides.

## Usage

1. Review and edit `values.yaml`:
- Set your application image and worker command.
- Choose exposure mode (Gateway API, Ingress, or MetalLB LoadBalancer service).
- Enable or disable metrics and ServiceMonitor.

2. If you deploy from a fork or branch, update `repoURL` and `targetRevision` in `application.yaml`.

3. Apply the Argo CD application:

```bash
kubectl apply -f deploy/argocd/application.yaml
```

4. Verify in Argo CD UI that the app is `Synced` and `Healthy`.

5. Verify on your homelab:

```bash
kubectl -n roadrunner get svc roadrunner -w
curl -sS http://<external-ip>/
curl -sS http://<external-ip>/health
```

If you prefer Gateway API mode, set `gateway.enabled=true`, configure hostnames, and ensure a controller/GatewayClass (for example `cilium`) exists.

## MetalLB Mode

Use this mode when your cluster has MetalLB but no Gateway API controller:

```yaml
service:
  type: LoadBalancer

gateway:
  enabled: false

ingress:
  enabled: false
```

After sync:

```bash
kubectl -n roadrunner get svc roadrunner -w
curl -sS http://<external-ip>/
curl -sS http://<external-ip>/health
```

## Default Example Values

- `image.repository`: `ghcr.io/roadrunner-server/rr-php-worker-example`
- `image.tag`: `latest`
- `service.type`: `LoadBalancer`
- `gateway.enabled`: `false`
- `ingress.enabled`: `false`

## Notes

- The chart runs RoadRunner with:

```bash
rr serve -c /etc/rr/.rr.yaml -w /app
```

- The chart mounts `/etc/rr/.rr.yaml` from a ConfigMap by default. This allows GitOps-managed RR config updates without rebuilding the image.
- Probes use the status plugin endpoints on the status port:
- readiness: `/ready?plugin=http`
- liveness: `/health?plugin=http`

- Status and RPC ports are not exposed by Service by default.
- Gateway API is the default north-south exposure model.
- This requires Gateway API CRDs and a Gateway controller (for example, Cilium Gateway API support).
- Ingress is still available as a compatibility fallback (`ingress.enabled=true` and `gateway.enabled=false`).
- If ArgoCD app health remains `Progressing` with message `Waiting for controller`, check whether `Gateway`/`HTTPRoute` are still rendered and whether any `GatewayClass` exists.
