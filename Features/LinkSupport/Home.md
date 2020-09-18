Link support
============

External links
--------------

External links to `*.md` files should **not** have their extension changed to
target extension (e.g.: `*.html`).

 -  [pandoc-md-wiki/README.md](https://github.com/jraygauthier/pandoc-md-wiki/blob/master/README.md)
 -  [pandoc-md-wiki/TODO.md]

[pandoc-md-wiki/TODO.md]: https://github.com/jraygauthier/pandoc-md-wiki/blob/master/TODO.md


Internal links {#internal-links}
--------------

### Relative

Internal relative links to `*.md` files **should** have their extension changed
to target extension (e.g.: `*.html`):

 -  [./SubDirectory/PageInSubDirectory.md](./SubDirectory/PageInSubDirectory.md)
 -  [SubDirectory/PageInSubDirectory.md](SubDirectory/PageInSubDirectory.md)
 -  [../../README.md](../../README.md)

Internal relative links without extension **should** have their extension
changed to target extension (e.g.: `*.html`):

 -  [./SubDirectory/PageInSubDirectory](./SubDirectory/PageInSubDirectory)
 -  [SubDirectory/PageInSubDirectory](SubDirectory/PageInSubDirectory)
 -  [../../README](../../README)


However, links to other files types should **not** have their extension changed:

 -  [../PlantUMLSupport/Diagrams/SequenceExample.puml](../PlantUMLSupport/Diagrams/SequenceExample.puml)
 -  [../ImageSupport/Images/ImageExample.svg](../ImageSupport/Images/ImageExample.svg)


This also applies to image links:

![../ImageSupport/Images/ImageExample.svg](../ImageSupport/Images/ImageExample.svg)


To directory:

-  [./SubDirectory/](./SubDirectory/)


### Absolute

Internal absolute links should be converted to relative links so that they are functional
even without a web server.

Links to `*.md` **should** also have their extension changed to target extension
(e.g.: `*.html`):

 -  [/README.md](/README.md)
 -  [/README](/README)

However, links to other files types should **not** have their extension changed
but should still have been converted to relative links:

 -  [/Features/PlantUMLSupport/Diagrams/SequenceExample.puml](/Features/PlantUMLSupport/Diagrams/SequenceExample.puml)
 -  [/Features/ImageSupport/Images/ImageExample.svg](/Features/ImageSupport/Images/ImageExample.svg)

This also applies to image links:

TODO: Fix me, the image link fails the build when uncommented:

<!--
![/Features/ImageSupport/Images/ImageExample.svg](/Features/ImageSupport/Images/ImageExample.svg)
-->

Note that this is not a lua filter issue.

To directory:

-  [/Features/LinkSupport/SubDirectory/](/Features/LinkSupport/SubDirectory/)


### Referring to particular section via anchors

To local current page anchor:

 -  [\#internal-links](#internal-links)

To explicitly named anchors:

 -  [./SubDirectory/PageInSubDirectory.md\#my-second-section](./SubDirectory/PageInSubDirectory.md#my-second-section)

 -  [SubDirectory/PageInSubDirectory.md\#my-second-section](SubDirectory/PageInSubDirectory.md#my-second-section)

Without extension:

 -  [./SubDirectory/PageInSubDirectory\#my-second-section](./SubDirectory/PageInSubDirectory#my-second-section)

To automatically generated anchors:

 -  [./SubDirectory/PageInSubDirectory.md\#my-third-section](./SubDirectory/PageInSubDirectory.md#my-third-section)

Absolute local links:

 -  [/SubDirectory/PageInSubDirectory\#my-second-section](/Features/LinkSupport/SubDirectory/PageInSubDirectory#my-second-section)

