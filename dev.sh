#!/bin/bash

select_project () {
    echo -n "What Project ID do you want to deploy the solution to? (for example my-project-1234): "
    read var_project_id
    gcloud config set project $var_project_id
    export PROJECT_ID=$var_project_id
    export PROJECT_NUMBER=$(gcloud projects list --filter="$(gcloud config get-value project)" --format="value(PROJECT_NUMBER)")
}

if [ -z "$GOOGLE_CLOUD_PROJECT" ]
then
    echo "Project not set!"
    select_project
else
    export PROJECT_ID=$GOOGLE_CLOUD_PROJECT
fi


while : ; do
    echo -n "Deploy solution to project: "$PROJECT_ID" Y/n: "
    read var_confirm
    case "$var_confirm" in
        [yY][eE][sS]|[yY]) 
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
        [yY][eE][sS]|[yY]) 
            echo "Deploying to $REGION"
            break
            ;;
        *)
            select_region
            ;;
    esac
done



echo $PROJECT_ID $REGION;