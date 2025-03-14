# Cleanup acceptance old deployments. Check deployment creation date and delete deployment, service, and configmap

## Implementation 
```
Cluster: myplayground-cluster

Namespace: apps
```

```
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
```
