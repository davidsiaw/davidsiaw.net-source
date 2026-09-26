# Styling

## Structure

- Every page uses weaver's dark theme (`theme: "dark"`), then **one stylesheet
  of its own** in `css/`, loaded with `request_css`:
  - `css/front.css`: `/` and `/playground` (shared card layout)
  - `css/bitrep.css`: `/playground/bitrep`
  - `css/elements.css`: `/playground/elements`
- Class names are prefixed per page (`front-`, `bitrep-`, `elements-`/`element-`)
  so the stylesheets can't collide.
- Each stylesheet declares its palette as custom properties on the page's root
  class, and comments explain any theme rule it overrides.

## Palette

Taken from weaver's dark theme so custom parts sit well with it:

| Role | Value |
|---|---|
| page background | `rgb(6 8 24)` |
| card background | `#1b1e35` (hover `#23274a`) |
| input / inset background | `#0d1026` |
| border | `#3b3f5c` |
| text | `rgb(214 218 236)` |
| muted text | `rgb(136 142 168)` |
| accent | `#7b7fd4` |

Periodic table categories each have a colour variable (`--cat-alkali-metal` and
so on) in `css/elements.css`. Elements set `--cat` from their `cat-*` class, and
everything downstream (text, borders, tints via `color-mix`) uses `var(--cat)`.

Type: headings are light weight (200–300) with slight letter-spacing; numbers
and bit/hex values use a monospace stack
(`ui-monospace, SFMono-Regular, Menlo, Consolas, monospace`).

## What the owner likes (and doesn't)

Learned from feedback. Follow these unless told otherwise:

- **Hover should be subtle.** Highlight the related thing (a halo, a colour
  brightening); don't change the rest of the page. Dimming the rest of the
  table on hover was tried at two strengths and rejected both times ("as a human
  it feels weird").
- **Dimming the page is for modals only**, like the element detail popover,
  which opens on click.
- A clean, quiet look: dark cards, thin borders, colour used for meaning
  (categories, bit fields), not decoration.
- Interactive details are welcome where they explain something, e.g. the
  lanthanide marker haloing the row it stands for, or the legend lighting up for
  the hovered element's category.

## Techniques in use

- **`:has()` for cross-element hover effects, no JS.** Example:
  `.elements-grid:has(.marker-lanthanide:hover) .series-lanthanide { … }`. For
  a small fixed set (the 10 categories) write one selector per value; that
  duplication is intentional and sits next to the matching colour rules.
- **Scope selectors to beat the theme.** The theme has heavy rules like
  `.middle-box h1`. Use `.page .page-title` (two classes) rather than
  `!important`.
- **Interactive cells are `<button>`s** (keyboard access for free). Reset them
  with `font: inherit` *before* `line-height`, because the `font` shorthand
  resets line-height. Getting this backwards made every periodic table cell
  taller.
- **Modals are native `<dialog>` + `showModal()`**: backdrop, Esc, focus trap
  and focus return come built in. Close on backdrop click by checking
  `e.target === dialog` (keep the dialog's own padding at 0 so only real
  backdrop clicks hit it). Lock page scroll with `body:has(dialog[open])`.
  `::backdrop` doesn't reliably inherit custom properties, so give it literal
  colours.
- **Wide content scrolls sideways inside its own wrapper**
  (`.elements-scroll { overflow-x: auto }`) rather than squashing or overflowing
  the page.
- Keep effects short: transitions are 0.12–0.2s.
