# Week X — Global Load Balancing, Cloud Armor, Cloud CDN, and Terraform

## Overview

This week focused on Google Cloud external global application load balancing, managed instance groups, health checks, Cloud Armor, Cloud CDN, Cloud NAT, and basic Terraform infrastructure deployment.

The goal was to understand how enterprise web applications are made more available, fault tolerant, secure, and globally reachable using Google Cloud networking and edge services.

---

## Resources Used

### Udemy

* Masterclass — Section 12

  * Used to review Google Cloud networking and load balancing concepts.
* Security — Section 21

  * Used to understand security controls around edge protection and web application defense.

### Books

* Packt — Chapter 5

  * Used to reinforce networking, load balancing, and security concepts.
* Terraform — Chapters 5 and 6

  * Used to review Terraform structure, resource organization, variables, outputs, formatting, and best practices.

### Documentation and Articles

#### Cloud NAT

* Cloud NAT documentation

  * Used to understand how private resources can reach the internet without having public IP addresses.
* Private NAT documentation

  * Used to understand private-to-private NAT use cases inside Google Cloud.
* Google Cloud NAT blog

  * Used to understand practical use cases and architecture decisions.

#### Global Load Balancing

* Global external HTTPS load balancer documentation

  * Used to understand frontend configuration, backend services, URL maps, target proxies, forwarding rules, and health checks.
* Google Cloud blog deep dive

  * Used to understand why Google Cloud load balancing is global and how traffic is distributed.

#### Cloud CDN

* Cloud CDN product page and documentation

  * Used to understand caching, POPs, TTL, origins, and how CDN improves content delivery.
* CDN explanation resources

  * Used to understand CDN concepts at a beginner level.

#### Cloud Armor

* Cloud Armor product page and documentation

  * Used to understand WAF rules, rate limiting, DDoS protection, and security policies.
* WAF basics from Cloudflare, F5, and Simplilearn

  * Used to understand what a WAF is and how it differs from normal firewall rules.
* Google Cloud blog posts

  * Used to understand real-world Cloud Armor use cases and Layer 7 attack protection.

---

# Q&A

## Load Balancers

### 1. How does load balancing contribute to fault tolerance? What about high availability?

Answer: Load Balancing contributes to fault tolerance by having multiple points at which traffic can flow preventing 1 fault from disrupting the flow of traffic. It becomes highly available because, the backend or instances can be in multiple availability zones and that makes it highly available.

---

### 2. Do global load balancers decrease latency for end users? Why or why not?

Answer: Global load balancers decrease latency for end users because, glb use any cast ip which allows them to not have a static ip but use the ip that is closest to their region. That is the main reason.

---

### 3. What are load balancer health checks for? Do we always need them? Is a load balancer different from a reverse proxy?

Answer: They are to ensure that the traffic is flowing from the lb to a healthy instance. We need them to detect if an instance is unhealthy so our traffic doesn't go to a bad server. A load balancer is different from a reverse proxy because it has the ability to decide which end location to route the traffic while reverse proxy just route the traffic to a preset location.

---

### 4. What are load balancer routing rules and URL maps for? Give an example or two of them in use.

Answer: Load balancer routing rules are a set of protocols to route traffic within a load balancer to the servers. Examples are http and https routing rules.

---

### 5. Explain what an anycast IP address is used for in the context of a global load balancer.

Answer: An anycast IP address is an ip that gets assigned to multiple load balancers all over the world. For a global load balancer, it assigns the load balancers ip to multiple load balancers all around the world.

---

## Cloud Armor

### 1. What does Cloud Armor offer?

Answer: It offers enterprise-grade network security and web application firewall service that protects applications from distributed denial of service attacks and many many other web vulnerabilities.

---

### 2. Why is it used in the first place?

Answer: It is used to protect your website against web attacks.

---

### 3. What layer in the OSI model does it operate at? Why is this important, and how is this firewall different from VPC firewall rules?

Answer:

---

### 4. What are rate-based rules for?

Answer: This are mainly used to protect againt dos and ddos attacks. That is literally the main point.

---

### 5. What is reCAPTCHA and how does it relate to this service?

Answer: This is a security service used to protect websites from automated abuse, spam, fraud and bot attacks.

---

## Cloud CDN

### 1. What are POPs used for?

Answer:Point of Presense are servers that store and deliver the cached content to the users. 

---

### 2. What kind of files are served with Cloud CDN?

Answer: Usually static files are stored like website, movies, photos, etc. We do not serve sensitive stuff like passwords, tokens, etc.

---

### 3. What services can be used with Cloud CDN for the source of content?

Answer: We can use the backend service for source, we can also use cloud storage for hosting as well.

---

### 4. Does Cloud CDN help protect against any types of malicious actors or cyberattacks? Explain.

Answer: CDNs protect against cyberattacks by putting the burden of responses on the cdn network rather than my server which improves performance and this protects me against attacks like ddos,etc.

---

### 5. Should an enterprise always use Cloud CDN? Why or why not?

Answer:

---An enterprise should use a cdn. They should use it to improve edge location performance, reduce cost of serving content, and to improve security.

### 6. What is TTL and how does it control content freshness?

Answer: TTL is time to live which with cdns is how long a piece of data is cache at a caching server and it controls content freshness by preventing new content changes from immediately showing up at the edge location, requiring the ttl to expire for the new content to be delivered, it is essentially a buffer.

---

# Runbook

## End Goal

The goal is to deploy a fully configured Google Cloud external global application load balancer using the Google Cloud Console. The load balancer will use a managed instance group as the backend. Health checks are required so the load balancer only sends traffic to healthy VM instances.

---

## Prerequisites

Before starting, make sure the following are ready:

* A Google Cloud project with billing enabled.
* Compute Engine API enabled.
* IAM permissions to create VPCs, firewall rules, instance templates, managed instance groups, health checks, backend services, and load balancers.
* A custom VPC and subnet.
* A working instance template with a startup script that serves a basic web page.
* A managed instance group created from the instance template.
* Firewall rules allowing health check traffic and HTTP traffic to the backend VMs.
* Confirmed backend application port, such as port `80` or `8888`.

---

## High-Level Steps

### 1. Create or Verify the VPC

Use a custom VPC instead of the default VPC.

Key settings:

* VPC mode: Custom
* Subnet: Regional subnet
* Firewall rules: Use target tags to control access

Reason:

A custom VPC gives better control over networking and avoids relying on default infrastructure.

---

### 2. Create the Instance Template

Create an instance template that defines how the backend VMs will be built.

Key settings:

* Machine type: Same as used in class
* Boot disk: Same OS image used in class
* Network tag: Example: `web-server`
* Startup script: Install and start a basic web server
* Network: Custom VPC
* Subnet: Selected custom subnet

Reason:

The instance template allows the managed instance group to create identical backend instances.

---

### 3. Create the Managed Instance Group

Create a managed instance group from the instance template.

Key settings:

* Type: Managed instance group
* Location: Regional or zonal, depending on class setup
* Instance template: Select the template created earlier
* Autoscaling: Optional unless required
* Minimum instances: Same as class configuration
* Named port: Add the backend service port, such as `http:80` or `customhttp:8888`

Reason:

The MIG provides repeatable backend instances and allows the load balancer to route traffic to healthy VMs.

---

### 4. Create the Health Check

Create an HTTP health check.

Key settings:

* Protocol: HTTP
* Port: Backend application port
* Request path: `/`
* Healthy threshold: Default or class setting
* Unhealthy threshold: Default or class setting

Reason:

The load balancer uses health checks to confirm which backend instances can receive traffic.

---

### 5. Create the Backend Service

Create a backend service and attach the managed instance group.

Key settings:

* Backend type: Instance group
* Backend: Select the MIG
* Port name: Match the named port on the MIG
* Health check: Select the health check created earlier
* Cloud CDN: Optional

Reason:

The backend service connects the load balancer to the actual backend compute resources.

---

### 6. Create the URL Map

Create a URL map for routing requests.

Basic setup:

* Default backend service: Main backend service

Optional path routing:

* `/colombia` routes to the Colombia backend service
* `/thailand` routes to the Thailand backend service

Reason:

URL maps control which backend service receives traffic based on the request path.

---

### 7. Create the Target HTTP Proxy

Create a target HTTP proxy and connect it to the URL map.

Reason:

The proxy receives HTTP traffic and uses the URL map to decide where to send requests.

---

### 8. Create the Forwarding Rule

Create the global forwarding rule.

Key settings:

* Protocol: HTTP
* Port: `80`
* IP address: Global external IP
* Target proxy: Select the HTTP proxy

Reason:

The forwarding rule gives users a public IP address to reach the global load balancer.

---

### 9. Test the Load Balancer

After the load balancer is created, test the public IP.

Commands:

```bash
curl http://LOAD_BALANCER_IP
curl http://LOAD_BALANCER_IP/colombia
curl http://LOAD_BALANCER_IP/thailand
```

Expected result:

* The root path should return the default page.
* `/colombia` should return the Colombia-themed page.
* `/thailand` should return the Thailand-themed page.

---

### 10. Validate Health

Confirm the backend service shows healthy instances.

Check:

* Backend service health status
* MIG VM status
* Firewall rules
* Health check port
* Startup script success

---

## Key Settings Used

| Setting            | Value                                     |
| ------------------ | ----------------------------------------- |
| Load Balancer Type | External Global Application Load Balancer |
| Protocol           | HTTP                                      |
| Port               | 80                                        |
| Backend            | Managed Instance Group                    |
| Health Check       | HTTP Health Check                         |
| Routing            | URL Map                                   |
| Firewall Control   | Target Tags                               |
| Optional Feature   | Cloud CDN                                 |

---

# Terraform

## Directory Structure

```text
terraform/
├── .gitignore
├── 00-versions.tf
├── 01-provider.tf
├── 02-variables.tf
├── 03-network.tf
├── 04-firewall.tf
├── 05-instance-template.tf
├── 06-mig.tf
├── 07-health-check.tf
├── 08-load-balancer.tf
├── 09-outputs.tf
└── README.md
```

---

## Terraform Requirements

The Terraform code must include:

* `terraform {}` block
* Provider version requirements
* Google provider block
* Custom VPC
* Custom subnet
* Firewall rules using target tags
* Instance template
* Managed instance group
* Health check
* External global application load balancer
* Backend service
* URL map
* Target proxy
* Forwarding rule
* Informative outputs
* Comments explaining important values

---

## Required `.gitignore`

```gitignore
# Terraform local files
.terraform/
.terraform.lock.hcl
terraform.tfstate
terraform.tfstate.*
crash.log
crash.*.log

# Variable files that may contain sensitive values
*.tfvars
*.tfvars.json

# Plan files
*.tfplan
plan.out

# OS/editor files
.DS_Store
.vscode/
.idea/
```

---

## Terraform Commands Used

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
```

---

## Important Submission Notes

* Do not commit Terraform state files.
* Do not commit `.terraform/`.
* Do not commit provider binaries.
* Code should be cleanly formatted with `terraform fmt`.
* Code should run after cloning with:

```bash
terraform init
terraform validate
terraform apply
```

---

# Optional Extension

## External Global Load Balancer With Two Backends

The optional extension adds two backend services:

* `colombia`
* `thailand`

The URL map should route traffic like this:

| Path        | Backend Service  |
| ----------- | ---------------- |
| `/colombia` | Colombia backend |
| `/thailand` | Thailand backend |

Each backend should serve a simple themed webpage.

Recommended professional wording:

* Colombia page: Colombia-themed demo page
* Thailand page: Thailand-themed demo page

Cloud CDN can also be enabled on the backend services if the content is mostly static and does not need to change frequently.

---

# Notes

This assignment demonstrates how Google Cloud can serve web applications through a global frontend, route traffic to managed backend compute, check backend health, optionally cache content at the edge, and apply security controls before traffic reaches the application.




I did everything in this project below 

https://github.com/7twoduo/GCP-Runtime-Domain-Load-Balancer

