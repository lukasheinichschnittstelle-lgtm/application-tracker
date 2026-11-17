# 02-01 Summary: Oberfläche im Gepard-Design

**Status:** gebaut 17.11.2026 · CI grün (Run 44136587057). Geplant und gebaut in einem Zug, ohne eigene PLAN-Datei: Der Betreuer wollte den Bau während seiner Abwesenheit, die Vorgaben stehen in ROADMAP Phase 2 und in PROJECT.md.

Dateien: `Sources/TrackerCore/Theme.swift` (Farben aus gepard.css, Schriften, Knöpfe, Nebel), `Sources/TrackerCore/TrackerView.swift` (Fenster, Hinzufügen, Zeile, Status-Menü, Bearbeiten, Löschen mit Rückfrage), `Sources/ApplicationTracker/App.swift` (ein Fenster, Menüpunkt „Show Data in Finder“), `Tests/TrackerCoreTests/SnapshotTests.swift`.

Prüfung (R20): CI rendert das Fenster mit `NSHostingView` als PNG (light, dark, empty-light, empty-dark), Artefakt `snapshots`. Gesehen: Archivo-Überschrift, Geist-Mono-Zähler, sechs unterscheidbare Statusfarben, weicher Farbnebel im Dunkeln, leerer Zustand mit Hinweis.

Bekannt und offen für die Abnahme am Mac:
- Status-Pillen zeigen im Testbild kleine Zacken an den Enden (Rahmen des Menüknopfs). `.borderlessButton` entfernt sie, nimmt aber auch die Farbe weg, deshalb bleibt `.button` + `.plain`.
- „1 interviews“: feste Beschriftungen wie im Mock-up, keine Einzahl.
- Der Nebel ist mit `EllipticalGradient` umgesetzt statt mit Weichzeichnen, weil Weichzeichnen im Testbild harte Kanten hatte.
