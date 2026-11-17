# Roadmap: Application Tracker

## Overview

Drei grobe Phasen. Zuerst entsteht der Kern, der Daten sicher speichert. Er wird automatisch auf einem macOS-Runner getestet, weil der Bau-Server Linux ist. Dann folgt die Oberfläche im Gepard-Design. CI rendert sie als Bilder, damit sie von Linux aus prüfbar ist. Zum Schluss kommen Release, Ein-Befehl-Installer und die Abnahme auf einem echten Mac. Jede Phase endet mit einer Prüfung, die nicht vom Bauenden selbst stammt (R20): CI-Tests, gerenderte Bilder und am Ende eine Prüfliste, die eine zweite Sitzung auf dem Mac Punkt für Punkt abhakt.

## Phases

- [x] **Phase 1: Kern und Speicherung** - Datenmodell, sichere JSON-Datei und Zählweise, getestet auf GitHub Actions
- [x] **Phase 2: Oberfläche im Gepard-Design** - Ein Fenster mit Liste, Status, Notizen, Hinzufügen und Kennzahlen, Hell und Dunkel
- [ ] **Phase 3: Auslieferung und Abnahme** - Release-Zip, Ein-Befehl-Installer und Update, README, Abnahme auf dem Mac

## Phase Details

### Phase 1: Kern und Speicherung
**Goal**: Ein Swift-Paket mit einer Bibliothek `TrackerCore`, die Bewerbungen hält, jede Änderung atomar speichert und nie Daten überschreibt, die sie nicht lesen konnte.
**Depends on**: Nothing (first phase)
**Requirements**: FT-02, FT-03, FT-06, FT-09, FT-10, INST-02
**Success Criteria** (what must be TRUE):
  1. `swift test` läuft auf `macos-15` (GitHub Actions) grün, ausgelöst bei jedem Push
  2. Speichern, dann neu laden ergibt exakt dieselben Bewerbungen (Roundtrip-Test)
  3. Eine absichtlich kaputte Datendatei bleibt als `applications.unreadable-<Zeitstempel>.json` erhalten; die App startet leer und meldet das
  4. Beim Start liegt eine Sicherungskopie `applications.backup.json` der vorigen Datei daneben
  5. Statuswechsel weg von „To apply“ setzt das Versanddatum genau einmal; die vier Zähler stimmen mit der festgelegten Formel überein
**Plans**: 1 plan
**Prüfung (R20)**: Die Tests laufen in CI, nicht auf dem Rechner des Bauenden. Der Prüfer liest das Testprotokoll aus `gh run view` und gleicht die Kriterien 2–5 je einem Testnamen zu.

Plans:
- [x] 01-01: Paket, Datenmodell, Speicher, Zähler, Tests und CI-Workflow

### Phase 2: Oberfläche im Gepard-Design
**Goal**: Eine SwiftUI-App mit einem einzigen Fenster, die alle Features FT-01 bis FT-12 zeigt und bedienbar macht, in den Farben und Schriften des neuen Gepard-Designs.
**Depends on**: Phase 1
**Requirements**: FT-01, FT-02, FT-04, FT-05, FT-06, FT-07, FT-08, FT-11, FT-12
**Success Criteria** (what must be TRUE):
  1. CI baut die App fehlerfrei (`swift build -c release`)
  2. CI rendert das Hauptfenster mit Beispieldaten (nur im Test) per `ImageRenderer` als PNG in Hell und Dunkel, dazu den leeren Zustand. Die Bilder hängen als Artefakt am Lauf
  3. Auf den Bildern sind die Archivo-Überschrift, die Geist-Mono-Kennzahlen, sechs unterscheidbare Statusfarben und im Dunkeln der Farbnebel zu sehen
  4. Löschen fragt immer nach; ohne Firma lässt sich nichts hinzufügen
**Plans**: 1 plan
**UI hint**: yes
**Prüfung (R20)**: Der Betreuer bzw. eine zweite Sitzung vergleicht die PNG-Artefakte Feature für Feature mit FT-01 bis FT-12 und mit dem Mock-up.

Plans:
- [x] 02-01: Design-Tokens, Hauptfenster, Bearbeiten/Löschen, Link, leerer Zustand, Render-Test (in einem Plan)

### Phase 3: Auslieferung und Abnahme
**Goal**: Die Nutzerin installiert und aktualisiert die App mit einem einzigen Befehl aus dem öffentlichen Repo, ohne Datenverlust.
**Depends on**: Phase 2
**Requirements**: FT-13, INST-01, INST-02, INST-03, INST-04
**Success Criteria** (what must be TRUE):
  1. Der Tag `v0.1.0` erzeugt ein Release mit `ApplicationTracker.zip`, darin ein ad-hoc signiertes `Application Tracker.app` (`codesign --verify --deep --strict` grün in CI)
  2. `curl -fsSL https://raw.githubusercontent.com/lukasheinichschnittstelle-lgtm/application-tracker/main/install.sh | bash` installiert und startet die App auf einem Mac mit Apple Silicon, ohne Gatekeeper-Dialog
  3. Derselbe Befehl erneut: Die App wird ersetzt, alle Einträge sind noch da
  4. Repo-Prüfung in CI: keine Personennamen aus der Akte und keine E-Mail-Adressen außer noreply (`git grep`-Schritt)
**Plans**: 2 plans (TBD at plan-phase)
**Prüfung (R20)**: Abnahme-Prüfliste auf dem Mac (Ratatouille) durch eine zweite Sitzung (Colette), nicht durch den Bauenden. Belege sind echte, gekürzte Befehlsausgaben. Die Prüfliste steht unten.

Plans:
- [x] 03-01: App-Bündel mit Icon „B“, Release-Workflow, install.sh, README, Lizenzen
- [ ] 03-02: Abnahme auf dem Mac nach Prüfliste

## Abnahme-Prüfliste (Phase 3, R20)

Auf dem Mac, je Punkt ein Beleg (Befehl und gekürzte Ausgabe oder Bildschirmfoto):

1. Installation mit dem einen Befehl. Kein Gatekeeper-Dialog; `xattr -l ~/Applications/Application\ Tracker.app` zeigt kein `com.apple.quarantine`
2. FT-05: Drei Bewerbungen anlegen, eine ohne Firma wird abgelehnt
3. FT-02/FT-03: Status von „To apply“ auf „Sent“ stellen; das heutige Datum erscheint
4. FT-04: Notiz tippen und die App sofort mit `kill -9` beenden. Nach dem Neustart ist die Notiz da (FT-09)
5. Laptop zuklappen, aufklappen: Die Daten sind da
6. FT-06: Die Zähler stimmen von Hand nachgezählt
7. FT-07: Ein Klick auf den Link öffnet den Browser
8. FT-08: Bearbeiten wirkt; Löschen fragt nach, „Abbrechen“ lässt den Eintrag stehen
9. FT-10: `applications.backup.json` existiert; „Show Data in Finder“ öffnet den Ordner
10. FT-11: Hell/Dunkel in den Systemeinstellungen umschalten, die App folgt sofort; Archivo und Geist sind sichtbar (keine Systemschrift)
11. FT-12: Mit leerer Datendatei erscheint der Hinweis
12. INST-04: Den Befehl erneut ausführen; die App läuft neu, alle Einträge sind da
13. Kein Netz: `lsof -i -a -p $(pgrep -x ApplicationTracker)` ist leer
14. Deinstallation nach README funktioniert
15. FT-13: Im Dock und im Finder erscheint das „B“-Icon

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Kern und Speicherung | 1/1 | Complete | 2026-11-17 |
| 2. Oberfläche im Gepard-Design | 1/1 | Complete (Abnahme am Mac offen) | 2026-11-17 |
| 3. Auslieferung und Abnahme | 1/2 | Abnahme am Mac offen | - |
