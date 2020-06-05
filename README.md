# GCP Quota Exporter

As we want to get the resource quotas of our GCP projects and check when we are exhausting the limits we need
to get the data from GCP and export them somewhere, in this case this exports the data to Prometheus.

It's installed as a dependency in the main chart, but if you want to do all the steps manually, which helps to understand
how it works, you can follow the next steps:

## Test

### Create Service Account file

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

## Deploy in production
This use helm, the idea is to add this as a subchart of your preferred monitoring chart, but it can be launched independently as well:

```bash
helm upgrade --install --namespace monitoring-v2 gcp-quota-exporter .
```

NOTE: The deployment expects you to provide a secret with the service account to mount in the pod.

## Grafana Dashboard

Once you have this in Prometheus you can start using it and create alerts or generate Grafana Dashboards for detect when you are reaching a limit,
in the `grafana` folder you have an example of a simple dashboard that does some basic Prometheus queries.