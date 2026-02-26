set -Eeuo pipefail

before() {
  echo "noop"
}

after() {
  # Verify the require-labels policy is active by attempting to create a pod without the label.
  # We can't rely on TEST_OUTPUT from the rollout restart since Kyverno 1.13 autogen rules
  # do not intercept rollout restart patches (which only update annotations, not labels).
  output=$(kubectl run hook-test-pod --image=nginx --restart=Never 2>&1 || true)

  if [[ "$output" != *"validate.kyverno.svc-fail"* ]]; then
    >&2 echo "Expected pod creation to be blocked by Kyverno admission webhook, but got: $output"
    exit 1
  fi

  if [[ "$output" != *"require-labels"* ]]; then
    >&2 echo "Expected pod creation to be blocked by require-labels policy, but got: $output"
    exit 1
  fi

  if [[ "$output" != *"CostCenter"* ]]; then
    >&2 echo "Expected block reason to mention 'CostCenter' label, but got: $output"
    exit 1
  fi
}

"$@"
