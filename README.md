# !!! WIP !!!

# bosh-inception-day1
This is the first of a multi-day bosh inception. The goal of this first day is to set a baseline of what bosh is and to get a director deployed along with a release.

## Agenda (Rough)

| Time | Topic                                                                                         |
| ---- | --------------------------------------------------------------------------------------------- |
| 1000 | What is Bosh                                                                                  |
| 1010 | Bosh Primitives (Stemcells, Releases, CPI, Manifests)                                         |
| 1020 | Bosh Tools (bosh-init, bosh-cli, bosh-aws-cpi)                                                |
| 1030 | Deploy Jumpbox                                                                                |
| 1040 | Setup Jumpbox                                                                                 |
| 1045 | Bosh Manifest Breakdown (Create bosh manifest)                                                |
| 1100 | Upload Stemcell & Release                                                                     |
| 1105 | Create Release Manifest (bosh 2.0 style manifest, talk about differences between 1.0 and 2.0) |
| 1115 | Deploy Release                                                                                |
| 1145 | Bosh Addons (runtime-config)                                                                  |
| 1200 | Manifest Generation                                                                           |

## Prep

In order to perform the environment creation steps you will need to have access to AWS along with AWS Access and Secret 
Keys. You will also have to create a key-pair on AWS and have downloaded the resultant pem file. Create this key-pair
via the AWS console in the EC2 > Key Pairs section. Call the keypair "bosh" as that is what is used in the Terraform
files. After downloading the bosh.pem file copy it to ~/.ssh/bosh.pem and chmod it to 400.

## Slide Deck

To run the slide deck go into the `presentation` directory and execute `python -m SimpleHTTPServer`

Open a browser and navigate to: `http://localhost:8080` to view the slides.
