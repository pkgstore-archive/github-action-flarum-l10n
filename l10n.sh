#!/bin/bash -e

init() {
  REPO="${1}"
  USER="${2}"
  EMAIL="${3}"
  TOKEN="${4}"

  curl_header="Authorization: token ${TOKEN}"
  file_exts="_exts.txt"
  path_repo="/root/git/l10n"
  api_url=""
  api_code="0"

  curl="$( command -v curl )"
  date="$( command -v date )"
  git="$( command -v git )"
  jq="$( command -v jq )"
  sed="$( command -v sed )"

  ${git} config --global user.email "${EMAIL}"
  ${git} config --global user.name "${USER}"
  ${git} config --global init.defaultBranch 'main'

  git_clone     \
    && get_l10n \
    && git_push
}

# -------------------------------------------------------------------------------------------------------------------- #
# GIT: CLONE REPOSITORY.
# -------------------------------------------------------------------------------------------------------------------- #

git_clone() {
  REPO_AUTH="https://${USER}:${TOKEN}@${REPO#https://}"

  ${git} clone "${REPO_AUTH}" "${path_repo}" \
    && _pushd "${path_repo}" || exit 1
  ${git} remote add 'l10n' "${REPO_AUTH}"

  mapfile -t exts < "${file_exts}"
  _popd || exit 1
}

# -------------------------------------------------------------------------------------------------------------------- #
# L10N: GET LANGUAGE FILES.
# -------------------------------------------------------------------------------------------------------------------- #

get_l10n() {
  mkdir -p "${path_repo}/locale" \
    && _pushd "${path_repo}/locale" || exit 1

  for ext in "${exts[@]}"; do
    echo "--- [CURL] GET: '${ext}'"

    api_url=$( _get_api "https://api.github.com/repos/${ext}/contents/resources/locale/en.yml" )
    api_code="${?}"

    if [[ "${api_code}" != "0" ]]; then
      api_url=$( _get_api "https://api.github.com/repos/${ext}/contents/locale/en.yml" )
      api_code="${?}"
    fi

    if [[ "${api_code}" != "0" ]]; then
      api_url=$( _get_api "https://api.github.com/repos/${ext}/contents/locale/core.yml" )
      api_code="${?}"
    fi

    url_download=$( echo "${api_url}" | ${jq} -r '.download_url' )
    name=$( _get_api "${url_download}" | ${sed} -n 1p | ${sed} "s/://g" )

    if [[ "${name}" == "core" ]]; then
      _get_file "${url_download}" "${ext//\//_}-${name}.yml"
    else
      _get_file "${url_download}" "${name}.yml"
    fi
  done

  _popd || exit 1
}

# -------------------------------------------------------------------------------------------------------------------- #
# GIT: PUSH REPOSITORY.
# -------------------------------------------------------------------------------------------------------------------- #

git_push() {
  _pushd "${path_repo}" || exit 1

  ts="$( _timestamp )"

  ${git} add . \
    && ${git} commit -a -m "[L10N] AUTO-UPDATE: ${ts}" \
    && ${git} push 'l10n'

  _popd || exit 1
}

# -------------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------< COMMON FUNCTIONS >------------------------------------------------ #
# -------------------------------------------------------------------------------------------------------------------- #

# Pushd.
_pushd() {
  command pushd "$@" > /dev/null || exit 1
}

# Popd.
_popd() {
  command popd > /dev/null || exit 1
}

# Timestamp.
_timestamp() {
  ${date} -u '+%Y-%m-%d %T'
}

# Get API.
_get_api() {
  ${curl} -sf -X GET -H "${curl_header}" "${1}"
}

# Get files.
_get_file() {
  ${curl} -f -X GET -H "${curl_header}" "${1}" -o "${2}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< INIT FUNCTIONS >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

init "$@"; exit 0
