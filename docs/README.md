# davidsiaw.net-source

Source for https://davidsiaw.net: a small static site built with
[weaver](https://github.com/davidsiaw/weaver) (a Ruby DSL that generates HTML).
It has a front page linking to David's other sites, and a playground of small
interactive experiments.

These docs are for whoever works on it next, human or agent. Read this page,
then whichever of the others matches your task.

## Layout

```
source/                 .weave pages (Ruby); the path is the URL
  index.weave             /             front page
  playground.weave        /playground   playground index
  playground/*.weave      /playground/* one file per experiment
css/  js/               per-page stylesheets and scripts (copied into the build as-is)
data/elements/          vendored periodic table data + hand corrections
script/pull-elements    refreshes data/elements/ from its sources
Dockerfile              dev image (runs `weaver preview`)
heighliner.config       local dev environment (see development.md)
.github/workflows/      build on every push, deploy from master
build/                  output of `weaver build` (gitignored)
shots/                  screenshots taken while working (gitignored)
```

`test.bash` is a leftover from the old CircleCI setup and is not used.

## Ground rules

- **No runtime fetching from third parties.** Data is pulled into the repo by a
  script, committed, and turned into HTML at build time. Pages must not fetch
  from external APIs or CDNs while being viewed. See [element-data.md](element-data.md).
- **Credit what you use.** The periodic table data is CC BY-SA and needs its
  attribution line; keep it accurate when you change what data is shown.
- **Dark theme everywhere** (`theme: "dark"` on every page), with the
  conventions in [styling.md](styling.md).
- **Hover effects are subtle.** Dimming the page is reserved for modals. The
  owner has pushed back on anything heavier; see [styling.md](styling.md).
- **Verify visually.** Take screenshots at desktop and phone widths before
  calling a UI change done; see [testing.md](testing.md).
- **Build output must work as static files.** Everything has to survive
  `weaver build` (served from GitHub Pages), not just `weaver preview`.

## Docs

| File | Read it when |
|---|---|
| [development.md](development.md) | running the site locally, the dev container, versions |
| [deployment.md](deployment.md) | anything about CI, the deploy key, or the live site |
| [weaver.md](weaver.md) | writing or editing a `.weave` page (many gotchas and bugs) |
| [styling.md](styling.md) | changing how anything looks |
| [pages.md](pages.md) | working on a specific page, or adding a new one |
| [element-data.md](element-data.md) | the periodic table's data, sources, and corrections |
| [testing.md](testing.md) | checking your work, and traps in the sandbox tools |
