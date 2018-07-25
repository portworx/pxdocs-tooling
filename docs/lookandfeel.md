## look and feel

The HTML is generated from the files in `layouts` - you have total control over what HTML is displayed by editing these files.

### static files

Any files & folders you put into the `static` folder are merged into the final build and can be referenced from any of the templates.

### material design
The CSS can also be updated in any way you want - the current site uses [material design lite](https://github.com/google/material-design-lite) as a CSS framework but you can replace that and use any CSS framework / custom CSS you want.

There is documentation for generating the material design CSS with custom colors [here](docs/material-design.md)

### custom CSS

The main pages for changing the HTML for the site are as follow:

 * `layouts/_default/baseof.html` - the core HTML template that includes the CSS and Javascripts for the page and generates the layout
 * `layouts/_default/single.html` - the template used for displaying a single page of content
 * `layouts/_default/list.html` - the template used for displaying a section homepage
 * `layouts/_default/li.html` - the template used for displaying a section homepage list item

### partials

The partials are template fragments that can be used from other templates:

 * `layouts/partials/contentheaderhtml` - the section at the top of the page that displays the title, edited by info and github link
 * `layouts/partials/menu.html` - the template that generates the menu tree on the left
 * `layouts/partials/prevnext.html` - the template that generates the previous & next links at the bottom of a content page

### shortcodes

Shortcodes can be used from within content pages:

 * `layouts/shortcodes/content.html` - the shortcode used to include some content from another page - used for sharing content between pages
 * `layouts/shortcodes/info.htmk` - used to display an inset block with some information that should be highlighted
 * `layouts/shortcodes/widelink.htmk` - render a wide orange link that can be used inside some content

