# Johann van Staal

Music composed and performed as code, using [Sonic Pi](https://sonic-pi.net).
These tracks explore what happens when funeral liturgy meets the dancefloor —
**Crypt House**: church bells, Latin prayers, rain and crows over house and
witch-house grooves.

Each track is a single, self-contained `.rb` file. It plays the entire
arrangement from bar 0 to the final bell and stops by itself.

## Tracks

- **`Inter_Arma.rb`** — dark trance, 138 BPM,
  176 bars, E minor. A track about dancing in the middle of a threatening
  world: Vegetius' war doctrine (*Si vis pacem, para bellum*) is drilled
  in three escalating commands, Cicero's *Silent leges inter arma* falls
  into the drop, Calgacus' "where they make a desert, they call it peace"
  owns the breakdown, answered by an air-raid siren, while the crowd
  keeps chanting *Inter arma nos saltamus*. Opens and closes with the
  breath of a fleeing soldier; the last word, almost inaudible, is
  *Cedant arma togae*.

## Requirements

- **Sonic Pi v4 or later** — free, available for macOS, Windows and Linux
  at [sonic-pi.net](https://sonic-pi.net). No other software is needed.
- The **sample files** (`*.wav`) from this repository, stored on your
  local machine.

## Setup

1. **Clone or download this repository** to your computer.

2. **Keep all `.wav` files together in one local folder.** The tracks load
   them from disk at startup.

   > ⚠️ If you store the folder in a cloud-synced location (iCloud Drive,
   > OneDrive, Dropbox), make sure the files are *actually downloaded* and
   > not just cloud placeholders. On macOS: right-click the folder →
   > *"Keep Downloaded"* / *"Immer auf diesem Mac behalten"*. A track that
   > hangs silently at startup is almost always a sample file that the
   > cloud has offloaded.

3. **Set your local path.** Near the top of each track file you will find:

   ```ruby
   define :fx_pfad do |name|
     "... insert local path name here ..." + name + ".wav"
   end
   ```

   Replace the placeholder with the absolute path to your sample folder.
   **The path must end with a trailing `/`**, because the file name is
   appended directly to it:

   ```ruby
   define :fx_pfad do |name|
     "/Users/yourname/Music/crypt-house/samples/" + name + ".wav"
   end
   ```

4. **Run the track as a file — do not paste it into a buffer.**
   Sonic Pi's editor silently truncates large pasted text, which results
   in a half-loaded track (or total silence). Instead, put a single line
   into an empty buffer and press *Run*:

   ```ruby
   run_file "/Users/yourname/Music/crypt-house/we06r_deephouse.rb"
   ```

   Press *Stop* to end playback at any time. Every track resets its own
   state (master volume, bar counter) at the top, so you can simply press
   *Run* again for a fresh playthrough.

## Samples

The track expects the following files, referenced by name.

```
effect_battlefield.wav       effect_airraid_siren.wav
effect_craw.wav              vocal_para_bellum.wav
vocal_para_bellum_1.wav      vocal_para_bellum_2.wav
vocal_para_bellum_3.wav      vocal_raptores.wav
vocal_silent_leges.wav       vocal_vae_victis.wav
vocal_inter_arma_puls.wav    vocal_cedant_arma.wav
```

Voice recordings by Johann van Staal. Ambience samples (rain, crows,
battlefield noises) from free sample libraries; see their respective sources
for license details.

## The Latin texts

All spoken samples are transcribed in this repository, with translations
and sources:

- **`inter_arma_texte.txt`** — all spoken texts of *Inter Arma*, with
  translations and sources: Vegetius' *"qui desiderat pacem, praeparet
  bellum"* (*Epitoma rei militaris* III, the original behind "Si vis
  pacem, para bellum"), Cicero's *"Silent enim leges inter arma"*
  (*Pro Milone*), the Calgacus speech from Tacitus' *Agricola* 30,
  Livy's *"Vae victis"*, Cicero's *"Cedant arma togae"* (*De officiis*),
  and the original chant *Inter arma nos saltamus* by Johann van Staal.
  Unlike the liturgical tracks, these recordings use classical (not
  ecclesiastical) Latin pronunciation.

## How the tracks work

All tracks share the same architecture: a master clock (`live_loop :puls`)
counts bars into a shared counter, and every other loop reads that counter
to decide what to play — sections, breakdowns, fades and one-shot events
are all functions of the bar number. Fixed vocal moments live in a single
`case takt` block; ambience levels (e.g. rain) follow explicit level
curves. Because everything derives from the clock, individual loops can be
edited and re-evaluated live without losing their place in the arrangement.

## Troubleshooting

- **Total silence, clock ticking in the log** — a sample failed to load or
  is being fetched from the cloud. Check the log for errors and see the
  iCloud note above.
- **Sound cuts out mid-track with a "Timing Exception"** — your machine is
  under load. The tracks already use shared FX instances and an increased
  `set_sched_ahead_time!`; closing other applications usually resolves it.
- **You re-exported a sample but hear the old version** — Sonic Pi caches
  samples in memory. Run `sample_free_all` once in an empty buffer, then
  restart the track.
