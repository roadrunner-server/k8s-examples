{{- define "roadrunner.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "roadrunner.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "roadrunner.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "roadrunner.labels" -}}
helm.sh/chart: {{ include "roadrunner.chart" . }}
{{ include "roadrunner.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "roadrunner.selectorLabels" -}}
app.kubernetes.io/name: {{ include "roadrunner.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "roadrunner.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "roadrunner.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "roadrunner.configMapName" -}}
{{- if .Values.roadrunner.existingConfigMap -}}
{{- .Values.roadrunner.existingConfigMap -}}
{{- else -}}
{{- printf "%s-config" (include "roadrunner.fullname" .) -}}
{{- end -}}
{{- end -}}
