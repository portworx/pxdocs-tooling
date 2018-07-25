### versions

To build the version drop-down that will redirect to another version of the site - you need the following variables:

 * `VERSIONS_ALL` - a comma delimited list of all versions (e.g. `1.2,1.3,1.4`)
 * `VERSIONS_BASE_URL` - the base url that the version will be prepended to (e.g. `pxdocs.wk1.co`)
 * `VERSIONS_CURRENT` - the current version we are building

We manage content for each version in it's own branch (named after the version). The `content` directory is sourced from a branch named after the version that is being built and is merged with the rest of the files from `master`.

If you are making content updates - you must make the changes in the branch named after the version you are updating.

If you are making updates to the core build itself - make those changes in `master`.