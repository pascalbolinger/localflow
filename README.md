# LocalFlow

Lokale Diktier-App für macOS 26. Spracherkennung läuft vollständig on-device.

Dieses Repository verteilt nur die fertige App und ihr Update-Manifest —
kein Quellcode.

## Installation

Neueste Version unter [Releases](../../releases/latest) laden, entpacken und nach
`/Applications` ziehen. Beim ersten Start meldet macOS einen unbekannten
Entwickler: **Systemeinstellungen → Datenschutz & Sicherheit → „Trotzdem
öffnen"**.

## Updates

Die App aktualisiert sich selbst: **LocalFlow → Nach Updates suchen…**
Sie prüft Prüfsumme und Code-Signatur, ersetzt sich im Hintergrund und
startet neu. Ein Update wird nur angenommen, wenn es mit demselben
Zertifikat signiert ist wie die installierte Version.

### Einmalig: von Build 89 oder älter auf Build 90

Build 90 ist mit einem neuen Zertifikat signiert. Ältere Fassungen lehnen
es über „Nach Updates suchen…" deshalb ab. Einmal diese zwei Befehle im
Terminal ausführen — Diktate, Wörterbuch und Einstellungen bleiben erhalten:

    curl -fsSL -o localflow-install.sh https://github.com/pascalbolinger/localflow/releases/download/installer-v1/install.sh
    echo "789153e22001a11457bdc83dec9017fa0b209dce05543557b785af4a1bc0b146  localflow-install.sh" | shasum -a 256 -c - && bash localflow-install.sh && rm localflow-install.sh

Der erste Befehl lädt das Installationsskript aus dem festen Release
[`installer-v1`](../../releases/tag/installer-v1), nicht aus dem
veränderlichen `main`. Der zweite startet es nur, wenn die SHA-256-Prüfsumme
stimmt; sonst meldet `shasum` „FAILED" und es passiert nichts. Das Skript
selbst installiert nur ein Paket, das mit dem LocalFlow-Zertifikat signiert
ist.

Danach wie angezeigt LocalFlow unter **Bedienungshilfen** wieder einschalten
und die App neu starten. Ab dann funktioniert das Update wieder per Klick.
