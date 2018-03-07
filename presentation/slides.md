# Bosh Inception - Day 1

[bosh-inception-day1](https://github.com/tracyde/bosh-inception-day1.git)
---

# Agenda

1. What is Bosh
2. Bosh Primitives
3. Bosh Tools
4. Deploy Jumpbox
5. Setup Jumpbox
6. Bosh Manifest Breakdown
7. Upload Stemcell & Release
8. Create Release Manifest
9. Deploy Release
10. Bosh Addons
11. Manifest Generation

---

# What is Bosh

`BOSH is an open source tool for release engineering, deployment, lifecycle management, and monitoring of distributed systems.`

.image-100[![Image of Bosh architecture](./images/Bosh-breakdown.png)]

---

# What is Bosh

![Image of Bosh architecture](./images/Bosh-architecture.png)

--

![Image of Bosh logo](./images/Bosh-logo.png)
[[bosh.io/docs](http://bosh.io/docs)]

---

# Bosh Primitives

* Stemcells
* Releases
* CPI
* Manifests

---

# Bosh Primitives - Stemcells

A bosh stemcell packages the basics for creating a new VM.
* Minimal OS image
* bosh Agent
* monit

---

# Bosh Primitives - Releases

A bosh release can either be an archive file or a git repository. It describes the steps needed to install and configure software.

A bosh release ultimately packages up all related binary assets, source code, compilation scripts, configurable properties, startup scripts and templates for configuration files.

---

# Bosh Primitives - CPI

The bosh CPI (Cloud Provider Interface) is essentially a library that abstracts away the intricacies of various cloud providers. The CPI is how bosh is ported to new providers.

Current CPI's
* AWS
* Azure
* OpenStack
* vSphere
* vCloud
* SoftLayer
* Google Cloud Platform (GCP)
* RackHD
* Local machine using BOSH Lite

---

# Bosh Primitives - Manifest

The bosh manifest is a yaml document that describes what actions to perform.

A manifest is similar to a puppet manifest or a chef recipe except the bosh manifest is more detailed since it is 
responsible for creating, monitoring, destroying, the underlying VM's along with configuring and installing software packages.

---

# Bosh Tools

* bosh-init [[repo](https://github.com/cloudfoundry/bosh-init), [docs](https://bosh.io/docs/using-bosh-init.html)]
* bosh-cli [[docs](https://bosh.io/docs/bosh-cli.html)]
* bosh-cpi [[docs](https://bosh.io/docs)]
* spruce [[docs](https://github.com/geofffranks/spruce)]

---

# Deploy Jumpbox

* [Terraform](https://www.terraform.io/) ([downloads](https://www.terraform.io/downloads.html))
  - [terraform-aws-vpc](https://github.com/cloudfoundry-community/terraform-aws-vpc)
  - Creates [subnets](https://github.com/cloudfoundry-community/terraform-aws-vpc#subnets)

Install Terraform on your machine

Run `terraform init` to initialize Terraform with the AWS provider

```
terraform get -update
terraform plan -module-depth=-1 -var-file terraform.tfvars -out terraform.tfplan
terraform apply "terraform.tfplan"
```

This will create two EC2 instances, bastion and nat. It will also create a VPC called cf-vpc with two subnets, 
cf-vpc-bastion and cf-vpc-microbosh.

---

### Deploy Command Flow

The deploy command consumes:

1. combo manifest (installation & deployment manifests)
1. stemcell (root file system)
1. CPI release
1. BOSH release

The deploy command produces:

1. a local installation of the CPI
1. a remote deployment of BOSH (and its multiple jobs) on a single VM or container on the cloud infrastructure targeted by the CPI

---

### Deploy Command Flow

.image-100[![bosh-init deploy flow](./images/bosh-init-deploy-flow.png "bosh-init deploy flow")]

---

# Create Bosh Manifest

---

# Upload Stemcell & Release

```
bosh upload stemcell https://bosh.io/d/stemcells/bosh-aws-xen-hvm-ubuntu-trusty-go_agent
```

---

# Create Release Manifest

[Bosh Manifest Layout](http://bosh.io/docs/manifest-v2.html)

--

Concourse!

---

# Deploy Release

---

# Bosh 2.0

* Jobs --> Instance Groups
  - So as not to be confused with Jobs in a Bosh Release
* CloudConfig ([docs](http://bosh.io/docs/cloud-config.html))
  - Separate IaaS config from deployment config
* AZs ([docs](http://bosh.io/docs/azs.html))
  - AZ is now a proper bosh type
* Links ([docs](http://bosh.io/docs/links.html))
  - Lets release authors use configuration from other jobs either in the same release or not
* RuntimeConfig ([docs](http://bosh.io/docs/runtime-config.html))
  - Yea, Addons!
* Job Migration ([docs](http://bosh.io/docs/migrated-from.html ))
* Persistent/Orphaned Disks ([docs](http://bosh.io/docs/persistent-disks.html))

---

# Bosh Addons

---

# Manifest Generation
