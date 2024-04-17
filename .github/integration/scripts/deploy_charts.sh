#!/bin/bash
set -ex


helm install htsget charts/htsget-rs/ \
--set tls.clusterIssuer=cert-issuer  \
--set tls.enabled="$1" \
-f .github/integration/scripts/values.yaml \
--wait
