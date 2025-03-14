#!/bin/bash
#
# Cleanup acceptance old stories
# Check deployment creation date and delete deployment, service, and configmap
set -x

# Catch errors and give them line number & exit code
error() {
  local line=$1
  local exitcode=$2
  shift 2
  echo "Error on line ${line} (exit ${exitcode}) $@" >&2
}

trap 'error $LINENO $?' ERR

echo "
=====================================
 Cleaning old stories
====================================="

# Optional variables
DAY_LIMIT=${DAY_LIMIT:-7}

namespace=${NAMESPACE:-"frontend-acceptance"}

# Get the list of deployments excluding those ending with "-canary"
app_list=$(kubectl get deployment --no-headers --namespace=${namespace} | awk '{print $1}')

for app_name in $app_list; do
  echo -ne "\nChecking deployment ${app_name}... "

  # Get creation timestamp in RFC3339 format
  creationDate=$(kubectl get deployment ${app_name} -n ${namespace} -o jsonpath='{.metadata.creationTimestamp}')

  # Convert creation timestamp to seconds since epoch
  creationEpoch=$(date -d "${creationDate}" +%s)

  # Get the age of the deployment in days
  ageDays=$(( ( $(date +%s) - ${creationEpoch} ) / 86400 ))

  echo "age: ${ageDays} days, limit: ${DAY_LIMIT} days"

  if [ "${ageDays}" -ge "${DAY_LIMIT}" ]; then
    echo -ne "The app ${app_name} is too old, deleting... "
    kubectl delete --ignore-not-found \
      deployment/${app_name} \
      poddisruptionbudget/${app_name} \
      horizontalpodautoscaler/${app_name} \
      secrets/${app_name}-letsencrypt-certificate \
      serviceaccount/${app_name} \
      service/${app_name} \
      ingress/${app_name} \
      ingress/${app_name}-internal \
      configMap/${app_name}-config \
      -n ${namespace}
    echo -n "done"
  fi
  echo ""
done
