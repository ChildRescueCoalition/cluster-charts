{{/*
Expand the name of the chart.
*/}}
{{- define "haproxy-redis.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "haproxy-redis.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Namespace — falls back to the release namespace.
*/}}
{{- define "haproxy-redis.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride }}
{{- end }}

{{/*
Chart label.
*/}}
{{- define "haproxy-redis.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "haproxy-redis.labels" -}}
helm.sh/chart: {{ include "haproxy-redis.chart" . }}
{{ include "haproxy-redis.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "haproxy-redis.selectorLabels" -}}
app.kubernetes.io/name: {{ include "haproxy-redis.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Redis selector labels.
*/}}
{{- define "haproxy-redis.redis.selectorLabels" -}}
app.kubernetes.io/name: {{ include "haproxy-redis.name" . }}-redis
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
HAProxy selector labels.
*/}}
{{- define "haproxy-redis.haproxy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "haproxy-redis.name" . }}-haproxy
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Compute Redis maxmemory from limits.memory × memoryFraction.
Supports Mi and Gi suffixes, emits an integer mb value.
*/}}
{{- define "haproxy-redis.maxmemory" -}}
{{- $limit := .Values.redis.resources.limits.memory -}}
{{- $fraction := .Values.redis.memoryFraction | float64 -}}
{{- $mb := 0 -}}
{{- if hasSuffix "Gi" $limit -}}
  {{- $num := $limit | trimSuffix "Gi" | float64 -}}
  {{- $mb = mulf (mulf $num 1024.0) $fraction | int -}}
{{- else if hasSuffix "Mi" $limit -}}
  {{- $num := $limit | trimSuffix "Mi" | float64 -}}
  {{- $mb = mulf $num $fraction | int -}}
{{- else -}}
  {{- $mb = 220 -}}
{{- end -}}
{{- printf "%dmb" $mb -}}
{{- end }}

{{/*
DNS name of the master pod (redis-0).
*/}}
{{- define "haproxy-redis.masterDNS" -}}
{{- printf "%s-redis-0.%s-redis-headless.%s.svc.cluster.local" .Release.Name .Release.Name (include "haproxy-redis.namespace" .) -}}
{{- end }}

{{/*
Name of the auth Secret.
*/}}
{{- define "haproxy-redis.authSecretName" -}}
{{- .Values.redis.auth.existingSecret | default (printf "%s-auth" .Release.Name) -}}
{{- end }}
