<div align="center">

# ⚡ GCP Terraform Ops Panel with VPC Flow Logs

**Production-inspired Google Cloud networking and compute project using Terraform, custom VPC subnets, firewall rules, startup automation, Nginx, and metadata-driven validation endpoints**

<br/>

<img width="1200" alt="GCP Ops Panel Architecture" src="./Evidence/01-architecture/gcp-ops-panel-architecture.png" />

<br/>
<br/>

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-Cloud%20Provider-4285F4?style=for-the-badge&logo=googlecloud&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-Infrastructure%20as%20Code-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Compute Engine](https://img.shields.io/badge/Compute%20Engine-VM%20Runtime-4285F4?style=for-the-badge&logo=googlecloud&logoColor=white)
![VPC](https://img.shields.io/badge/VPC-Custom%20Network-0EA5E9?style=for-the-badge)
![VPC Flow Logs](https://img.shields.io/badge/VPC%20Flow%20Logs-Network%20Observability-16A34A?style=for-the-badge)
![Firewall](https://img.shields.io/badge/Firewall-Network%20Control-DC2626?style=for-the-badge)
![Debian](https://img.shields.io/badge/Debian%2012-Server%20OS-A81D33?style=for-the-badge&logo=debian&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-Web%20Server-009639?style=for-the-badge&logo=nginx&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-Startup%20Automation-121011?style=for-the-badge&logo=gnubash&logoColor=white)
![Status](https://img.shields.io/badge/Status-Working%20Deployment-success?style=for-the-badge)

</div>

---

## 📋 Table of Contents

- [📌 Overview](#-overview)
- [🧠 Problem Statement](#-problem-statement)
- [🎯 Project Objective](#-project-objective)
- [🏗️ Architecture Diagram](#️-architecture-diagram)
- [🔄 Architecture Flow](#-architecture-flow)
- [🧰 Technology Stack](#-technology-stack)
- [✅ What This Builds](#-what-this-builds)
- [🧱 Core Google Cloud Resources](#-core-google-cloud-resources)
- [📂 Project Structure](#-project-structure)
- [⚙️ Terraform Configuration Summary](#️-terraform-configuration-summary)
- [🚀 Quick Start](#-quick-start)
- [🧪 Validation and Testing](#-validation-and-testing)
- [📸 Deployment Evidence](#-deployment-evidence)
- [📊 Observability](#-observability)
- [🔐 Security Architecture](#-security-architecture)
- [🧭 Trust Boundaries](#-trust-boundaries)
- [⚠️ Current Demo Limitations](#️-current-demo-limitations)
- [🧠 Engineering Challenges and Key Decisions](#-engineering-challenges-and-key-decisions)
- [🧪 Troubleshooting](#-troubleshooting)
- [💰 Cost Considerations](#-cost-considerations)
- [♻️ Teardown](#️-teardown)
- [📈 Production Roadmap](#-production-roadmap)
- [🚀 Why This Project Matters](#-why-this-project-matters)
- [👨‍💻 About the Author](#-about-the-author)

---

## 📌 Overview

This project deploys a **Google Cloud Compute Engine web node** inside a **custom VPC network** using Terraform.

The instance is automatically configured with a Bash startup script that installs Nginx, reads Google Cloud metadata, and serves a small operational dashboard through HTTP. The deployment also creates multiple regional subnets with **VPC Flow Logs enabled**, providing network visibility for traffic analysis and troubleshooting.

The project demonstrates:

- Terraform-based Google Cloud infrastructure provisioning
- Custom VPC design with manual subnet creation
- Subnet-level VPC Flow Logs for network telemetry
- Compute Engine bootstrapping with startup scripts
- Nginx service deployment on Debian 12
- Metadata-driven application output
- HTTP health check and JSON metadata endpoints
- Firewall rule targeting through network tags

---

## 🧠 Problem Statement

Cloud engineers need to prove that infrastructure is not only deployed, but also **reachable, observable, and explainable**.

A basic virtual machine is not enough. A production-style infrastructure project should answer operational questions such as:

- Is the server reachable over the expected ports?
- What network and subnet is the VM attached to?
- Can the instance report its own identity, zone, region, and IP addresses?
- Are network flows being logged for investigation and troubleshooting?
- Can the environment be recreated consistently with Infrastructure as Code?
- Can a health endpoint be used by future load balancers or monitoring systems?

This project answers those questions by combining Terraform, Compute Engine, VPC Flow Logs, firewall rules, startup automation, and a working Nginx dashboard.

---

## 🎯 Project Objective

Build a repeatable Google Cloud infrastructure deployment where:

- Terraform creates the network, subnets, firewall rule, service account, and VM
- the VPC uses custom subnets instead of auto-created subnetworks
- every subnet has VPC Flow Logs enabled
- a Compute Engine instance boots automatically using a Bash startup script
- Nginx serves a web dashboard on port `80`
- `/healthz` returns a simple health response
- `/metadata` returns structured JSON about the running instance
- the deployment can be validated with browser access, `curl`, Terraform outputs, and GCP CLI commands

---

## 🏗️ Architecture Diagram

> Save your architecture image as:
>
> `Evidence/01-architecture/gcp-ops-panel-architecture.png`

<img width="1200" alt="GCP Ops Panel Architecture" src="./Evidence/01-architecture/gcp-ops-panel-architecture.png" />

---

## 🔄 Architecture Flow

```text
                          ┌──────────────────────────┐
                          │        External User      │
                          │     Browser / curl        │
                          └─────────────┬────────────┘
                                        │
                                        │ HTTP :80
                                        ▼
                          ┌──────────────────────────┐
                          │     Ephemeral Public IP   │
                          │   Compute Engine NIC      │
                          └─────────────┬────────────┘
                                        │
                                        ▼
┌──────────────────────────────────────────────────────────────────────┐
│                         Custom GCP VPC                               │
│                         freefree                                     │
│                                                                      │
│  ┌──────────────────────────┐       ┌──────────────────────────┐     │
│  │ public1-log-test-subnet   │       │ public2-log-test-subnet   │     │
│  │ 10.1.0.0/16               │       │ 10.2.0.0/16               │     │
│  │ VPC Flow Logs Enabled     │       │ VPC Flow Logs Enabled     │     │
│  └─────────────┬────────────┘       └──────────────────────────┘     │
│                │                                                     │
│                ▼                                                     │
│  ┌──────────────────────────┐       ┌──────────────────────────┐     │
│  │ private1-log-test-subnet  │       │ private2-log-test-subnet  │     │
│  │ 10.11.0.0/16              │       │ 10.12.0.0/16              │     │
│  │ VM Attached Here          │       │ VPC Flow Logs Enabled     │     │
│  │ VPC Flow Logs Enabled     │       │                           │     │
│  └─────────────┬────────────┘       └──────────────────────────┘     │
│                │                                                     │
│                ▼                                                     │
│  ┌──────────────────────────┐                                        │
│  │ Compute Engine VM         │                                        │
│  │ instance-god              │                                        │
│  │ Debian 12 / e2-medium     │                                        │
│  │ Tags: foo, bar            │                                        │
│  └─────────────┬────────────┘                                        │
│                │                                                     │
│                ▼                                                     │
│  ┌──────────────────────────┐                                        │
│  │ Startup Script            │                                        │
│  │ apt + nginx + curl + jq    │                                        │
│  │ metadata collection        │                                        │
│  └─────────────┬────────────┘                                        │
│                │                                                     │
│                ▼                                                     │
│  ┌──────────────────────────┐                                        │
│  │ Nginx Web Service         │                                        │
│  │ /                         │                                        │
│  │ /healthz                  │                                        │
│  │ /metadata                 │                                        │
│  └──────────────────────────┘                                        │
└──────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
                          ┌──────────────────────────┐
                          │ Google Cloud Logging      │
                          │ VPC Flow Log Records      │
                          └──────────────────────────┘
```

---

## 🧰 Technology Stack

| Layer | Technology |
|---|---|
| Cloud Provider | Google Cloud Platform |
| Infrastructure as Code | Terraform |
| Terraform Provider | `hashicorp/google` version `7.35.0` |
| Network | Custom-mode Google Compute VPC |
| Subnets | Four regional subnetworks with VPC Flow Logs |
| Compute | Google Compute Engine |
| Operating System | Debian 12 |
| Web Server | Nginx |
| Automation | Bash startup script |
| Metadata Source | Google Compute Metadata Server |
| Validation | Browser, `curl`, `jq`, `gcloud`, Terraform outputs |

---

## ✅ What This Builds

This Terraform deployment creates:

- A custom Google Cloud VPC network
- Four manually defined regional subnets
- VPC Flow Logs enabled on each subnet
- A firewall rule allowing TCP `80`, `8080`, and `22` to tagged instances
- A custom service account resource
- A Compute Engine VM named `instance-god`
- Debian 12 boot disk image
- An ephemeral public IP address
- VM network tags: `foo` and `bar`
- A Bash startup script that installs and configures Nginx
- A web dashboard served from `/`
- A plain-text health endpoint at `/healthz`
- A JSON metadata endpoint at `/metadata`

---

## 🧱 Core Google Cloud Resources

| Resource | Purpose |
|---|---|
| `google_compute_network` | Creates the custom VPC network with automatic subnet creation disabled. |
| `google_compute_subnetwork` | Creates subnet ranges and enables VPC Flow Logs. |
| `google_compute_firewall` | Allows selected TCP ports to instances with matching network tags. |
| `google_service_account` | Creates a custom service account for future least-privilege VM identity. |
| `google_compute_instance` | Deploys the Debian-based web node. |
| Metadata Startup Script | Bootstraps the VM and creates the Nginx dashboard. |
| Cloud Logging | Receives VPC Flow Logs generated by the subnet log configuration. |

---

## 📂 Project Structure

```text
Homework Week 2/
├── 0-userdata.sh
├── 1-main.tf
├── 2-var.tf
├── 3-output.tf
├── website.png
├── terraform apply.png
├── README.md
├── .gitignore
└── .terraform.lock.hcl
```

Recommended repository structure for evidence and diagrams:

```text
Homework Week 2/
├── Evidence/
│   ├── 01-architecture/
│   │   └── gcp-ops-panel-architecture.png
│   ├── 02-terraform-apply/
│   │   └── terraform-apply-complete.png
│   ├── 03-browser-validation/
│   │   └── ops-panel-browser.png
│   ├── 04-curl-validation/
│   │   ├── healthz-output.txt
│   │   └── metadata-output.json
│   └── 05-flow-logs/
│       └── vpc-flow-logs-query.png
├── 0-userdata.sh
├── 1-main.tf
├── 2-var.tf
├── 3-output.tf
├── README.md
├── .gitignore
└── .terraform.lock.hcl
```

> The README references the screenshots using the files already in the repository root:
>
> - `./website.png`
> - `./terraform%20apply.png`
>
> GitHub renders spaces in image paths more reliably when the space is encoded as `%20`.

> Do not commit `.terraform/`, `terraform.tfstate`, or `terraform.tfstate.backup` to GitHub.

---

## ⚙️ Terraform Configuration Summary

### Provider

```hcl
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.35.0"
    }
  }
}
```

The provider deploys resources into the configured Google Cloud project and region.

---

### Variables

| Variable | Description | Default |
|---|---|---|
| `project_id` | Google Cloud project ID where resources are created. | `gcp-mastery-495919` |
| `region` | Region used for regional resources such as subnets. | `us-central1` |
| `network_name` | Name of the custom VPC network. | `freefree` |
| `instance_name` | Variable reserved for VM naming. | `my-instance` |

> Note: The current VM resource uses the hardcoded name `instance-god` and zone `us-central1-a`. A production-ready version should convert the VM name and zone into variables.

---

### VPC and Subnets

The VPC is created with `auto_create_subnetworks = false`, which means the subnet layout is controlled manually instead of relying on Google Cloud's default subnet creation behavior.

| Subnet Name | CIDR Range | Region | Flow Logs |
|---|---:|---|---|
| `public1-log-test-subnetwork` | `10.1.0.0/16` | `us-central1` | Enabled |
| `public2-log-test-subnetwork` | `10.2.0.0/16` | `us-central1` | Enabled |
| `private1-log-test-subnetwork` | `10.11.0.0/16` | `us-central1` | Enabled |
| `private2-log-test-subnetwork` | `10.12.0.0/16` | `us-central1` | Enabled |

Flow log settings:

```hcl
log_config {
  aggregation_interval = "INTERVAL_10_MIN"
  flow_sampling        = 0.5
  metadata             = "INCLUDE_ALL_METADATA"
}
```

This provides sampled network telemetry with metadata included, which helps with troubleshooting, audit review, and network visibility.

---

### Firewall Rule

The firewall rule allows inbound traffic to instances with the `foo` and `bar` network tags.

```hcl
allow {
  protocol = "tcp"
  ports    = ["80", "8080", "22"]
}

source_ranges = ["0.0.0.0/0"]
target_tags   = ["foo", "bar"]
```

For this demo, the open source range makes browser and SSH testing easier. For production, SSH should not be open to the internet.

Recommended production alternatives:

- restrict SSH to a trusted admin IP
- use OS Login
- use Identity-Aware Proxy TCP forwarding
- remove the public IP and use private administration paths
- separate HTTP rules from administrative access rules

---

### Compute Engine Instance

The VM is deployed with:

| Setting | Value |
|---|---|
| Name | `instance-god` |
| Machine Type | `e2-medium` |
| Zone | `us-central1-a` |
| Image | `debian-cloud/debian-12` |
| Tags | `foo`, `bar` |
| Public IP | Ephemeral |
| Startup Script | `0-userdata.sh` |

The startup script installs Nginx, reads metadata from the Google metadata server, creates `/metadata.json`, and serves the dashboard through Nginx.

---

## 🚀 Quick Start

### 1. Authenticate to Google Cloud

```bash
gcloud auth login
gcloud auth application-default login
```

Set the active project:

```bash
gcloud config set project gcp-mastery-495919
```

---

### 2. Enable Required APIs

```bash
gcloud services enable compute.googleapis.com
```

---

### 3. Clone the Repository

```bash
git clone <your-repo-url>
cd <your-repo-folder>
```

---

### 4. Review Variables

Open `2-var.tf` and update the values if needed:

```hcl
variable "project_id" {
  default = "gcp-mastery-495919"
}

variable "region" {
  default = "us-central1"
}

variable "network_name" {
  default = "freefree"
}
```

---

### 5. Initialize Terraform

```bash
terraform init
```

---

### 6. Validate the Terraform Code

```bash
terraform validate
```

---

### 7. Review the Plan

```bash
terraform plan
```

---

### 8. Deploy the Infrastructure

```bash
terraform apply -auto-approve
```

Expected result:

```text
Apply complete! Resources: 0 added, 2 changed, 0 destroyed.

Outputs:

instance_ip = "http:34.58.124.43"
```

> If your output shows `http:34.x.x.x`, update `3-output.tf` to use `http://` instead of `http:`. See the troubleshooting section below.

---

## 🧪 Validation and Testing

### 1. Capture the VM IP Address

If the output is fixed to use `http://`, run:

```bash
terraform output -raw instance_ip
```

If the current output still returns `http:IP_ADDRESS`, extract the IP like this:

```bash
INSTANCE_IP=$(terraform output -raw instance_ip | sed 's#^http:##')
echo $INSTANCE_IP
```

---

### 2. Test the Homepage

```bash
curl -i http://$INSTANCE_IP/
```

Expected result:

```text
HTTP/1.1 200 OK
Server: nginx
Content-Type: text/html
```

Browser test:

```text
http://<INSTANCE_PUBLIC_IP>/
```

You should see the **SEIR-I Ops Panel** dashboard with instance identity, location, network, and system information.

---

### 3. Test the Health Endpoint

```bash
curl -s http://$INSTANCE_IP/healthz
```

Expected result:

```text
ok
```

This endpoint is useful for future load balancer health checks, uptime checks, and monitoring probes.

---

### 4. Test the Metadata Endpoint

```bash
curl -s http://$INSTANCE_IP/metadata | jq .
```

Expected fields:

```json
{
  "service": "seir-i-node",
  "student_name": "Anonymous Padawan (temporarily)",
  "project_id": "gcp-mastery-495919",
  "instance_name": "instance-god",
  "hostname": "instance-god",
  "region": "us-central1",
  "zone": "us-central1-a",
  "machine_type": "e2-medium",
  "network": {
    "vpc": "freefree",
    "subnet": "private1-log-test-subnetwork",
    "internal_ip": "10.11.x.x",
    "external_ip": "x.x.x.x"
  }
}
```

---

### 5. Confirm the VM in Google Cloud

```bash
gcloud compute instances describe instance-god \
  --zone us-central1-a \
  --format="table(name,status,machineType.basename(),networkInterfaces[0].networkIP,networkInterfaces[0].accessConfigs[0].natIP)"
```

Expected result:

```text
NAME          STATUS    MACHINE_TYPE  NETWORK_IP  NAT_IP
instance-god  RUNNING   e2-medium     10.11.x.x   x.x.x.x
```

---

### 6. Confirm Firewall Rule

```bash
gcloud compute firewall-rules describe my-firewall-rule \
  --format="yaml(name,network,allowed,sourceRanges,targetTags)"
```

Expected controls:

```yaml
allowed:
- IPProtocol: tcp
  ports:
  - '80'
  - '8080'
  - '22'
sourceRanges:
- 0.0.0.0/0
targetTags:
- foo
- bar
```

---

### 7. Confirm Subnet Flow Log Configuration

```bash
gcloud compute networks subnets describe private1-log-test-subnetwork \
  --region us-central1 \
  --format="yaml(name,ipCidrRange,enableFlowLogs,logConfig)"
```

Repeat for the other subnets:

```bash
gcloud compute networks subnets list \
  --filter="network:freefree" \
  --format="table(name,region.basename(),ipCidrRange,enableFlowLogs)"
```

---

### 8. Query VPC Flow Logs

After generating traffic to the VM, query recent flow logs:

```bash
gcloud logging read \
  'resource.type="gce_subnetwork" AND logName:"compute.googleapis.com%2Fvpc_flows"' \
  --limit=10 \
  --format=json | jq .
```

Generate test traffic first:

```bash
curl -s http://$INSTANCE_IP/healthz
curl -s http://$INSTANCE_IP/metadata | jq .
```

---

## 📸 Deployment Evidence

This repository includes screenshots that prove the infrastructure deployed successfully and the application endpoint rendered from the Compute Engine public IP.

### Terraform Apply Complete

The Terraform apply output shows the deployment completing successfully and returning the external HTTP endpoint for the VM.

<img width="1200" alt="Terraform apply complete output showing the Compute Engine instance endpoint" src="./terraform%20apply.png" />

---

### Website Validation

The browser validation confirms that the Nginx startup script completed, the SEIR-I Ops Panel is online, and the instance metadata is being rendered from the running VM.

<img width="1200" alt="SEIR-I Ops Panel website running on the Compute Engine external IP" src="./website.png" />

---

## 📊 Observability

This project includes two observability layers.

### 1. Application-Level Health

The Nginx service exposes:

| Endpoint | Purpose |
|---|---|
| `/` | Human-readable operational dashboard. |
| `/healthz` | Plain-text service health response. |
| `/metadata` | JSON metadata and system information. |

### 2. Network-Level Visibility

Each subnet enables VPC Flow Logs with:

- 10-minute aggregation interval
- 50% flow sampling
- metadata included

This helps answer questions such as:

- Which source IPs are reaching the VM?
- Which destination ports are receiving traffic?
- Is traffic flowing through the expected subnet?
- Are firewall changes affecting connectivity?
- What network evidence exists for troubleshooting?

---

## 🔐 Security Architecture

| Layer | Control | Current Implementation |
|---|---|---|
| Network Isolation | Custom VPC | Auto subnet creation disabled; manual subnet layout. |
| Traffic Control | Firewall rule | Allows TCP `80`, `8080`, and `22` to tagged instances. |
| Targeting | Network tags | Firewall applies only to instances tagged `foo` and `bar`. |
| Observability | VPC Flow Logs | Enabled on all subnets with metadata included. |
| Host Bootstrap | Startup script | Automates package install and service configuration. |
| Service Health | `/healthz` | Provides a simple operational health check. |
| Runtime Context | `/metadata` | Shows non-secret instance identity and system details. |

### Important Security Notes

This is a learning and portfolio project, not a hardened production deployment.

The following items should be changed before production use:

- Do not leave SSH open to `0.0.0.0/0`.
- Do not expose internal metadata details publicly unless there is a strong reason.
- Attach a least-privilege custom service account to the VM.
- Remove the public IP and use IAP, VPN, or a load balancer pattern where possible.
- Use HTTPS instead of plain HTTP.
- Split firewall rules by purpose: web traffic, admin access, health checks, and internal traffic.
- Add Cloud Monitoring alerts for service uptime and VM health.

---

## 🧭 Trust Boundaries

### Boundary 1 — Public Internet to Compute Engine

Users reach the VM through an ephemeral public IP on port `80`. The firewall rule controls whether traffic reaches the instance based on source range, protocol, port, and target tags.

### Boundary 2 — Compute Engine to Metadata Server

The startup script queries the Google metadata server from inside the VM. Metadata access should be treated carefully because metadata can expose sensitive runtime identity information if mishandled.

### Boundary 3 — VPC Network to Cloud Logging

Subnet flow records are exported to Cloud Logging. This creates a separate evidence layer for network activity outside the VM itself.

---

## ⚠️ Current Demo Limitations

The current implementation intentionally keeps the design simple. Known limitations:

```text
- SSH is open to 0.0.0.0/0 for demo access.
- The VM has an ephemeral public IP.
- HTTPS is not configured.
- There is no load balancer in front of the VM.
- The custom service account is created but not attached to the VM.
- The VM zone is hardcoded as us-central1-a.
- The instance name variable exists but is not used by the VM resource.
- The Terraform output currently formats the URL as http:IP instead of http://IP.
- The /metadata endpoint exposes infrastructure details publicly.
- There are no Cloud Monitoring alerts or dashboards yet.
```

These limitations are acceptable for the current project because the goal is to prove Terraform provisioning, subnet logging, VM startup automation, and HTTP validation first.

---

## 🧠 Engineering Challenges and Key Decisions

| Problem | Why It Mattered | Decision | Implementation |
|---|---|---|---|
| Avoiding default networking | Auto-created subnetworks hide the network design and reduce learning value. | Use a custom-mode VPC. | Set `auto_create_subnetworks = false`. |
| Adding network visibility | A VM deployment without traffic logs is harder to troubleshoot and audit. | Enable VPC Flow Logs on every subnet. | Added `log_config` to each `google_compute_subnetwork`. |
| Proving the VM actually bootstrapped | A running VM alone does not prove the app stack configured correctly. | Use a startup script to install Nginx and create endpoints. | `0-userdata.sh` installs packages, writes Nginx config, and restarts the service. |
| Making validation scriptable | Browser-only validation is weak evidence. | Add plain-text and JSON endpoints. | `/healthz` returns `ok`; `/metadata` returns structured JSON. |
| Linking firewall rules to compute | Broad network rules can apply unintentionally if not scoped. | Use target network tags. | VM uses tags `foo` and `bar`; firewall targets the same tags. |
| Capturing runtime context | Engineers need to know where the VM runs and what network it uses. | Query GCP metadata server at boot. | Startup script reads project, zone, region, machine type, VPC, subnet, and IPs. |
| Keeping the deployment repeatable | Manual console builds are hard to review and recreate. | Use Terraform for infrastructure provisioning. | VPC, subnets, firewall, service account, and VM are defined as code. |

---

## 🧪 Troubleshooting

### Issue 1 — Terraform output returns `http:IP` instead of `http://IP`

Current output:

```hcl
output "instance_ip" {
  value = "http:${google_compute_instance.standard.network_interface[0].access_config[0].nat_ip}"
}
```

Recommended fix:

```hcl
output "instance_ip" {
  value       = "http://${google_compute_instance.standard.network_interface[0].access_config[0].nat_ip}"
  description = "The external HTTP URL of the Compute Engine instance."
}
```

Then run:

```bash
terraform apply -auto-approve
terraform output -raw instance_ip
```

---

### Issue 2 — Browser cannot reach the VM

Check the firewall rule:

```bash
gcloud compute firewall-rules describe my-firewall-rule \
  --format="yaml(allowed,sourceRanges,targetTags)"
```

Check the VM tags:

```bash
gcloud compute instances describe instance-god \
  --zone us-central1-a \
  --format="yaml(tags)"
```

The firewall target tags and VM tags must match.

---

### Issue 3 — Nginx is not serving the dashboard

SSH into the VM or use the serial console, then run:

```bash
sudo systemctl status nginx --no-pager
sudo nginx -t
curl -s localhost/healthz
curl -s localhost/metadata | jq .
```

Restart Nginx if needed:

```bash
sudo systemctl restart nginx
```

---

### Issue 4 — Startup script did not complete

Check startup script logs:

```bash
sudo journalctl -u google-startup-scripts.service --no-pager
```

Also check package installation:

```bash
which nginx
which curl
which jq
```

---

### Issue 5 — Flow logs are not visible immediately

VPC Flow Logs may take time to appear. Generate traffic and wait several minutes:

```bash
curl -s http://$INSTANCE_IP/healthz
curl -s http://$INSTANCE_IP/metadata | jq .
```

Then query Cloud Logging again:

```bash
gcloud logging read \
  'resource.type="gce_subnetwork" AND logName:"compute.googleapis.com%2Fvpc_flows"' \
  --limit=10
```

---

## 💰 Cost Considerations

This project is small, but it can still generate cost.

Potential cost sources:

- Compute Engine `e2-medium` runtime
- External IP usage
- Persistent boot disk storage
- Cloud Logging ingestion from VPC Flow Logs
- Network egress if accessed heavily

Cost-control recommendations:

- Destroy the environment when testing is complete.
- Reduce machine size if performance is not required.
- Lower VPC Flow Log sampling for longer-running demos.
- Avoid leaving public VMs running overnight.
- Review Cloud Logging retention and ingestion volume.

---

## ♻️ Teardown

To destroy all resources created by Terraform:

```bash
terraform destroy -auto-approve
```

Confirm the VM is gone:

```bash
gcloud compute instances list --filter="name=instance-god"
```

Confirm the firewall rule is gone:

```bash
gcloud compute firewall-rules list --filter="name=my-firewall-rule"
```

Confirm the VPC is gone:

```bash
gcloud compute networks list --filter="name=freefree"
```

---

## 📈 Production Roadmap

This project is a strong foundation for a larger GCP infrastructure build. A production-inspired version would add the following improvements.

### Phase 1 — Network and Access Hardening

- Replace open SSH with Identity-Aware Proxy TCP forwarding.
- Restrict administrative traffic to trusted identities or trusted IPs.
- Remove the public IP from the VM.
- Use Cloud NAT for outbound updates from private instances.
- Split firewall rules by function and port.

### Phase 2 — Load Balancing and HTTPS

- Place the VM behind an external HTTP(S) Load Balancer.
- Use Google-managed certificates for TLS.
- Convert the single VM into a Managed Instance Group.
- Use `/healthz` as the load balancer health check path.
- Add autoscaling policies based on CPU or request load.

### Phase 3 — Identity and Least Privilege

- Attach the custom service account to the VM.
- Grant only the minimum IAM roles needed.
- Disable broad default service account usage.
- Add OS Login for SSH identity control.
- Add organization policy constraints where appropriate.

### Phase 4 — Observability and Security Operations

- Build Cloud Monitoring dashboards for VM health and uptime.
- Add uptime checks against `/healthz`.
- Create alert policies for VM downtime and high CPU.
- Export VPC Flow Logs to BigQuery for deeper analysis.
- Create log-based metrics for suspicious traffic patterns.

### Phase 5 — Platform Expansion

- Add multiple service nodes across zones.
- Add private backend services.
- Add Cloud Armor in front of the load balancer.
- Add CI/CD with GitHub Actions or Cloud Build.
- Add automated Terraform validation and security scanning.

---

## 🚀 Why This Project Matters

This project is more than a basic VM deployment.

It demonstrates the ability to design, provision, validate, and explain a working Google Cloud environment using real infrastructure engineering practices.

### What This Project Proves

| Area | Value Shown |
|---|---|
| Infrastructure as Code | Google Cloud infrastructure is created through Terraform, not manual console clicks. |
| Network Design | Custom VPC and subnets are explicitly defined. |
| Observability | VPC Flow Logs are enabled for traffic visibility. |
| Automation | Startup scripts configure the server without manual intervention. |
| Operations | Health and metadata endpoints provide validation evidence. |
| Security Thinking | Firewall targeting, access limitations, and production gaps are clearly identified. |
| Troubleshooting | The project includes practical commands to verify compute, network, app, and logs. |

### This is the foundation of real cloud operations:

```text
Provision Infrastructure
        ↓
Bootstrap Runtime
        ↓
Expose a Controlled Service
        ↓
Validate Health
        ↓
Inspect Metadata
        ↓
Capture Network Logs
        ↓
Document Evidence
        ↓
Improve Toward Production
```

---

## 👨‍💻 About the Author

<p align="center">
  <img src="https://readme-typing-svg.demolab.com?font=Inter&weight=600&size=22&pause=1000&color=58A6FF&center=true&vCenter=true&width=900&lines=Cloud+Engineer+focused+on+AWS%2C+GCP%2C+Terraform%2C+and+automation;Building+production-inspired+infrastructure+projects;Turning+cloud+concepts+into+real-world+implementations" alt="Typing SVG" />
</p>

<p align="center">
  I build hands-on cloud projects designed to reflect practical engineering work rather than simple demos.
  My focus is on <b>cloud infrastructure</b>, <b>Infrastructure as Code</b>, <b>automation</b>, <b>security-minded design</b>,
  and <b>real implementation patterns</b> that translate into production environments.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/AWS-Architecting-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white" />
  <img src="https://img.shields.io/badge/Google%20Cloud-Infrastructure-4285F4?style=for-the-badge&logo=googlecloud&logoColor=white" />
  <img src="https://img.shields.io/badge/Terraform-Infrastructure-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" />
  <img src="https://img.shields.io/badge/Cloud-Engineering-1F6FEB?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Automation-Building-success?style=for-the-badge" />
</p>

<p align="center">
  <a href="https://www.linkedin.com/in/sama-engineer/">
    <img src="https://img.shields.io/badge/LinkedIn-Let's%20Connect-blue?style=for-the-badge&logo=linkedin" />
  </a>
  <a href="https://github.com/7twoduo">
    <img src="https://img.shields.io/badge/GitHub-See%20More%20Projects-black?style=for-the-badge&logo=github" />
  </a>
  <a href="https://gavinfogwe.win/">
    <img src="https://img.shields.io/badge/Portfolio-Explore-orange?style=for-the-badge&logo=googlechrome&logoColor=white" />
  </a>
</p>
