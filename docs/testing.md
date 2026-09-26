# Testing and verification

There's no test suite. Changes are verified by rendering them. The checklist
for anything user-visible:

1. **It serves.** The page returns 200 in preview (a Ruby error in a `.weave`
   file gives a 500; the stack trace is in the app log).
2. **No console errors** on load and after interacting.
3. **It looks right**: screenshots at desktop (1280), phone (375–390) and,
   for wide layouts, a middle width (1024–1080, the owner uses a portrait 4K
   screen, about 1080 CSS px). Actually look at them.
4. **It builds**: `heighliner login -- bundle exec weaver build -r https://davidsiaw.net`,
   then check the page and its assets exist under `build/`, with correct
   relative paths.

## Tools (in the agent sandbox)

- `screenshot_url` for a page's initial state; `page_console` +
  `page_screenshot` for the state after interaction. Save into `shots/`
  (gitignored) so the owner can look too.
- `page_console` runs JS in a live page. Useful patterns:
  - **Several widths at once**: load the page into hidden `<iframe>`s of
    different widths and measure (`scrollWidth > clientWidth` finds clipping).
  - **Read computed styles** to check which rule actually wins
    (`getComputedStyle`, or filter `document.styleSheets` for rules matching an
    element).

### Things scripts can't do, and what to do instead

- **Real `:hover`**: dispatched mouse events don't trigger it. Either include
  `:focus-visible` in the rule and call `.focus()` (the halo rules do this), or
  copy the rule text with `:hover` replaced by a test class, inject it, and add
  the class to an element. Then say plainly that real-mouse hover wasn't
  exercised.
- **Focus from `.click()`**: a scripted click doesn't focus the button, so
  "focus returns to the cell after closing the dialog" can't be checked this way.
- **Esc on a `<dialog>`**: not sendable; `dialog.requestClose()` goes through
  the same close path.

### Check that guards actually fire

For build-time safety checks (like `corrections.json`'s `replaces`), break the
input on purpose, confirm the build fails with a useful message, then restore
the file.

## Shell traps

- **`pkill -f` / `pgrep -f` can kill your own shell**: the pattern also matches
  the bash command line that contains it, so the command dies with exit 143 and
  no output. Kill by PID, or use a pattern that can't match itself.
- **`grep -c` counts lines, not matches.** Built HTML is often a single line;
  use `grep -o PATTERN file | wc -l`.
- **`heighliner login`** needs `--` before the command, and can't run
  `sh -c '…'` ([development.md](development.md)).
- The `heighliner up -av` log contains terminal control codes; grep it with
  `grep -a`.
- `LANG=C.UTF-8` when running Ruby by hand, or UTF-8 files fail to parse.
