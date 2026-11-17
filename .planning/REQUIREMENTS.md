# Requirements: Application Tracker

**Defined:** 2026-11-17
**Core Value:** Kein Eintrag geht verloren: Jede Änderung ist sofort sicher auf der Platte.

Die IDs `FT-01` bis `FT-12` sind die **festen Feature-Nummern** der Mockup-Schleife. Änderungen an einem Feature werden unter seiner Nummer festgehalten. Die Spalte „Herkunft“ trennt Vorgaben (Mock-up, Aussagen des Betreuers) von Vorschlägen der Planung.

## v1 Requirements

### App (Features)

| ID | Feature | Herkunft |
|----|---------|----------|
| FT-01 | Liste aller Bewerbungen, neueste zuerst, je Zeile Firma, Stelle, Status und Versanddatum | Mock-up |
| FT-02 | Status in sechs Stufen mit eigener Farbe: To apply, Sent, Got a reply, Interview, Rejected, Offer. Wechsel per Auswahlmenü | Mock-up |
| FT-03 | Verlässt eine Bewerbung „To apply“ und hat noch kein Versanddatum, wird das heutige Datum gesetzt. Ohne Datum steht „Not sent yet“ | Mock-up |
| FT-04 | Freie Notiz je Bewerbung, sichtbar und direkt bearbeitbar | Mock-up |
| FT-05 | Bewerbung hinzufügen: Firma (Pflicht), Stelle, Link. Neue Einträge starten mit „To apply“ | Mock-up |
| FT-06 | Kennzahlen-Zeile mit vier Zählern: total, sent, replies, interviews | Mock-up; „replies“ zählt jede Antwort (Got a reply, Interview, Rejected, Offer), T6 entschieden 17.11.2026 |
| FT-07 | Der Link ist ein eigenes Feld; ein Klick öffnet ihn im Standardbrowser | **Vorschlag**: Das Mock-up schreibt den Link in die Notiz, das Glossar nennt „Link“ als Feld |
| FT-08 | Bewerbung bearbeiten (Firma, Stelle, Link, Versanddatum) und löschen; Löschen nur nach Rückfrage | **Vorschlag**, nicht im Mock-up |
| FT-09 | Jede Änderung wird sofort atomar in die Datendatei geschrieben; Beenden, Absturz oder Zuklappen kosten nichts | Q3, Q4 |
| FT-10 | Beim Start wird die vorige Datendatei als Sicherungskopie abgelegt. Eine unlesbare Datei wird nie überschrieben, sondern beiseitegelegt, mit Hinweis. Menüpunkt „Show Data in Finder“ | Vorschlag, bestätigt 17.11.2026 (T7, ersetzt Export/Import) |
| FT-11 | Aussehen nach dem neuen Gepard-Design (Farben, Schriften, Paneel, eckige Knöpfe, Umriss-Etiketten), Hell/Dunkel folgt dem System, im Dunkeln mit Farbnebel | Q8 |
| FT-12 | Leere Liste mit kurzem Hinweis „Add your first application“ | **Vorschlag**, Folge aus T5 (keine Demo) |

### Auslieferung

- [ ] **INST-01**: Ein öffentliches Repo `application-tracker` mit README (Installation, Update, wo die Daten liegen, Deinstallation), MIT-Lizenz und OFL-Datei für die Schriften
- [ ] **INST-02**: GitHub Actions baut bei jedem Push und testet; bei einem Tag `v*` entsteht ein ad-hoc signiertes `Application Tracker.app` als Zip an einem Release
- [ ] **INST-03**: Ein Befehl (`curl -fsSL …/install.sh | bash`) lädt das neueste Release, legt die App nach `~/Applications` und startet sie, ohne Gatekeeper-Dialog
- [ ] **INST-04**: Derselbe Befehl aktualisiert die App: eine laufende App wird sauber beendet und ersetzt, die Datendatei bleibt unberührt

### Checkliste für v1

- [ ] **FT-01** … **FT-12** umgesetzt und nach [ROADMAP.md](ROADMAP.md) geprüft

## v2 Requirements

Bewusst aufgeschoben, kommt nur bei echtem Bedarf:

- Suche oder Filter nach Status
- Datum der Rückmeldung als eigenes Feld
- App-Icon (v1 zeigt das Standard-Icon, siehe T8)
- Export als CSV

## Out of Scope

| Feature | Reason |
|---------|--------|
| KI-Stellenanalyse, Research, Entwürfe, Lebenslauf-Links | Q1: „nicht die tiefgreifenden Funktionen“ |
| Server, Cloud, Konto, Sync | Q4: lokal |
| Handy | F3, bestätigt: nur Mac |
| Update-Knopf, Telemetrie, jeder Netzzugriff | F5: Update per Befehl; keine Netzrechte nötig |
| Demo-Verlauf | T5: abgewählt |
| Umschaltbare Sprache | F7: nur Englisch |
| Intel-Mac / Universal-Build | F2: Gerät ist Apple Silicon |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| FT-02 (Datenmodell) | Phase 1 | Pending |
| FT-03 | Phase 1 | Pending |
| FT-06 (Zählweise) | Phase 1 | Pending |
| FT-09 | Phase 1 | Pending |
| FT-10 | Phase 1 | Pending |
| FT-01 | Phase 2 | Pending |
| FT-02 (Anzeige) | Phase 2 | Pending |
| FT-04 | Phase 2 | Pending |
| FT-05 | Phase 2 | Pending |
| FT-06 (Anzeige) | Phase 2 | Pending |
| FT-07 | Phase 2 | Pending |
| FT-08 | Phase 2 | Pending |
| FT-11 | Phase 2 | Pending |
| FT-12 | Phase 2 | Pending |
| INST-01 | Phase 3 | Pending |
| INST-02 | Phase 1 (Test-Lauf), Phase 3 (Release) | Pending |
| INST-03 | Phase 3 | Pending |
| INST-04 | Phase 3 | Pending |

**Coverage:**
- v1 requirements: 16 total (12 Features, 4 Auslieferung)
- Mapped to phases: 16
- Unmapped: 0 ✓

---
*Requirements defined: 2026-11-17*
*Last updated: 2026-11-17 after initialization*
