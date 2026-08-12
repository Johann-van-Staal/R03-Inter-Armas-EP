# Johann van Staal

Music composed and performed as code, using [Sonic Pi](https://sonic-pi.net).
These tracks explore what happens when the old world's dead languages meet
the dancefloor — **Crypt House**: Latin voices, bells, crows, rain and
sirens over trance, house and witch-house grooves.

Each track is a single, self-contained `.rb` file. It plays the entire
arrangement from bar 0 to the final bell and stops by itself.

This repository contains **Release R03** — three tracks that form one
arc: defiance, resurrection, acceptance.

## Tracks

- **`Inter_Arma.rb` — "Inter Arma"** — dark trance, 138 BPM, 176 bars,
  E minor. Dancing in the middle of a threatening world: Vegetius' war
  doctrine (*Si vis pacem, para bellum*) is drilled in three escalating
  commands, Cicero's *Silent leges inter arma* falls into the drop, and
  Calgacus' "where they make a desert, they call it peace" owns the
  breakdown. At its end the crowd banishes the god of war himself —
  *Vade retro, deus belli: nox nostra est, non tua* — and is answered by
  an air-raid siren, while the chant *Inter arma nos saltamus* keeps
  returning. Opens and closes with the breath of a fleeing soldier; the
  last word, almost inaudible, is *Cedant arma togae*.

- **`Pulvis_et_Umbra_Resurgemus_Mix.rb` — "Pulvis et Umbra (Resurgemus
  Mix)"** — deep house, 124 BPM, 128 bars, E minor. A remix that takes
  its own title literally: the Requiem opens over rain and crows, muted
  piano chords and a two-layer bass carry the groove, and a Gregorian
  breakdown recites Horace's *"pulvis et umbra sumus"* — we are dust and
  shadow. At bar 96 the floor is cut away: two bars of sudden rain and a
  single crow — and when the beat slams back, the bell theme of the
  original track rises over the groove for the first time. *Resurgemus* —
  "we shall rise again" — performed by the arrangement itself.

- **`Hymnus_Noctis.rb` — "Hymnus Noctis"** — gothic dance, 138 BPM,
  160 bars, E minor/Phrygian. A celebration of mortality: the hook is
  built from the *Dies irae*, the medieval sequence of the dead, revealed
  in stages — three ghostly notes in the intro, one phrase in the verses,
  the full hymn only after the breakdown. Over it, a graveyard bell, rain,
  crows, whispering ghosts and six recorded voices: the *Media vita*
  antiphon, Horace's *Pallida Mors*, and the four stanzas of an original
  Latin hymn, chanted on a single note. At bar 104 everything stops; the
  fourth stanza speaks into the silence — *ergo noctem celebramus*, "so
  we celebrate the night" — and the finale answers with the only
  on-the-beat chord of the whole piece.

## Requirements

- **Sonic Pi v4 or later** — free, available for macOS, Windows and Linux
  at [sonic-pi.net](https://sonic-pi.net). No other software is needed.
- The **sample files** (`*.wav`) from this repository, stored on your
  local machine, one folder per track.

## Setup

1. **Clone or download this repository** to your computer.

2. **Keep each track's `.wav` files together in one local folder.**
   The tracks load them from disk at startup. *Inter Arma* and the
   *Resurgemus Mix* stop with a clear `FEHLT:` log message if a file is
   missing; *Hymnus Noctis* loads tolerantly and simply skips missing
   voices (logged as `NOCH NICHT DA`).

   > ⚠️ If you store the folders in a cloud-synced location (iCloud
   > Drive, OneDrive, Dropbox), make sure the files are *actually
   > downloaded* and not just cloud placeholders. On macOS: right-click
   > the folder → *"Keep Downloaded"* / *"Immer auf diesem Mac
   > behalten"*. A track that hangs silently at startup is almost always
   > a sample file that the cloud has offloaded.

3. **Set your local path.** Near the top of each track file you will find
   a path definition such as:

   ```ruby
   define :pfad do |name|
     "... insert local path name here ..." + name + ".wav"
   end
   ```

   Replace the placeholder with the absolute path to that track's sample
   folder, **written as a single line** and **ending with a trailing
   `/`**, because the file name is appended directly to it:

   ```ruby
   define :pfad do |name|
     "/Users/yourname/Music/crypt-house/R03_Hymnus_Noctis/" + name + ".wav"
   end
   ```

   On startup the log prints a `PFAD-TEST:` line with the full path the
   track has built — if loading fails, compare that line character by
   character with the real location of your folder.

4. **Run each track as a file — do not paste it into a buffer.**
   Sonic Pi's editor is limited to roughly 10,000 characters per buffer:
   pasted text beyond that is silently truncated, and editing stops
   working once the limit is reached. These tracks are all at or beyond
   that size. Instead, put a single line into an empty buffer and press
   *Run*:

   ```ruby
   run_file "/Users/yourname/Music/crypt-house/Hymnus_Noctis.rb"
   ```

   Press *Stop* to end playback at any time. Every track resets its own
   state (master volume, bar counter) at the top, so you can simply press
   *Run* again for a fresh playthrough.

## Samples

**For `Inter_Arma.rb`:**

```
effect_battlefield.wav       effect_airraid_siren.wav
effect_craw.wav              vocal_para_bellum.wav
vocal_para_bellum_1.wav      vocal_para_bellum_2.wav
vocal_para_bellum_3.wav      vocal_raptores.wav
vocal_silent_leges.wav       vocal_vae_victis.wav
vocal_inter_arma_puls.wav    vocal_cedant_arma.wav
vocal_nox_nostra.wav
```

**For `Pulvis_et_Umbra_Resurgemus_Mix.rb`:**

```
effect_gregorian_chant.wav   effect_rain.wav
effect_craw.wav              requiem_aeternam.wav
pulvis_et_umbra.wav          lux_perpetua.wav
resurgemus.wav               amen.wav
the_mourning_is_over.wav     welcome_home.wav
```

**For `Hymnus_Noctis.rb`:**

```
effect_craw.wav              effect_rain.wav
effect_graveyard_bell.wav    effect_ghosts_whispering.wav
vocal_media_vita.wav         vocal_pallida_mors.wav
vocal_hymnus_1.wav           vocal_hymnus_2.wav
vocal_hymnus_3.wav           vocal_hymnus_4.wav
```

Voice recordings by Johann van Staal. Ambience samples (rain, crows,
bells, ghosts, battlefield, sirens, Gregorian chant) from free sample
libraries; see their respective sources for license details.

## The Latin texts

All spoken samples are transcribed in this repository, with translations
and sources:

- **`inter_arma_texte.txt`** — all spoken texts of *Inter Arma*:
  Vegetius (*Epitoma rei militaris* III, the original behind "Si vis
  pacem, para bellum"), Cicero's *Silent enim leges inter arma*
  (*Pro Milone*), the Calgacus speech from Tacitus' *Agricola* 30,
  Livy's *Vae victis*, Cicero's *Cedant arma togae* (*De officiis*),
  and two original texts by Johann van Staal: the chant *Inter arma nos
  saltamus* and the banishment formula *Nox nostra*, built from Cato's
  *Mars pater* prayer, Virgil's *procul este* and the *vade retro* of
  the St. Benedict medal. Classical (not ecclesiastical) pronunciation.
- **`requiem_aeternam.txt`** — the Introit of the Requiem Mass,
  traditional Latin liturgy, public domain. Its second line is the
  source of the hook sample `lux_perpetua.wav`.
- **`pulvis_et_umbra.txt`** — an abridged excerpt from Horace,
  *Odes* IV.7 (*"Diffugere nives"*), ending in *"pulvis et umbra
  sumus"* — "we are dust and shadow". Classical Latin, public domain.
- **`hymnus_noctis.txt`** — the four stanzas of the original hymn by
  Johann van Staal, written in the trochaic metre of the *Dies irae*:
  death knocks at every threshold; in the midst of life it is right to
  sing; the earth will have us all; so we celebrate the night that
  awaits us all.
- **`media_vita.txt`** — the medieval antiphon *Media vita in morte
  sumus* (8th/9th century, public domain), source of Luther's "Mitten
  wir im Leben sind".
- **`pallida_mors.txt`** — Horace, *Odes* I.4, verses 13–17: pale Death
  knocks with equal foot at the huts of the poor and the towers of
  kings. Classical Latin, public domain.

The hook melody of *Hymnus Noctis* quotes the opening phrase of the
*Dies irae* plainchant (public domain); its continuation phrases are
original, composed in the same modal style.

## How the tracks work

All tracks share the same architecture: a master clock (`live_loop
:puls`) counts bars into a shared counter, and every other loop reads
that counter to decide what to play — sections, breakdowns, fades, cuts
and one-shot events are all functions of the bar number, organised in a
central `section` definition. Fixed vocal moments live in a single
`case takt` block; ambience levels follow explicit level curves. Because
everything derives from the clock, individual loops can be edited and
re-evaluated live without losing their place in the arrangement.

## Troubleshooting

- **The run stops immediately with `FEHLT:` lines in the log** — the
  path definition does not point at your sample folder, or the folder
  name differs. Compare the `PFAD-TEST:` log line with the real path.
- **A voice is loaded but never plays** — check the log: *Hymnus
  Noctis* prints a `VOX SPIELT:` line for every vocal event. If the
  line appears but you hear nothing, Sonic Pi is probably serving an
  old cached version of the sample: run `sample_free_all` once in an
  empty buffer (or restart Sonic Pi), then start the track again.
- **Total silence, clock ticking in the log** — a sample is being
  fetched from the cloud. See the iCloud note above.
- **Sound cuts out mid-track with a "Timing Exception"** — your machine
  is under load. The tracks already use shared FX instances and an
  increased `set_sched_ahead_time!`; closing other applications usually
  resolves it.
- **The editor refuses to accept new lines** — you have hit the ~10,000
  character buffer limit. Edit the `.rb` files in an external editor and
  use `run_file` as described above.
