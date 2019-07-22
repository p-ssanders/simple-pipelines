#   Test Pipeline

1.  Download Platform Automation
    ```
    pivnet accept-eula -p platform-automation -r 3.0.1

    pivnet download-product-files -p platform-automation -r 3.0.1 -g platform-automation-image-3.0.1.tgz

    pivnet download-product-files -p platform-automation -r 3.0.1 -g platform-automation-tasks-3.0.1.zip
    ```

1.  Upload Platform Automation to S3
    ```
    aws configure

    aws s3 cp platform-automation-image-3.0.1.tgz s3://com.fionathebluepittie.sandbox/platform-automation/

    aws s3 cp platform-automation-tasks-3.0.1.zip s3://com.fionathebluepittie.sandbox/platform-automation/
    ```
    * Note: you can now delete the local copies of Platform Automation

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
    ```
    credhub set -t value -n '/concourse/main/access_key_id' -v <YOUR ACCESS KEY>
    credhub set -t value -n '/concourse/main/secret_access_key' -v <YOUR SECRET KEY>
    ```

1.  Login to Concourse
    ```
    fly login --target sam-ci --team-name main --concourse-url https://plane.control.fionathebluepittie.com
    ````

1.  Create the Test Pipeline
    ```
    fly -t sam-ci set-pipeline -p test-pipeline -c sandbox/test/pipeline.yml

    fly -t sam-ci unpause-pipeline -p test-pipeline
    ```
    * Note: The test pipeline has no triggers, so start it manually.