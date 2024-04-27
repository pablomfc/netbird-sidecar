## Automatically Inject Netbird with Kyverno ClusterPolicy

This guide details how to automatically inject Netbird as a sidecar container into deployments using a Kyverno cluster policy. Kyverno enforces policies as an admission control, validating Kubernetes resources before admitting them into the cluster.

**Optional Local Network Route Fix**

An init container can be optionally included to address local network routes and ensure routing through the exit node.

**Prerequisites**

* A Kubernetes cluster  (Amazon EKS was used in this example)

**Steps**

1. **Install Kyverno**

   ```bash
   helm repo add kyverno https://kyverno.github.io/kyverno/
   helm repo update
   helm install kyverno --namespace kyverno kyverno/kyverno --create-namespace
   ```

2. **Create Netbird Configuration Secret**

   Create a Kubernetes secret named `netbird` in the `default` namespace to store Netbird configuration details. Replace the placeholder with your actual setup key:

   ```bash
   kubectl create secret generic netbird -n default \
       --from-literal=NB_SETUP_KEY='your_netbird_setup_key' \
       --from-literal=EXTRA_SUBNETS='192.168.0.0/16,172.20.0.0/16'  # Optional comma-separated extra subnets
   ```

3. **Create ConfigMap Script (Optional)**

   If you want to fix local network routes and route traffic through the exit node during initialization, create a ConfigMap named `netbird-init` in the `default` namespace. Include your init script named `nb-init.sh` within the ConfigMap.

   ```bash
   kubectl create configmap netbird-init -n default --from-file=nb-init.sh
   ```

4. **Create Kyverno ClusterPolicy**

   Apply the `kyverno-clusterpolicy.yaml` file containing the Kyverno policy definition. This policy looks for deployments with the annotation `netbird.io/inject: "true"` and automatically injects the Netbird sidecar container.

   ```bash
   kubectl apply -f kyverno-clusterpolicy.yaml
   ```

5. **Test with Deployment Example**

   Deploy a test deployment with the `netbird.io/inject: "true"` annotation in the `deployment.yaml` file and apply it to the default namespace. Kyverno will automatically inject the Netbird container during deployment.

   ```bash
   kubectl apply -f deployment.yaml -n default
   ```

This process automates Netbird injection for deployments marked for the sidecar container, streamlining your configuration management and ensuring consistent network management with Netbird.