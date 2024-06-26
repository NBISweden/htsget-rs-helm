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
helm repo add minio https://charts.min.io/

helm repo update

helm install \
        cert-manager jetstack/cert-manager \
        --namespace cert-manager \
        --create-namespace \
        --set installCRDs=true

kubectl apply -f .github/integration/scripts/dependencies.yaml

## S3 storage backend
MINIO_ACCESS="user" && export MINIO_ACCESS
MINIO_SECRET="password" && export MINIO_SECRET

kubectl create namespace minio
helm install minio minio/minio \
        --namespace minio \
        --set rootUser="$MINIO_ACCESS",rootPassword="$MINIO_SECRET",persistence.enabled=false,mode=standalone,resources.requests.memory=128Mi \
        --set buckets[0].name=data --set buckets[0].policy=none --set buckets[0].purge=false \
        --set ingress.enabled=true

# load data into minio
curl -s https://dl.min.io/client/mc/release/linux-amd64/mc --create-dirs -o $HOME/minio-binaries/mc
chmod +x $HOME/minio-binaries/mc && export PATH=$PATH:$HOME/minio-binaries/

mc alias set minio http://minio-example.local "$MINIO_ACCESS" "$MINIO_SECRET"
mc mirror .github/integration/test-data/ minio/data