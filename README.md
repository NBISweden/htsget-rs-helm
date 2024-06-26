# Htsget-rs Helm Chart

This repository hosts Helm charts for installing the [rust server implementation of the htsget protocol](https://github.com/umccr/htsget-rs) on a kubernetes environment.

## Installing the Chart

To install the Chart with the release name `htsget-rs`:

```sh
helm install htsget-rs charts/htsget-rs
```

## Uninstalling the Chart

To uninstall the `htsget-rs` deployment and remove all kubernetes resources associated with the chart:

```sh
helm delete htsget-rs
```

## Configuration

The following table lists the configurable parameters of the htsget-rs chart. These can be changed by editing the `values.yaml` file or by passing them as arguments to `helm install`.

### Standard configuration

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `replicaCount` | Number of replicas to deploy | `1` |
| `image.repository` | htsget-rs image repository | `harbor.nbis.se/gdi/htsget-rs` |
| `image.pullPolicy` | htsget-rs image pull policy | `IfNotPresent` |
| `image.tag` | htsget-rs image tag | `""` |
| `imagePullSecrets` | Image registry secret names as an array | `[]` |
| `nameOverride` | String to partially override htsget-rs.fullname template with a string (will prepend the release name) | `""` |
| `fullnameOverride` | String to fully override htsget-rs.fullname template with a string | `""` |
| `rbacEnabled` | Use role based access control | `true` |
| `podSecurityPolicy.create` | Specifies whether a PodSecurityPolicy should be created | `false` |
| `serviceAccount.create` | Specifies whether a service account should be created | `false` |
| `serviceAccount.annotations` | Annotations to add to the service account | `{}` |
| `serviceAccount.name` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | `""` |
| `serviceAccount.automount` | Automount service account token | `true` |
| `podAnnotations` | Extra annotations to add to the pod | `{}` |
| `podLabels` | Extra labels to add to the pod | `{}` |
| `containerSecurityContext.allowPrivilegeEscalation` | Allow privilege escalation | `false` |
| `containerSecurityContext.capabilities.drop` | Drop capabilities | `["ALL"]` |
| `containerSecurityContext.privileged` | Run container in privileged mode | `false` |
| `podSecurityContext.fsGroup` | Group ID for the container | `1000` |
| `podSecurityContext.runAsUser` | User ID for the container | `1000` |
| `podSecurityContext.runAsNonRoot` | Run as non-root user | `true` |
| `podSecurityContext.seccompProfile.type` | Seccomp profile type | `RuntimeDefault` |
| `service.type` | Service type for the ticket server | `ClusterIP` |
| `service.port` | Service port for the ticket server | `8080` |
| `ingress.enabled` | Enable ingress controller resource for the ticket server | `true` |
| `ingress.className` | Ingress controller class name | `""` |
| `ingress.annotations` | Annotations for the ingress | `{}` |
| `ingress.hosts` | Hosts configuration for the ingress | `[{"host": "htsget.local","paths": [{"path": "/","pathType": "Prefix"}]}]` |
| `ingress.tls` | TLS configuration for the ingress | `[]` |
| `ingress.issuer` | Issuer for the TLS certificate | `""` |
| `ingress.clusterIssuer` | Cluster issuer for the TLS certificate | `""` |
| `dataServer.service.type` | Service type for the data server | `ClusterIP` |
| `dataServer.service.port` | Service port for the data server | `8081` |
| `dataServer.ingress.enabled` | Enable ingress controller resource for the data server | `true` |
| `dataServer.ingress.className` | Ingress controller class name | `""` |
| `dataServer.ingress.annotations` | Annotations for the ingress | `{}` |
| `dataServer.ingress.hosts` | Hosts configuration for the ingress | `[{"host": "data-server.local","paths": [{"path": "/","pathType": "Prefix"}]}]` |
| `dataServer.ingress.tls` | TLS configuration for the ingress | `[]` |
| `dataServer.ingress.issuer` | Issuer for the TLS certificate | `""` |
| `dataServer.ingress.clusterIssuer` | Cluster issuer for the TLS certificate | `""` |
| `resources` | CPU/memory resource requests/limits | `{}` |
| `autoscaling.enabled` | Enable horizontal pod autoscaling | `false` |
| `autoscaling.minReplicas` | Minimum number of replicas when autoscaling is enabled | `1` |
| `autoscaling.maxReplicas` | Maximum number of replicas when autoscaling is enabled | `20` |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization percentage when autoscaling is enabled | `80` |
| `nodeSelector` | Node labels for pod assignment | `{}` |
| `tolerations` | Tolerations for pod assignment | `[]` |
| `affinity` | Affinity for pod assignment | `{}` |

### htsget-rs specific configuration

To access all configuration options of `htsget-rs` one needs to pass the configuration in a `toml` file format (for details see [here](https://github.com/umccr/htsget-rs/tree/crypt4gh/htsget-config)). This is done by the `configMapData` parameter.
The following table lists the parameters of the htsget-rs chart that are specific to the htsget-rs server configuration and as such they must be set in accordance with the `toml` configuration held by the `configMapData` parameter. These parameters map the required kubernetes resources to the htsget-rs server configuration.

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `configMapData` | htsget-rs configuration in toml format | see `values.yaml` and [here](https://github.com/umccr/htsget-rs/tree/crypt4gh/htsget-config) for details |
| `tls.enabled` | Enable TLS for the ticket server. Set to `true` if `ticket_server_tls` parameters are set. | `false` |
| `tls.issuer` | Issuer for the ticker server TLS certificate | `""` |
| `tls.clusterIssuer` | Cluster issuer for the ticket server TLS certificate | `""` |
| `tls.secretName` | Name of the secret containing the TLS certificates for the ticket server | `""` |
| `htsget.tlsPath` | Path where the ticket server TLS certificates are mounted in the pod container| `"/tls"` |
| `c4gh.predefined` | Set to `true` if `private_key` and `public_key` are set under the `[resolver.object_type]` table of the `toml` config| `false` |
| `c4gh.secretName` | Name of the secret containing the private key and public key for crypt4gh | `""` |
| `htsget.c4ghPath` | Path where the crypt4gh keys are mounted to the pod container| `""` |
| `htsget.dataServer.enabled` | Enable the data server. Set to `true` if `data_server` parameter is set. | `true` |
| `htsget.dataServer.localPath` | Path where data is mounted if the data server is run in local storage mode. Should agree with htsget config option `data_server_local_path` if specified. | `""` |
| `htsget.dataServer.existingClaim` | Name of the existing PVC to use for the local data server storage backend. | `""` |
| `htsget.dataServer.nfsServer` | NFS server address to use as storage for the local data server. | `""` |
| `htsget.dataServer.nfsPath` | Path on the NFS server to use as storage for the local data server. | `""` |
| `tlsDataServer.enabled` | Enable TLS for the data server. Set to `true` if `data_server_tls` parameters are set.  | `false` |
| `tlsDataServer.secretName` | Name of the secret containing the TLS certificates for the data server | `""` |
| `htsget.tlsPathDataServer` | Path where the data server TLS certificates are mounted in the pod container| `""` |
| `tlsClient.enabled` | Enable TLS for the client. Set to `true` if `tls` parameters are set under the `[resolvers.storage.endpoints]` of the `toml` config.  | `false` |
| `tlsClient.secretName` | Name of the secret containing the TLS certificates for the client | `""` |
| `htsget.tlsPathClient` | Path where the TLS certificates for the client are mounted in the pod container| `""` |
| `htsget.s3Storage.enabled` | Set to `true` if htsget is configured to use S3 storage | `false` |
| `htsget.s3Storage.region` | AWS region of the S3 storage backend | `""` |
| `htsget.s3Storage.user` | AWS S3 access key id | `""` |
| `htsget.s3Storage.password` | AWS S3 secret access key | `""` |
| `htsget.s3Storage.secretName` | Existing secret holding the above two S3 credentials in `.data.user` and `.data.password` fields | `""` |
| `htsget.rustLog` | Rust log level | `"info"` |
| `htsget.formattingStyle` | Formatting style for the rust logs | `"Pretty"` |

### Example configurations

Further examples of how to configure the `htsget-rs` deployment can be found Under `.github/integration/scripts/`. The `values.yaml` file inside this directory  presents an example configuration for deploying `htsget-rs` in a `url storage` backend configuration with `crypt4gh` encryption and `TLS` features enabled.
The `data-server-config.toml` has a configuration example for deploying htsget with the `data server` enabled and running in `local storage` mode where data are held by a local storage backend. Lastly, the `s3-backend-config.toml` has a configuration example for deploying htsget with S3 as storage backend that holds files in a bucket named `data`.
Note that all examples are for illustrative purposes and not recommended for production deployments without further administrative considerations.

For further details of how to configure the `htsget-rs` server, please refer to the [htsget-rs configuration documentation](https://github.com/umccr/htsget-rs/tree/main/htsget-config) and the examples therein.
