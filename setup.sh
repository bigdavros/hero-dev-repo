#!/bin/sh

export REGION=$(gcloud config get-value compute/zone)
if [ -z "$REGION" ] then;
    echo "Region not set";
fi




gcloud services enable recaptchaenterprise.googleapis.com \
    compute.googleapis.com \
    storage.googleapis.com \

if [ -z "$GOOGLE_CLOUD_PROJECT" ]
then
   echo Project not set!
   echo What Project Id do you want to deploy the solution to?
   read var_project_id
   gcloud config set project $var_project_id
   export PROJECT_ID=$var_project_id
else
   export PROJECT_ID=$GOOGLE_CLOUD_PROJECT
fi

gcloud compute project-info describe --project $GOOGLE_CLOUD_PROJECT

PROJECT_NUMBER=$(gcloud projects list --filter="$(gcloud config get-value project)" --format="value(PROJECT_NUMBER)")
COMMITID=$(git log --format="%H" -n 1)
SERVICE_ACCOUNT=recaptcha-heroes-compute@$PROJECT_NAME.iam.gserviceaccount.com
LOG_BUCKET=$PROJECT_NAME-recaptcha-heroes-logs


APIKEY=$(gcloud services api-keys create --api-target=service=recaptchaenterprise.googleapis.com --display-name="reCAPTCHA Heroes Demo API key" --format="json" 2>/dev/null | jq '.response.keyString' | cut -d"\"" -f2)
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

sed -e "s/LOG_BUCKET/$LOG_BUCKET/" -e "s/SERVICE_ACCOUNT/$SERVICE_ACCOUNT/" -e "s/REGION/$REGION/" -e "s/PROJECT_ID/$PROJECT_NAME/" -e "s/APIKEY/$APIKEY/" -e "s/PROJECT_NUMBER/$PROJECT_NUMBER/" -e "s/COMMITID/$COMMITID/" -e "s/APIKEY/$APIKEY/" -e "s/V3KEY/$V3KEY/" -e "s/V2KEY/$V2KEY/" -e "s/TEST2KEY/$TEST2KEY/" -e "s/TEST8KEY/$TEST8KEY/" -e "s/EXPRESSKEY/$EXPRESSKEY/" cloudbuild-template.yaml > cloudbuild.yaml

gcloud iam service-accounts create recaptcha-heroes-compute \
  --display-name "reCAPTCHA Heroes Compute Service Account"
gcloud storage buckets create gs://$LOG_BUCKET

gcloud projects add-iam-policy-binding $PROJECT_NUMBER \
    --member=serviceAccount:$SERVICE_ACCOUNT \
    --role='roles/cloudbuild.builds.builder' \
    --role='roles/cloudbuild.serviceAgent' \
    --role='roles/run.developer' \
    --role='roles/run.admin' \
    --role='roles/run.serviceAgent' \
    --role='roles/logging.logWriter' \
    --role='roles/storage.admin'

gcloud artifacts repositories create recaptcha-heroes-docker-repo \
    --repository-format=docker \
    --location=$REGION --description="Docker repository"

echo gcloud builds submit --region=$REGION --config cloudbuild.yaml

echo $0 "done."


#ARG iapbackend=0