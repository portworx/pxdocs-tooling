## material-design

We are using [material-design-light](https://getmdl.io/) as the CSS framework for this site.

## customize

To build out the custom color scheme for mdl, first you will need [node.js](https://nodejs.org/en/download/) installed.

Then we clone the material design lite repo and install required modules:

```
git clone https://github.com/google/material-design-lite.git
cd material-design-lite
npm install
```

Then open `src/_variables.css` and change the following variables:

#### colors
The Portworx orange as the primary color and blue as the accent color

**Before:**

```sass
$color-primary: $palette-indigo-500 !default;
$color-primary-dark: $palette-indigo-700 !default;
$color-accent: $palette-pink-A200 !default;
```

**After:**

```sass
$color-primary: "241,90,36" !default;
$color-primary-dark: "216,65,11" !default;
$color-accent: $palette-blue-A200 !default;
```

#### drawer width
Make the drawer wide:

**Before:**

```sass
$layout-drawer-narrow: 240px !default;
$layout-drawer-wide: 456px !default;
$layout-drawer-width: $layout-drawer-narrow !default;
```

**After:**

```sass
$layout-drawer-narrow: 240px !default;
$layout-drawer-wide: 456px !default;
$layout-drawer-width: 280px !default;
```

#### build

Then we rebuild the CSS (ignore the error about babel not registering):

```bash
./node_modules/.bin/gulp
```

Finally - we copy the resulting CSS build into our project:

```bash
cp dist/material.min.css ../px-docs-spike/static/css/material.min.css
```
