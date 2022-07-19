{{/*
Chart name
*/}}
{{- define "app.name" -}}
{{- default .Chart.Name | trunc 63 }}
{{- end }}

{{/*
Chart name and version
*/}}
{{- define "app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Labels selector
*/}}
{{- define "app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "app.name" . }}
{{- end }}

{{/*
Labels
*/}}
{{- define "app.labels" -}}
helm.sh/release: {{ default (include "app.chart" .) .Release.Name }}
helm.sh/chart: {{ include "app.chart" . }}
{{ include "app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
