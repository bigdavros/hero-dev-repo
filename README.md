[![banner](https://raw.githubusercontent.com/GoogleCloudPlatform/click-to-deploy-solutions/refs/heads/main/banner.png)](https://cloud.google.com/?utm_source=github&utm_medium=referral&utm_campaign=GCP&utm_content=packages_repository_banner)

# Protect your Application from Fraud, Automation, and Bot activity with reCAPTCHA

## Introduction

_This architecture uses click-to-deploy so you can spin up infrastructure and applications in minutes!_

reCAPTCHA leverages a sophisticated and adaptable risk analysis engine to shield against automated software, thwarting abusive activities within an organization’s website and mobile apps. It safeguards your website and mobile applications from abusive traffic without compromising the user experience. reCAPTCHA employs an invisible score-based detection mechanism to differentiate between legitimate users and bots or other malicious attacks.

This click to deploy demo implements reCAPTCHA into an application, and reveals on the web page the results of the API calls made. It demonstrates the key functionality of the product along with some of the advanced protection features.



* __Protection from OWASP Automated Attacks__: 

## Architecture

<p align="center"> <img src="assets/architecture.png" width="700"> </p>

The main components that we would be setting up are (to learn more about these products, click on the hyperlinks):

* [reCAPTCHA](https://cloud.google.com/security/products/recaptcha) - reCAPTCHA is a service that helps to protect your websites and mobile applications from spam and abuse..
* [Cloud Build](https://cloud.google.com/build) - This demo includes a Java Application that will be built in Google Cloud Build.
* [Cloud Run](https://cloud.google.com/run) - The demo application will be deployed to Google Cloud using Cloud run, where it can then be viewed.

## Costs

reCAPTCHA is billed volumetrically. It functions in two stages, the client side execute which is free, and an API call known as an assessment which is charged.

There are multiple tiers for reCAPTCHA (including a free tier). For more details see [reCAPTCHA Compare Tiers](https://cloud.google.com/recaptcha/docs/compare-tiers)

## Deploy the architecture

Estimated deployment time: 4 min 23 sec

1. Click on Open in Google Cloud Shell button below.

<a href="https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/bigdavros/hero-dev-repo&cloudshell_workspace=/&cloudshell_open_in_editor=setup.sh" target="_new">
    <img alt="Open in Cloud Shell" src="https://gstatic.com/cloudssh/images/open-btn.svg">
</a>

2. Run the prerequisites script to enable APIs and set Cloud Build permissions.
```
sh prereq.sh
```

3. Run the Cloud Build Job
```
gcloud builds submit . --config build/cloudbuild.yaml
```
## Testing the architecture

1. Verify that the Juice Shop Application is running
```
PUBLIC_SVC_IP="$(gcloud compute forwarding-rules describe juice-shop-http-lb  --global --format="value(IPAddress)")"
```
```
echo $PUBLIC_SVC_IP
```
Paste the output IP Address into your url bar to see the application

2. Verify that the Cloud Armor policies are blocking malicious attacks

LFI vulnerability

```
curl -Ii http://$PUBLIC_SVC_IP/?a=../
```

RCE Attack

```
curl -Ii http://$PUBLIC_SVC_IP/ftp?doc=/bin/ls
```

Well-known scanner detection
```
curl -Ii http://$PUBLIC_SVC_IP -H "User-Agent: blackwidow"
```

Protocol attack mitigation
```
curl -Ii "http://$PUBLIC_SVC_IP/index.html?foo=advanced%0d%0aContent-Length:%200%0d%0a%0d%0aHTTP/1.1%20200%20OK%0d%0aContent-Type:%20text/html%0d%0aContent-Length:%2035%0d%0a%0d%0a<html>Sorry,%20System%20Down</html>"
```

Session fixation attempt
```
curl -Ii http://$PUBLIC_SVC_IP/?session_id=a
```
3. All the above commands should return
```
HTTP/1.1 403 Forbidden
<..>
```

4. You can view the logs in Cloud Armor policies to verify these.

## Cleaning up your environment
Run the command below on Cloud Shell to destroy the resources.
```
gcloud builds submit . --config build/cloudbuild_destroy.yaml
```