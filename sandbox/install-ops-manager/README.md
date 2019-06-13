#   Install Ops Manager Pipeline

1.  [Pave the IaaS](../../terraform/README.md) for PKS

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

    Note: Create a git deploy key for your repository following [these instructions](https://developer.github.com/v3/guides/managing-deploy-keys/#deploy-keys).

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
        credhub set -t ssh -n '/concourse/main/git-deploy-key' --private id_rsa --public id_rsa.pub && \
        credhub set -t value -n '/concourse/main/credhub-client' -v credhub_admin_client && \
        credhub set -t value -n '/concourse/main/credhub-secret' -v <YOUR CONTROL PLANE CREDHUB SECRET> && \
        credhub set -t certificate -n '/concourse/main/lets_encrypt_cert -r "$(cat certs/ca.pem)" -c "$(cat certs/cert.pem)" -p "$(cat certs/private_key.pem.rsa.key)" && \
        credhub set -t value -n '/concourse/main/sandbox/pivnet-api-token' -v <YOUR PIVNET API TOKEN> && \
        credhub set -t value -n '/concourse/main/sandbox/access_key_id' -v <YOUR ACCESS KEY> && \
        credhub set -t value -n '/concourse/main/sandbox/secret_access_key' -v <YOUR SECRET KEY> && \
        credhub set -t value -n '/concourse/main/sandbox/ops_manager_iam_user_access_key' -v <terraform output ops_manager_iam_user_access_key> && \
        credhub set -t value -n '/concourse/main/sandbox/ops_manager_iam_user_secret_key' -v <terraform output ops_manager_iam_user_secret_key> && \
        credhub set -t value -n '/concourse/main/sandbox/ops-manager-password' -v "$(openssl rand -base64 16)" && \
        credhub set -t value -n '/concourse/main/sandbox/ops-manager-decryption-passphrase' -v "$(openssl rand -base64 32)" && \
        credhub set -t ssh -n '/concourse/main/sandbox/ops_manager_ssh_private_key' -p <terraform output ops_manager_ssh_private_key> && \
        credhub set -t value -n /concourse/main/sandbox/rds_password -v <terraform output rds_password>
        ```

1.  Login to Concourse
    ```
    fly login --target sam-ci --team-name main --concourse-url https://plane.control.fionathebluepittie.com
    ````

1.  Create the Install Ops Manager Pipeline
    ```
    fly -t sam-ci set-pipeline -p install-ops-manager -c sandbox/install-ops-manager/pipeline.yml -l sandbox/install-ops-manager/vars.yml

    fly -t sam-ci unpause-pipeline -p install-ops-manager
    ```
    * Note: The test pipeline has no triggers, so start it manually.