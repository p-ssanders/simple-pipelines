#   Terraform for PKS

Note: the `modules` directory can probably be replaced with the `modules` directory from a new `terraforming-aws` release if necessary.

1.  Generate Let's Encrypt Certificates

    *   Create Hosted Zones
    
        Create a new Hosted Zone for `sandbox.fionathebluepittie.com`. 
        
        Then create a new `NS` record in the `fionathebluepittie.com` hosted zone with for `sandbox.fionathebluepittie.com` with the values from the the `sandbox.fionathebluepittie.com` `NS` record.

    *   Generate Certs Using Certbot
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

    *   Copy the certificate files into `sandbox/certs` (as these certs are for `sandbox` environment)
        ```
        sudo cp -r /etc/letsencrypt/live/sandbox.fionathebluepittie.com/* ../sandbox/certs/

        sudo chown ssanders:staff ../sandbox/certs
        ```

1.  "Pave the IaaS"

    *   Create a `terraform.tfvars` file using `terraform.tfvars-example` as a template

    *   Terraform
        ```
        cd terraform/terraforming-pks

        terraform init
        terraform plan -out=pks.tfplan
        terraform apply pks.tfplan
        ```

1.  Create BOSH Director Database

    ```
    terraform output ops_manager_ssh_private_key > /tmp/pks/opsmgrkey
    chmod 0400 /tmp/pks/opsmgrkey
    ssh -i /tmp/pks/opsmgrkey ubuntu@pcf.sandbox.fionathebluepittie.com

    mysql -h <terraform output rds_address> -u <terraform output rds_username> -P <terraform output rds_port> -p
    <enter `terraform output rds_password`>
    create database bosh;
    ```
