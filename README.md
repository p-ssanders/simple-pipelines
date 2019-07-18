#   PCF Automation

This repository contains [Concourse](https://concourse-ci.org) pipelines that can create, and update PCF foundations using [Platform Automation](http://docs.pivotal.io/platform-automation).

Currently there is only one environment: `sandbox`.

The work was done on AWS, but can be adapted, conceptually, for any IaaS.

### Prerequisites

1. Create a Control Plane using [Control Plane with Let's Encrypt Certificates on AWS](https://github.com/pivotal-samuel-sanders/terraforming-aws-control-plane) as a guide.

### Get Started
1. Pave the IaaS for your PKS using the included [Terraform](https://github.com/pivotal-samuel-sanders/pcf-automation/tree/master/terraform).
1. Deploy and run the [Test Pipeline](https://github.com/pivotal-samuel-sanders/pcf-automation/blob/master/sandbox/test) to confirm your setup.
1. Deploy and run the [Install Ops Manager Pipeline](https://github.com/pivotal-samuel-sanders/pcf-automation/blob/master/sandbox/install-ops-manager).
1. Deploy and run the [Install PKS Pipeline](https://github.com/pivotal-samuel-sanders/pcf-automation/tree/master/sandbox/install-pks).