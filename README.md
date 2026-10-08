# 🏝️ Diorama Sandbox – Native Godot Edition

[![Engine](https://img.shields.io/badge/Godot-4.7%2B-478cbf?logo=godotengine&logoColor=white)](https://godotengine.org)
[![Platform](https://img.shields.io/badge/Platforms-Linux%20%7C%20Windows%20%7C%20Android-green)](#-downloads--installation)
[![Version](https://img.shields.io/badge/Release-v0.1.0--beta.1-blue)](https://github.com/ChobitsChii/diorama-godot/releases)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](CREDITS.md)
[![Design](https://img.shields.io/badge/Style-Zero--Asset%20Low--Poly-orange)](#-grafik--design-philosophie)

Ein gemütliches, entspannendes 3D-Diorama-Bauspiel im Low-Poly-Voxelstil, entwickelt in **Godot 4**. Erschaffe deine eigene Miniatur-Inselwelt mit Pflanzen, Häusern, Tieren und Deko, wechsle fließend zwischen Tag und Nacht oder erkunde deine Kreationen interaktiv.

---

## 🌟 Highlights & Features

- 🎨 **Umfangreicher 3D-Baukatalog (38 Items):**
  - 🌱 **Böden:** Rasen, Pflasterstein, Holzterrasse, Wasser, Trittsteine, Gemüsebeete, Obstbeete, Pilzwald, Blumenwiesen.
  - 🏡 **Gebäude:** Cozy Häuser, Holzhütten, Windmühle, Scheune, Brunnen, Marktplatz, Pergola.
  - 🌲 **Natur:** Kiefern, Tannen, Birken, Laubbäume, Büsche, Blumen, Felsen.
  - 🐾 **Tiere:** Katzen, Hunde, Enten, Hühner, Schafe, Kühe, Schweine.
  - 💡 **Dekoration:** Straßenlaternen, Holzzäune, Steinmauern, Parkbänke, Picknicktische, Lagerfeuer.

- 📐 **Dynamische Rastergrößen (Grid Scaling):**
  - Wähle in der oberen Leiste per Klick zwischen **8×8**, **12×12**, **16×16**, **20×20** und **24×24** Feldern.
  - Automatische Begrenzung, Zentrierung und Erhaltung der bestehenden Bauten beim Vergrößern/Verkleinern.
  - Optional einblendbares 3D-Gitter (`3D-Gitterlinien`).

- 🔍 **Interaktiver Erkunden-Modus:**
  - Klicke im Erkunden-Modus auf Tiere, um Sprachblasen und authentische Soundeffekte (Miauen, Bellen, Quaken) auszulösen.
  - Schalte Straßenlaternen ein und aus.
  - Pick-up- und Absetz-Animationen für platziertes Mobiliar und Dekoration.

- 🌅 **Tag- & Nacht-Atmosphäre:**
  - Fließender Übergang zwischen sonnigem Tag und stimmungsvoller Nacht mit leuchtenden Laternen, gemütlicher Umgebungsbeleuchtung und ACES/Filmic Tonemapping.

- 📱 **Intelligentes responsives Dual-UI:**
  - **Desktop / Querformat (Landscape):** Schlanke rechte Sidebar, 2-Spalten-Raster, Schnellzugriffs-Pills für Rastergrößen und Werkzeuge.
  - **Smartphone / Hochformat (Portrait):** Daumenfreundliches Bottom-Dock, 4-Spalten-Item-Grid, Android-Safe-Area-/Notch-Unterstützung, vergrößerte Touch-Flächen und DPI-angepasste Dialogfenster.

- 👆 **Multi-Touch & Gesten-Schutz:**
  - Zwei-Finger-Pinch-to-Zoom, -Rotate und -Pan auf Smartphones und Touchscreens.
  - Automatische Erkennung und Sperre gegen versehentliches Platzieren von Objekten bei Kamera- und Zoom-Gesten.

- 💾 **Persistenz & Verlauf:**
  - Volles **Undo/Redo** (`Strg+Z` / `Strg+Y`) für alle Platzier- und Abriss-Aktionen.
  - Lokales Speichern und Laden (`StorageManager`) im nativen JSON-Format.
  - Integrierter HTTP-Synchronisations-Client (`SyncManager`).

---

## 🎮 Steuerung

### Desktop (Maus & Tastatur)
| Aktion | Eingabe |
|---|---|
| **Objekt platzieren / Auswählen** | Linke Maustaste (`LMB`) |
| **Kamera drehen** | Rechte Maustaste (`RMB`) gedrückt halten + Maus bewegen |
| **Kamera verschieben (Pan)** | Mittlere Maustaste (`MMB`) oder `Shift + RMB` |
| **Zoom** | Mausrad hoch / runter |
| **Objekt rotieren (90°)** | Taste `R` oder Button `90°` |
| **Abreißen / Löschen** | Taste `Entf` / `Backspace` oder Modus `Abreißen` |
| **Undo (Rückgängig)** | `Strg + Z` |
| **Redo (Wiederholen)** | `Strg + Y` oder `Strg + Umschalt + Z` |
| **Auswahl / Aktion abbrechen** | Taste `Esc` |

### Touch & Smartphone (Android / Mobile)
| Aktion | Geste |
|---|---|
| **Platzieren / Interagieren** | 1-Finger-Tippen auf ein Gitterfeld oder Objekt |
| **Kamera rotieren** | 2 Finger horizontal/kreisförmig wischen |
| **Kamera zoomen** | 2-Finger-Pinch (Zusammen-/Auseinanderziehen) |
| **Kamera verschieben** | 2 Finger parallel verschieben |
| **Werkzeuge / Katalog öffnen** | Bottom-Dock Button `▲ Werkzeuge` |

---

## 📦 Downloads & Installation

Fertig kompilierte Binärpakete stehen unter **[Releases](https://github.com/ChobitsChii/diorama-godot/releases)** zur Verfügung:

| Plattform | Dateiformat | Anleitung |
|---|---|---|
| 🐧 **Linux (x86_64)** | `.tar.gz` | Archiv entpacken, `chmod +x DioramaSandbox.x86_64`, starten |
| 🪟 **Windows Desktop** | `.zip` | Zip-Archiv entpacken, `DioramaSandbox.exe` per Doppelklick starten |
| 🤖 **Android (ARM64)** | `.apk` | APK auf dem Smartphone herunterladen und installieren |

---

## 🛠️ Entwicklung & Build-Pipeline

### Voraussetzungen
- [Godot Engine 4.7+ (Standard Edition)](https://godotengine.org/download)
- Optional für Android-Builds: Android SDK mit `build-tools` und `platform-tools`

### Projekt im Editor starten
```bash
# Repository klonen
git clone https://github.com/ChobitsChii/diorama-godot.git
cd diorama-godot

# Im Godot Editor öffnen
godot -e
```

### Automatisierte Cross-Platform Builds
Das mitgelieferte Skript [`build_all.sh`](build_all.sh) kümmert sich um Versionierung, Multi-Plattform-Kompilierung und Release-Packaging:

```bash
# 1. Lokaler Build aller Plattformen (Linux, Windows, Android) ohne Versions-Bump:
./build_all.sh --no-bump

# 2. Build mit automatischem Version-Bump (z.B. beta.1 -> beta.2):
./build_all.sh --bump

# 3. Build + Git Tagging + Upload als GitHub Release mit allen Assets:
./build_all.sh --bump --upload
```

### Automatisierte Tests
```bash
godot --headless -s tests/test_light_theme_hud.gd
```

---

## 📁 Projektstruktur

```text
diorama-godot/
├── assets/
│   ├── audio/              # CC0 Soundeffekte (Pop, Wood, Splash, Animals)
│   ├── icons/              # Symmetrische SVG Vektor-Icons (Kamera, Info, Settings)
│   └── splash.png          # Start- und Ladebildschirm
├── scenes/
│   ├── main.tscn           # Hauptszene (Kamera, IslandBase, Controller, HUD)
│   ├── island_base.tscn    # 3D-Inselplattform mit dynamischem Raster
│   ├── ui/hud.tscn         # Responsives HUD mit TopBar, Sidebar & Bottom-Dock
│   └── catalog/            # 3D-Modelle für alle 38 platzierbaren Objekte
├── scripts/
│   ├── catalog.gd          # Katalog-Datenbank und Metadaten
│   ├── grid_manager.gd     # 3D-Rasterkoordinaten und Belegung
│   ├── placement_controller.gd # Raycasting, Platzieren, Drehen & Gestenschutz
│   ├── camera_controller.gd# Isometrische Kamera, Panning, Zoom & Smooth Slerp
│   ├── audio_manager.gd    # Lautstärkemanager und Audio-Synthesizer
│   ├── history_manager.gd  # Undo/Redo Transaktionsverwaltung
│   ├── storage_manager.gd  # Lokales Laden/Speichern von Insel-Layouts
│   ├── sync_manager.gd     # Cloud/HTTP-Synchronisations-Client
│   ├── version.gd          # Automatisch generierte Build-Version (AppVersion)
│   └── ui/hud.gd           # Responsiver Controller für Desktop- & Mobile-Layouts
├── tests/                  # Headless Integrationstests
├── tools/                  # Screenshot-Capture- und Hilfsskripte
├── build_all.sh            # Universal Build- und Release-Pipeline
├── export_presets.cfg      # Godot Export-Konfiguration für Linux, Windows & Android
├── VERSION                 # Versionsdatei (z.B. 0.1.0-beta.1)
└── CREDITS.md              # Detaillierte Lizenz- und Urheberangaben
```

---

## 🎨 Grafik- & Design-Philosophie

Diorama Sandbox verfolgt ein striktes **Zero-Asset Low-Poly Konzept**:
- Keine externen 3D-Meshes oder schwere Texturen: Alle 3D-Objekte werden prozedural aus Godot-Mesh-Primitiven (Box, Zylinder, Kugel, Prisma, CSG) zusammengesetzt.
- Warme, harmonische Farbpalette inspiriert von Natur und Spielzeug-Dioramen.
- Minimale Ladezeiten, extrem geringer Speicherverbrauch und 60 FPS auch auf mobilen Geräten.

---

## 👥 Team & Mitwirkende

- **Jennifer Graßl:** Architektur, Engine-Portierung & Software-Entwicklung (Godot 4, GDScript, Cross-Platform)
- **Sara Graßl:** Ideen, Content-Beiträge & Playtesting
- **Gemini:** Konzept & KI-Entwicklungspartner

---

## 📜 Lizenzen

- **Code:** [MIT Lizenz](CREDITS.md) – Freie Verwendung und Modifikation.
- **Audio:** Alle Sounds stammen von [Kenney](https://kenney.nl) (CC0 1.0 Universal) und Wikimedia Commons (CC0).
- Detaillierte Lizenztexte und Nachweise siehe [CREDITS.md](CREDITS.md).
