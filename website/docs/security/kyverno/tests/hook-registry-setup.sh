set -Eeuo pipefail

before() {
  # Clean up any leftover nginx pod from previous test runs to prevent AlreadyExists errors
  kubectl delete pod nginx --ignore-not-found=true
}

after() {
  echo "noop"
}

"$@"
