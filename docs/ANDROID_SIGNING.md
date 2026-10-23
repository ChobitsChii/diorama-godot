# Android-Release-Signierung für Diorama Sandbox

Diorama Sandbox verwendet einen **dauerhaften, projektspezifischen Release-Signierschlüssel** für alle Veröffentlichungen in Chii Arcade und direkte APK-Installationen.

- **Paketkennung:** `de.chobitschii.diorama`
- **Versionscode:** `12`
- **Versionsname:** `0.1.0-beta.12`

## Öffentlicher Zertifikats-Fingerabdruck

Öffentlicher SHA-256-Fingerabdruck des Release-Zertifikats:

```text
a36a3326986f9c6da099df5f9ea9ad914f48aae26a5a9dd47684c5e25b1e428f
```

Dieser Wert ist öffentlich und wird von Chii Arcade in `TrustedGameCertificates.kt` als Vertrauensanker hinterlegt. Er enthält keine privaten Schlüssel oder Passwörter.

Prüfung einer signierten APK:
```bash
apksigner verify --print-certs <APK-Datei>
```

## Lokale Aufbewahrung

Die privaten Signierdaten liegen **ausschließlich außerhalb des Repositorys**:
- Keystore: `~/.local/share/diorama/signing/diorama-release.keystore` (Modus 0600)
- Zugangsdaten: `~/.local/share/diorama/signing/credentials.json` (Modus 0600)
- Verzeichnis: `~/.local/share/diorama/signing/` (Modus 0700)

Keine privaten Schlüssel, Passwörter oder Keystores werden jemals im Git-Repository versioniert oder übertragen.
