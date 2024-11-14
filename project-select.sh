
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

echo Project $PROJECT_ID $PROJECT_NUMBER
