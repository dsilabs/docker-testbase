#!/bin/bash
# Checks that have already shipped broken images:
# an unsigned Chrome apt source, Chrome for Testing in place of the
# stable .deb, and a google-chrome symlink to the raw binary.
#
# Safe to run as a file or as `bash -s < scripts/image-smoke.sh`.
set -euo pipefail

fail() {
  echo "image smoke failed: $*" >&2
  exit 1
}

expected_chrome="${EXPECTED_CHROME:-Google Chrome 133.0.6943.141}"

echo "checking apt sources"
if [[ -e /etc/apt/sources.list.d/google-chrome.list || -e /etc/apt/sources.list.d/google-chrome.sources ]]; then
  fail "Google Chrome apt source is still enabled"
fi
apt-get update -qq

echo "checking commands"
for cmd in ping locale nginx mysql google-chrome; do
  command -v "$cmd" >/dev/null || fail "missing command: $cmd"
done

echo "checking Chrome package"
# google-chrome --version prints "Google Chrome 133.0.6943.141" with a trailing space.
chrome_version="$(google-chrome --version)"
chrome_version="${chrome_version%"${chrome_version##*[![:space:]]}"}"
echo "chrome: ${chrome_version}"
if [[ "${chrome_version}" == *"for Testing"* ]]; then
  fail "Chrome for Testing is installed, expected stable Chrome"
fi
if [[ "${chrome_version}" != "${expected_chrome}" ]]; then
  fail "expected '${expected_chrome}', got '${chrome_version}'"
fi

chrome_bin="$(command -v google-chrome)"
chrome_real="$(readlink -f "${chrome_bin}")"
if [[ ! -f "${chrome_real}" ]]; then
  fail "google-chrome does not resolve to a file: ${chrome_bin}"
fi
if head -1 "${chrome_real}" | grep -q '^#!'; then
  :
else
  fail "google-chrome is not the deb wrapper script: ${chrome_real}"
fi
if ! grep -q 'CHROME_VERSION_EXTRA="stable"' "${chrome_real}"; then
  fail "google-chrome wrapper is not the stable deb wrapper"
fi

echo "checking headless Chrome"
page="$(google-chrome --headless --no-sandbox --disable-gpu --dump-dom about:blank 2>/dev/null || true)"
if ! printf '%s' "${page}" | grep -qi '<html'; then
  fail "headless Chrome did not return an HTML page"
fi

echo "image smoke ok"
