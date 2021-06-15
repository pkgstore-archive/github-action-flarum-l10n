#!/bin/bash

REPO="${1}"
USER="${2}"
EMAIL="${3}"
TOKEN="${4}"

map="_exts.txt"
header="Authorization: token ${TOKEN}"

git=$( command -v git )
date=$( command -v date )
curl=$( command -v curl )
jq=$( command -v jq )

${git} config --global user.email "${EMAIL}"
${git} config --global user.name "${USER}"

REPO_AUTH="https://${USER}:${TOKEN}@${REPO#https://}"

${git} clone "${REPO_AUTH}" '/root/git/source' && cd '/root/git/source' || exit 1
${git} remote add 'l10n' "${REPO_AUTH}"

mapfile -t exts < "${map}"

_timestamp() {
  ${date} -u '+%Y-%m-%d %T'
}

_getAPI() {
  ${curl} -sf -X GET -H "${header}" "${1}"
}

_getFile() {
  ${curl} -sf -X GET -H "${header}" "${1}" -o "${2}"
}

getL10N() {
  for ext in "${exts[@]}"; do
    echo "--- Open: '${ext}'"

    url_api=$( _getAPI "https://api.github.com/repos/${ext}/contents/resources/locale/en.yml" )
    url_api_res="${?}"

    if [[ ${url_api_res} != "0" ]]; then
      url_api=$( _getAPI "https://api.github.com/repos/${ext}/contents/locale/en.yml" )
    fi

    url_dwn=$( echo "${url_api}" | ${jq} -r '.download_url' )
    name=$( _getAPI "${url_dwn}" | sed -n 1p | sed "s/://g" )
    _getFile "${url_dwn}" "${name}.yml"
  done
}

getL10N

ts=$( _timestamp )

${git} add .                            \
  && ${git} commit -a -m "L10N: ${ts}"  \
  && ${git} push 'l10n'

exit 0
