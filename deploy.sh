# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

select_project () {
    num_projects=0

    while IFS= read -r line; do
        project_list+=( "$line" )
    done < <( gcloud projects list --sort-by=projectId --format="value(PROJECT_ID)")
    num_projects=$(echo ${#project_list[@]})

    while : ; do
        echo "Available projects:"
        count=0
        for i in "${project_list[@]}"; do
            echo "[$count]" ${project_list[$count]};
            count=$(expr $count + 1);
        done
        echo -n "Please select a project: "
        read var_project
        # TODO: set the REGION variable based on this answer
        # include logic to make sure the input makes sense
        if [ "$num_projects" -gt "$var_project" ]; then
            export PROJECT_ID="${project_list[$var_project]}"
            gcloud config set project $PROJECT_ID
            export PROJECT_NUMBER=$(gcloud projects list --filter="$(gcloud config get-value project)" --format="value(PROJECT_NUMBER)")
            break
        else
            echo "Selection out of range."
        fi
    done
}

if [ -z "$GOOGLE_CLOUD_PROJECT" ]
then
    select_project
else
    export PROJECT_ID=$GOOGLE_CLOUD_PROJECT
    export PROJECT_NUMBER=$(gcloud projects list --filter="$(gcloud config get-value project)" --format="value(PROJECT_NUMBER)")
fi

while : ; do
    echo -n "Deploy solution to project: "$PROJECT_ID" Y/n: "
    read var_confirm
    case "$var_confirm" in
        [yY][eE][sS]|[yY]|"") 
            echo "Deploying to $PROJECT_ID"
            break
            ;;
        *)
            select_project
            ;;
    esac
done

export REGION=$(gcloud config get-value compute/zone)
regions=()
num_regions=0

populate_regions () {
    if [ -z "${regions[0]}" ] 
    then
        while IFS= read -r line; do
            regions+=( "$line" )
        done < <( gcloud compute regions list --uri | cut -d'/' -f9 )
        num_regions=$(echo ${#regions[@]})
    fi
}

select_region () {
    populate_regions
    while : ; do
        echo "Please select a region."
        count=0
        for i in "${regions[@]}"; do
            echo "[$count]" ${regions[$count]};
            count=$(expr $count + 1);
        done
        echo -n "What region do you want to deploy the reCAPTCHA demo to?: "
        read var_region
        # TODO: set the REGION variable based on this answer
        # include logic to make sure the input makes sense
        if [ "$num_regions" -gt "$var_region" ]; then
            REGION="${regions[$var_region]}"
            break
        else
            echo "Selection out of range."
        fi
    done
    
}

echo -n "Checking region: "

if [ -z "$REGION" ] 
then
    echo "Region not set"
    select_region
fi

while : ; do
  echo -n "Deploy reCAPTCHA demo to region: "$REGION" Y/n: "
    read var_confirm
    case "$var_confirm" in
        [yY][eE][sS]|[yY]|"") 
            echo "Deploying to $REGION"
            break
            ;;
        *)
            select_region
            ;;
    esac
done
COMMITID=$(git log --format="%H" -n 1)
SHORTCOMMIT=${COMMITID: -5}

SERVICE_ACCOUNT=recaptcha-heroes-compute-${SHORTCOMMIT}@${PROJECT_ID}.iam.gserviceaccount.com

echo "gcloud iam service-accounts delete $SERVICE_ACCOUNT --quiet" >> cleanup-$SHORTCOMMIT.sh

echo "Creating service account $SERVICE_ACCOUNT"
gcloud iam service-accounts create recaptcha-heroes-compute-$SHORTCOMMIT \
  --display-name "reCAPTCHA Heroes Compute Service Account"

echo "Granting permissions to $SERVICE_ACCOUNT"

declare -a roles=(
   "roles/artifactregistry.writer"
   "roles/cloudbuild.builds.builder"
   "roles/cloudbuild.integrations.owner"
   "roles/iam.serviceAccountUser"
   "roles/logging.logWriter"
   "roles/run.developer"
   "roles/storage.objectUser"
)

echo -n "."
sleep 5
echo -n "."
sleep 5

for role in "${roles[@]}"
do
    echo -n "."
    gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:$SERVICE_ACCOUNT --role="$role" --no-user-output-enabled
    echo -n "."
    sleep 1
done
echo ""

echo "Permissions added:"
gcloud projects get-iam-policy $PROJECT_ID --flatten="bindings[].members" --format='table(bindings.role)' --filter="bindings.members:$SERVICE_ACCOUNT" | grep "roles"

gcloud services enable recaptchaenterprise.googleapis.com \
    compute.googleapis.com \
    storage.googleapis.com \


APIKEY=$(gcloud services api-keys create --api-target=service=recaptchaenterprise.googleapis.com --display-name="reCAPTCHA Heroes Demo API key" --format="json" 2>/dev/null | jq '.response.keyString' | cut -d"\"" -f2)
echo Created an API key for use by reCAPTCHA Enterprise
echo "gcloud recaptcha keys delete $APIKEY --quiet" >> cleanup-$SHORTCOMMIT.sh
V3KEY=$(gcloud recaptcha keys create --display-name=heroes-score-site-key --web --allow-all-domains --integration-type=score 2>&1 | grep -Po '\[\K[^]]*')
echo Created score based site-key $V3KEY
echo "gcloud recaptcha keys delete $V3KEY --quiet" >> cleanup-$SHORTCOMMIT.sh
V2KEY=$(gcloud recaptcha keys create --display-name=heroes-checkbox-site-key --web --allow-all-domains --integration-type=checkbox 2>&1 | grep -Po '\[\K[^]]*')
echo Created visual challenge based site-key $V2KEY
echo "gcloud recaptcha keys delete $V2KEY --quiet" >> cleanup-$SHORTCOMMIT.sh
TEST2KEY=$(gcloud recaptcha keys create --display-name=heroes-test2-site-key --testing-score=0.2 --web --allow-all-domains --integration-type=score 2>&1 | grep -Po '\[\K[^]]*')
echo Created test site-key with a score of 0.2 $TEST2KEY
echo "gcloud recaptcha keys delete $TEST2KEY --quiet" >> cleanup-$SHORTCOMMIT.sh
TEST8KEY=$(gcloud recaptcha keys create --display-name=heroes-test8-site-key --testing-score=0.8 --web --allow-all-domains --integration-type=score 2>&1 | grep -Po '\[\K[^]]*')
echo Created test site-key with a score of 0.8 $TEST8KEY
echo "gcloud recaptcha keys delete $TEST8KEY --quiet" >> cleanup-$SHORTCOMMIT.sh
EXPRESSKEY=$(gcloud recaptcha keys create --display-name=heroes-express-site-key --express 2>&1 | grep -Po '\[\K[^]]*')
echo Created express site-key $EXPRESSKEY
echo "gcloud recaptcha keys delete $EXPRESSKEY --quiet" >> cleanup-$SHORTCOMMIT.sh

LOG_BUCKET=recaptcha-heroes-logs-$SHORTCOMMIT
echo "gcloud storage rm --recursive gs://$LOG_BUCKET --quiet" >> cleanup-$SHORTCOMMIT.sh
echo "Creating log bucket gs://$LOG_BUCKET"
gcloud storage buckets create gs://$LOG_BUCKET

echo "Creating cloudbuild.yaml"
sed -e "s/LOG_BUCKET/$LOG_BUCKET/" -e "s/SHORTCOMMIT/$SHORTCOMMIT/" -e "s/SERVICE_ACCOUNT/$SERVICE_ACCOUNT/" -e "s/REGION/$REGION/" -e "s/PROJECT_ID/$PROJECT_ID/" -e "s/APIKEY/$APIKEY/" -e "s/PROJECT_NUMBER/$PROJECT_NUMBER/" -e "s/COMMITID/$COMMITID/" -e "s/APIKEY/$APIKEY/" -e "s/V3KEY/$V3KEY/" -e "s/V2KEY/$V2KEY/" -e "s/TEST2KEY/$TEST2KEY/" -e "s/TEST8KEY/$TEST8KEY/" -e "s/EXPRESSKEY/$EXPRESSKEY/" cloudbuild-template.yaml > cloudbuild.yaml

echo "gcloud artifacts repositories delete recaptcha-heroes-docker-repo-$SHORTCOMMIT --quiet" >> cleanup-$SHORTCOMMIT.sh
echo "Creating artifact registry repository recaptcha-heroes-docker-repo-$SHORTCOMMIT"
gcloud artifacts repositories create recaptcha-heroes-docker-repo-$SHORTCOMMIT \
    --repository-format=docker \
    --location=$REGION --description="Docker repository"


echo "gcloud run services delete recaptcha-demo-service-$SHORTCOMMIT" >> cleanup-$SHORTCOMMIT.sh
echo "Starting build"
gcloud builds submit --region=$REGION --config cloudbuild.yaml 

echo -n "Would you like to connect to the demo now? Y/n: "
read var_confirm
case "$var_confirm" in
    [yY][eE][sS]|[yY]|"") 
        gcloud run services proxy recaptcha-demo-service-$SHORTCOMMIT --project $PROJECT_ID --region $REGION
        ;;
    *)
        echo "exiting"
        ;;
esac

echo To connect to the demo use: gcloud run services proxy recaptcha-demo-service-$SHORTCOMMIT --project $PROJECT_ID --region $REGION
