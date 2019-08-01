#   Install Compliance Scanner Pipeline

This pipeline will install [Compliance Scanner for PCF](https://docs.pivotal.io/addon-compliance-tools/1-0/index.html).

1.  Create folder in S3 named `compliance-scanner`

1.  Login to Concourse
    ```
    fly login --target sam-ci --team-name main --concourse-url https://plane.control.fionathebluepittie.com
    ````

1.  Create the Install Compliance Scanner for PCF Pipeline
    ```
    fly -t sam-ci set-pipeline -p install-compliance-scanner -c sandbox/install-compliance-scanner/pipeline.yml

    fly -t sam-ci unpause-pipeline -p install-compliance-scanner
    ```