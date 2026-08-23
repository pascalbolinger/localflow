#!/bin/bash
# LocalFlow installieren oder aktualisieren.
#
#   curl -fsSL https://raw.githubusercontent.com/pascalbolinger/localflow/main/install.sh | bash
#
# Holt die neueste Fassung, prüft Prüfsumme und Signatur und ersetzt eine
# vorhandene Installation. Diktate, Wörterbuch und Einstellungen liegen in
# ~/Library/Application Support/LocalFlow und werden nicht angefasst.
set -euo pipefail

REPO="pascalbolinger/localflow"
# Fingerabdruck des Signaturzertifikats „LocalFlow Dev". Nur ein Paket mit
# genau diesem Zertifikat wird installiert — so kann auch ein übernommenes
# GitHub-Konto nichts Fremdes unterschieben.
FINGERPRINT="3727c521ff0bf113266e5048f87bb18145a791edaa31d85afa0c33f2a60a09f3"

fail() { echo "✗ $1" >&2; exit 1; }

echo "▸ Suche neueste Version…"
API=$(curl -fsSL -H 'Accept: application/vnd.github+json' \
  "https://api.github.com/repos/${REPO}/releases/latest") || fail "Keine Verbindung zu GitHub."

URL=$(printf '%s' "$API" | /usr/bin/python3 -c '
import json,sys
d=json.load(sys.stdin)
a=[x for x in d["assets"] if x["name"].endswith(".zip")]
print(a[0]["browser_download_url"] if a else "")')
DIGEST=$(printf '%s' "$API" | /usr/bin/python3 -c '
import json,sys
d=json.load(sys.stdin)
a=[x for x in d["assets"] if x["name"].endswith(".zip")]
print((a[0].get("digest") or "").replace("sha256:","") if a else "")')
TAG=$(printf '%s' "$API" | /usr/bin/python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"])')
[ -n "$URL" ] || fail "Im neuesten Release liegt kein Paket."
echo "  gefunden: $TAG"

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

echo "▸ Lade herunter…"
curl -fsSL -o "$WORK/LocalFlow.zip" "$URL" || fail "Download fehlgeschlagen."

if [ -n "$DIGEST" ]; then
  ACTUAL=$(shasum -a 256 "$WORK/LocalFlow.zip" | cut -d' ' -f1)
  [ "$ACTUAL" = "$DIGEST" ] || fail "Prüfsumme stimmt nicht — Download verworfen."
  echo "  Prüfsumme stimmt"
fi

echo "▸ Prüfe Signatur…"
/usr/bin/ditto -x -k "$WORK/LocalFlow.zip" "$WORK/entpackt" || fail "Archiv nicht lesbar."
APP="$WORK/entpackt/LocalFlow.app"
[ -d "$APP" ] || fail "Im Archiv ist keine LocalFlow.app."
/usr/bin/xattr -dr com.apple.quarantine "$APP" 2>/dev/null || true
codesign --verify --deep --strict "$APP" 2>/dev/null || fail "Signatur ungültig — Paket verworfen."
codesign -d --extract-certificates="$WORK/cert" "$APP" 2>/dev/null || fail "Signatur nicht lesbar."
GOT=$(shasum -a 256 "$WORK/cert0" | cut -d' ' -f1)
[ "$GOT" = "$FINGERPRINT" ] || fail "Fremdes Zertifikat — Paket verworfen."
echo "  Signatur stimmt"

# Vorhandene Installation finden; sonst nach /Applications.
DEST="/Applications/LocalFlow.app"
for candidate in "/Applications/LocalFlow.app" "$HOME/Applications/LocalFlow.app"; do
  [ -d "$candidate" ] && DEST="$candidate" && break
done
PARENT=$(dirname "$DEST")
[ -w "$PARENT" ] || fail "Kein Schreibrecht in $PARENT."

if [ -d "$DEST" ]; then
  OLD=$(defaults read "$DEST/Contents/Info.plist" CFBundleVersion 2>/dev/null || echo "?")
  echo "▸ Ersetze vorhandene Version (Build $OLD)"
  osascript -e 'quit app "LocalFlow"' >/dev/null 2>&1 || true
  for _ in $(seq 1 25); do pgrep -x LocalFlow >/dev/null || break; sleep 0.2; done
  pkill -x LocalFlow 2>/dev/null || true
  sleep 0.5
  rm -rf "$DEST"
else
  echo "▸ Installiere neu nach $PARENT"
fi

/usr/bin/ditto "$APP" "$DEST" || fail "Kopieren fehlgeschlagen."
NEW=$(defaults read "$DEST/Contents/Info.plist" CFBundleVersion)
echo "▸ Starte LocalFlow (Build $NEW)"
open "$DEST"

cat <<'DONE'

✓ Fertig. Ab jetzt geht es ohne Terminal:
  LocalFlow im Menü oben → „Nach Updates suchen…"
  oder Einstellungen → ganz unten bei „Version".

Diktate, Wörterbuch und Einstellungen sind unverändert geblieben.
DONE
