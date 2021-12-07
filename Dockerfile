FROM alpine

LABEL "name"="Flarum L10N"
LABEL "description"=""
LABEL "maintainer"="Kitsune Solar <kitsune.solar@gmail.com>"
LABEL "repository"="https://github.com/pkgstore/github-action-flarum-l10n.git"
LABEL "homepage"="https://pkgstore.github.io/"

COPY *.sh /
RUN apk add --no-cache bash curl git git-lfs jq sed

ENTRYPOINT ["/entrypoint.sh"]
