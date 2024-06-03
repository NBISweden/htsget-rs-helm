#!/bin/bash
set -ex

C4GH_VERSION="$(curl -sL https://api.github.com/repos/neicnordic/crypt4gh/releases/latest | jq -r '.name')"

random-string() {
        head -c 32 /dev/urandom | base64 -w0 | tr -d '/+' | fold -w 32 | head -n 1
}

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
