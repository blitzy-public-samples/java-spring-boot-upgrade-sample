{{/*
HUMAN TASKS:
1. Verify that the Chart.yaml and values.yaml files are in the correct locations relative to this template
2. Ensure Helm v3.12.3 or later is installed for sprig template functions compatibility
3. Review naming conventions align with your organization's standards
*/}}

{{/*
Requirement Addressed: Spring Boot Application Containerization
Generates the chart name, using either the default from Chart.yaml or an override from values.yaml
*/}}
{{- define "spring-boot-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Requirement Addressed: Spring Boot Application Containerization
Generates a fully qualified app name combining release name and chart name.
If fullnameOverride is specified in values.yaml, it will be used instead.
*/}}
{{- define "spring-boot-app.fullname" -}}
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
Requirement Addressed: Spring Boot Application Containerization
Generates common Kubernetes labels following Kubernetes recommended label schema:
https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/
*/}}
{{- define "spring-boot-app.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/name: {{ include "spring-boot-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Requirement Addressed: Spring Boot Application Containerization
Generates the selector labels that are used by Kubernetes services and deployments
for pod selection. These are a subset of the common labels that are immutable.
*/}}
{{- define "spring-boot-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "spring-boot-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}