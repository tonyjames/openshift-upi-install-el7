#!/usr/bin/env bash

REGISTRY_IP=""
REGISTRY_PORT=""

oc -n openshift-config create configmap registry-config \
  --from-file=registry-ca.crt=/data/registry-certs/ca.crt

oc patch image.config.openshift.io/cluster \
  --patch '{"spec":{"additionalTrustedCA":{"name":"registry-config"}}}' \
  --type=merge

cat << EOF > /tmp/patch.json
{
  "spec": {
    "samplesRegistry": "${REGISTRY_IP}:${REGISTRY_PORT}"
  }
}
EOF

oc -n openshift-cluster-samples-operator patch configs.samples.operator.openshift.io/cluster \
  --type merge \
  --patch-file /tmp/patch.json

oc patch configs.samples.operator.openshift.io/cluster \
  --type merge --patch '{"spec":{"managementState": "Removed" }}'

sleep 30

oc patch configs.samples.operator.openshift.io/cluster \
  --type merge --patch '{"spec":{"managementState": "Managed" }}'