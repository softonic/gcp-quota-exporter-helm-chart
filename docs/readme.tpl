# {{ .Project.ShortName }}

[{{ .Project.Name }}]({{ .Project.URL }}) - {{ .Project.Description }}

As we want to get the resource quotas of our GCP projects and check when we are exhausting the limits we need
to get the data from GCP and export them somewhere, in this case this exports the data to Prometheus.

It's installed as a dependency in the main chart, but if you want to do all the steps manually, which helps to understand
how it works, you can follow the next steps:

## TL;DR;

```console
$ helm repo add {{ .Repository.Name }} {{ .Repository.URL }}
$ helm repo update
$ helm install {{ .Release.Name }} {{ .Repository.Name }}/{{ .Chart.Name }} -n {{ .Release.Namespace }}{{ with .Chart.Version }} --version={{.}}{{ end }}
```

## Introduction

This chart deploys {{ .Project.App }} on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites
{{ range .Prerequisites }}
- {{ . }}
{{- end }}

### Example of how to create a Service Account file

```bash
gcloud iam service-accounts create gcp-quota-exporter --project ${GCP_PROJECT}
gcloud projects add-iam-policy-binding ${GCP_PROJECT} \
--member "serviceAccount:gcp-quota-exporter@${GCP_PROJECT}.iam.gserviceaccount.com" \
--role "roles/compute.instanceAdmin"
gcloud iam service-accounts keys create service-account-gcp-quota-exporter.json \
--iam-account "gcp-quota-exporter@${GCP_PROJECT}.iam.gserviceaccount.com"
```

### Launch exporter as a test
```bash
docker run -it --rm \
-p 9592:9592 \
-v $(pwd)/service-account-gcp-quota-exporter.json:/app/credentials.json \
-e GOOGLE_APPLICATION_CREDENTIALS=/app/credentials.json \
-e GOOGLE_PROJECT_ID=${GCP_PROJECT} mintel/gcp-quota-exporter
```

### Check exporter output
```bash
curl localhost:9592/metrics
# HELP gcp_quota_exporter_build_info A metric with a constant '1' value labeled by version, revision, branch, and goversion from which gcp_quota_exporter was built.
# TYPE gcp_quota_exporter_build_info gauge
gcp_quota_exporter_build_info{branch="",goversion="go1.12.5",revision="",version=""} 1
# HELP gcp_quota_limit quota limits for GCP components
# TYPE gcp_quota_limit gauge
gcp_quota_limit{metric="AUTOSCALERS",project="PROJECT_NAME",region="asia-east1"} 500
gcp_quota_limit{metric="AUTOSCALERS",project="PROJECT_NAME",region="asia-east2"} 500
gcp_quota_limit{metric="AUTOSCALERS",project="PROJECT_NAME",region="asia-northeast1"} 500
gcp_quota_limit{metric="AUTOSCALERS",project="PROJECT_NAME",region="asia-northeast2"} 50
gcp_quota_limit{metric="AUTOSCALERS",project="PROJECT_NAME",region="asia-northeast3"} 50
gcp_quota_limit{metric="AUTOSCALERS",project="PROJECT_NAME",region="asia-south1"} 500
gcp_quota_limit{metric="AUTOSCALERS",project="PROJECT_NAME",region="asia-southeast1"} 500
...
```

## Installing the Chart

This uses helm, the idea is to add this as a subchart of your preferred monitoring chart, but it can be launched independently as well:

To install the chart with the release name `{{ .Release.Name }}`:

```console
$ helm install {{ .Release.Name }} {{ .Repository.Name }}/{{ .Chart.Name }} -n {{ .Release.Namespace }}{{ with .Chart.Version }} --version={{.}}{{ end }}
```

The command deploys {{ .Project.App }} on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **NOTE**: The deployment expects you to provide a secret with the service account to mount in the pod.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `{{ .Release.Name }}`:

```console
$ helm delete {{ .Release.Name }} -n {{ .Release.Namespace }}
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the `{{ .Chart.Name }}` chart and their default values.

{{ .Chart.Values }}

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example:

```console
$ helm install {{ .Release.Name }} {{ .Repository.Name }}/{{ .Chart.Name }} -n {{ .Release.Namespace }}{{ with .Chart.Version }} --version={{.}}{{ end }} --set {{ .Chart.ValuesExample }}
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while
installing the chart. For example:

```console
$ helm install {{ .Release.Name }} {{ .Repository.Name }}/{{ .Chart.Name }} -n {{ .Release.Namespace }}{{ with .Chart.Version }} --version={{.}}{{ end }} --values values.yaml
```

## Grafana Dashboard

Once you have this in Prometheus you can start using it and create alerts or generate Grafana Dashboards for detect when you are reaching a limit,
in the `grafana` folder you have an example of a simple dashboard that does some basic Prometheus queries.

This documentation has been generated using `chart-doc-gen` with the command:

```console
chart-doc-gen -d ./docs/doc.yaml -t ./docs/readme.tpl -v=./values.yaml > README.md
```