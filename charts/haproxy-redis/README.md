# haproxy-redis

A production-ready Helm chart that deploys a Redis master/replica StatefulSet fronted by an HAProxy Deployment. Applications connect to a single stable ClusterIP through HAProxy, which always routes to the master pod.

## Architecture

```
App → <release>-haproxy Service (ClusterIP :6379)
         └─ HAProxy Deployment (2 pods)
               └─ <release>-redis-0  (master)   ← balance first
                  <release>-redis-1  (replica)
                  <release>-redis-2  (replica)
```

## Quick start

```bash
helm repo add cluster-charts https://<your-github-username>.github.io/cluster-charts
helm repo update
helm install redis cluster-charts/haproxy-redis -n redis --create-namespace
```

Application connection string:
```
redis-haproxy.redis.svc.cluster.local:6379
```

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `namespaceOverride` | Override the target namespace | `""` |
| `redis.replicaCount` | Total Redis pods (1 master + N-1 replicas) | `3` |
| `redis.memoryFraction` | Fraction of memory limit used for `maxmemory` | `0.85` |
| `redis.resources` | CPU/memory requests and limits | see values.yaml |
| `redis.auth.enabled` | Enable Redis password authentication | `false` |
| `redis.auth.password` | Password (used when no existingSecret) | `""` |
| `redis.auth.existingSecret` | Name of a pre-existing Secret | `""` |
| `redis.auth.existingSecretKey` | Key within the Secret | `password` |
| `redis.persistence.enabled` | Enable persistent storage | `false` |
| `redis.persistence.size` | PVC size per pod | `1Gi` |
| `redis.persistence.storageClass` | StorageClass (empty = cluster default) | `""` |
| `redis.topologySpread.enabled` | Spread pods across nodes | `true` |
| `haproxy.replicaCount` | Number of HAProxy pods | `2` |
| `haproxy.service.type` | Kubernetes service type for HAProxy | `ClusterIP` |
| `haproxy.replicaFrontend.enabled` | Expose read replicas on a second port | `false` |
| `haproxy.replicaFrontend.port` | Port for the replica frontend | `6380` |

## Authentication

### Plain password
```yaml
redis:
  auth:
    enabled: true
    password: "yourpassword"
```

### Pre-existing Secret
```yaml
redis:
  auth:
    enabled: true
    existingSecret: "my-redis-secret"
    existingSecretKey: "password"
```

## Persistence

```yaml
redis:
  persistence:
    enabled: true
    size: 2Gi
    storageClass: "fast-ssd"  # omit to use cluster default
```

> **Note:** PVCs are not deleted on `helm uninstall` and must be cleaned up manually.

## Upgrading

```bash
helm upgrade redis cluster-charts/haproxy-redis -n redis -f my-values.yaml
```

## Uninstalling

```bash
helm uninstall redis -n redis
# If persistence was enabled, also clean up PVCs:
kubectl delete pvc -n redis -l app.kubernetes.io/instance=redis
```
