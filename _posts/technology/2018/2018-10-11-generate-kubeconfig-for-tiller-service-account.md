---
layout: post
category: technology
tags: kubernetes
title: Generate Kubeconfig For Tiller Service Account
---

In this post, I'll discuss how to get a kubeconfig for helm tiller service account.

In Kubernetes, it's a best practice granting a role to an application-specific service account. By creating a service account for designated operations ensures your application operating tasks in a particular scope.  In my case, I deploy applications into AWS EKS via Helm. The essential steps for configuring RBAC for EKS is described in [Helm: Role-Based Access Control](https://docs.helm.sh/using_helm/#role-based-access-control).

I suddenly realize that my kubeconfig looks like below, which is nothing special as the one introduced in [Getting Started with Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html):

```
apiVersion: v1
clusters:
- cluster:
    server: https://000000000000000000000000000.sk1.eu-west-1.eks.amazonaws.com
    certificate-authority-data: [REDACTED]
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "some-kinda-k8s-cluster"
        - "-r"
        - "arn:aws:iam::000000000000:role/SomeKindaRole"
```

In our security model, any AWS Operation must go through an AWS federated login switching to a dedicated IAM Role. It also requires me running `okta2aws login` for obtaining a temporary credential for a few hours.

It's unlikely I can complete authentication in Jenkins server because `okta2aws login` requires either Phone Approval or Ubikey Approval. So my way is to take a detour, use the `tiller` service account created above! In short, we save `tiller` service account secret in Jenkins for authentication.

The secret is Every k8s ServiceAccount has a secret.

```
$ k get serviceaccount tiller -o yaml
apiVersion: v1
kind: ServiceAccount
...(truncated)
secrets:
- name: tiller-token-lkeck

$ k get secret tiller-token-lkeck
apiVersion: v1
data:
  ca.crt: xxxx=
  namespace: Blah=
  token: BlahBlahBlah=
kind: Secret
```

The `ca.crt`, `namespace`, `token` are encoded in base64. You can get token by running `base64` command:

```
$ TOKEN=`echo 'BlahBlahBlah=' | base64 --decode`
```

```
$ curl -k -XPOST  -H "Content-Type: application/json" -H "Accept: application/json, */*" -H "User-Agent: kubectl/v1.11.3 (darwin/amd64) kubernetes/a452946" 'https://000000000000000000000000000.sk1.eu-west-1.eks.amazonaws.com' -d '{"kind":"SelfSubjectAccessReview","apiVersion":"authorization.k8s.io/v1","metadata":{"creationTimestamp":null},"spec":{"resourceAttributes":{"namespace":"a-kinda-namespace","verb":"get","resource":"pods"}},"status":{"allowed":false}}' -H"Authorization: Bearer $TOKEN
```

Above curl command is somewhat equivalent to `k auth can-i get pod`. And the answer is yes, because the same token just let me pass the authentication.

```
apiVersion: v1
clusters:
- cluster:
    server: https://000000000000000000000000000.sk1.eu-west-1.eks.amazonaws.com
    certificate-authority-data: [REDACTED]
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    namespace: a-kinda-namespace
    user: tiller
  name: tiller
current-context: a-kinda-namespace
kind: Config
preferences: {}
users:
- name: tiller
  user:
    token: ${REPLACE ABOVE TOKEN HERE}
```

Note that the `certificate-authority-data` should be base64-encoded, as the original content of `ca.crt` being in `k get secret`. However, the `token` should be base64-decoded. Guess the reason is the token is a JWT encoded message which has filtered illegal characters.

Both `kubectl` and `helm` can use the second kubeconfig for operations which has less scope and, of course, more secure!
