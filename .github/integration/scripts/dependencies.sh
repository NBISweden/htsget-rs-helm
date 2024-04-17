#!/bin/bash
set -ex

YQ_VERSION="v4.20.1"
C4GH_VERSION="$(curl -sL https://api.github.com/repos/neicnordic/crypt4gh/releases/latest | jq -r '.name')"

random-string() {
        head -c 32 /dev/urandom | base64 -w0 | tr -d '/+' | fold -w 32 | head -n 1
}

sudo curl -sLO "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" -O /usr/bin/yq &&
        sudo chmod +x /usr/bin/yq

curl -sL https://github.com/neicnordic/crypt4gh/releases/download/"${C4GH_VERSION}"/crypt4gh_linux_x86_64.tar.gz | sudo tar -xz -C /usr/bin/ &&
        sudo chmod +x /usr/bin/crypt4gh

# secret for the crypt4gh keypair
C4GHPASSPHRASE="$(random-string)"
export C4GHPASSPHRASE
crypt4gh generate -n c4gh -p "$C4GHPASSPHRASE"
kubectl create secret generic c4gh --from-file="c4gh.sec.pem" --from-file="c4gh.pub.pem" --from-literal=passphrase="${C4GHPASSPHRASE}"


helm repo add jetstack https://charts.jetstack.io

helm repo update

helm install \
        cert-manager jetstack/cert-manager \
        --namespace cert-manager \
        --create-namespace \
        --set installCRDs=true

kubectl apply -f .github/integration/scripts/dependencies.yaml

## update values file with all credentials
yq -i '
.htsget.c4gh.publicKey = "c4gh.pub.pem" |
.htsget.c4gh.privateKey = "c4gh.sec.pem" |
.htsget.c4gh.passPhrase = strenv(C4GHPASSPHRASE) |
.htsget.tls.urlStorage.key = "tls.key" |
.htsget.tls.urlStorage.cert = "tls.crt" |
.htsget.tls.urlStorage.rootStore = "ca.crt" |
.htsget.tls.ticketServer.key = "tls.key" |
.htsget.tls.ticketServer.cert = "tls.crt" |
.releasetest.secrets.accessToken = strenv(TEST_TOKEN)
' .github/integration/scripts/values.yaml
