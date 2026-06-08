# Homework Week 8 — GCP Infrastructure, Instance Groups, and Terraform VM Deployment

## Table of Contents

* [Lab Objective](#lab-objective)
* [Project Overview](#project-overview)
* [Project Structure](#project-structure)
* [Q & A](#q--a)
* [Runbook](#runbook)
* [Terraform](#terraform)
* [Validation and Testing](#validation-and-testing)
* [References](#references)
* [Author](#author)

---

## Lab Objective

This homework focused on Google Cloud infrastructure concepts, including instance groups, instance templates, autoscaling, autohealing, health checks, load balancing, and Terraform-based VM provisioning.

The Terraform portion provisions a Compute Engine instance inside a custom VPC network with subnets, firewall rules, an external IP address, a CentOS Stream 10 boot image, and a startup script.

---

## Project Overview

This project contains written documentation and Terraform code for Homework Week 8.

The written documentation includes:

* Q & A answers
* A runbook for creating a managed instance group through ClickOps
* Terraform explanation notes
* Validation steps
* References used

The Terraform configuration creates:

* A custom VPC network
* Multiple subnets with flow logging enabled
* A firewall rule allowing TCP traffic
* A Compute Engine VM
* An external IP address
* A startup script attached to the VM

---

## Project Structure

```text
Homework Week 8/
├── README.md
└── infra/
    ├── 0-userdata.sh
    ├── 1-main.tf
    ├── 2-var.tf
    ├── 3-output.tf
    ├── terraform apply.png
    └── website.png
```

Files that should not be committed:

```text
.terraform/
terraform.tfstate
terraform.tfstate.backup
```

---

## Q & A

Answer the following questions in a section called “Q & A”:
Each bullet point can be between 1-5 sentences. You choose the amount of detail as long as I see that you understand it.
What is the difference between high availability and fault tolerance? Which is best to strive for?

High availability is having something avaible in multiple locations at the same time and fault tolerance is having something that can withand failure if one part fails. We should strive for both to ensure our systems stay online according to our purposes.

Explain the difference between autoscaling and elasticity. What is vertical and horizontal autoscaling? Is one better? Are they feasible on prem?

Autoscaling is when something increases and decreases in size based on demand. Elasticity is the capacity for something to expand and increase it size and also reduce it's size. Horizontal scalling is raising the number of something like an ec2 instance from one to 2 instance to meet a demand and vertical scaling is raising the processing power of a server like an ec2 instance from 1cpu core to 10cpu cores. One is not better than the other, it is just up to the need at the time, usually, we use vertical since we can scale infinitely instead of vertical which can only scale so far before we hit cpu max and gpu max power. They are feasible on prem if they configure their set of servers properly like aws configured their own.

Explain what the difference between managed and unmanaged instance groups is.

a managed instance group is a set of servers that the expansion and compression are being controlled by a controller while the unmanaged instance group are instances that exist with no controller of expansion or compression.

Explain the different use cases for health checks used by applications (in instance groups) and health checks used by load balancers. Can they be the same? Are they different API calls? Should they be the same?

The health checks for the instance groups are so the instance can expand and compress the number of instances. The health checks used by the mig are so incase the instance fails at that level, the traffic gets routed else where. They can be the same and that can work if the y go to the /healthz route and do their 200 series health checks. They can be different api calls, depending on how they set it up. It is usally better to have them be different so you can have better checks to ensure 1 part of the ec2 instance application is working but the other is not working.

---

## Runbook

### End Goal

The goal is to create a fully configured managed instance group using ClickOps in the Google Cloud Console. The instance group should be able to use an instance template, support autoscaling, and use autohealing with a health check. The final result should be a managed group of VM instances that can be maintained by Google Cloud.

### Prerequisites

Before starting, the engineer should have:

* Access to the correct Google Cloud project
* Compute Engine API enabled
* Permissions to create instance templates
* Permissions to create managed instance groups
* Permissions to create health checks
* Permissions to create firewall rules
* A VPC and subnet available
* A startup script or image ready if needed
* A known health check path
* A selected region and zones

### Create the Instance Template

1. Go to **Compute Engine**.
2. Go to **Instance templates**.
3. Click **Create instance template**.
4. Select the machine type.
5. Select the boot disk image.
6. Configure the network and subnet.
7. Add network tags if firewall rules require them.
8. Add the startup script if needed.
9. Save the instance template.

### Create the Managed Instance Group

1. Go to **Compute Engine**.
2. Go to **Instance groups**.
3. Click **Create instance group**.
4. Choose **New managed instance group**.
5. Select the instance template.
6. Choose regional or multiple zones.
7. Select the region.
8. Select the zones.
9. Set the initial number of instances.
10. Create the group.

### Enable Autoscaling

1. Open the managed instance group.
2. Enable autoscaling.
3. Set the minimum number of instances.
4. Set the maximum number of instances.
5. Choose the scaling metric.
6. Set the target utilization.
7. Save the configuration.

### Enable Autohealing

1. Create or select a health check.
2. Attach the health check to the managed instance group.
3. Set the initial delay.
4. Save the configuration.

### Verify Multi-Zone Management

1. Open the managed instance group details page.
2. Confirm the group is regional or multi-zone.
3. Check the instances created by the group.
4. Confirm the instances are placed across multiple zones.
5. Confirm autoscaling is enabled.
6. Confirm autohealing is enabled.
7. Confirm the health check is attached.

### Critical Configuration

* Instance template must be attached to the MIG.
* The MIG must use the correct region and zones.
* Firewall rules must allow the required ports.
* Health checks must use the correct protocol, port, and path.
* Autoscaling minimum and maximum values must be set.
* Autohealing must have enough initial delay for startup.
* Named ports should be configured if the MIG is used with a load balancer.

---

## Terraform

### Terraform Goal

The Terraform configuration provisions a Google Compute Engine VM and the supporting networking resources.

The configuration includes:

* Google provider configuration
* Custom VPC
* Custom subnetworks
* Firewall rule
* Compute Engine instance
* Boot disk configuration
* External IP configuration
* Startup script
* Output values

### Terraform Resources Created

```text
google_compute_network.vpc_network
google_compute_subnetwork.private-subnetwork1-with-logging
google_compute_subnetwork.private-subnetwork2-with-logging
google_compute_subnetwork.public-subnetwork1-with-logging
google_compute_subnetwork.public-subnetwork2-with-logging
google_compute_firewall.rules
google_service_account.desauno
google_compute_instance.standard
```

### Provider Configuration

The provider block connects Terraform to Google Cloud using the project and region values from variables.

```hcl
provider "google" {
  project = var.project_id
  region  = var.region
}
```

### VPC Configuration

The VPC is created with automatic subnet creation disabled.

```hcl
resource "google_compute_network" "vpc_network" {
  project                 = var.project_id
  name                    = var.network_name
  auto_create_subnetworks = false
  mtu                     = 1460
}
```

### Subnet Configuration

The configuration creates subnetworks with VPC flow logging enabled.

Flow logging settings include:

* Aggregation interval
* Flow sampling
* Metadata inclusion

### Firewall Configuration

The firewall rule allows TCP traffic on:

```text
80
8080
22
```

The firewall targets instances with the following tags:

```text
foo
bar
```

### Compute Instance Configuration

The VM is created with:

* Name: `instance-god`
* Zone: `us-central1-a`
* Network tags: `foo`, `bar`
* Boot disk image: `centos-cloud/centos-stream-10`
* Boot disk size: `100`
* Boot disk type: `pd-balanced`
* External IP through `access_config`
* Startup script from `0-userdata.sh`

### Startup Script

The startup script is attached using:

```hcl
metadata_startup_script = file("${path.module}/0-userdata.sh")
```

### Variables

The configuration uses variables for:

* Project ID
* Region
* Network name
* Instance name

```hcl
variable "project_id" {
  description = "The ID of the project in which to create resources."
  type        = string
  default     = "gcp-mastery-495919"
}

variable "region" {
  description = "The region in which to create resources."
  type        = string
  default     = "us-central1"
}

variable "network_name" {
  description = "The name of the VPC network."
  type        = string
  default     = "freefree"
}

variable "instance_name" {
  description = "The name of the Compute Engine instance."
  type        = string
  default     = "my-instance"
}
```

---

## Validation and Testing

### Terraform Commands

Run these commands from the Terraform directory:

```bash
terraform fmt
terraform init
terraform validate
terraform plan
terraform apply
```

### Verify Terraform Apply

The `terraform apply` command should complete successfully and create the resources in Google Cloud.

### Verify in Google Cloud Console

Check the following in the GCP Console:

* VPC network exists
* Subnets exist
* Firewall rule exists
* VM instance exists
* VM has an external IP
* VM has the expected boot disk
* VM has the expected network tags
* Startup script was attached

### Verify Outputs

Run:

```bash
terraform output
```

The output should show the values defined in `3-output.tf`.

### Git Check Before Submission

Before pushing to GitHub, run:

```bash
git status
```

Make sure these are not committed:

```text
.terraform/
terraform.tfstate
terraform.tfstate.backup
```

---

## References

### Google Cloud Documentation

Instance Groups:

```text
https://docs.cloud.google.com/compute/docs/instance-groups#managed_instance_groups
https://cloud.google.com/instance-groups?hl=en
```

Load Balancing:

```text
https://cloud.google.com/load-balancing?hl=en
https://docs.cloud.google.com/load-balancing/docs/application-load-balancer
https://docs.cloud.google.com/load-balancing/docs/https
https://docs.cloud.google.com/load-balancing/docs/application-load-balancer#three-tier_web_services
```

Solutions Architecture:

```text
https://docs.cloud.google.com/architecture/infra-reliability-guide/design
```

Additional Resource:

```text
https://levelup.gitconnected.com/load-balancing-on-google-cloud-platform-gcp-why-and-how-a8841d9b70c
```

### Course and Book Resources

```text
Udemy Masterclass Section 11
Udemy Terraform Section 7
Packt Chapter 4
Packt Chapter 10
Terraform Chapters 3-4
```

---

## Author

Gavin Fogwe








Answer the following questions in a section called “Q & A”:
Each bullet point can be between 1-5 sentences. You choose the amount of detail as long as I see that you understand it. 
What is the difference between high availability and fault tolerance? Which is best to strive for? 

High availability is having something avaible in multiple locations at the same time and fault tolerance is having something that can withand failure if one part fails. We should strive for both to ensure our systems stay online according to our purposes.

Explain the difference between autoscaling and elasticity. What is vertical and horizontal autoscaling? Is one better? Are they feasible on prem? 

Autoscaling is when something increases and decreases in size based on demand. Elasticity is the capacity for something to expand and increase it size and also reduce it's size. Horizontal scalling is raising the number of something like an ec2 instance from one to 2 instance to meet a demand and vertical scaling is raising the processing power of a server like an ec2 instance from 1cpu core to 10cpu cores. One is not better than the other, it is just up to the need at the time, usually, we use vertical since we can scale infinitely instead of vertical which can only scale so far before we hit cpu max and gpu max power. They are feasible on prem if they configure their set of servers properly like aws configured their own.

Explain what the difference between managed and unmanaged instance groups is.

a managed instance group is a set of servers that the expansion and compression are being controlled by a controller while the unmanaged instance group are instances that exist with no controller of expansion or compression.

Explain the different use cases for health checks used by applications (in instance groups) and health checks used by load balancers. Can they be the same? Are they different API calls? Should they be the same?

The health checks for the instance groups are so the instance can expand and compress the number of instances. The health checks used by the mig are so incase the instance fails at that level, the traffic gets routed else where. They can be the same and that can work if the y go to the /healthz route and do their 200 series health checks. They can be different api calls, depending on how they set it up. It is usally better to have them be different so you can have better checks to ensure 1 part of the ec2 instance application is working but the other is not working.

Explain in a few sentences what the 3 tier architecture is and how it relates to what you are learning. 
In a section called “runbook” 
In the first few sentences (3 max) explain the end goal. 
Add a section on prerequisites (what do I, as an engineer, need to have ready to make this happen?)
Goal: a fully configured managed instance group created via Clickops
Explain how to enable autoscaling and autohealing

Use a MIG and put the target group withing it and set the desired instances to be more the min and less than the max. That enables autoscaling and autohealing.

Explain how to verify that the instance group will manage instances across multiple zones

The instances are within a target group and the mig is regional so it can manage instances across multiple zones.

Explain any other critical config explicitly 

You need to set the health checks, set the forwarding rule, set the http or https proxy and set the url map, set the backend to the target groups and finally set the mig as backends for the target groups which within  them will have an autoscalling policy, a lauch tempalte, etc.

Remember this is for other engineers so no need to try to explain everything like I am a nontechnical person. Also keep in mind runbooks are not for learning but for executing something properly.  Keep it pretty high level. Use whatever amount of detail you feel is correct. 
Test it by having a group mate use this runbook to accomplish the goal. They should be able to rely on it only to spin up a properly configured instance group. 
In a section called “terraform”
Explain the mandatory (required) arguments for a VM in terraform 

you neeed name, machine_type,zone,tags,boot_disk,network_interface,access_config, and metadata if you want tags.

Explain how to output the internal and external IP addresses of the provisioned VM and how you figured this out 

Here is the argument, just find it on the internet, ${google_compute_instance.standard.network_interface[0].access_config[0].nat_ip} & ${google_compute_instance.standard.network_interface[0].access_config[0].internal_ip}

Choose 2 non-required arguments and give an explanation for both (do not copy and paste the reference material) 

  metadata = {
    foo = "bar"
  }
This is for adding tags, not necessary but useful.

I don't know, there is another one but I don't have the example.

Explain how you would figure out the correct format for creating a VM with the “centOS stream 10” image (the specific image is up to you). 

I would find it on google or in the goolge documentation on how to make centOS stream 10 image and then I would add it to the machine type since it is a machine type.

Explain the difference between the “name” argument and the computed “id” and “self_link” attributes 

The name is the name I give the resource and the id is the arn name which is like the dns name in a public cloud. The self_link is a strict global unique url that is used to gain access to a resource, it is like the absolute path to a resource over the internet.
