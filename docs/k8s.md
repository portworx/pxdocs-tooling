## k8s

Notes on working with the k8s cluster.

## connect

```bash
gcloud auth login
gcloud config set compute/region us-west1
gcloud config set compute/zone us-west1-b
gcloud config set project production-apps-210001
gcloud container clusters get-credentials production-app-cluster
kubectl get no
```

## create service account with token for ops

First we create a service account that has access to these roles:

 * `roles/container.developer`
 * `roles/storage.admin`


```bash
export SERVICE_ACCOUNT_NAME=k8s-ops
export PROJECT_NAME=production-apps-210001
export SERVICE_ACCOUNT_EMAIL=$SERVICE_ACCOUNT_NAME@$PROJECT_NAME.iam.gserviceaccount.com
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME --display-name "k8s ops service account"
gcloud iam service-accounts keys create $SERVICE_ACCOUNT_NAME.json \
  --iam-account $SERVICE_ACCOUNT_EMAIL
gcloud projects add-iam-policy-binding $PROJECT_NAME \
    --member serviceAccount:$SERVICE_ACCOUNT_EMAIL --role roles/container.developer
gcloud projects add-iam-policy-binding $PROJECT_NAME \
    --member serviceAccount:$SERVICE_ACCOUNT_EMAIL --role roles/storage.admin
```

You now have a `k8s-ops.json` file - keep it secure.

You will need to add a base64 encoded version of this key to the `GCLOUD_SERVICE_ACCOUNT_TOKEN` secret variable in travis.

## create admin role for your user

```bash
kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole cluster-admin \
  --user <YOUR_GCLOUD_EMAIL_ADDRESS>
```

## install ingress-nginx

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/cloud-generic.yaml
```

This will create an IP under the `ingress-nginx` service in the `ingress-nginx` namespace:

```bash
kubectl get svc -n ingress-nginx ingress-nginx
```

Wait for the IP to show and up configure DNS to point at it.

## install helm

download the latest [helm binary](https://github.com/helm/helm/releases)

Setup a cluster role binding so helm has the `cluster-admin` role:

```bash
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
EOF
```

Initialize helm:

```bash
helm init --service-account tiller
```

Update helm repos:

```bash
helm repo update
```

## install cert-manager

Deploy cert manager using helm:

```bash
helm install \
  --name cert-manager \
  --namespace kube-system \
  --set ingressShim.defaultIssuerName=letsencrypt-prod \
  --set ingressShim.defaultIssuerKind=ClusterIssuer \
  stable/cert-manager
```

Create the cluster issuer:

```bash
cat << EOF | kubectl apply -f -
apiVersion: certmanager.k8s.io/v1alpha1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: harsh@portworx.com
    privateKeySecretRef:
      name: letsencrypt-prod
    http01: {}
EOF
```

