FROM alpine

LABEL "name"="GitHub Flarum L10N"
LABEL "description"=""
LABEL "maintainer"="Kitsune Solar <kitsune.solar@gmail.com>"
LABEL "repository"="https://github.com/pkgstore/github-action-flarum-l10n.git"
LABEL "homepage"="https://pkgstore.github.io/"

LABEL "com.github.actions.name"="GitHub Flarum L10N"
LABEL "com.github.actions.description"=""
LABEL "com.github.actions.icon"=""
LABEL "com.github.actions.color"=""

COPY *.sh /
RUN apk add --no-cache bash git git-lfs

ENTRYPOINT ["/entrypoint.sh"]
