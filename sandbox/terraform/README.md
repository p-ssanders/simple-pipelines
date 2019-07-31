#   Terraform for PKS

Note: the `modules` directory can probably be replaced with the `modules` directory from a new `terraforming-aws` release if necessary.

1.  Run the Terraform ("Pave the IaaS")
    ```
    cd terraforming-pks
    terraform init
    terraform plan -out=pks.tfplan
    terraform apply pks.tfplan
    ```

1.  Login to Control Plane Credhub

    *   SSH to OpsManager VM
        ```
        ssh -i /tmp/opsmgrkey ubuntu@pcf.control.fionathebluepittie.com
        ```

    *   Login to BOSH's Credhub
        ```
        export OM_TARGET=https://pcf.control.fionathebluepittie.com
        export OM_USERNAME=admin
        export OM_PASSWORD=<YOUR OM PASSWORD>

        eval "$(om bosh-env)"
        ```

    *   Get the Control Plane Credhub Password
        ```
        credhub get -n "/p-bosh/control-plane/credhub_admin_client_password"
        ```

    *   Login to Credhub
        ```
        unset "${!CREDHUB@}"
        export CREDHUB_URL="https://credhub.control.fionathebluepittie.com:8844"
        export CREDHUB_CLIENT="credhub_admin_client"
        export CREDHUB_PASSWORD=<YOUR CREDHUB PASSWORD>
        export CA_CERT="$(cat certs/ca.pem)"

        credhub login -s "${CREDHUB_URL}" --client-name "${CREDHUB_CLIENT}" --client-secret "${CREDHUB_PASSWORD}" --ca-cert="$(cat certs/ca.pem)"
        ```

1.  Store Pipeline Secrets in Credhub

    Note: This approach leverages Concourse's [Credential Lookup Rules](https://concourse-ci.org/credhub-credential-manager.html#credential-lookup-rules)

    Note: Create a git deploy key for your repository following [these instructions](https://developer.github.com/v3/guides/managing-deploy-keys/#deploy-keys). Store them in a folder named `deploy-keys`.

    *   Convert Let's Encrypt Private Key to RSA
        ```
        openssl rsa -in ../certs/privkey.pem -out ../certs/private_key.pem.rsa.key
        ```

    *   Create Entries in the Control Plane Credhub

        Let:
        * `ca.pem` contains the contents of `../certs/chain.pem`
        * `certificate.pem` contains the contents of `../certs/cert.pem`
        * `private_key.pem` contains the contents of `../certs/private_key.pem`

        ```
        credhub set -t ssh -n /concourse/main/git-deploy-key --private deploy-keys/id_rsa --public deploy-keys/id_rsa.pub && \
        credhub set -t certificate -n /concourse/main/lets_encrypt_cert -r "$(cat certs/ca.pem)" -c "$(cat certs/cert.pem)" -p "$(cat certs/private_key.pem.rsa.key)" && \
        ```

1.  Login to Concourse
    ```
    fly login --target sam-ci --team-name main --concourse-url https://plane.control.fionathebluepittie.com
    ````

1.  Create the Install Ops Manager Pipeline
    ```
    fly -t sam-ci set-pipeline -p pave-iaas -c sandbox/terraform/pipeline.yml

    fly -t sam-ci unpause-pipeline -p pave-iaas
    ```
