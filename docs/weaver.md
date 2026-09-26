# Weaver: how pages are written, and its traps

Weaver is written by the site's owner, David Siaw
([davidsiaw/weaver](https://github.com/davidsiaw/weaver)). Bugs in it can be
fixed upstream, so report them rather than patching the installed gem. The
workarounds below exist until that happens.

To read weaver's own source: `gem unpack weaver -v 0.9.8`. The interesting files
are `lib/weaver/elements.rb`, `lib/weaver/page_types/*.rb` and `exe/weaver`.

## Anatomy of a page

A `.weave` file is Ruby, evaluated with the **project root as the working
directory**. You can `require`, read files and define locals before the page
call, and the page's blocks close over them (see `source/playground/elements.weave`).

```ruby
nonnav_page "", "page title", theme: "dark" do
	request_css 'css/mypage.css'     # path from the site root, no leading slash
	request_js 'js/mypage.js'
	on_page_load "init();"          # runs inside $(document).ready

	row do
		col 12 do
			div class: "mypage" do
				h1 "hello", class: "mypage-title"
			end
		end
	end
end
```

- The first argument is the page's sub-path within the file, and is almost
  always `""`.
- `theme: "dark"` swaps `css/style.css` for `css/style-dark.css`. Every page
  here uses it.
- `request_css` / `request_js` paths get the right number of `../` for the
  page's depth, in preview and in build. Write them from the site root.

## Page types used here

| Type | Used by | Shape |
|---|---|---|
| `center_page` | `/`, `/playground` | content in `.middle-box`: centred, max-width 400px, `text-align: center` |
| `nonnav_page` | the playground experiments | Bootstrap `.container` of `row do col N do … end end` |
| `topnav_page` | (no longer used) | like nonnav with a top nav bar, which renders as an empty band if you give it no items |

`nonnav_page` content must be inside `row`/`col`. A bare element at the page
level fails the build: `undefined method 'div' for an instance of
Weaver::NonNavPage`.

## The element DSL

Any method weaver doesn't know becomes an HTML tag (`method_missing`):

```ruby
div "text", class: "a"          # <div class="a">text</div>
div class: "a" do … end         # children from the block
a "label", href: "/x"
span el[:name], class: "n"
button "×", type: "button", "aria-label": "close"
```

Gotchas:

- **A tag with no text and no block is self-closed**: `div class: "x"` becomes
  `<div class="x" />`. In HTML that is an *unclosed* `<div>` that swallows
  everything after it. For an empty element write `div "", class: "x"`.
  Genuinely void elements (`input`, `hr`, `br`) are fine as-is.
- **Nothing is escaped.** Text and attribute values go into the HTML verbatim.
  Don't put untrusted text through it, and don't use `"` in attribute values.
- **Typos render silently.** An unknown name just becomes that tag: the old
  front page used `full do … end`, which rendered a literal `<full>` element and
  broke the layout. Row helpers that do exist: `col N`, `half`, `third`.
- `text "…"` inserts a raw HTML string.
- `icon :name` gives Font Awesome **4.7** `<i class="fa fa-name">`, with `_` in
  the symbol becoming `-` (`icon :file_text_o`).
- Keyword args pass straight through as attributes, so you can splat optional
  ones: `**(year ? { "data-year": year } : {})`.
- Embedding JSON: `script type: "application/json", id: "x" do text json end`.
  Escape `</` in the JSON (`json.gsub("</", "<\\/")`) or a string containing
  `</script>` ends the element early.

### Built-in widgets to avoid

- **`wform` / `textfield`**: auto-generates ids (`form0`, `textfield0`) and
  injects validator JS that calls your `onchange` handler in odd places. The
  bitrep page replaced it with a plain `form`/`input`.
- **`table`** (0.9.8): always appends `<ul class="pagination" />` after the table
  (a bug, see below). For layout use `div`s and CSS grid or flex.
- **`ibox`**: emits `style="min-height: px"`, an empty value (bug).
- **`jumbotron`**: heavy grey slab. The pages here use their own headings.

## Known bugs in weaver 0.9.8

| Bug | Where | Effect | Workaround |
|---|---|---|---|
| viewport meta uses `contents=` not `content=` | `page_types/page.rb:31` | browsers ignore it; phones render at desktop width and zoom out | none yet; fix upstream |
| `table` appends `<ul class="pagination" />` | `element_types/dynamic_table.rb:288` | unclosed `<ul>` wraps following content | don't use `table` |
| `ibox` emits `min-height: px` | `elements.rb` | harmless invalid CSS | don't rely on ibox sizing |
| links a `favicon.ico` that doesn't exist | `page.rb` | 404 in the console | add a favicon, or ignore |
| dark theme: `.middle-box h1 { font-size: 170px }` | `style-dark.css` | any `h1` on a `center_page` is enormous | scope your selector under your own class (`.front .front-title`) to win on specificity |
| dark theme: `body:not(.mini-navbar) { background-color: #000 }` below 768px | `style-dark.css` | page turns pure black on phones (meant for sidebar layouts); `weaver.js` adds `body-small` at that width | `html body.gray-bg { background-color: rgb(6 8 24); }` in the page CSS |
| dark theme uses `var(--tw-bg-opacity)`, which is never defined | navbar rules in `style-dark.css` | those backgrounds are invalid | avoid the nav page types, or override |

## Bootstrap 3 underneath

Weaver pages use Bootstrap 3. `.container` has **fixed** widths: 750px from 768px
wide, 970px from 992px, 1170px from 1200px. A wide component (like the 18-column
periodic table) gets clipped inside a 970px container on a 1080px-wide screen,
with empty margins either side. `css/elements.css` fixes that for its page with
`.container:has(.elements) { width: auto; max-width: 1170px; }`.
