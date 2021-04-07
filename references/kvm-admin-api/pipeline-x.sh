#!/bin/sh

# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

export TOKEN=$(gcloud auth print-access-token)

# Deploy the proxy
mvn install -ntp -B -Pgoogleapi -Dorg="$APIGEE_ORG" -Denv="$APIGEE_ENV" -Dapigee.config.options=update \
  -Dtoken="$TOKEN"

# Create the KVM
curl -X POST \
    "https://apigee.googleapis.com/v1/organizations/${APIGEE_ORG}/environments/$APIGEE_ENV/keyvaluemaps" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    --data '{"name": "'${KVM_NAME}'", "encrypted": true}'

jq -c '.envConfig.eval.kvms[].entry[]' ../identity-facade/edge.json | while read kvm_pair; do \
    KEY=`echo $kvm_pair | jq .name`
    VALUE=`echo $kvm_pair | jq .value`
    DATA='{ "key": '"$KEY"', "value": '"$VALUE"' }'
    curl -X POST \
      "https://$API_HOSTNAME/kvm-admin/v1/organizations/$APIGEE_ORG/environments/$APIGEE_ENV/keyvaluemaps/$KVM_NAME/entries" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -H "Host: $HOST" \
      -d "$DATA"; 
done

#APIGEE_TOKEN=$TOKEN npm run test

#curl -X DELETE \
#    "https://apigee.googleapis.com/v1/organizations/${APIGEE_ORG}/environments/$APIGEE_ENV/keyvaluemaps/kvmtestmap" \
#    -H "Authorization: Bearer $TOKEN"
