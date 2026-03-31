# cluster-charts

A collection of Helm charts that make Kubernetes easier on our lives.

## Usage

```bash
helm repo add cluster-charts https://ChildRescueCoalition.github.io/cluster-charts
helm repo update
```

## Available Charts

| Chart | Description | Version |
|-------|-------------|---------|
| [haproxy-redis](./charts/haproxy-redis/README.md) | Redis StatefulSet with HAProxy frontend | 0.1.0 |

## Releasing a New Chart Version

1. Make changes inside `charts/<chart-name>/`
2. Bump `version` in `Chart.yaml`
3. Commit and push to `main`
4. The GitHub Actions workflow packages and publishes automatically

## Adding a New Chart

1. Create `charts/<chart-name>/` with a valid `Chart.yaml`
2. The release workflow picks up all charts automatically
