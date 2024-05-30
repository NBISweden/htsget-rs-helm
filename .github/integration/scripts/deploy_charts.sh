#!/bin/bash
set -e

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
