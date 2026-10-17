# Violet – privater Musikplayer für iOS

> Arbeitsname „Violet“. Name und Bundle-ID kannst du jederzeit ändern.

## Start-Prompt für Claude Code

Kopiere das in Claude Code, nachdem diese Datei im Repo liegt:

```
Lies PROJEKT.md komplett. Das ist die Spezifikation für meine iOS-App.
Ich arbeite auf Windows ohne Mac. Swift kann hier NICHT lokal kompiliert werden,
gebaut wird ausschließlich über GitHub Actions.
Arbeite die Phasen der Reihe nach ab und beginne mit Phase 1.
Nach jeder Phase: committen, pushen, mit `gh run watch` auf den Build warten und
bei Fehlern `gh run view --log-failed` lesen und fixen, bis der Build grün ist.
Erst dann sagst du mir Bescheid, und ich teste die IPA auf dem iPhone,
bevor du mit der nächsten Phase anfängst.
```

---

## 1. Kontext & Rahmenbedingungen

- Rein private App, kein App Store.
- Entwickler arbeitet auf **Windows ohne Mac**. Claude Code läuft auf Windows.
- **Kein lokaler Swift-Compiler.** Jede Änderung wird über GitHub Actions (macOS-Runner) gebaut. Compile-Fehler kommen nur aus den CI-Logs, deshalb:
  - In kleinen, compile-sicheren Schritten arbeiten.
  - Nur stabile, gut dokumentierte APIs verwenden, keine Beta-APIs.
  - Keine Fremd-Abhängigkeiten, außer es geht wirklich nicht anders.
- CI erzeugt eine **unsignierte .ipa**. Installation per **Sideloadly** mit **kostenloser Apple-ID** (Signatur läuft nach 7 Tagen ab).
- Kostenlose Apple-ID bedeutet: **kein iCloud, keine Push-Notifications**. Alles bleibt lokal auf dem Gerät.

## 2. Technik

- Swift, SwiftUI, **iOS 17+**
- Persistenz: **SwiftData**
- Audio: **AVAudioEngine** (für Effekte, Crossfade, Gapless)
- Projekt wird mit **XcodeGen** erzeugt (`project.yml`). Keine `.xcodeproj` von Hand pflegen oder einchecken.
- Bundle-ID: `com.deinname.violet` (Platzhalter)
- UI-Sprache: **Deutsch**

### Info.plist
- `UIBackgroundModes`: `audio`
- `UIFileSharingEnabled`: `YES` und `LSSupportsOpeningDocumentsInPlace`: `YES`. Damit erscheint der App-Ordner in der Dateien-App, und MP3s können direkt hineingezogen werden.
- `NSPhotoLibraryUsageDescription` ist nicht nötig, wenn `PhotosPicker` verwendet wird.

## 3. CI (GitHub Actions)

`.github/workflows/build.yml`:
- Trigger: `push` und `workflow_dispatch`
- `runs-on: macos-latest`
- Schritte:
  1. Checkout
  2. `brew install xcodegen`
  3. `xcodegen generate`
  4. `xcodebuild -project Violet.xcodeproj -scheme Violet -configuration Release -sdk iphoneos -derivedDataPath build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" build`
  5. `Payload/`-Ordner anlegen, `Violet.app` hineinkopieren, zu `Violet.ipa` zippen
  6. `actions/upload-artifact` mit `Violet.ipa`
- Build-Logs müssen bei Fehlern gut lesbar sein (z. B. `xcbeautify` oder `| tee`).

## 4. Design

- **Nur Dark Mode.** Layout orientiert sich an Spotify, aber mit eigenem Namen und ohne Spotify-Logos oder -Assets.
- Farben:
  - Hintergrund `#121212`
  - Flächen `#1E1E1E` und `#2A2A2A`
  - Text primär `#FFFFFF`, sekundär `#A7A7A7`
  - **Akzent Lila `#A970FF`** (Play-Buttons, aktive Chips, Häkchen, Fortschritt)
- Abgerundete Ecken, fette Überschriften, große Cover.
- **Tab-Leiste:** Start · Suche · Bibliothek · Erstellen
- **Mini-Player** über der Tab-Leiste: Cover, Titel/Künstler, Play/Pause, dünne Fortschrittslinie. Tippen öffnet Now Playing, Wischen nach links/rechts wechselt den Song.
- **Dynamische Farben:** Dominante Farbe des aktuellen Covers ermitteln und als Verlauf im Now-Playing-Hintergrund und im Playlist-Header verwenden. Mit Fallback auf Lila, wenn kein Cover vorhanden ist.

## 5. Datenmodell (SwiftData)

**Song**
- `id`, `fileName` (relativer Pfad in `Documents/Music`)
- `title`, `artist`, `album?`
- `coverData?` (`@Attribute(.externalStorage)`)
- `duration`, `dateAdded`, `playCount`, `lastPlayed?`
- `loudnessGain` (für den Lautstärke-Ausgleich)

**Playlist**
- `id`, `name`, `details?`, `coverData?`
- geordnete Songs (eigene Entity `PlaylistEntry` mit `position`, damit derselbe Song mehrfach vorkommen darf)
- `isPinned`, `dateCreated`, `lastPlayed?`

Künstler und Alben werden **aus den Song-Feldern abgeleitet** und sind keine eigenen Entities.

## 6. Import

- Die Metadaten werden **manuell eingegeben**. Die Tags in der MP3 werden nicht genutzt.
- Import über `.fileImporter`: mehrere Dateien gleichzeitig, Typen `.mp3` und `.audio`. Security-scoped Zugriff verwenden und nach `Documents/Music` **kopieren**.
- Beim App-Start `Documents/Music` scannen: Neue Dateien, die über die Dateien-App hineingelegt wurden, als „Neu, noch nicht bearbeitet“ markieren.
- Nach dem Import folgt ein **Bearbeiten-Sheet** mit Titel, Künstler, Album und Cover (`PhotosPicker`, quadratisch zuschneiden).
  - Den Titel aus dem Dateinamen vorbefüllen: Endung entfernen, `_` und `-` durch Leerzeichen ersetzen.
  - Mehrfachauswahl: Künstler, Album oder Cover für mehrere Songs gleichzeitig setzen.
- Die Dauer per `AVURLAsset` auslesen. Den Lautstärkewert (RMS/Peak) im Hintergrund analysieren und als `loudnessGain` speichern.
- Ein Song kann gelöscht werden. Dabei wird auch die Datei gelöscht, nach einer Rückfrage.

## 7. Screens

### Start
- Filter-Chips: Alle · Playlists · Künstler
- 2-spaltiges Raster mit bis zu 8 kompakten Kacheln (angepinnte und zuletzt gehörte Playlists), wie bei Spotify
- „Deine Playlists“: horizontal scrollende große Cover
- „Wieder reinhören“: zuletzt gespielte Songs und Playlists
- „Neu hinzugefügt“

### Suche
- Suchfeld oben. Ergebnisse in Abschnitten: Songs, Künstler, Alben, Playlists
- Letzte Suchanfragen speichern und löschbar machen

### Bibliothek
- Filter-Chips: Playlists · Künstler · Alben
- Sortierung: Zuletzt · Hinzugefügt · Alphabetisch
- Umschalter zwischen Liste und Raster
- Angepinnte Elemente oben (grünes Pin-Symbol, hier in Lila)
- Fester Eintrag „Alle Songs“ ganz oben

### Playlist-Detail
- Großes Cover: das eigene Cover, sonst eine **Collage aus 4 Song-Covern**
- Name, Songanzahl und Gesamtdauer (z. B. „3 Std. 23 Min.“)
- Buttons: Hinzufügen · Bearbeiten · Sortieren, dazu Shuffle-Toggle und großer lila Play-Button
- Bearbeiten: umbenennen, Beschreibung, Cover ändern, Songs per Drag & Drop umsortieren, Songs entfernen
- Song-Zeile mit „…“-Menü:
  - Als Nächstes spielen
  - Zur Warteschlange hinzufügen
  - Zu Playlist hinzufügen
  - Song bearbeiten
  - Aus Playlist entfernen
- Swipe-Aktionen: nach rechts „Zur Warteschlange“, nach links „Entfernen“
- Der aktuell spielende Song wird lila hervorgehoben

### Künstler- und Album-Ansicht
- Liste der zugehörigen Songs mit Play und Shuffle

### Erstellen
- Neue Playlist anlegen
- Songs importieren
- „Neu, noch nicht bearbeitet“ (Songs ohne Metadaten)

### Now Playing (Vollbild-Sheet)
- Oben: Pfeil nach unten, Name der Playlist, „…“-Menü
- Großes Cover; nach links oder rechts wischen wechselt den Song
- Titel und Künstler
- Scrubber mit verstrichener und verbleibender Zeit
- Shuffle · Zurück · Play/Pause · Weiter · Repeat (Aus / Alle / Eins)
- Untere Leiste: Sleep-Timer · Effekte (Slowed/EQ) · Warteschlange · Teilen-Menü (Song zu Playlist hinzufügen)
- Hintergrund als dynamischer Farbverlauf aus dem Cover
- Nach unten wischen schließt das Sheet

### Warteschlange
- Abschnitte: „Läuft gerade“ · „Als Nächstes“ (manuell hinzugefügt) · „Weiter aus: [Playlist]“
- Drag & Drop zum Umsortieren, Wischen zum Entfernen, „Warteschlange leeren“

## 8. Audio-Engine

Signalweg:
```
PlayerNode A ─┐
              ├─> MixerNode ─> AVAudioUnitTimePitch ─> AVAudioUnitEQ (10 Bänder) ─> AVAudioUnitReverb ─> mainMixer
PlayerNode B ─┘
```

- **AVAudioSession** `.playback`. Unterbrechungen behandeln (Anrufe). Bei einem Route-Wechsel (Kopfhörer bzw. Bluetooth getrennt) pausieren.
- **Sperrbildschirm & Kontrollzentrum:** `MPNowPlayingInfoCenter` (Titel, Künstler, Cover, Dauer, Position, Rate) und `MPRemoteCommandCenter` (Play, Pause, Weiter, Zurück, Scrubben). Die verstrichene Zeit muss die aktuelle Wiedergabegeschwindigkeit berücksichtigen.
- **Gapless:** Den nächsten Song vorab auf demselben PlayerNode schedulen.
- **Crossfade:** Slider von 0 bis 12 s (0 = aus). Mit zwei PlayerNodes, deren Lautstärke gegenläufig geblendet wird.
- **Slowed + Reverb / Speed:**
  - Geschwindigkeit 0,5× bis 1,5× über `AVAudioUnitTimePitch.rate`
  - Toggle „Tonhöhe mitziehen“ (Vinyl-Effekt): `pitch = 1200 * log2(rate)` Cent
  - Presets:
    - Normal
    - **Slowed + Reverb**: 0,85×, Tonhöhe mitgezogen, Hall „Large Hall“ mit etwa 35 % Wet
    - **Nightcore**: 1,25×, Tonhöhe mitgezogen
    - Eigene Einstellung
  - Die Einstellung gilt global und ist im Now Playing über ein kleines Badge sichtbar
- **Equalizer:** 10 Bänder (32 Hz bis 16 kHz, ±12 dB)
  - Presets: Flat, Bass-Boost, Höhen, Stimme, Eigene
  - Zusätzlich ein separater **Bass-Boost-Slider**
  - **Lautstärke-Ausgleich** an/aus, wendet `loudnessGain` pro Song an
- **Shuffle:** Erst wiederholen, wenn alle Songs einmal gespielt wurden.
- **Sleep-Timer:** 5, 10, 15, 30, 45 oder 60 Min. oder „Ende des Songs“. In den letzten 30 Sekunden langsam ausblenden. Restzeit im Now Playing anzeigen.
- **Zustand speichern:** Warteschlange, aktueller Song, Position und Effekte bleiben beim App-Neustart erhalten.
- `playCount` und `lastPlayed` hochzählen, wenn mehr als 50 % eines Songs gespielt wurden.

## 9. Phasen

Jede Phase endet mit einem **grünen CI-Build** und einer kurzen Liste, was ich auf dem iPhone testen soll.

1. **Gerüst:** `project.yml`, App-Struktur, Farben, Tab-Leiste mit leeren Screens, CI-Workflow. Ziel: Die IPA baut und startet.
2. **Import & Wiedergabe:** Import, Bearbeiten-Sheet, Liste „Alle Songs“, einfache Wiedergabe, Mini-Player, Hintergrund-Wiedergabe, Sperrbildschirm-Steuerung.
3. **Playlists & Navigation:** Playlists erstellen und bearbeiten, Cover und Collage, Bibliothek mit Filtern und Sortierung, Startseite, Suche, Künstler- und Album-Ansicht.
4. **Now Playing & Warteschlange:** Vollbild-Player, Scrubber, Shuffle/Repeat, Warteschlange, dynamische Farben, Zustand speichern.
5. **Audio-Effekte:** Slowed + Reverb, Speed, EQ und Bass-Boost, Lautstärke-Ausgleich, Gapless, Crossfade, Sleep-Timer mit Fade-out.

## 10. Nicht im Umfang

- Kein Streaming, keine Accounts, kein Download aus dem Internet
- Kein iCloud-Sync
- Keine Widgets, keine Live Activity / Dynamic Island, keine App Extensions (nur ein einziges App-Target)
- Keine Spotify-Logos, -Namen oder -Assets
