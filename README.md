# Container bundled with utilities for network testing

## Run the Node.JS application locally

```
npm init -y
npm install express
node app.js
```

Open http://localhost:3000

> The application at the moment does not have any functionality but only serves as a placeholder for potentially adding features later on. Network testing is carried out by connecting a shell into the running container and performing some diagnostic commands as shown in the sections below.

## Connect to the Cloud Platform AWS EKS cluster

Login to https://login.live.cloud-platform.service.justice.gov.uk and download the `~/.kube/config` file.

## Connect a shell into the running container

```
kubectl config set-context --current --namespace=nettest
kubectl get pods
kubectl exec --stdin --tty nettest-5948d76c47-g56s2 -- bash
```

## Example tests to run from within the running container

Check if the container has access to the internet

    curl ipinfo.io

Check if the container can access port 1521 at the IP address 10.26.12.202

    curl --connect-timeout 5 10.26.12.202:1521

In the above

- `curl: (28) Connection timed out after 5001 milliseconds` means NO
- `curl: (56) Recv failure: Connection reset by peer` means YES

## How to redeploy the container into the Cloud Platform

Change the application code and/or the Dockerfile

Build the docker image

    docker build -t nettest .

Retrieve ECR info

    cloud-platform decode-secret -n nettest -s ecr-repo-nettest

Configure the AWS profile

~/.aws/config
```
[profile nettest]
region = eu-west-2
output=json
aws_access_key_id=<refer to the ECR info above>
aws_secret_access_key=<refer to the ECR info above>
```

Login to the repository

```
aws ecr get-login-password --region eu-west-2 --profile nettest \
| docker login --username AWS --password-stdin \
754256621582.dkr.ecr.eu-west-2.amazonaws.com
```

Tag the image and push it to your ECR

    docker tag nettest 754256621582.dkr.ecr.eu-west-2.amazonaws.com/modernisation-platform/nettest-ecr:1.0

Push

    docker push 754256621582.dkr.ecr.eu-west-2.amazonaws.com/modernisation-platform/nettest-ecr:1.0

Update the image in `kubectl_deploy/deployment.yaml`, then deploy

    kubectl -n nettest apply -f kubectl_deploy

Open https://nettest.apps.live.cloud-platform.service.justice.gov.uk

Additional useful commands

    kubectl delete pod nettest-76bfd79fd9-9xfr6
    kubectl describe pod nettest-76bfd79fd9-9xfr6

## References

1. https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/env-create.html#creating-a-cloud-platform-environment
