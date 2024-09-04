#!/bin/sh

REGION=europe-west1-b

while true; do
    read -p "Region is $REGION, change? (y/n): " yn
    case $yn in
        [Yy]* ) read -p "New region: " REGION;
        while true; do
            read -p "Change region to $REGION? (y/n): " conf 
            case $conf in
                [Yy]* ) break;;
                [Nn]* ) exit;;
                * ) echo "Please answer yes or no.";;
            esac
        done;                
        break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

gcloud services enable recaptchaenterprise.googleapis.com
PROJECT_NAME=$(gcloud config get-value project 2>/dev/null)
PROJECT_NUMBER=$(gcloud projects list --filter="$(gcloud config get-value project)" --format="value(PROJECT_NUMBER)")
COMMITID=$(git log --format="%H" -n 1)

APIKEY=$(gcloud services api-keys create --api-target=service=recaptchaenterprise.googleapis.com --display-name="reCAPTCHA Heroes Demo API key" 2> /dev/null)
echo Created an API key for use by reCAPTCHA Enterprise
V3KEY=$(gcloud recaptcha keys create --display-name=heroes-score-site-key --web --allow-all-domains --integration-type=score 2>&1 | grep -Po '\[\K[^]]*')
echo Created score based site-key $V3KEY
V2KEY=$(gcloud recaptcha keys create --display-name=heroes-checkbox-site-key --web --allow-all-domains --integration-type=checkbox 2>&1 | grep -Po '\[\K[^]]*')
echo Created visual challenge based site-key $V2KEY
TEST2KEY=$(gcloud recaptcha keys create --display-name=heroes-test2-site-key --web --allow-all-domains --integration-type=score 2>&1 | grep -Po '\[\K[^]]*')
echo Created test site-key with a score of 0.2 $TEST2KEY
TEST8KEY=$(gcloud recaptcha keys create --display-name=heroes-test8-site-key --web --allow-all-domains --integration-type=score 2>&1 | grep -Po '\[\K[^]]*')
echo Created test site-key with a score of 0.8 $TEST8KEY
EXPRESSKEY=$(gcloud recaptcha keys create --display-name=heroes-express-site-key --web --integration-type=score --allow-all-domains --waf-feature=express --waf-service=unspecified 2>&1 | grep -Po '\[\K[^]]*')
echo Created express site-key $EXPRESSKEY

REPORAND=$(shuf -i 10000-99999 -n 1)
REPO_NAME="recaptcha-heroes-docker-repo-$REPORAND"

#gcloud artifacts repositories create $REPO_NAME \
#    --repository-format=docker \
#    --location=$REGION \
#    --description="Docker repository reCAPTCHA"

# gcloud builds submit --region=$REGION --tag $REGION-docker.pkg.dev/$PROJECT_NAME/$REPONAME/recaptcha-demo-heroes-image:tag1

sed -e "s/REGION/$REGION/" \
 -e "s/PROJECT_ID/$PROJECT_NAME/" \
 -e "s/REPO_NAME/$REPO_NAME/" \ 
 cloudbuild-template.yaml > cloudbuild.yaml

echo ""
#ARG iapbackend=0