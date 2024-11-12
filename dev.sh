#!/bin/bash
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
}

echo -n "Checking region: "

if [ -z "$REGION" ] 
then
    echo "Region not set"
    select_region
fi

echo ${regions[14]};