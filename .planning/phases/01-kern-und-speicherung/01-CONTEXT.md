# Phase 1: Kern und Speicherung - Context

**Gathered:** 2026-11-17
**Status:** Ready for planning

<domain>
## Phase Boundary

Ein Swift-Paket mit der Bibliothek `TrackerCore` (Datenmodell, Speicher, Zähler) samt Tests und einem CI-Workflow, der die Tests auf einem macOS-Runner ausführt. Keine Oberfläche, kein App-Bündel, kein Installer: Das kommt in den Phasen 2 und 3.

</domain>

<decisions>
## Implementation Decisions

### Paket
- **D-01:** `Package.swift` mit `swift-tools-version: 5.10`, `platforms: [.macOS(.v14)]`, Ziele `TrackerCore` (library) und `TrackerCoreTests` (XCTest). Das ausführbare Ziel `ApplicationTracker` kommt erst in Phase 2.
- **D-02:** Keine Abhängigkeiten von außen. Nur Foundation und Observation.

### Datenmodell (FT-02, FT-03)
- **D-03:** `struct Application: Codable, Identifiable, Equatable` mit `id: UUID`, `company: String`, `role: String`, `link: String`, `status: Status`, `sentDate: Date?`, `note: String`, `createdAt: Date`.
- **D-04:** `enum Status: String, Codable, CaseIterable` mit den Rohwerten `to-apply`, `sent`, `reply`, `interview`, `rejected` und `offer`. Die Anzeigenamen „To apply“, „Sent“, „Got a reply“, „Interview“, „Rejected“ und „Offer“ stehen als `title`. Die Reihenfolge der Fälle ist die Reihenfolge im Menü.
- **D-05:** `mutating func setStatus(_:on:)` setzt das Versanddatum, wenn der neue Status nicht `toApply` ist und `sentDate == nil`. Ein späterer Wechsel überschreibt das Datum nicht (wie im Mock-up).

### Zähler (FT-06, T6 entschieden 17.11.2026)
- **D-06:** `total` = alle Einträge, `sent` = alle außer `toApply`, `replies` = `reply + interview + rejected + offer` (jede Antwort der Firma zählt, laut Glossar), `interviews` = `interview`.

### Speicher (FT-09, FT-10, T7 entschieden 17.11.2026)
- **D-07:** `@Observable final class Store`, Initialisierer `init(directory: URL)`, damit Tests einen Temp-Ordner nutzen. In der App ist der Ordner `~/Library/Application Support/Application Tracker/` (Phase 2).
- **D-08:** Die Datei heißt `applications.json` und enthält ein JSON-Array. `JSONEncoder` mit `.prettyPrinted` und `.sortedKeys`, Datumsformat ISO 8601. Geschrieben wird mit `Data.write(to:options: .atomic)`.
- **D-09:** Gespeichert wird im `didSet` von `applications`, also bei jeder Änderung. Kein Zwischenspeicher, kein Timer.
- **D-10:** Laden in dieser Reihenfolge: Fehlt die Datei, beginnt die Liste leer. Lässt sie sich lesen, wird sie **erst danach** nach `applications.backup.json` kopiert (vorhandene Kopie ersetzen). Ist sie unlesbar, wird sie nach `applications.unreadable-<yyyyMMdd-HHmmss>.json` umbenannt, die Liste beginnt leer und `loadProblem` enthält einen kurzen Text. So überschreibt eine kaputte Datei nie die letzte gute Sicherung.
- **D-11:** Scheitert das Speichern, wird `saveError` gesetzt. Phase 2 zeigt den Fehler an, statt ihn zu verschlucken.
- **D-12:** Kein Export/Import (T7). Der Menüpunkt „Show Data in Finder“ gehört zu Phase 2.

### CI (INST-02, Teil 1)
- **D-13:** `.github/workflows/ci.yml` läuft bei `push` und `pull_request` auf `macos-15` mit den Schritten `actions/checkout`, `swift --version` und `swift test`.
- **D-14:** Dazu ein Schritt, der das Repo nach E-Mail-Adressen durchsucht, die nicht noreply sind (R18). Personennamen stehen bewusst **nicht** im Workflow, denn das Muster würde sie selbst veröffentlichen. Die Namensprüfung macht der Bauende vor jedem Push mit einer Musterliste, die außerhalb des Repos liegt.

### Claude's Discretion
- Namen der Testfälle und Hilfsfunktionen, Aufteilung in Dateien unter `Sources/TrackerCore/`.
- Ob `Counts` eine eigene Struktur oder eine berechnete Eigenschaft des Stores ist.

</decisions>

<specifics>
## Specific Ideas

- Das Verhalten folgt dem Mock-up (`STATUS`-Tabelle, `today()` beim Statuswechsel, Zählformeln), außer bei `replies` (D-06).
- `.gitignore` für `.build/` und `.swiftpm/`.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

- `.planning/REQUIREMENTS.md`: feste Feature-Nummern FT-01 bis FT-12 und INST-01 bis INST-04
- `.planning/ROADMAP.md`: Erfolgskriterien von Phase 1 und Abnahme-Prüfliste
- Apple-Dokumentation `Data.WritingOptions.atomic` und `Observation` (macOS 14+)

</canonical_refs>

<code_context>
## Existing Code Insights

Greenfield: Es gibt noch keinen Code. Der Bau-Server hat **keine** Swift-Werkzeuge. Kompiliert und getestet wird nur in CI. Darum gilt: kleine Commits, und nach jedem Push das Ergebnis mit `gh run watch` abwarten.

</code_context>

<deferred>
## Deferred Ideas

- Swift-Werkzeuge auf dem Bau-Server, um `TrackerCore` lokal zu testen (F8). Nur nach OK, denn installieren ist in der Planung ausgeschlossen.
- Datum der Rückmeldung als eigenes Feld (v2).

</deferred>

---

*Phase: 01-kern-und-speicherung*
*Context gathered: 2026-11-17*
