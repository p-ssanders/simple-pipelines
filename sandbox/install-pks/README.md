#   Install PKS Pipeline

1.  [Install Ops Manager](../install-ops-manager/README.md)

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

    *   Create Entries in the Control Plane Credhub

        ```
        credhub set -n /concourse/main/sandbox/lets_encrypt_cert -t certificate -r "$(cat pks/pks-certs/ca.pem)" -c "$(cat pks/pks-certs/certificate.pem)" -p "$(cat pks/pks-certs/private_key.pem)" && \
        credhub set -n /concourse/main/sandbox/pks_api_hostname -t value -v api.pks.sandbox.fionathebluepittie.com && \
        credhub set -n /concourse/main/sandbox/pks_master_iam_instance_profile_name -t value -v sandbox_pks-master && \
        credhub set -n /concourse/main/sandbox/pks_worker_iam_instance_profile_name -t value -v sandbox_pks-worker
        ```

1.  Login to Concourse
    ```
    fly login --target sam-ci --team-name main --concourse-url https://plane.control.fionathebluepittie.com
    ````

1.  Create the Install Ops Manager Pipeline
    ```
    fly -t sam-ci set-pipeline -p install-pks -c sandbox/install-pks/pipeline.yml

    fly -t sam-ci unpause-pipeline -p install-pks
    ```
    * Note: The test pipeline has no triggers, so start it manually.

1.  Login to PKS API
    ```
    eval "$(om bosh-env -i /tmp/pks-opsmgrkey)"
    ADMIN_PASSWORD=$(om credentials \
    -p pivotal-container-service \
    -c '.properties.uaa_admin_password' \
    -f secret)

    pks login -a https://api.pks.sandbox.fionathebluepittie.com -u admin -p ${ADMIN_PASSWORD} --ca-cert sandbox/certs/cert.pem
    ```

1.  Create a Cluster
    ```
    pks clusters
    pks create-cluster cluster-1 --num-nodes 3 --plan small --external-hostname cluster-1.sandbox.fionathebluepittie.com
    watch pks cluster cluster-1
    ```

1.  Create a Load Balancer for the Cluster

    *   Use instructions at https://docs.pivotal.io/pks/1-4/aws-cluster-load-balancer.html#create
    *   Update DNS with an aliased A record that maps the cluster external hostname to the load balancer

1.  Access the Cluster
    ```
    pks cluster cluster-1
    pks get-credentials cluster-1
    kubectl config use-context cluster-1
    kubectl cluster-info
    ```

1.  Login to the Dashboard

    *   Create a file `~/expose-k8s-dashboard.yml` with the following content:
        ```
        ---
        apiVersion: rbac.authorization.k8s.io/v1beta1
        kind: ClusterRoleBinding
        metadata:
        name: kubernetes-dashboard
        labels:
            k8s-app: kubernetes-dashboard
        roleRef:
        apiGroup: rbac.authorization.k8s.io
        kind: ClusterRole
        name: cluster-admin
        subjects:
        - kind: ServiceAccount
        name: kubernetes-dashboard
        namespace: kube-system
        ```

    *   Run: `kubectl create -f ~/expose-k8s-dashboard.yml`
    *   Run: `kubectl proxy`
    *   Browse to: http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy and select the ~/kubeconfig file if prompted to do so.

1.  Deploy an App **TODO**