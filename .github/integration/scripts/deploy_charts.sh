#!/bin/bash
set -e

# Test deployment of htsget-rs with url backend and using c4gh encryption

if [ "$2" == "urlstorage" ]; then

if [ "$1" == "true" ]; then
    echo "TLS enabled"
    sed -i 's/# .*\(ticket_server_tls.key.*\)/\1/' .github/integration/scripts/values.yaml
    sed -i 's/# .*\(ticket_server_tls.cert.*\)/\1/' .github/integration/scripts/values.yaml
else
    echo "TLS disabled"
    sed -i 's/\(ticket_server_tls.key.*\)/# \1/' .github/integration/scripts/values.yaml
    sed -i 's/\(ticket_server_tls.cert.*\)/# \1/' .github/integration/scripts/values.yaml
fi

helm install htsget charts/htsget-rs/ \
--set tls.clusterIssuer=cert-issuer  \
--set tls.enabled="$1" \
-f .github/integration/scripts/values.yaml \
--wait

fi

# Test deployment of htsget-rs with data server enabled using a local storage backend

if [ "$2" == "dataserver" ]; then

if [ "$1" == "true" ]; then
    echo "TLS enabled"
    sed -i 's/# .*\(ticket_server_tls.key.*\)/\1/' .github/integration/scripts/data-server-config.toml
    sed -i 's/# .*\(ticket_server_tls.cert.*\)/\1/' .github/integration/scripts/data-server-config.toml
    sed -i 's/# .*\(data_server_tls.key.*\)/\1/' .github/integration/scripts/data-server-config.toml
    sed -i 's/# .*\(data_server_tls.cert.*\)/\1/' .github/integration/scripts/data-server-config.toml

else
    echo "TLS disabled"
    sed -i 's/\(ticket_server_tls.key.*\)/# \1/' .github/integration/scripts/data-server-config.toml
    sed -i 's/\(ticket_server_tls.cert.*\)/# \1/' .github/integration/scripts/data-server-config.toml
    sed -i 's/\(data_server_tls.key.*\)/# \1/' .github/integration/scripts/data-server-config.toml
    sed -i 's/\(data_server_tls.cert.*\)/# \1/' .github/integration/scripts/data-server-config.toml
fi

helm install htsget charts/htsget-rs/ \
--set htsget.dataServer.enabled=true  \
--set tls.clusterIssuer=cert-issuer  \
--set tls.enabled="$1" \
--set tlsDataServer.enabled="$1" \
--set tlsDataServer.secretName=htsget-htsget-rs-certs  \
--set-file configMapData=.github/integration/scripts/data-server-config.toml \
-f .github/integration/scripts/values.yaml \
--wait

fi
