### versions

To build the version drop-down that will redirect to another version of the site - you need the following variables:

 * `VERSIONS_ALL` - a comma delimited list of all versions (e.g. `1.2,1.3,1.4`)
 * `VERSIONS_BASE_URL` - the base url that the version will be prepended to (e.g. `docs.portworx.wk1.co`)
 * `VERSIONS_CURRENT` - the current version we are building

We manage content for each version in it's own branch (named after the version). The `content` directory is sourced from a branch named after the version that is being built and is merged with the rest of the files from `master`.

If you are making content updates - you must make the changes in the branch named after the version you are updating.

If you are making updates to the core build itself - make those changes in `master`.

### add new version branch

To add a new version branch to the build we need to follow these steps:

 1. add a new ingress and service manifests to k8s
 2. update the VERSIONS_ALL variable in travis
 3. create a new algolia index
 4. create and push new branch in the pxdocs repo
 5. rebuild all other version branches

#### add new ingress and service manifests

Copy both the following files and rename them with your new version:

 * `deploy/manifests/service-1-5.yaml`
 * `deploy/manifests/ingress-1-5.yaml`

Then - using [the docs](k8s.md) - connect to the k8s cluster.

Then using `kubectl` - apply the new manifests:

```bash
kubectl apply -f deploy/manifests/service-1-5.yaml
kubectl apply -f deploy/manifests/ingress-1-5.yaml
```

If this version should be the default one - change the selector in `deploy/manifests/ingress-default.yaml` and reapply it also.

#### update travis variable

To enable a build and show the version in the drop-down - you will need to add the version to the `VERSIONS_ALL` variable in the [Travis secret variables page](https://travis-ci.org/portworx/pxdocs/settings)

#### create a new algolia index

You must create a new index with algolia with the name of the new version.

If the version is `1.5` - the index name must be `1-5` (replace the periods with dashes).

#### create new branch

This step is as simple as:

```bash
cd pxdocs
git checkout -b 1.5
git push origin 1.5
```

#### rebuild other version branches

For the new version to show up in the drop-down for other versions - you will need to rebuild those branches in travis.

Or you can add a commit to each branch and push it - a rebuild is needed to consume the update to the `VERSIONS_ALL` variable.

