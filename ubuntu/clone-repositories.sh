#!/usr/bin/env bash

# Clones every pt-* repository in the osinfra-io organization into the standard
# platform-group directory layout. Safe to re-run: existing clones are skipped.
#
# Layout: ~/repositories/osinfra-io/platform-group/<team>/<repository>
# Repositories named pt-ai-* live directly under platform-group/.

set -euo pipefail

ORG="osinfra-io"
BASE_DIR="${HOME}/repositories/${ORG}/platform-group"

if ! command -v gh > /dev/null; then
    echo "Error: GitHub CLI (gh) is required. Run ubuntu/setup.sh first." >&2
    exit 1
fi

if ! gh auth status > /dev/null 2>&1; then
    echo "Error: not authenticated with GitHub. Run 'gh auth login' first." >&2
    exit 1
fi

mkdir -p "${BASE_DIR}"

repositories=$(gh repo list "${ORG}" --limit 1000 --no-archived --json name --jq '.[].name' | grep '^pt-' | sort)

while IFS= read -r repository; do
    team=$(cut -d- -f2 <<< "${repository}")

    if [[ "${team}" == "ai" ]]; then
        target="${BASE_DIR}/${repository}"
    else
        target="${BASE_DIR}/${team}/${repository}"
    fi

    if [[ -d "${target}/.git" ]]; then
        echo "Skipping ${repository} (already cloned)"
        continue
    fi

    mkdir -p "$(dirname "${target}")"
    echo "Cloning ${repository} into ${target}"
    gh repo clone "${ORG}/${repository}" "${target}"
done <<< "${repositories}"

echo "Done. Repositories are in ${BASE_DIR}"
