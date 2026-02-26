---
title: "Reports & Auditing"
sidebar_position: 74
---

Kyverno includes a [Policy Reporting](https://kyverno.io/docs/policy-reports/) tool that uses an open format defined by the Kubernetes Policy Working Group. These reports are deployed as custom resources in the cluster. Kyverno generates these reports when admission actions like _CREATE_, _UPDATE_, and _DELETE_ are performed in the cluster. Reports are also generated as a result of background scans that validate policies on existing resources.

Throughout this workshop, we have created several policies with specific rules. When a resource matches one or more rules according to the policy definition and violates any of them, an entry is created in the report for each violation. This can result in multiple entries if the same resource matches and violates multiple rules. When resources are deleted, their entries are removed from the reports. This means that Kyverno Reports always represent the current state of the cluster and do not record historical information.

As discussed earlier, Kyverno has two types of `validationFailureAction`:

1. `Audit` mode: Allows resources to be created and reports the action in the Policy Reports.
2. `Enforce` mode: Denies resource creation but does not add an entry in the Policy Reports.

For example, if a Policy in `Audit` mode contains a single rule requiring all resources to set the label `CostCenter`, and a Pod is created without that label, Kyverno will allow the Pod's creation but record it as a `FAIL` result in a Policy Report due to the rule violation. If this same Policy is configured with `Enforce` mode, Kyverno will immediately block the resource creation, and this will not generate an entry in the Policy Reports. However, if the Pod is created in compliance with the rule, it will be reported as `PASS` in the report. You can check blocked actions in the Kubernetes events for the Namespace where the action was requested.

Let's examine our cluster's compliance status with the policies we've created so far in this workshop by reviewing the Policy Reports generated.

```bash hook=reports
$ kubectl get policyreports -A
NAMESPACE     NAME                                   KIND          NAME                                             PASS   FAIL   WARN   ERROR   SKIP   AGE
...
carts         14b206ec-f98c-4f5a-98b8-08613b2bba3c   ReplicaSet    carts-757dbcfcf7                                 3      0      0      0       0      11m
carts         16f00a47-fe76-46e7-be02-3ec4bb16231e   ReplicaSet    carts-7dfbb5d849                                 3      0      0      0       0      179m
carts         50358693-2468-4b73-8873-c6239b90876c   Deployment    carts-dynamodb                                   1      2      0      0       0      179m
carts         60f7683d-3de7-40c8-8291-6dce06d2900e   Pod           carts-dynamodb-995f7768c-kl4s6                   1      2      0      0       0      179m
carts         6e48edbf-dd0d-478e-a52d-aed182785c24   Pod           carts-757dbcfcf7-sgpqv                           3      0      0      0       0      12m
carts         b0356ab5-e6a5-4326-a931-0e8d1a9f7f94   Deployment    carts                                            3      0      0      0       1      179m
carts         c914951d-21af-475d-a8f4-a0780a9d71c2   ReplicaSet    carts-dynamodb-995f7768c                         1      2      0      0       0      179m
carts         c9ee5eed-ecd0-47a5-9930-b4185757db02   ReplicaSet    carts-68d496fff8                                 2      1      0      0       0      179m
catalog       7584031d-b299-4ae6-8520-16b6b2df479f   StatefulSet   catalog-mysql                                    2      1      0      0       0      179m
catalog       8bae7be3-6452-4f2f-9d85-cf6cc3362d24   ReplicaSet    catalog-5fdcc8c65                                2      1      0      0       0      179m
catalog       93b327e5-9ce7-442c-831b-5816db78bb33   Pod           catalog-5fdcc8c65-qn5tx                          2      1      0      0       0      179m
catalog       b9de1775-064e-4d1c-b393-b5f88b0200b6   Pod           catalog-mysql-0                                  2      1      0      0       0      179m
catalog       d6c40501-8f34-4398-97a6-27ab1050ef93   Deployment    catalog                                          2      1      0      0       0      179m
checkout      11f1bb14-11b2-4f50-9da0-fde2375f66c9   ReplicaSet    checkout-redis-69cb79ff4d                        2      1      0      0       0      179m
checkout      3f896219-057e-40c0-bf99-c6ad4a57350b   Deployment    checkout                                         2      1      0      0       0      179m
checkout      3fefabc9-d971-4ea6-9045-688f825ed232   Pod           checkout-5b885fb57c-cnlkx                        2      1      0      0       0      179m
checkout      4df6b9d4-b87f-4a83-bbc3-985227280d2a   Deployment    checkout-redis                                   2      1      0      0       0      179m
checkout      b7e33f5a-8afa-4c32-98fb-aed787944a8e   ReplicaSet    checkout-5b885fb57c                              2      1      0      0       0      179m
checkout      da8392bf-5e4c-463e-98c3-20675b5aecd2   Pod           checkout-redis-69cb79ff4d-hdj5r                  2      1      0      0       0      179m
default       7c37b6cb-08e6-4ad3-adb3-df5f52bfb767   Pod           nginx-ecr                                        4      0      0      0       0      27s
default       ea02cd57-8684-43ad-8e8f-c0140beeec2b   Pod           nginx                                            3      1      0      0       0      2m29s
...
```

> Note: The output may vary. Reports will be generated for pods across all Namespaces.

In Kyverno 1.13+, policy reports are scoped per-resource rather than per-policy. Each report is named by the resource's UID and shows the aggregated pass/fail counts across all policies that evaluated that resource. You can see that the `nginx` pod has 1 `FAIL` (the `restrict-image-registries` rule) while `nginx-ecr` has all passes.

As mentioned earlier, blocked actions are recorded in the Namespace events. Let's examine those using the following command:

```bash
$ kubectl get events | grep block
4m29s       Warning   PolicyViolation   clusterpolicy/baseline-policy             Pod default/privileged-pod: [baseline] fail (blocked); Validation rule 'baseline' failed. It violates PodSecurity "baseline:latest": (Forbidden reason: privileged, field error list: [spec.containers[0].securityContext.privileged is forbidden, forbidden values found: true])
82s         Warning   PolicyViolation   clusterpolicy/restrict-image-registries   Pod default/nginx-public: [validate-registries] fail (blocked); validation error: Unknown Image registry. rule validate-registries failed at path /spec/containers/0/image/
```

> Note: The output may vary.

Now, let's take a closer look at the Policy Reports for the `default` Namespace used in the labs:

```bash
$ kubectl get policyreports
NAME                                   KIND   NAME        PASS   FAIL   WARN   ERROR   SKIP   AGE
7c37b6cb-08e6-4ad3-adb3-df5f52bfb767   Pod    nginx-ecr   4      0      0      0       0      98s
ea02cd57-8684-43ad-8e8f-c0140beeec2b   Pod    nginx       3      1      0      0       0      3m40s
```

Notice that the `nginx` pod has 1 `FAIL` and the `nginx-ecr` pod has all passes. This is because all the ClusterPolicies were created with `Enforce` mode — blocked resources are not reported, only resources that were admitted and then evaluated by the background scanner. The `nginx` Pod, which we left running with a publicly available image, is the only remaining resource that violates the `restrict-image-registries` policy.

To examine the violations for the `nginx` pod in more detail, describe its report. Since reports are named by UID, use `kubectl get policyreports` to find the report name for the `nginx` pod, then describe it:

```bash
$ kubectl describe policyreport $(kubectl get policyreports -o json | jq -r '.items[] | select(.scope.name=="nginx") | .metadata.name')
Name:         ea02cd57-8684-43ad-8e8f-c0140beeec2b
Namespace:    default
Labels:       app.kubernetes.io/managed-by=kyverno
Annotations:  <none>
API Version:  wgpolicyk8s.io/v1alpha2
Kind:         PolicyReport
Scope:
  API Version:  v1
  Kind:         Pod
  Name:         nginx
  Namespace:    default
Results:
  Message:  validation error: Unknown Image registry. rule validate-registries failed at path /spec/containers/0/image/
  Policy:   restrict-image-registries
  Result:   fail
  Rule:     validate-registries
  Scored:   true
  Source:   kyverno
  ...
Summary:
  Error:  0
  Fail:   1
  Pass:   3
  Skip:   0
  Warn:   0
Events:   <none>
```

The report shows the `nginx` pod's `fail` result for `restrict-image-registries` with the validation error message. The `nginx-ecr` pod has its own separate report with all passes. Monitoring reports in this way could be an overhead for administrators. Kyverno also supports a GUI-based tool for [Policy reporter](https://kyverno.github.io/policy-reporter/core/targets/#policy-reporter-ui), which is outside the scope of this workshop.

In this lab, you learned how to augment the Kubernetes PSA/PSS configurations with Kyverno. Pod Security Standards (PSS) and the in-tree Kubernetes implementation of these standards, Pod Security Admission (PSA), provide good building blocks for managing pod security. The majority of users switching from Kubernetes Pod Security Policies (PSP) should be successful using the PSA/PSS features.

Kyverno enhances the user experience created by PSA/PSS by leveraging the in-tree Kubernetes pod security implementation and providing several helpful enhancements. You can use Kyverno to govern the proper use of pod security labels. Additionally, you can use the new Kyverno `validate.podSecurity` rule to easily manage pod security standards with additional flexibility and an enhanced user experience. And, with the Kyverno CLI, you can automate policy evaluation upstream of your clusters.
