#!/bin/bash
commitid=$1
echo "#!/usr/bin/env bash" > /newcatalina.sh

#echo "export JAVA_OPTS=\"$JAVA_OPTS -Dhttps.proxySet=true -Dhttps.proxyHost=192.168.240.161 -Dhttps.proxyPort=8080 \" " >> /newcatalina.sh

# echo "export GOOGLE_APPLICATION_CREDENTIALS=\"/secrets/sa.json\"" >> /newcatalina.sh

cat config.json | jq '."project-info" ."project-number"' | awk '{print "export PROJECTID="$0}'>> /newcatalina.sh
cat config.json | jq '."site-keys" .v3 .value' | awk '{print "export V3KEY="$0}'>> /newcatalina.sh
cat config.json | jq '."site-keys" .v2 .value' | awk '{print "export V2KEY="$0}'>> /newcatalina.sh
cat config.json | jq '."site-keys" .test2 .value' | awk '{print "export TEST2KEY="$0}'>> /newcatalina.sh
cat config.json | jq '."site-keys" .test8 .value' | awk '{print "export TEST8KEY="$0}'>> /newcatalina.sh
cat config.json | jq '."site-keys" .express .value' | awk '{print "export EXPRESSKEY="$0}'>> /newcatalina.sh
cat config.json | jq '."iap-info" ."iap-audience"' | awk '{print "export IAPBACKEND="$0}'>> /newcatalina.sh
cat /secrets/recaptcha-demo-secrets.json | jq '."api-keys" ."api-access-key-for-recaptcha-from-services-and-apis-console"' | awk '{print "export APIKEY="$0}'>> /newcatalina.sh
echo "export COMMITID=$commitid">> /newcatalina.sh
echo "" >> /newcatalina.sh

export MYDATE=$(date +"%d-%b-%Y_%H:%M:%S") && echo export LASTBUILD="\"$MYDATE\"" >> /newcatalina.sh
