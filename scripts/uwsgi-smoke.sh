#!/bin/bash
# Smoke-test the uWSGI Python plugin inside the image.
# A version string is not enough: new CPython releases break uWSGI in the
# request path, when it swaps private thread-state/frame structures.
#
# Safe to run as a file or as `bash -s < scripts/uwsgi-smoke.sh`.
set -euo pipefail

if ! command -v uwsgi >/dev/null; then
  echo "uwsgi is not installed" >&2
  exit 1
fi

uwsgi_py="$(uwsgi --python-version)"
echo "uWSGI $(uwsgi --version) embedded Python ${uwsgi_py}"

if [[ -n "${EXPECTED_PYTHON:-}" && "${uwsgi_py}" != "${EXPECTED_PYTHON}"* ]]; then
  echo "expected Python ${EXPECTED_PYTHON}, uWSGI embedded ${uwsgi_py}" >&2
  exit 1
fi

app="$(mktemp /tmp/wsgi-XXXX.py)"
log="$(mktemp /tmp/uwsgi-XXXX.log)"
pidfile="$(mktemp /tmp/uwsgi-XXXX.pid)"

cleanup() {
  if [[ -s "${pidfile}" ]]; then
    kill "$(cat "${pidfile}")" 2>/dev/null || true
  fi
  rm -f "${app}" "${log}" "${pidfile}"
}
trap cleanup EXIT

printf '%s\n' \
  'def application(environ, start_response):' \
  '    start_response("200 OK", [("Content-Type", "text/plain")])' \
  '    return [b"uwsgi-ok"]' \
  > "${app}"

# --threads 2 forces the Python thread-state swap on each request.
uwsgi \
  --http 127.0.0.1:18080 \
  --wsgi-file "${app}" \
  --callable application \
  --need-app \
  --master \
  --processes 1 \
  --enable-threads \
  --threads 2 \
  --pidfile "${pidfile}" \
  --die-on-term \
  >"${log}" 2>&1 &

python -c '
import os, socket, sys, time, urllib.error, urllib.request
log_path = sys.argv[1]
deadline = time.time() + 20
last = None
while time.time() < deadline:
    try:
        with socket.create_connection(("127.0.0.1", 18080), 0.2):
            break
    except OSError as exc:
        last = exc
        time.sleep(0.1)
else:
    sys.stderr.write(open(log_path, encoding="utf-8", errors="replace").read())
    sys.exit("uwsgi did not accept connections: %s" % last)
try:
    for _ in range(3):
        with urllib.request.urlopen("http://127.0.0.1:18080/", timeout=5) as resp:
            body = resp.read()
            code = resp.status
        if code != 200 or body != b"uwsgi-ok":
            raise SystemExit("unexpected response: %s %r" % (code, body))
except (urllib.error.URLError, TimeoutError, SystemExit) as exc:
    sys.stderr.write(open(log_path, encoding="utf-8", errors="replace").read())
    raise SystemExit("uwsgi request failed: %s" % exc) from exc
print("uwsgi request ok")
' "${log}"
