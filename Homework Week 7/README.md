# 🌐 GCP Static Website Hosting and VPC Deployment with Terraform

<p align="center">
  <img src="https://img.shields.io/badge/Google%20Cloud-GCP-4285F4?style=for-the-badge&logo=googlecloud&logoColor=white" />
  <img src="https://img.shields.io/badge/Terraform-IaC-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" />
  <img src="https://img.shields.io/badge/Cloud%20Storage-Static%20Website-success?style=for-the-badge" />
  <img src="https://img.shields.io/badge/VPC-Networking-blue?style=for-the-badge" />
</p>

---

# 📋 Table of Contents

* Overview
* Lab Objective
* Architecture
* What This Project Builds
* Technology Stack
* Project Structure
* Implementation Steps
* Validation and Testing
* Security Considerations
* Lessons Learned
* Troubleshooting
* Cleanup
* References

---

# 📌 Overview

This project demonstrates how to use Terraform to provision infrastructure in Google Cloud Platform (GCP).

The deployment combines two Terraform exercises:

1. Creating a custom VPC network in GCP.
2. Hosting a static website using Google Cloud Storage.

All resources were provisioned using Infrastructure as Code (IaC) through Terraform.

---

# 🎯 Lab Objective

The purpose of this lab was to:

* Learn Terraform fundamentals
* Configure the Google Cloud provider
* Deploy a custom VPC network
* Create cloud storage resources
* Host a static website from a GCS bucket
* Upload website assets through Terraform
* Practice Terraform outputs
* Understand infrastructure automation concepts

---

# 🏗️ Architecture

```text
Terraform
    │
    ▼
Google Cloud Platform
    │
    ├── Custom VPC Network
    │
    └── Cloud Storage Bucket
            │
            ├── index.html
            ├── 404.html
            ├── avatar.png
            └── style.css
                    │
                    ▼
              Static Website
```

---

# ✅ What This Project Builds

## Networking

* Custom GCP VPC
* Manual subnet mode
* Terraform-managed network resource

## Storage

* Google Cloud Storage bucket
* Website hosting configuration
* Public read access

## Website Content

* Index page
* Custom 404 page
* Avatar image
* CSS styling

## Outputs

* Website URL
* VPC identifier

---

# 🧰 Technology Stack

| Component       | Technology            |
| --------------- | --------------------- |
| Cloud Provider  | Google Cloud Platform |
| IaC             | Terraform             |
| Networking      | Google VPC            |
| Storage         | Google Cloud Storage  |
| Frontend        | HTML                  |
| Styling         | CSS                   |
| Version Control | GitHub                |

---

# 📁 Project Structure

```text
Homework Week 7/
│
├── README.md
├── .gitignore
│
└── infra/
    ├── provider.tf
    ├── variables.tf
    ├── outputs.tf
    ├── main.tf
    ├── local-file.tf
    │
    └── assets/
        ├── index.html
        ├── 404.html
        ├── avatar.png
        └── style.css
```

---

# ⚙️ Implementation Steps

## 1. Configure Terraform Provider

Configured the Google provider using the project ID and region variables.

## 2. Create VPC Network

Created a custom VPC network with:

* Auto subnet creation disabled
* Custom network name
* Terraform-managed deployment

## 3. Create Cloud Storage Bucket

Configured a GCS bucket with:

* Website hosting enabled
* Custom index page
* Custom error page
* Uniform bucket access

## 4. Configure Public Access

Granted public object viewing permissions using:

```text
roles/storage.objectViewer
```

for:

```text
allUsers
```

## 5. Upload Website Assets

Terraform uploaded:

* index.html
* 404.html
* avatar.png
* style.css

to the bucket.

## 6. Create Outputs

Terraform generated outputs for:

* Website URL
* VPC identifier

---

# 🧪 Validation and Testing

## Terraform Validation

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

Successful deployment output:

```text
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

## Website Validation

Verified:

* Website loads successfully
* CSS renders correctly
* Image loads correctly
* Custom error page is accessible

## Network Validation

Verified VPC creation through:

```bash
terraform output
```

and the GCP Console.

---

# 🔐 Security Considerations

This project is intended as a learning exercise.

Security measures implemented:

* Infrastructure managed through Terraform
* Uniform bucket access enabled
* Controlled IAM permissions through Terraform

Production improvements would include:

* Cloud CDN
* HTTPS load balancing
* Cloud Armor
* Restricted public access
* Logging and monitoring

---

# 🧠 Lessons Learned

Through this project I learned:

* Terraform provider configuration
* Terraform resource management
* Google Cloud networking fundamentals
* Cloud Storage website hosting
* IAM policy configuration
* Terraform outputs
* Infrastructure as Code workflows
* Resource dependency management

---

# 🧪 Troubleshooting

## Bucket Already Exists

Issue:

```text
Bucket name already in use
```

Resolution:

```text
Use a globally unique bucket name.
```

## IAM Access Issues

Issue:

```text
Website returned Access Denied.
```

Resolution:

```text
Add storage.objectViewer permissions for allUsers.
```

## Website Not Loading Assets

Issue:

```text
CSS or image files not loading.
```

Resolution:

```text
Verify object upload paths and content types.
```

---

# 🧹 Cleanup

To remove all resources:

```bash
terraform destroy
```

---

# 📚 References

* Terraform Documentation
* Terraform Google Provider Documentation
* Google Cloud Storage Documentation
* Google VPC Documentation
* Terraform Registry
* Udemy Terraform Course

---

# 👨‍💻 Author

**Gavin Fogwe**

Cloud Engineer | Infrastructure as Code | Terraform | Google Cloud Platform

This project was completed as part of Terraform and Google Cloud infrastructure coursework focused on infrastructure automation and cloud fundamentals.





























Follow-Up Questions
When you are done, ideally you can answer the following:

Is Terraform a good tool to provision buckets?
Yes, terraform is a good tool for provisioning buckets in any public cloud.
Is Terraform an ideal tool to upload objects into buckets? Why or why not?
Not really, terraform can upload things to the bucket but it is not ideal because it requires a lot of manual effor to locate the files and it is not as good as some tools like bash for scripting which is more powerful.
Explain how you wrote the output (if you did). The output can be challenging.
IAM and access:
Did you need uniform bucket-level access? Do you know what it does?
Yes, Uniform bucket level access gives access to all objects within the bucket. I know what it does.
Explain the IAM resource. Why is it needed? Was it hard to implement? Did the hints help?
IAM is the identity resource for any cloud, it allows us to know who did what, which is the most important thing. It is hard to implement it since I need to have an account to create an identity from. Yes the hints helped.
What setting did you change to enable static website hosting on the bucket?
I don't know,
What changes could improve this infrastructure?
I think adding more security and controlling the amount of request that can hit the bucket using a cdn and a waf to protect the bucket which makes it more available and more defensible.