# Htsget-rs Helm Chart
This repository hosts Helm charts for deploying the [rust server implementation of the htsget protocol](https://github.com/umccr/htsget-rs) on a kubernetes environment.

## Development environment

This development environment has been tested in minikube. Instructions for
installing minikube can be found in the
[official instructions](https://minikube.sigs.k8s.io/docs/start/).

### Setting up the environment and starting the minikube cluster on Ubuntu

1. Start the minikube and we use [calico](https://docs.tigera.io/calico/latest/getting-started/kubernetes/minikube) for the networkpolicy

```
minikube start --network-plugin=cni --cni=calico
```
2. Enable the addons
```
minikube addons enable ingress
minikube addons enable ingress-dns
```
3. Add the `minikube-ip` as a DNS server
```
echo -e $"\nsearch local\nnameserver $(minikube ip)\ntimeout 5" \
| sudo tee -a /etc/resolv.conf
```
4. Add minikibe 'htsget domain name ' to host file
```
echo -e  $"\n$(minikube ip) htsget.local\n$(minikube ip)" | sudo tee -a /etc/hosts
```
When you are done with testing, you can cleanup `resolv.conf` or wait till this is done automatically when the dhcp lease is renewed. The file `/etc/hosts` needs to be cleaned up manually.


### Installing the htsget-rs helm chart

Run `helm install htsget-rs charts/htsget-rs` to install the  `htsget-rs` chart.

You can use the `kubectl get pods` command to see the kubernetes pods come online. After that, you can verify the deployment with `curl -s http://htsget.local/reads/service-info`.


### Testing with sda-download

Start by checking out [this branch}(https://github.com/GenomicDataInfrastructure/starter-kit-storage-and-interfaces/tree/featute/test-htsget-reencrypt) of the GDI starter-kit-storage&interfaces repository. This branch contains the re-encryption of file headers in the sda-download service.
Follow the instructions in the README of that repository to set-up all necessary configuration files. Then run:
```sh
docker compose -f docker-compose-demo.yml up
```
and wait until the `data_loader` completes with `exit 0`.

Then paste the following into charts/htsget-rs/templates/configmap.yaml:
```ini
ticket_server_addr = "0.0.0.0:8080"
ticket_server_cors_allow_origins = "All"
[[resolvers]]
regex = "(.*)"
substitution_string = "$1"

[resolvers.storage]
# The url that will be used for the client's url
response_url = "http://host.minikube.internal:8443/s3/"
forward_headers = true

[resolvers.storage.endpoints]
index = "http://host.minikube.internal:8443/s3/"
# Header and file url
file = "http://host.minikube.internal:8443/s3/"
```
and run `helm install charts/htsget-rs`.

After the pod is Ready, you should be able to run the following commands successfully:
```sh
token=$(curl -s -k https://localhost:8080/tokens | jq -r '.[0]')
```
to get a valid token and then
```sh
curl -v -H "Authorization: Bearer $token" -k http://htsget.local/reads/DATASET0001/htsnexus_test_NA12878
```
to get the htsget response using transcactions with unencrypted files.

The default configuration in the `toml` file is for use with encrypted file transactions and is the one that should be deployed in production-like environments.
