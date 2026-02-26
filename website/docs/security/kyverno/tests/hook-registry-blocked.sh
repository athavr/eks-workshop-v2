set -Eeuo pipefail

before() {
  echo "noop"
}

after() {
  # TEST_OUTPUT contains the output of the kubectl run command from the markdown block
  if [[ "$TEST_OUTPUT" != *"validate.kyverno.svc-fail"* ]]; then
    >&2 echo "Expected pod to be blocked by Kyverno admission webhook, but got: $TEST_OUTPUT"
    exit 1
  fi

  if [[ "$TEST_OUTPUT" != *"restrict-image-registries"* ]]; then
    >&2 echo "Expected pod to be blocked by restrict-image-registries policy, but got: $TEST_OUTPUT"
    exit 1
  fi

  if [[ "$TEST_OUTPUT" != *"Unknown Image registry"* ]]; then
    >&2 echo "Expected block reason to mention 'Unknown Image registry', but got: $TEST_OUTPUT"
    exit 1
  fi
}

"$@"
