#   Fetch Platform Automation

This pipeline will download Platform Automation from PivNet, and store it in an S3 bucket.

1.  Create bucket `com.fionathebluepittie.sandbox`
1.  Create folder `platform-automation`
1.  Store Pipeline Secrets in Credhub

    Note: This approach leverages Concourse's [Credential Lookup Rules](https://concourse-ci.org/credhub-credential-manager.html#credential-lookup-rules)

    ```
    credhub set -t value -n /concourse/main/pivnet-api-token -v <YOUR PIVNET API TOKEN>
    ```

1.  Login to Concourse
    ```
    fly login --target sam-ci --team-name main --concourse-url https://plane.control.fionathebluepittie.com
    ````

1.  Create the Fetch Platform Automation Pipeline
    ```
    fly -t sam-ci set-pipeline -p fetch-platform-automation -c sandbox/fetch-platform-automation/pipeline.yml

    fly -t sam-ci unpause-pipeline -p fetch-platform-automation
    ```