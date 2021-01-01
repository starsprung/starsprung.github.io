#!/bin/bash

GITHUB_REPO="https://github.com/starsprung/${REPO_NAME}.git"

VERSION_DIR=version
VERSION_FILE="${VERSION_DIR}/${REPO_NAME}"

CHECKOUT_DIR=$(mktemp -d -t build-XXXXXXX)
CURRENT_HASH=$([[ -f "${VERSION_FILE}" ]] && cat "${VERSION_FILE}" || echo '')

git clone "${GITHUB_REPO}" "${CHECKOUT_DIR}"
NEW_HASH=$(git -C "${CHECKOUT_DIR}" rev-parse --verify HEAD)

if [[ "${NEW_HASH}" == "${CURRENT_HASH}" ]]; then
  echo 'Hash is unchanged, skipping'
  exit 0
fi

echo "New hash is ${NEW_HASH}, rebuilding"

(cd "${CHECKOUT_DIR}" && npm install && npm run docs)
rsync -r "${CHECKOUT_DIR}"/docs/ "./${REPO_NAME}"
mkdir -p "${VERSION_DIR}"
echo "${NEW_HASH}" >| "${VERSION_FILE}"

git add .
git config --local user.email "s@starsprung.com"
git config --local user.name "shaun Starsprung"
git commit -a -m "${REPO_NAME} docs update"

git push
