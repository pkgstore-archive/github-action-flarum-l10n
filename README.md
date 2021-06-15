# GitHub Action: Flarum L10N

## Workflow Syntax

```yml
name: "Flarum L10N"

on:
  schedule:
    - cron:  "0 22 * * *"

jobs:
  mirror:
    runs-on: ubuntu-latest
    name: "L10N"
    steps:
      - uses: "pkgstore/github-action-flarum-l10n@main"
        with:
          repo: "https://github.com/${{ github.repository }}.git"
          user: "${{ secrets.L10N_USER_NAME }}"
          email: "${{ secrets.L10N_USER_EMAIL }}"
          token: "${{ secrets.L10N_USER_TOKEN }}"
```
