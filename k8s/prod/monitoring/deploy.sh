#!/bin/sh

kubectl apply -f namespace.yaml

KUBECTL="kubectl --namespace=prod-monitoring"

eval "${KUBECTL} create configmap alertmanager-templates --from-file=alertmanager-templates -o json --dry-run" | eval "${KUBECTL} apply -f -"
eval "${KUBECTL} create configmap prometheus-rules --from-file=prometheus-rules -o yaml --dry-run" | eval "${KUBECTL} apply -f -"
eval "${KUBECTL} create configmap grafana-dashboards --from-file=grafana-dashboards -o json --dry-run" | eval "${KUBECTL} apply -f -"

eval "${KUBECTL} apply -f alertmanager-config.yaml"
eval "${KUBECTL} apply -f prometheus-config.yaml"

eval "${KUBECTL} apply -f node-exporter.yaml"
eval "${KUBECTL} apply -f alertmanager.yaml"
eval "${KUBECTL} apply -f prometheus.yaml"
eval "${KUBECTL} apply -f grafana.yaml"
