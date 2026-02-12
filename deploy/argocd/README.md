# Argo CD Example

This folder provides a ready-to-sync Argo CD application for the in-repo Helm chart.

## Files

- `application.yaml`: Argo CD `Application` definition.
- `values.yaml`: Example value overrides.

## Usage

1. Review and edit `values.yaml`:
- Set your application image and worker command.
- Adjust Gateway API hostnames and `gateway.className` (default: `cilium`).
- Enable or disable metrics and ServiceMonitor.

2. If you deploy from a fork or branch, update `repoURL` and `targetRevision` in `application.yaml`.

3. Apply the Argo CD application:

```bash
kubectl apply -f deploy/argocd/application.yaml
```

4. Verify in Argo CD UI that the app is `Synced` and `Healthy`.

5. Verify on your homelab:

```bash
curl -sS http://roadrunner.home.arpa/
curl -sS http://roadrunner.home.arpa/health
```

If your cluster does not expose `GatewayClass` `cilium`, either install/configure Gateway API support or switch to ingress compatibility mode (`gateway.enabled=false`, `ingress.enabled=true`).

## Default Example Values

- `image.repository`: `ghcr.io/roadrunner-server/rr-php-worker-example`
- `image.tag`: `latest`
- `gateway.className`: `cilium`
- `gateway.route.hostnames`: `roadrunner.home.arpa`

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
