# Development

## Versions

- Ruby **4.0** (Dockerfile `FROM ruby:4.0`, CI `ruby-version: '4.0'`). Keep the
  two in step.
- weaver **0.9.8**, Sinatra 4, Rack 3.
- `webrick` is in the Gemfile on purpose: `weaver preview` needs a Rack server
  and Rack 3 no longer bundles one. Without it preview dies with
  "Couldn't find handler for: puma, falcon, thin, webrick".
- Do not go back to weaver 0.6.x / Ruby < 3.2: 0.6.5 calls `File.exists?`,
  which Ruby 3.2 removed.

## Running it: heighliner

The dev environment is [Heighliner](https://github.com/davidsiaw/heighliner),
configured by `heighliner.config`. There is no database.

```sh
heighliner up -av      # build the image and attach; runs in the foreground
heighliner logs        # app output
```

`up -av` stays attached, so run it in the background and tail its output:

```sh
(nohup heighliner up -av > /tmp/hl-up.log 2>&1 &)
tail -f /tmp/hl-up.log   # it's done when WEBrick logs "Server#start"
```

The site is then at `https://<env>.<suffix>/` (plain `http://` redirects to
HTTPS). Get the suffix from `heighliner show http-suffix`; the environment is
currently `davidsiawnet`, and the container is reachable directly at
`http://davidsiawnet-app:4567/`.

### What reloads without a rebuild

`weaver preview` renders each page on every request, and `heighliner.config`
bind-mounts `source/`, `css/`, `js/` and `data/` when attached. So edits to
pages, styles, scripts and data show up on refresh.

You need `heighliner up` again for: `Gemfile`/`Gemfile.lock`, the
`Dockerfile`, `heighliner.config`, or a **new top-level directory** (it is
neither in the image nor mounted until you add a mount and rebuild).

### Running commands in the container

```sh
heighliner login -- bundle exec weaver build -r https://davidsiaw.net
```

**Put `--` before the command.** Without it heighliner parses the command's
flags as its own (`unknown argument '-r'`). `sh -c '...'` does not work
either (`unknown argument '-c'`); run single commands.

## Encoding: always UTF-8

Page sources contain non-ASCII text (for example "résumé" on the front page), and
the data files are UTF-8 JSON. Under a non-UTF-8 locale Ruby fails with
`invalid multibyte char (US-ASCII)` (the page returns 500) or
`"\xCE" on US-ASCII`.

- The Dockerfile and CI set `LANG=C.UTF-8`. Keep it.
- When reading files in Ruby, pass `encoding: "UTF-8"` explicitly, as
  `elements.weave` does, so the build doesn't depend on the locale.
- Running Ruby by hand outside the container: prefix `LANG=C.UTF-8`.

## Preview vs build

- `weaver preview` (dev): Sinatra renders pages on request. Relative asset
  paths are computed from the request path.
- `weaver build -r https://davidsiaw.net` (CI): writes every page to
  `build/<path>/index.html`, plus weaver's bundled assets and your `css/`, `js/`.

Check both when you touch paths or add files; see [testing.md](testing.md).
