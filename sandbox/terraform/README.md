#   Terraform for PKS

Note: the `modules` directory can probably be replaced with the `modules` directory from a new `terraforming-aws` release if necessary.

1.  "Pave the IaaS"
    ```
    cd terraforming-pks
    terraform init
    terraform plan -out=pks.tfplan
    terraform apply pks.tfplan
    ```
