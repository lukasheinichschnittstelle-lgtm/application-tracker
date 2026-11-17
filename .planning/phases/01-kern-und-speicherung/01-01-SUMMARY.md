# 01-01 Summary: Kern und Speicherung

**Status:** erledigt 17.11.2026 · CI grün (Run 44134957363 und folgende, `macos-15`)

| Erfolgskriterium (ROADMAP Phase 1) | Beleg |
|---|---|
| 1 `swift test` grün in CI | 9 Tests, 0 Fehler |
| 2 Roundtrip | `StoreTests.testRoundtrip` |
| 3 Unlesbare Datei bleibt erhalten | `StoreTests.testUnreadableFileIsKept` |
| 4 Sicherungskopie beim Start | `StoreTests.testBackupCreatedOnLoad` |
| 5 Versanddatum einmal, Zähler | `ApplicationTests.testSentDateSetOnce`, `testToApplyKeepsNoDate`, `testCounts` (6/5/4/1), `testStatusTitles` |
| Jede Änderung wird geschrieben | `StoreTests.testEveryChangeIsWritten` |

Abweichungen vom Plan:
- Datumswerte werden auf ganze Sekunden gekürzt (`Date.wholeSeconds`), damit ISO 8601 ohne Bruchteile verlustfrei zurückgelesen wird.
- Kann die unlesbare Datei nicht verschoben werden, schaltet der Store auf „nicht speichern“ (`readOnly`), statt sie zu überschreiben.
- Das Repo wurde von Hand angelegt (die GitHub-App des Bau-Servers durfte kein Repo erstellen und hatte trotz Freigabe keine Schreibrechte). Gepusht wird über einen Deploy-Key nur für dieses Repo.
