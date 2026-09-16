#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

python3 - <<'PY'
import plistlib
from pathlib import Path
for path in (Path("DialerApp/Resources/Info.plist"), Path("DialerApp/Resources/DialerApp.entitlements")):
    with path.open("rb") as stream:
        plistlib.load(stream)
PY
test -f DialerApp.xcodeproj/project.pbxproj

if grep -q 'CODE_SIGN_ENTITLEMENTS = DialerApp/Resources/DialerApp.entitlements' DialerApp.xcodeproj/project.pbxproj; then
  echo "Managed dialing entitlement must not be enabled in the default build." >&2
  exit 1
fi

if grep -q 'DIALER_ENABLE_LIVE_COMMUNICATION_KIT' DialerApp.xcodeproj/project.pbxproj; then
  echo "LiveCommunicationKit must not be enabled in the default build." >&2
  exit 1
fi

while IFS= read -r source; do
  name="$(basename "$source")"
  grep -q "$name" DialerApp.xcodeproj/project.pbxproj || {
    echo "Project target is missing $source" >&2
    exit 1
  }
done < <(find DialerApp -name '*.swift' -type f | sort)

echo "Project structure and property lists are valid."
