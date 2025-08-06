# Task Tracker Application

This repository delivers a production-grade, end-to-end DevOps pipeline for the **Task Tracker API**—including infrastructure provisioning, application deployment, security, and observability.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Deployment Workflow Overview](#deployment-workflow-overview)
- [Setup Instructions](#setup-instructions)
  - [1. Prepare Your AWS Environment](#1-prepare-your-aws-environment)
  - [2. Configure GitHub Secrets](#2-configure-github-secrets)
  - [3. Run the Terraform Deployment](#3-run-the-terraform-deployment)
  - [4. Deploy the Application and Monitoring Stack](#4-deploy-the-application-and-monitoring-stack)
- [Monitoring & Access](#monitoring--access)
- [Clean Up](#clean-up)
- [Notes & Security](#notes--security)

## Prerequisites

Please ensure the following are available **before** starting the deployment:

- **AWS Account**  
  - Access to create EC2, VPC, S3, IAM, and Key Pairs.
- **AWS CLI** installed and configured locally (`aws configure`), or set credentials via GitHub Secrets.
- **Terraform**: v1.0 or newer ([install guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli))
- **Ansible**: v2.16 or newer ([install guide](https://docs.ansible.com/ansible/latest/installation_guide/index.html))
- **Docker & Docker Compose**: Docker v24+  
- **GitHub Account with repository for this code**

## Deployment Workflow Overview

1. **Infrastructure Provisioning**: Using Terraform scripts in `/infra` to provision AWS resources.
2. **Application & Monitoring Deployment**: Via Docker Compose (FastAPI app, Prometheus, Grafana) on the target EC2.
3. **Automation**: CI/CD with GitHub Actions (manual trigger).
4. **Observability**: Prometheus scrapes both the application and host metrics; Grafana visualizes them.

## Setup Instructions

### 1. Prepare Your AWS Environment

- Create an **SSH key pair** if you do not already have one; keep your private key secure.
- Optionally, add a key tag (e.g., `task-tracker-key`) for easy identification.

### 2. Configure GitHub Secrets

In your GitHub repository, go to Settings > Secrets and add:

- `AWS_ACCESS_KEY_ID`  
- `AWS_SECRET_ACCESS_KEY`  
- `SSH_PUBLIC_KEY` (the **public** part of your SSH key)
- `EC2_SSH_KEY` (the **private** part of your SSH key)
- `DOCKER_USERNAME`
- `DOCKER_PASSWORD`

_**Important:**_  
**Never commit credentials to source control.**

### 3. Run the Terraform Deployment

From your local machine or via GitHub Actions (recommended):

- **Manual Steps:**
  - Go to **Action** tab in repo and trigger the `terraform-deploy.yml`. This workflow will create the EC2, Security Group, S3, etc.. and output the public IP.
- Add the public IP as secret in repo
  - `EC2_HOST` (the **Public IP** of EC2)
- Trigger `ci-cd.yml` workflow this will build docker image, push it, and run the ansible playbook on EC2 server. this is required once after terraform resources created with workflow. 


## K8S Deployment Instructions

![Architecture Diagram](images/k8s.drawio.svg)

- Setup Jenkins server with EKS config 
- Create Jenkins job with config `k8s_deployment/prod/Jenkinsfile`
- Build the job and it will build the Docker image, push it to ECR and deploy the app in EKS cluster.
