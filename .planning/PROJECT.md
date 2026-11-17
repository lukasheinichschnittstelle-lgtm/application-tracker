# Application Tracker

## What This Is

Eine sehr kleine, native Mac-App, in der die Nutzerin ihre Bewerbungen festhält: rausgeschickt, Rückmeldung, ein bisschen Dokumentation. Sie ist eine stark vereinfachte Version eines bestehenden Bewerbungscockpits, ohne dessen tiefe Funktionen. Die Daten bleiben lokal auf dem Mac und überstehen das Zuklappen des Laptops und das Beenden der App.

## Core Value

**Kein Eintrag geht verloren:** Jede Änderung ist sofort sicher auf der Platte, egal ob die App beendet, abgestürzt oder der Laptop zugeklappt wird.

## Requirements

### Validated

(None yet — ship to validate)

### Active

Die Feature-Nummern `FT-xx` sind fest (Mockup-Schleife). Vollständige Liste: [REQUIREMENTS.md](REQUIREMENTS.md).

- [ ] Bewerbungen erfassen, Status pflegen, Notizen schreiben (FT-01 bis FT-08)
- [ ] Speichern ohne Datenverlust (FT-09, FT-10)
- [ ] Aussehen nach dem neuen Gepard-Design, Hell/Dunkel nach System (FT-11, FT-12)
- [ ] Installation und Update mit einem Befehl aus einem öffentlichen GitHub-Repo (INST-01 bis INST-04)

### Out of Scope

- Stellenanzeige mit KI, Research, Entwürfe, Lebenslauf-Links — tiefe Cockpit-Funktionen, ausdrücklich nicht gewünscht.
- Server, Cloud, Konten, Sync — die Daten bleiben lokal.
- Handy, Windows, Intel-Macs — das Gerät der Nutzerin ist ein Mac mit Apple Silicon.
- Netzwerkzugriff in der App (auch kein Update-Knopf oder Telemetrie) — das Update läuft über denselben Installationsbefehl.
- Demo-Verlauf — vom Betreuer abgewählt (T5). Beispieldaten gibt es nur in Tests.
- Mehrsprachigkeit — die Oberfläche ist nur Englisch (F7).
- Suche, Filter, Erinnerungen, Anhänge — nicht verlangt, kommen erst bei Bedarf.

## Context

- Ausgangspunkt ist ein Mock-up (HTML, speichert nichts) mit Liste, sechs Status in Farbe, Notizfeld, Hinzufügen-Formular und vier Zählern.
- Das Design orientiert sich am neuen Gepard-Design (eigenes Design, Schritte 1 und 2, beide auf `develop` und `main` seit 17.11.2026): Farbvariablen in `src/design/gepard.css`, Schriften Archivo 800, Geist und Geist Mono.
- Gebaut wird auf einem Linux-Server ohne Swift-Werkzeuge. Kompilieren, Tests und Release laufen darum auf GitHub Actions (macOS-Runner). Oberfläche und Installer prüft der Betreuer auf einem echten Mac.

## Constraints

- **Tech-Stack**: Swift 5.10+/SwiftUI, Swift-Paket (SwiftPM) ohne Xcode-Projekt. Grund: echt Mac-nativ, keine Laufzeit nötig, und die Dateien sind auch von Linux aus lesbar und pflegbar.
- **Plattform**: macOS 14 (Sonoma) oder neuer, nur arm64. Grund: Die Geräte kamen mit macOS 14 bzw. 15, und `@Observable` braucht macOS 14.
- **Daten**: eine JSON-Datei in `~/Library/Application Support/Application Tracker/`, bei jeder Änderung atomar geschrieben.
- **Auslieferung**: ein öffentliches Repo und ein Ein-Befehl-Installer (`curl … | bash`). Die App ist nur ad-hoc signiert, weil es kein Apple-Developer-Konto gibt.
- **Datenschutz im Repo**: keine Personennamen, keine privaten E-Mail-Adressen, Commits nur mit der noreply-Adresse.
- **Lizenz**: Code unter MIT, Schriften unter SIL OFL 1.1 mit eigener Lizenzdatei.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Swift + SwiftUI, nur Mac, macOS 14+ (T1, F2, F3) | Mac-nativ gewünscht, deckt beide möglichen Geräte ab | ✓ Betreuer bestätigt 17.11.2026 |
| SwiftPM statt Xcode-Projekt | `.xcodeproj` ist von Linux aus kaum pflegbar; die App wird per Skript zu einem `.app` gebündelt | ✓ bestätigt (Teil von T1) |
| JSON-Datei statt SQLite/SwiftData | Wenige Dutzend Einträge; `Codable` und `.atomic` reichen und die Datei ist lesbar | ✓ bestätigt (Teil von T1) |
| Build und Release per GitHub Actions (macOS-Runner) | Linux kann kein SwiftUI bauen; Standard-Runner sind für öffentliche Repos kostenlos | ✓ bestätigt (Teil von T1) |
| Update = denselben Installationsbefehl erneut ausführen (F5) | Kein Netzcode in der App | ✓ bestätigt |
| Name „Application Tracker“, Repo `application-tracker`, UI Englisch (T3, F7) | Wie das Mock-up | ✓ bestätigt |
| MIT-Lizenz (T2) | Kurz und üblich | ✓ bestätigt |
| Keine Demo (T5) | Keine Vermischung von Beispiel- und echten Daten | ✓ bestätigt |
| Sicherungskopie beim Start statt Export/Import (FT-10) | Eine Zeile Code statt zweier Dialoge; schützt vor kaputter Datei und vor schlechten Updates | — Vorschlag, offen (T7) |
| Schriften über `ATSApplicationFontsPath` statt SPM-Ressourcen | SPM-Ressourcenbündel im handgebauten `.app` brechen die Signatur; der Info.plist-Schlüssel braucht keinen Code | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-11-17 after initialization*
