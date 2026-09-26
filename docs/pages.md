# Pages

## `/`: `source/index.weave`

`center_page` + `css/front.css`. A light title ("central dogma"), a subtitle, and
a 2×2 grid of link cards. The cards come from the `links` array at the top of
the file: add or change a link there (`href`, Font Awesome 4.7 `icon`, `title`,
`sub`).

## `/playground`: `source/playground.weave`

Same layout and stylesheet as the front page, with a "← davidsiaw.net" back link
(`.front-back`) and one card per experiment. The grid has two columns, so an odd
number of cards leaves a gap; that's why "home" became a back link rather than
a card.

## `/playground/bitrep`: bit representation

Files: `source/playground/bitrep.weave`, `js/bitrep.js`, `css/bitrep.css`.

Type an integer (shown as two's complement) or a decimal (shown as a float) and
see its bits at 8, 16, 24, 32 and 64 bits.

- **The JS finds everything by id; keep these when changing markup:**
  `form0` containing an input named `num`; `label{size}_{bit}` (index labels);
  `b{size}_{bit}` (value cells, whose `innerHTML` is read back as `"0"`/`"1"`);
  `info{size}` (readouts, filled by `updateInfo()`).
- `mantissa_bits` in the weave file mirrors `expobit` in `bitrep.js` (where each
  width's exponent starts). Change both together.
- Integer or float is decided by the presence of a `.`: `65504` takes the
  integer path, and `65504.0` is the largest half-precision float. The example
  chips rely on this.
- `bitrep.js` still logs a debug line per width on every conversion.

## `/playground/elements`: periodic table

Files: `source/playground/elements.weave`, `js/elements.js`,
`css/elements.css`, data in `data/elements/` (see [element-data.md](element-data.md)).

Build time (the weave file) does all the data work: loading, correcting, merging
and formatting. `js/elements.js` only displays it.

| Feature | How |
|---|---|
| layout | CSS grid, 18 columns; each cell's `grid-column`/`grid-row` comes from Bowserinator `xpos`/`ypos`. Rows 1–7 are the main table, 9–10 the f-block; row 8 is empty and sized as a 14px gap. |
| colours | PubChem `GroupBlock` becomes a `cat-*` class, which sets `--cat` |
| 57–71 / 89–103 markers | cells in group 3; hover or focus haloes the matching f-block row (`series-lanthanide` / `series-actinide`) and vice versa. CSS only. |
| legend highlight | hovering a cell brightens its category in the legend. CSS `:has()`, one selector per category. |
| detail popover | cells are `<button data-number>`; click opens `<dialog id="element-dialog">`, filled from the JSON in `<script id="elements-data">`. The rows are built by the `details` lambda in the weave file (units, °C, empty values dropped). |
| discovery timeline | range slider; cells carry `data-year` (none for "Ancient", which are always shown); later ones get `.undiscovered` + `disabled`. Markers take the year of the first element in their row. |

Things to keep true:
- The grid needs at least 951px (18 × 50px + gaps). Below that it scrolls
  sideways inside `.elements-scroll`. The page widens Bootstrap's container
  (see [weaver.md](weaver.md)) so it fits from 1024px up.
- Hidden (`.undiscovered`) cells must stay non-interactive: `disabled` on
  cells, `tabIndex = -1` on markers, `pointer-events: none` in CSS.
- The footer attribution names what comes from each source and lists the
  corrected elements (generated from `corrections.json`). Update the wording if
  you start showing data from somewhere new.
- A PubChem category the page doesn't know fails the build on purpose. Add a
  colour variable, a `.cat-*` rule, the legend-highlight selectors, and the
  category to the `categories` list.

## Adding a playground experiment

1. `source/playground/<name>.weave`: `nonnav_page "", "<title>", theme: "dark"`,
   content inside `row do col 12 do … end end`, and a "← playground" back link to
   `/playground` at the top.
2. Its own `css/<name>.css` / `js/<name>.js` with a `<name>-` class prefix,
   loaded with `request_css` / `request_js`.
3. A card for it in `source/playground.weave`.
4. Data? Vendor it into `data/` with a pull script and credit it, as described
   in [element-data.md](element-data.md). No fetching at view time.
5. Check it in preview and in `weaver build`, at desktop and phone widths
   ([testing.md](testing.md)).
