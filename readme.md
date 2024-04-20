# Auto-Inject netbird using kyverno clusterpolicy
    A way to auto-inject netbird using a kyverno clusterpolicy. 
    An init-container was also added to optionally fix local network routes and route to exit-node

    In this example we create a clusterpolicy that acts as an admission control.
    When it finds the annotation below in a deployment:

        annotations:
            netbird.io/inject: "true"

    Performs netbird auto-inject as a sidecar

# Install Kyverno
    helm repo add kyverno https://kyverno.github.io/kyverno/
    helm repo update
    helm install kyverno --namespace kyverno kyverno/kyverno --create-namespace

# Create secret for netbird configuration
    kubectl create secret generic netbird -n default \
    --from-literal=NB_SETUP_KEY='00000000-0000-0000-0000-00000000000' \
    --from-literal=EXTRA_SUBNETS='192.168.0.0/16,172.20.0.0/16'

# Create configmap script for exit-node and local routes
    kubectl create configmap netbird-init -n default --from-file=nb-init.sh

# Create clusterpolicy
    kubectl apply -f kyverno-clusterpolicy.yaml

# Test with deployment example
    kubectl apply -f deployment.yaml -n default


