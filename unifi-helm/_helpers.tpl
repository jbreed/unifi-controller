{{/*
Expand the name of the chart.
*/}}
{{- define "unifi-network-application.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "unifi-network-application.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "unifi-network-application.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "unifi-network-application.labels" -}}
helm.sh/chart: {{ include "unifi-network-application.chart" . }}
{{ include "unifi-network-application.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "unifi-network-application.selectorLabels" -}}
app.kubernetes.io/name: {{ include "unifi-network-application.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Chart name and version
*/}}
{{- define "unifi-network-application.chart" -}}
{{ .Chart.Name }}-{{ .Chart.Version }}
{{- end -}}

