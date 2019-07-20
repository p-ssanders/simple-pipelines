#   Terraform for PKS

Note: the `modules` directory can probably be replaced with the `modules` directory from a new `terraforming-aws` release if necessary.

1.  "Pave the IaaS"

    *   Create a `terraform.tfvars` file using `terraform.tfvars-example` as a template

    *   Terraform
        ```
        cd terraforming-pks

        terraform init
        terraform plan -out=pks.tfplan
        terraform apply pks.tfplan
        ```

1.  Create BOSH Director Database

    ```
    terraform output ops_manager_ssh_private_key > /tmp/pks-opsmgrkey
    chmod 0400 /tmp/pks-opsmgrkey
    ssh -i /tmp/pks-opsmgrkey ubuntu@pcf.sandbox.fionathebluepittie.com

    mysql -h <terraform output rds_address> -u <terraform output rds_username> -P <terraform output rds_port> -p
    <enter `terraform output rds_password`>
    create database bosh;
    ```
