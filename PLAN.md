# 🏝️ Implementierungsplan: 1:1 Modulon-Parity für Diorama-Sandbox (Godot 4)

## 1. Zielsetzung
Vollständiger visueller und funktionaler 1:1-Nachbau der **Modulon Diorama-Sandbox (`v1.0.7`)** in **Godot 4**, sodass Beleuchtung, Farben, Insel-Sockel, Starter-Insel, alle 41 prozeduralen 3D-Modelle, Autotiling, Partikeleffekte, Synthesizer-Sounds, das Erntekorb- und Fütterungssystem (`🧺 ERNTEKORB`) sowie das gesamte UI/HUD dem Original entsprechen.

---

## 2. Arbeitspakete

### Phase 1: Beleuchtung, Farb-Rendering, Kamera & 3-Schicht-Inselsockel
- **Tonemapping & Shading:** Linear Tonemapping (`tonemap_mode = 0`) und Standard-PBR/Lambert-Shading (`diffuse_mode = 0`) statt Toon-Shading, damit `#48bb78` (Gras) und `#0284c7` (Wasser) natürlich und kräftig wirken.
- **Tag-/Nacht-Beleuchtung (`day_night_controller.gd`):**
  - Tag: Hintergrund `#cde7ff`, Ambient `#dbeafe` (`0.68`), Sonne `#fff8ee` aus `(16, 24, 16)`.
  - Nacht: Hintergrund `#0e1628`, Ambient `#151d2f` (`0.28`), Mond `#60a5fa` (`0.35`).
- **3-Schicht-Inselsockel (`island_base.gd`):**
  1. Top Soil (`#5c4033`, `width + 0.3`, Höhe `0.3`, `y = -0.15`)
  2. Deep Earth (`#6d4c41`, `width + 0.15`, Höhe `0.9`, `y = -0.75`)
  3. Bedrock Bottom (`#475569`, verjüngt `width - 0.4`, Höhe `0.9`, `y = -1.65`)
  4. Dezentes Grid-Overlay bei `y = 0.025`.

### Phase 2: Alle 41 Prozeduralen 3D-Modelle & Autotiling (`procedural_models.gd` & `catalog.gd`)
- **Böden (10):** `grass` (mit 5 Grasbüscheln & Gänseblümchen), `water` (mit 4 schrägen weißen Reflexionsstreifen & Wellenanimation), `stone` (Erdbasis + 5 Pflastersteine), `wood` (4 Holzplanken), `steppingstones` (6 Natursteine im Gras), `field_vegetable`, `field_fruit`, `field_mushroom`, `field_flower`, `field_orchard`.
- **Gebäude (3):** `cottage` (Fachwerk, Walmdach, Kamin, 4 Fenster, Türknauf), `townhouse` (mit Nachbarschafts-Autotiling), `apartment` (mit Nachbarschafts-Autotiling).
- **Natur (12):** `tree` (mit Seitenast & 6-Kugel-Krone), `pine` (3 gestapelte 7-eckige Kegel), `pond` (mit Steinen, Seerose & Schilf), `bush` (mit Beeren), `flowerpot` (3 Tulpen), `claypot` (Terrakotta-Kübel mit Geranien), `sunflower`, `cactus`, `flyagaric` (Fliegenpilz), `mushrooms` (Champignon-Gruppe, erntbar), `strawberry_plant` (erntbar), `potato_plant` (erntbar).
- **Wesen (12):** `human`, `cat`, `dog`, `duck`, `squirrel`, `axolotl`, `pig`, `parrot`, `horse`, `elephant`, `lion`, `whitetiger`.
- **Deko (5):** `streetlamp` (mit Lichtkegel & 3 Modi), `bench`, `fountain` (mit rundem Becken & Fontäne), `fence` (mit 4-Wege-Autotiling), `beertable` (mit 2 Bänken & 4 Maßkrügen).

### Phase 3: Starter-Insel, Sitzen/Perching/Schwimmen & 3D-Partikel
- Exakte Starter-Insel aus `storage.js` (`loadDefaultStarterScene`).
- Multi-Slot-Sitzen auf `bench` (2 Plätze) und `beertable` (4 Plätze).
- Perching für `parrot` und `squirrel` auf `tree`, `pine` und `streetlamp`.
- Schwimmen für `duck` und `axolotl` auf `water` und `pond`.
- 3D-Partikelsystem (`particle_manager.gd`) für Kaminrauch, Herzen, Blätter, Wasserspritzer/Fontäne und Abriss-Staubwolke.

### Phase 4: Erntekorb (`🧺 ERNTEKORB`), Füttern & Synthesizer-Audio
- Erntekorb mit 4 Slots (`🍓`, `🥔`, `🍄`, `🌰`), Nachwachs-Timer (35 s) für abgeerntete Pflanzen und Baum-Schüttel-Ernte für Nüsse.
- Füttern aller Tiere und Menschen im Erkunden-Modus mit Herz-Partikeln, Kau-Sound und Toast-Nachricht.
- Prozeduraler Audio-Synthesizer (`audio_synthesizer.gd`) für alle Tier-, Ernte-, Kau- und Interaktionsgeräusche.

### Phase 5: 1:1 Modulon UI / HUD Redesign
- Schwebende TopBar mit Brand-Pill links und Save-Pill (`☁️ Gespeichert ✓`), Grid-Switcher (`8×8`–`24×24`), runden Icon-Buttons (`☀️`, `📐`, `🎥`, `🔊`, `🔗`, `🗑️`), grünem `📸 Foto`-Button sowie `ℹ️`/`⚙️` rechts.
- Schwebende rechte Sidebar mit abgerundeten Ecken (`20px`), 2-Spalten-Werkzeugraster (`👆 Auswählen`, `🖐️ Erkunden`, `🔨 Bauen`, `↻ Drehen (R)`, `🧨 Abreißen`, `↩`, `↪`), 5 Kategorie-Pills und 2-Spalten-Katalogkarten.
- Schwebendes `🧺 ERNTEKORB`-Widget unten links.
- 5-Slots-Snapshot-Modal (`🔗`) und 3-Optionen-Reset-Dialog (`🗑️`).
