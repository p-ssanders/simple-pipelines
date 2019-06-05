#   PCF Automation

This repository contains [Concourse](https://concourse-ci.org) pipelines that can create, and update PCF foundations using [Platform Automation](http://docs.pivotal.io/platform-automation).
The work was done on AWS, but can be adapted, conceptually, for any IaaS.

Assume was completed

### Prerequisites
1. Create a Control Plane. Walkthrough available in [this repo](https://github.com/pivotal-samuel-sanders/terraforming-aws-control-plane/README.md).
1. Pave IaaS for PKS (or PAS). Walktrhough available in [this repo](https://github.com/pivotal-samuel-sanders/terraforming-aws-pks) **TODO update this to be just terraform**

### Get Started
1. Deploy and run the [Test Pipeline](https://github.com/pivotal-samuel-sanders/pcf-automation/blob/master/sandbox/test-pipeline/README.md) to confirm your setup.
2. Deploy and run the [Install Ops Manager Pipeline](https://github.com/pivotal-samuel-sanders/pcf-automation/blob/master/sandbox/install-ops-manager-pipeline/README.md) to deploy an Ops Manager VM for PKS (or PAS) to your pre-paved IaaS.