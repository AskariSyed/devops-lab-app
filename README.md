# DevOps Lab App

Small Flask app packaged with Docker, deployed by Jenkins on an EC2 instance, and runnable locally on Minikube for Kubernetes practice.

## What is included

- Docker image for the Flask app
- Jenkins pipeline with GitHub webhook support
- Terraform for an EC2 `t3.micro` instance in `ap-southeast-1`
- Kubernetes manifests for local Minikube usage

## Terraform on AWS

The Terraform configuration is in [terraform/main.tf](terraform/main.tf), [terraform/variables.tf](terraform/variables.tf), and [terraform/outputs.tf](terraform/outputs.tf).

It creates:

- one EC2 `t3.micro` instance
- a security group for SSH, HTTP, and Jenkins access
- user data that installs Docker, Jenkins, and a small swap file

### Apply

```bash
cd terraform
terraform init
terraform apply -var "key_name=your-key-pair-name"
```

Set `key_name` before applying so you can SSH into the instance.

## Ansible on EC2

Use the files in [asnible/inventory.ini](asnible/inventory.ini) and [asnible/playbook.yaml](asnible/playbook.yaml) to configure the EC2 host after Terraform creates it.

The playbook does the following:

1. installs Docker, Jenkins, Git, and Java
2. configures the Docker and Jenkins apt repositories
3. starts and enables Docker and Jenkins
4. clones this repository into `/opt/devops-lab-app`
5. builds the Docker image and starts the container on port `5000`

Run it from the repo root or the `asnible` folder:

```bash
cd asnible
ansible-playbook -i inventory.ini playbook.yaml
```

If you recreate the EC2 instance, update the IP address in [asnible/inventory.ini](asnible/inventory.ini) and keep the key path pointing to [Devops_Lab_App.pem](Devops_Lab_App.pem).

## Jenkins + Docker flow

Install Jenkins on the EC2 instance through Terraform user data, then configure the GitHub repository webhook to hit the Jenkins job.

The pipeline in [Jenkinsfile](Jenkinsfile) does this:

1. checks out the repository
2. builds the Docker image
3. stops any existing container
4. starts the new container on port `5000`

## Local Kubernetes with Minikube

Use the manifests in [deployment.yaml](deployment.yaml) and [service.yaml](service.yaml) with Minikube on your local machine.

```bash
minikube start
minikube docker-env --shell powershell | Invoke-Expression
docker build -t devops-app:local .
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
minikube service devops-service
```

The deployment uses `devops-app:local` and `imagePullPolicy: Never` so Minikube uses the image you build locally.

## App

The Flask app is in [app.py](app.py) and serves `Hello DevOps World` on port `5000`.