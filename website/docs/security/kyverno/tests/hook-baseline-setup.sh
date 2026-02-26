set -Eeuo pipefail

before() {
  # Clean up policies from previous lab sections to prevent interference
  # require-labels blocks pod creation without CostCenter label, which would
  # prevent the privileged-pod from being created in this section
  kubectl delete clusterpolicy require-labels add-labels --ignore-not-found=true
}

after() {
  echo "noop"
}

"$@"
