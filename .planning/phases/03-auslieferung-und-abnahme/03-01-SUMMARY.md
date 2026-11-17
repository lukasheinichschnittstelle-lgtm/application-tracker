# 03-01 Summary: Auslieferung

**Status:** gebaut 17.11.2026, Release `v0.1.0` per Tag. Abnahme auf dem Mac (03-02) steht aus: Auftrag an die zweite Sitzung auf dem Mac.

Dateien: `Resources/Info.plist` (macOS 14, `ATSApplicationFontsPath` = Fonts, Icon), `scripts/make-icon.swift` (Icon „B“, FT-13), `scripts/build-app.sh` (Bündel, ad-hoc-Signatur, `codesign --verify --deep --strict`, Zip), `install.sh` (prüft arm64, beendet laufende App, ersetzt, startet, Daten unberührt), README, LICENSE (MIT), `Resources/Fonts/OFL-*.txt`, CI-Schritt „Publish release“ bei Tags `v*`.

Geprüft in CI: Bündel gebaut und Signatur gültig. Das Zip enthält das Programm, `AppIcon.icns`, vier Schriften, zwei OFL-Dateien und die Info.plist (Version aus dem Tag).
Nicht prüfbar ohne Mac: Gatekeeper/Quarantäne, Installer, Update, Icon-Anzeige, Schriften in der echten App. Das geht an die Abnahme-Prüfliste (ROADMAP).
