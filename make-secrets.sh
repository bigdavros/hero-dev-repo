#!/bin/bash
APIKEY=$1
LEGACYKEY=$2
TRUSTEDTESTERKEY=$3
echo
echo "{" > /secrets/recaptcha-demo-secrets.json
echo "\"api-keys\":{" >> /secrets/recaptcha-demo-secrets.json
echo "\"description\":\"Credentials from the Services and APIs Console, and from the site key legacy support panel\"," >> /secrets/recaptcha-demo-secrets.json
echo "\"api-access-key-for-recaptcha-from-services-and-apis-console\":\"$APIKEY\"," >> /secrets/recaptcha-demo-secrets.json
echo "\"legacy-secret-key-for-recaptcha-v3-site-key-from-site-key-settings\":\"$LEGACYKEY\"," >> /secrets/recaptcha-demo-sect
rets.json
echo "\"trusted-tester-api-key\":\"$TRUSTEDTESTERKEY\"" >> /secrets/recaptcha-demo-secrets.json
echo "}}" >> /secrets/recaptcha-demo-secrets.json