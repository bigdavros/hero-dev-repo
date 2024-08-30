# reCAPTCHA Enterprise Demo Offline Installation
## About
This is the repo for the reCAPTCHA Enterprise demo created by dlenehan@. It was originally made as a personal project, then FSRs wanted it shared across all CEs so here we are. It is normally deployed at [https://demo.rcedemo.xyz](https://demo.rcedemo.xyz) and all UPS CEs and UPS FSRs have access. Some additional Google Cloud CEs/partners/resellers have access to it as well.

The deployed version runs in Cloud Run. There is a Cloud Build trigger tied to this repo that pulls various API keys and other secrets from Google Cloud Secrets Manager. These are then loaded into a container at build time and held in memory when the instance is running; this allows for faster performance as secrets are retrieved only once at build time and not continuously as the container is used. Why is this important? When used outside of Cloud Run/Cloud Build the container needs to be started in a way that does not try to pull secrets from dlenehan@'s Argolis secrets manager, which is largely why this README was created

## Offline Installation
The offline installation is just a Docker Container. You'll need to grab this code from the repo using git clone, change some variables, then run the docker container with some offline variables set to stop the container trying to call out to secrets manager in Argolis.

### Pre-requisites
Guide assumes the following:
- You have git installed
- You have docker installed
- You have a basic understanding of git and docker

### TLDR
1) Get the code with `git clone ssh://your@email.com@source.developers.google.com:2022/p/recaptcha-demo-dlenehan/r/staging-rcedemo-java-container`
2) Change variables in `config.json`
3) Create a file called `secrets.json` and put your API keys in that file
4) Run docker container using command `docker build -t rcedemo-java --build-arg development=true --build-arg filename=secrets.json  . &&  docker run -p 8080:8080 rcedemo-java:latest`

### Get the code
You're already in the repo, so git clone this repo to your local machine. 
 `git clone ssh://your@email.com@source.developers.google.com:2022/p/recaptcha-demo-dlenehan/r/staging-rcedemo-java-container`

### Update and Create config files
The deployed version pulls variables from config.json, and the secrets from Google Cloud Secrets Manager. The offline version needs a file called `secrets.json` which will contain the same secrets the deployed version would pull.
Open the config.json file and put in your own project variables and site key variables. The implied task here is that you will need to go into Google Cloud and set all this up. Things to think about:
1) Allow list your project for 11 scores
2) Speak to Eng to enable SMS Fraud on your project
3) Make sure the site keys work on "localhost" as a domain, or all domains

<img alt="config.json" src="https://screenshot.googleplex.com/8ziDDe3MhsYc6Gu.png" width="300px">

[https://screenshot.googleplex.com/8ziDDe3MhsYc6Gu.png](https://screenshot.googleplex.com/8ziDDe3MhsYc6Gu.png)


The `iap-info` section is used in the deployed version to protect the demo using Identity Aware Proxy. This can be blank when hosted locally in docker as the demo will assume the logged in user is a pre-set default value.

The `trusted-tester` portion is needed for legacy reasons in the deployed version, you can use the same project details here as in the `project-info` portion. The history is that there was once MFA support via SMS; this was dropped but the deployed demo's project was already enabled for MFA with SMS. The newer SMS Fraud uses the same JSON enums as the legacy MFA SMS, so it's not possible to have both in the same project and Eng couldn't remove the flag from the original. Therefore the deployed version uses two projects, one just for SMS Fraud and the other project for everything else because a flag is set that breaks SMS Fraud.

You will next need to create `secrets.json`. This file will hold the API and legacy secret keys needed to make the demo work outside of Argolis (the deployed version creates this file using secrets held in Google Cloud Secrets Manager). The file needs to look like this:
```
{
    "api-keys":{
        "description":"Credentials from the Services and APIs Console, and from the site key legacy support panel",
        "api-access-key-for-recaptcha-from-services-and-apis-console":"",
        "legacy-secret-key-for-recaptcha-v3-site-key-from-site-key-settings":"",
        "trusted-tester-api-key":""
    }
}
```

The `trusted-tester-api-key` has the same history as the `config.json` file, so can contain the same API key as `api-access-key-for-recaptcha-from-services-and-apis-console`. The variables are named in an obvious way. If it is in any way unclear please speak to dlenehan@.

### Run the container
If you check the Dockerfile you can see that certain variables are expected, and default values are set in their absence. The deployed version passes these variables in via a Cloud Build YAML script, for offline we need to pass some of these when starting the container. These are passed as `build-arg` variables for docker:
1) --build-arg development=true 
2) --build-arg filename=secrets.json
These tell docker to trigger the development (offline) `if` statements in the Dockerfile, and to use the secrets in `secrets.json`

`docker build -t rcedemo-java --build-arg development=true --build-arg filename=secrets.json  . &&  docker run -p 8080:8080 rcedemo-java:latest`

### View the demo
Go to http://localhost:8080 and view the demo. If there are errors please tell dlenehan@. This was originally developed on his machine and has not been deployed anywhere but his work laptops and Cloud Run, so there could be issues on more exotic setups such as MacOS etc.

