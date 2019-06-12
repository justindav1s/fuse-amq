#!/usr/bin/env bash


PROMETHEUS_NAMESPACE=amq
MONITORABLE_NAMESPACE=fuse-int
SERVICE_TEAM=fuse

oc project ${PROMETHEUS_NAMESPACE}

oc delete prometheus.monitoring.coreos.com prometheus
oc delete all -l app=prometheus
oc delete servicemonitors -l app=prometheus

oc delete rolebindings.rbac.authorization.k8s.io "prometheus-operator"
oc delete roles.rbac.authorization.k8s.io "prometheus-operator"
oc delete rolebindings.rbac.authorization.k8s.io "prometheus"
oc delete roles.rbac.authorization.k8s.io "prometheus"

oc delete rolebindings.rbac.authorization.k8s.io "prometheus-operator" -n ${MONITORABLE_NAMESPACE}
oc delete roles.rbac.authorization.k8s.io "prometheus-operator" -n ${MONITORABLE_NAMESPACE}
oc delete rolebindings.rbac.authorization.k8s.io "prometheus" -n ${MONITORABLE_NAMESPACE}
oc delete roles.rbac.authorization.k8s.io "prometheus" -n ${MONITORABLE_NAMESPACE}

oc delete serviceaccounts "prometheus-operator"
oc delete serviceaccount prometheus

oc process -f prometheus-operator-namespaces-template.yaml \
    -p NAMESPACE=${PROMETHEUS_NAMESPACE} \
    -p NAMESPACE_LIST="${PROMETHEUS_NAMESPACE},${MONITORABLE_NAMESPACE}" \
    -p SERVICE_TEAM=${SERVICE_TEAM} \
   | oc create -f -

oc process -f prometheus-roles-template.yaml \
    -p PROMETHEUS_NAMESPACE=${PROMETHEUS_NAMESPACE} \
    -p MONITORABLE_NAMESPACE=${MONITORABLE_NAMESPACE} \
   | oc create -f -


SERVICE_NAMESPACE=${PROMETHEUS_NAMESPACE}

oc process -f servicemonitor-template.yaml \
    -p SERVICE_TEAM=${SERVICE_TEAM} \
    -p SERVICE_NAMESPACE=${SERVICE_NAMESPACE} \
    -p SERVICE_NAME=custom-amq6-broker-1-prometheus \
    -p ENDPOINT_PORT="prometheus" \
    -p APP_LABEL=custom-amq6-broker-1 \
    | oc apply -f -

oc process -f servicemonitor-template.yaml \
    -p SERVICE_TEAM=${SERVICE_TEAM} \
    -p SERVICE_NAMESPACE=${SERVICE_NAMESPACE} \
    -p SERVICE_NAME=custom-amq6-broker-2-prometheus \
    -p ENDPOINT_PORT="prometheus" \
    -p APP_LABEL=custom-amq6-broker-2 \
    | oc apply -f -

oc process -f servicemonitor-template.yaml \
    -p SERVICE_TEAM=${SERVICE_TEAM} \
    -p SERVICE_NAMESPACE=${SERVICE_NAMESPACE} \
    -p SERVICE_NAME=custom-amq6-broker-3-prometheus \
    -p ENDPOINT_PORT="prometheus" \
    -p APP_LABEL=custom-amq6-broker-3 \
    | oc apply -f -

SERVICE_NAMESPACE=${MONITORABLE_NAMESPACE}

oc process -f servicemonitor-template.yaml \
    -p SERVICE_TEAM=${SERVICE_TEAM} \
    -p SERVICE_NAMESPACE=${SERVICE_NAMESPACE} \
    -p SERVICE_NAME=consumer-app-prometheus \
    -p ENDPOINT_PORT="prometheus" \
    -p APP_LABEL=consumer-app \
    | oc apply -f -

oc process -f servicemonitor-template.yaml \
    -p SERVICE_TEAM=${SERVICE_TEAM} \
    -p SERVICE_NAMESPACE=${SERVICE_NAMESPACE} \
    -p SERVICE_NAME=producer-app-prometheus \
    -p ENDPOINT_PORT="prometheus" \
    -p APP_LABEL=producer-app \
    | oc apply -f -