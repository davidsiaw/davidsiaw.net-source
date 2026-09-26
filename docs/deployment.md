# Deployment

The live site is **GitHub Pages** serving the `master` branch of a *separate*
repo, [davidsiaw/davidsiaw.net](https://github.com/davidsiaw/davidsiaw.net),
under the custom domain `davidsiaw.net` (via a `CNAME` file). This repo holds
the source; CI builds it and pushes the result there.

## The workflow

`.github/workflows/deploy.yml`:

- Runs on **every push** (all branches) and on manual dispatch.
- Builds with `bundle exec weaver build -r https://davidsiaw.net`, then writes
  `build/CNAME`. The `-r` root is what absolute links resolve against.
- The deploy step runs **only on `master`**:
  1. clones davidsiaw/davidsiaw.net over SSH,
  2. deletes everything in it except `.git`, copies `build/` in (a mirror, so
     pages you remove disappear from the live site too),
  3. commits only if something changed ("update from davidsiaw.net-source@<sha>"),
     and pushes.
- Uses plain `git`/`ssh`, no third-party deploy action.

## The deploy key

Pushing to another repo needs credentials `GITHUB_TOKEN` doesn't have. The
setup is an SSH **deploy key**:

- public half: davidsiaw/davidsiaw.net → Settings → Deploy keys, with
  **write access**;
- private half: this repo's Actions secret **`DEPLOY_KEY`**.

Errors in the deploy step:
- `Permission denied (publickey)`: the secret or the key is missing or wrong.
- `...marked as read only`: the deploy key lacks write access.

Only the owner can change keys and secrets; if they're the problem, say so
rather than working around it.

## History

This used to deploy via CircleCI (`.circleci/`, `deploy.bash`), which stopped
working and was removed. Two things from that era:

- The old script copied `404/index.html` to `404.html`, but the site has never
  had a 404 page, so that step always failed silently. If you add a 404 page,
  GitHub Pages wants it at `build/404.html`.
- Nothing was deployed between June 2022 and the move to Actions.
