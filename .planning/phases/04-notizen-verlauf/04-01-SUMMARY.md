# 04-01 Summary: Notizen-Verlauf und nächster Schritt

**Anlass (Aussage Lukas, 17.11.2026):** Beim ersten Test auf dem Mac lief alles. Das Notizfeld nahm aber nur einen Absatz und muss für sauberes Abarbeiten ausgebaut werden.

**Entscheidungen (Lukas per Rückfrage, 17.11.2026):** Verlauf mit Datum; Notizen in der Zeile aufklappbar; nächster Schritt mit Datum, fällig hervorgehoben; Einträge ändern und löschen. Abgewählt: Abhak-Liste, Sortierung nach Fälligkeit.

**Gebaut (Vorschläge der Umsetzung, nicht von Lukas vorgegeben):**
- `Application.notes: [Note]` (id, date, text), `nextStep`, `nextStepDate`, `isDue(on:)`
- Eigenes `init(from:)`: Eine `note` aus einer v0.1.0-Datei wird erster Eintrag mit Datum `createdAt`; eine leere Notiz entfällt. Beim nächsten Speichern fällt das Feld `note` weg.
- Klick auf Firma/Stelle (Pfeil) klappt auf. Eingabe per `TextEditor`, Return = neuer Absatz, „Add note“ speichert. Ändern und Löschen gehen über die id, nicht über die Position.
- Fälliger Schritt (Datum ≤ heute): roter Rahmen und rote „Next:“-Zeile, auch zugeklappt

**Prüfung (R20, von Luigi gesehen):** CI-Lauf 44185634682 grün mit 11 Tests, neu sind `testV010FileMigrates` und `testNextStepDue`. Die Testbilder `light.png` und `row-expanded-light.png` sind angesehen. Release v0.2.0 über CI-Lauf 44187010429, Zip 501 190 Bytes.

**Offen:** Die Bedienung am echten Mac ist ungeprüft: Return im Eingabefeld, Ändern, Löschen und ein Update von v0.1.0 mit echten Daten.
