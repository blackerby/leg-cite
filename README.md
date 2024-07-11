# leg-cite Extension For Quarto

This filter implements citation macros for United States House and Senate bills, resolutions, and amendments, as well as Presidential Nominations. Given a short citation like `118hr8070` between curly brackets (a.k.a. braces &mdash; `{}`),  the rendered Quarto document will display a link to the bill, resolution, amendment, or nomination referenced by the citation on Congress.gov.

## Installing

```bash
# this installs from the main Git branch
quarto add blackerby/leg-cite

# the latest release is v0.0.3
quarto add blackerby/leg-cite@v0.1.0
```
Any of these will install the extension under the `_extensions` subdirectory.
If you're using version control, you will want to check in this directory.

## Using

Usage is simple: with `leg-cite` included in the filter list in the header of your `qmd` document, place a short citation, like `118hr8070`, between curly brackets (`{}`) in your text, i.e., {118hr8070}, and when rendered, your document will display a link to the legislation referenced by the citation on Congress.gov: [H.R.8070](https://www.congress.gov/bill/118th-congress/house-bill/8070). 

## Example

Here is the source code for a minimal example: [example.qmd](example.qmd).

