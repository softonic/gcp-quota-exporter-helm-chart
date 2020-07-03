# gcp-quota-exporter

[Google Cloud Platform Quota Exporter](https://github.com/softonic/gcp-quota-exporter-helm-chart) - Obtains the resource quotas from a GCP project and allows to export them to Prometheus

As we want to get the resource quotas of our GCP projects and check when we are exhausting the limits we need
to get the data from GCP and export them somewhere, in this case this exports the data to Prometheus.

It's installed as a dependency in the main chart, but if you want to do all the steps manually, which helps to understand
how it works, you can follow the next steps:

## TL;DR;

```console
$ helm repo add gcp-quota-exporter https://hub.helm.sh/charts/softonic/gcp-quota-exporter
$ helm repo update
$ helm install  gcp-quota-exporter/gcp-quota-exporter -n  --version=2.0.0
```

## Introduction

This chart deploys gcp-quota-exporter on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- You need a service account with `roles/compute.instanceAdmin` permissions

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

To install the chart with the release name ``:

```console
$ helm install  gcp-quota-exporter/gcp-quota-exporter -n  --version=2.0.0
```

The command deploys gcp-quota-exporter on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **NOTE**: The deployment expects you to provide a secret with the service account to mount in the pod.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the ``:

```console
$ helm delete  -n 
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the `gcp-quota-exporter` chart and their default values.

|             Parameter             |                                                                         Description                                                                          |           Default           |
|-----------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------|
| replicaCount                      | desired number of pods                                                                                                                                       | `1`                         |
| image.repository                  | container image repository                                                                                                                                   | `mintel/gcp-quota-exporter` |
| image.pullPolicy                  | container image pull policy                                                                                                                                  | `IfNotPresent`              |
| image.tag                         | container image tag                                                                                                                                          | `""`                        |
| imagePullSecrets                  | container image pull secrets                                                                                                                                 | `[]`                        |
| nameOverride                      |                                                                                                                                                              | `""`                        |
| fullnameOverride                  |                                                                                                                                                              | `""`                        |
| gcpProject                        | Google Cloud Platform project name to scrape data from                                                                                                       | `""`                        |
| serviceAccount.create             | Specifies whether a service account should be created                                                                                                        | `true`                      |
| serviceAccount.annotations        | Annotations to add to the service account                                                                                                                    | `{}`                        |
| serviceAccount.name               | The name of the service account to use. If not set and create is true, a name is generated using the fullname template                                       | ``                          |
| podSecurityContext                |                                                                                                                                                              | `{}`                        |
| securityContext                   |                                                                                                                                                              | `{}`                        |
| service.type                      | type of service to create                                                                                                                                    | `ClusterIP`                 |
| service.port                      | port for the http service                                                                                                                                    | `80`                        |
| ingress.enabled                   | enable or disable ingress                                                                                                                                    | `false`                     |
| ingress.annotations               | ingress annotations                                                                                                                                          | `{}`                        |
| ingress.tls                       | TLS certificate info defined here                                                                                                                            | `[]`                        |
| serviceAccountSecret              | name of the secret that contains the service account needed to get the data from GCP                                                                         | `gcp-quota-sa`              |
| livenessProbe.failureThreshold    |                                                                                                                                                              | `3`                         |
| livenessProbe.httpGet.path        |                                                                                                                                                              | `/metrics`                  |
| livenessProbe.httpGet.port        |                                                                                                                                                              | `http`                      |
| livenessProbe.httpGet.scheme      |                                                                                                                                                              | `HTTP`                      |
| livenessProbe.initialDelaySeconds |                                                                                                                                                              | `10`                        |
| livenessProbe.periodSeconds       |                                                                                                                                                              | `10`                        |
| livenessProbe.successThreshold    |                                                                                                                                                              | `1`                         |
| livenessProbe.timeoutSeconds      |                                                                                                                                                              | `5`                         |
| readinessProbe.failureThreshold   |                                                                                                                                                              | `3`                         |
| readinessProbe.httpGet.path       |                                                                                                                                                              | `/metrics`                  |
| readinessProbe.httpGet.port       |                                                                                                                                                              | `http`                      |
| readinessProbe.httpGet.scheme     |                                                                                                                                                              | `HTTP`                      |
| readinessProbe.periodSeconds      |                                                                                                                                                              | `10`                        |
| readinessProbe.successThreshold   |                                                                                                                                                              | `1`                         |
| readinessProbe.timeoutSeconds     |                                                                                                                                                              | `5`                         |
| resources                         |                                                                                                                                                              | `{}`                        |
| nodeSelector                      |                                                                                                                                                              | `{}`                        |
| tolerations                       |                                                                                                                                                              | `[]`                        |
| affinity                          |                                                                                                                                                              | `{}`                        |
| annotations                       | If you don't use prometheus operator you could use some annotations to use the Prometheus SD                                                                 | `{}`                        |
| podLabels                         |                                                                                                                                                              | `{}`                        |
| serviceMonitor.enabled            | When set true then use a ServiceMonitor to configure scraping                                                                                                | `false`                     |
| serviceMonitor.namespace          | Set the namespace the ServiceMonitor should be deployed                                                                                                      | `null`                      |
| serviceMonitor.additionalLabels   | additionalLabels is the set of additional labels to add to the ServiceMonitor                                                                                | `{}`                        |
| serviceMonitor.interval           | Set how frequently Prometheus should scrape interval: 30s                                                                                                    | `null`                      |
| serviceMonitor.path               | Set path to exporter telemetry-path path: /metrics                                                                                                           | `null`                      |
| serviceMonitor.timeout            | Set timeout for scrape timeout: 10s                                                                                                                          | `null`                      |
| serviceMonitor.honorLabels        | # Defaults to what's used if you follow CoreOS [Prometheus Install Instructions](https://github.com/helm/charts/tree/master/stable/prometheus-operator#tldr) | `true`                      |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example:

```console
$ helm install  gcp-quota-exporter/gcp-quota-exporter -n  --version=2.0.0 --set replicaCount=1
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while
installing the chart. For example:

```console
$ helm install  gcp-quota-exporter/gcp-quota-exporter -n  --version=2.0.0 --values values.yaml
```

## Grafana Dashboard

Once you have this in Prometheus you can start using it and create alerts or generate Grafana Dashboards for detect when you are reaching a limit,
in the `grafana` folder you have an example of a simple dashboard that does some basic Prometheus queries.

This documentation has been generated using `chart-doc-gen` with the command:

```console
chart-doc-gen -d ./docs/doc.yaml -t ./docs/readme.tpl -v=./values.yaml > README.md
```