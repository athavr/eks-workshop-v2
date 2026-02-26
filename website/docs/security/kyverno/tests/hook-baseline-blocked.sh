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

  if [[ "$TEST_OUTPUT" != *"baseline-policy"* ]]; then
    >&2 echo "Expected pod to be blocked by baseline-policy, but got: $TEST_OUTPUT"
    exit 1
  fi

  if [[ "$TEST_OUTPUT" != *"privileged"* ]]; then
    >&2 echo "Expected block reason to mention 'privileged', but got: $TEST_OUTPUT"
    exit 1
  fi
}

"$@"
