# LocalFlow

Lokale Diktier-App für macOS 26. Spracherkennung läuft vollständig on-device.

Dieses Repository verteilt nur die fertige App und ihr Update-Manifest —
kein Quellcode.

## Installation

Neueste Version unter [Releases](../../releases) laden, entpacken und nach
`/Applications` ziehen. Beim ersten Start meldet macOS einen unbekannten
Entwickler: **Systemeinstellungen → Datenschutz & Sicherheit → „Trotzdem
öffnen"**.

## Updates

Die App aktualisiert sich selbst: **LocalFlow → Nach Updates suchen…**
Sie prüft Prüfsumme und Code-Signatur, ersetzt sich im Hintergrund und
startet neu. Ein Update wird nur angenommen, wenn es mit demselben
Zertifikat signiert ist wie die installierte Version.
