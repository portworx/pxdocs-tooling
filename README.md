# pxdocs-theme

Theme for the Portworx docs site.  This is distributed as a git submodule into the [main docs site](https://github.com/portworx/pxdocs).

When you update this theme (and git pushed) - you will then need to update it for each branch of the docs:

```
cd pxdocs
make update.theme
```

It also contains the shared deployment files that are used in the build and deployment of the docs site.  This is so we have a common shared source for these files across multiple content branches.

## docs

The hugo theme has various components that are documented as follows:

 * [material design](docs/material-design.md)
 * [syntax highlighting](docs/syntax-highlighting.md)
 * [look and feel](docs/lookandfeel.md)
 * [versions](docs/versions.md)
 * [algolia](docs/algolia.md)
 * [k8s cluster](docs/k8s.md)

