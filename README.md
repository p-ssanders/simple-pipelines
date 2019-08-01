#   Simple Pipelines

This repository contains simple [Concourse](https://concourse-ci.org) pipelines that perform single, atomic, yet interesting work related to the creation, and maintenance of PCF foundations using [Platform Automation](http://docs.pivotal.io/platform-automation).

Currently there is only one environment: `sandbox`.

The work was done on AWS, but can be adapted, conceptually, for any IaaS.

##  Prerequisites

*   Create a Control Plane using [Control Plane with Let's Encrypt Certificates on AWS](https://github.com/pivotal-samuel-sanders/terraforming-aws-control-plane) as a guide.

##  Generate Let's Encrypt Certificates

1.  Create Hosted Zones

    Create a new Hosted Zone for `sandbox.fionathebluepittie.com`.

    Then create a new `NS` record in the `fionathebluepittie.com` hosted zone with for `sandbox.fionathebluepittie.com` with the values from the the `sandbox.fionathebluepittie.com` `NS` record.

1.  Generate Certs Using Certbot
    ```
    sudo certbot \
    --server https://acme-v02.api.letsencrypt.org/directory \
    -d sandbox.fionathebluepittie.com \
    -d *.sandbox.fionathebluepittie.com \
    -d *.pks.sandbox.fionathebluepittie.com \
    -d *.apps.sandbox.fionathebluepittie.com \
    -d *.sys.sandbox.fionathebluepittie.com \
    -d *.login.sys.sandbox.fionathebluepittie.com \
    -d *.uaa.sys.sandbox.fionathebluepittie.com \
    --manual --preferred-challenges dns-01 certonly
    ```

1.  Copy the certificate files into `sandbox/certs` (as these certs are for `sandbox` environment)
    ```
    sudo cp -r /etc/letsencrypt/live/sandbox.fionathebluepittie.com/* ../sandbox/certs/

    sudo chown <username>:<group> ../sandbox/certs
    ```

##  Deploy Pipelines

1.  Deploy and run the [Test Pipeline](https://github.com/pivotal-samuel-sanders/pcf-automation/blob/master/sandbox/test) to confirm your setup.

1.  Deploy and run the [Fetch Platform Automation Pipeline](https://github.com/pivotal-samuel-sanders/pcf-automation/blob/master/sandbox/fetch-platform-automation) to have Platform Automation available in S3

1.  Deploy and run the [Terraform Pipeline](https://github.com/pivotal-samuel-sanders/pcf-automation/blob/master/sandbox/terraform) to pave your IaaS for PKS.

1.  Deploy and run the [Install Ops Manager Pipeline](https://github.com/pivotal-samuel-sanders/pcf-automation/blob/master/sandbox/install-ops-manager) to create an Ops Manager VM and deploy a BOSH Director on your paved IaaS.

1.  Deploy and run the [Install PKS Pipeline](https://github.com/pivotal-samuel-sanders/pcf-automation/tree/master/sandbox/install-pks) to deploy PKS.

1.  Deploy and run the [Install Compliance Scanner Pipeline](https://github.com/pivotal-samuel-sanders/pcf-automation/tree/master/sandbox/install-compliance-scanner) to deploy Compliance Scanner for PCF.