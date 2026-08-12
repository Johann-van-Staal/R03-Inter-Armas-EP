set_volume! 1
set :takt, 0
set_sched_ahead_time! 1
use_bpm 138
use_random_seed 11
define :pfad do |name|
  "/Users/hansradtke/Library/Mobile Documents/com~apple~CloudDocs/" \
    "SonicPi-Repository/SonicPi-Repository/R03_Inter_Armas/" + name + ".wav"
end
define :fx_pfad do |name| pfad(name) end
define :vox_pfad do |name| pfad(name) end
alle_samples = ["effect_battlefield", "effect_airraid_siren", "effect_craw",
                "vocal_para_bellum", "vocal_para_bellum_1",
                "vocal_para_bellum_2", "vocal_para_bellum_3",
                "vocal_raptores", "vocal_silent_leges",
                "vocal_vae_victis", "vocal_inter_arma_puls",
                "vocal_cedant_arma", "vocal_nox_nostra"]
fehlend = alle_samples.reject { |n| File.exist?(pfad(n)) }
unless fehlend.empty?
  fehlend.each { |n| puts "FEHLT: " + pfad(n) }
  raise "Es fehlen #{fehlend.length} Sample-Datei(en) - siehe Log"
end
alle_samples.each { |n| load_sample pfad(n) }
puts "ALLE #{alle_samples.length} SAMPLES GELADEN"
sample pfad("effect_battlefield"), amp: 0.9
live_loop :puls do
  stop if takt >= schluss
  tick
  set :takt, look
  sleep 4
end
define :takt do
  get(:takt) || 0
end
define :schluss do 176 end
define :section do
  t = takt
  if t < 8 then :intro
  elsif t < 24 then :pulse
  elsif t < 48 then :build
  elsif t < 80 then :drop1
  elsif t < 104 then :break
  elsif t < 120 then :rebuild
  elsif t < 152 then :drop2
  elsif t < 160 then :final
  else :outro
  end
end
define :aufbau? do section == :build end
define :drop? do [:drop1, :drop2, :final].include?(section) end
define :breakdown? do section == :break end
define :rebuild? do section == :rebuild end
define :finale? do [:final, :outro].include?(section) end
define :kick? do
  [:build, :drop1, :drop2, :final].include?(section) ||
    ((takt >= 16) && (takt < 24)) || ((takt >= 112) && (takt < 120))
end
melodie_a = (ring :e4, :e5, :d5, :b4, :c5, :b4, :g4, :e4,
             :f4, :f5, :e5, :c5, :d5, :b4, :e4,
             :g4, :g5, :f5, :d5, :e5, :d5, :b4, :g4,
             :f4, :e5, :d5, :c5, :b4, :c5, :e4)
melodie_b = (ring :e4, :e5, :d5, :b4, :c5, :b4, :g4, :e4,
             :f4, :f5, :e5, :c5, :d5, :b4, :e4,
             :a4, :a5, :g5, :e5, :f5, :e5, :c5, :a4,
             :f4, :e5, :d5, :c5, :b4, :c5, :e4)
dauern  = (ring 0.25, 0.75, 0.5, 0.5, 0.75, 0.25, 0.5, 0.5,
           0.25, 0.75, 0.5, 0.5, 0.75, 0.25, 1.0,
           0.25, 0.75, 0.5, 0.5, 0.75, 0.25, 0.5, 0.5,
           0.5, 0.5, 0.5, 0.5, 0.75, 0.25, 1.0)
gegen_a = (ring :b3, :c4, :c4, :a3, :b3, :d4, :c4, :b3)
gegen_b = (ring :b3, :d4, :e4, :c4, :b3, :a3, :c4, :b3)
bass_roots = (ring :e2, :e2, :f2, :e2, :e2, :g2, :f2, :e2)
live_loop :abblende, sync: :puls do
  stop if takt >= schluss
  if takt >= 160
    set_volume! [1.0 - 0.05 * (takt - 160), 0.35].max
  end
  sleep 4
end
with_fx :reverb, room: 0.85, mix: 0.45 do
  with_fx :echo, phase: 0.75, decay: 4, mix: 0.2 do
    live_loop :riff, sync: :puls do
      stop if takt >= schluss
      if (takt >= 24) && (takt < 160)
        if breakdown? || aufbau? || rebuild?
          use_synth (breakdown? ? :dark_ambience : :prophet)
          8.times do |i|
            play melodie_a[i], release: dauern[i] * 0.9,
              cutoff: (breakdown? ? 70 : 78),
              amp: (breakdown? ? 0.8 : 0.45)
            sleep dauern[i]
          end
          sleep 12
        else
          mel = (takt >= 120 ? melodie_b : melodie_a)
          turn = (takt % 16 == 12)
          wende = (ring :e5, :d5, :c5, :b4, :g4, :f4, :e4)
          mel.length.times do |i|
            n = ((turn && i >= 23) ? wende[i - 23] : mel[i])
            syn = ((section == :drop1) && (i < 15) ? :prophet : :blade)
            basis = (syn == :prophet ? {cutoff: 82, amp: 0.5} : {cutoff: 88, amp: 0.6})
            rel = (i % 8 == 0 ? dauern[i] * 0.5 : dauern[i] * 0.9)
            acc = ([0, 8, 15, 23].include?(i) ? 1.15 : 1.0)
            oktav = (one_in(8) ? 12 : 0)
            use_synth syn
            play note(n) + oktav, release: rel, cutoff: basis[:cutoff],
              amp: basis[:amp] * acc
            if takt >= 120
              play note(n) + 12, release: dauern[i] * 0.6,
                cutoff: 100, amp: 0.15
            end
            use_synth :dsaw
            play note(n) - 12, release: dauern[i] * 0.9,
              cutoff: 65, detune: 0.4, amp: 0.22
            sleep dauern[i]
          end
        end
      else
        sleep 4
      end
    end
  end
end
with_fx :reverb, room: 0.9, mix: 0.6 do
  live_loop :oberstimme, sync: :puls do
    stop if takt >= schluss
    if drop?
      if takt.even?
        use_synth :sine
        ober = (ring :b4, :c5, :e5, :d5)
        play ober[(takt / 2) % 4], attack: 2, sustain: 4,
          release: 4, amp: 0.16
      end
      sleep 4
    else
      sleep 4
    end
  end
end
with_fx :reverb, room: 0.85, mix: 0.5 do
  live_loop :gegenstimme, sync: :puls do
    stop if takt >= schluss
    if (takt >= 32) && (takt < 160) && !breakdown?
      use_synth :blade
      noten = ([:drop2, :final].include?(section) ? gegen_b : gegen_a)
      noten.each do |n|
        play n, attack: (drop? ? 0.4 : 0.8), sustain: 1.0,
          release: 0.8, cutoff: 75, amp: (drop? ? 0.45 : 0.25)
        sleep 2
      end
    else
      sleep 4
    end
  end
end
live_loop :rollbass, sync: :puls do
  stop if takt >= schluss
  s = section
  if s == :break
    if takt < 88
      sleep 4
    else
      8.times do
        play :e2, release: 0.3, cutoff: [48 + (takt - 88), 60].min,
          res: 0.7, wave: 0, amp: 0.3
        sleep 0.5
      end
    end
  elsif (takt >= 8) && (takt < 168)
    grund = case s
            when :pulse   then 58
            when :build   then 58 + (takt - 24) * 0.5
            when :drop1   then 72 + (takt % 8)
            when :rebuild then 60 + (takt - 104)
            when :drop2   then 76 + (takt % 12)
            when :final   then 88 + (takt % 8)
            else 60
            end
    root = ([:drop2, :final].include?(s) ? bass_roots[takt % 8] : :e2)
    16.times do |i|
      play root, release: 0.12,
        cutoff: [grund + (i % 4) * 5, 125].min,
        res: 0.82, wave: 0, amp: (i % 4 == 2 ? 0.6 : 0.38)
      sleep 0.25
    end
  else
    sleep 4
  end
end
live_loop :schlag, sync: :puls do
  stop if takt >= schluss
  if kick?
    s = section
    laut = (takt < 24 ? 0.7 : (aufbau? ? 0.85 : 1.0))
    4.times do |i|
      sample :bd_tek, amp: 0.95 * laut, lpf: 95
      if [:drop2, :final].include?(s)
        sample :bd_haus, amp: 0.5, lpf: 80
      end
      if drop? && (i == 1 || i == 3)
        sample :sn_dolf, amp: 0.35, rate: 0.95, lpf: 100
      end
      sleep 1
    end
  else
    sleep 4
  end
end
live_loop :uebergang, sync: :puls do
  stop if takt >= schluss
  if [47, 79, 119, 151].include?(takt)
    8.times do |i|
      sample :sn_dolf, amp: 0.2 + i * 0.06, rate: 0.9 + i * 0.02, lpf: 105
      sleep 0.5
    end
  else
    sleep 4
  end
end
live_loop :hauch, sync: :puls do
  stop if takt >= schluss
  if (aufbau? || drop? || rebuild?) && (takt >= 28)
    if [:drop2, :final].include?(section)
      16.times do
        sample :drum_cymbal_closed, amp: 0.1, rate: 0.95, lpf: 95
        sleep 0.25
      end
    else
      4.times do
        sleep 0.5
        sample :drum_cymbal_closed, amp: 0.15, rate: 0.9, lpf: 95
        sleep 0.5
      end
    end
  else
    sleep 4
  end
end
with_fx :reverb, room: 0.9, mix: 0.5 do
  live_loop :drone, sync: :puls do
    stop if takt >= schluss
    use_synth :dark_ambience
    play :e2, attack: 4, sustain: 8, release: 4,
      amp: ((breakdown? || finale? || takt < 16) ? 0.4 : 0.25)
    sleep 16
  end
end
with_fx :reverb, room: 0.9, mix: 0.5 do
  live_loop :stimme, sync: :puls do
    stop if takt >= schluss
    case takt
    when 2
      sample fx_pfad("effect_craw"), rate: 0.8, amp: 0.5
    when 6
      sample vox_pfad("vocal_para_bellum_1"), rate: 0.8, amp: 0.9, lpf: 110
    when 26
      sample vox_pfad("vocal_para_bellum_2"), rate: 0.8, amp: 0.9, lpf: 110
    when 44
      sample vox_pfad("vocal_para_bellum_3"), rate: 0.8, amp: 0.9, lpf: 110
    when 47
      sample vox_pfad("vocal_silent_leges"), rate: 0.8, amp: 1.0
    when 68
      sample vox_pfad("vocal_inter_arma_puls"), rate: 0.8, amp: 0.9, hpf: 70
    when 82
      sample vox_pfad("vocal_raptores"), rate: 0.8, amp: 1.0, lpf: 100
    when 100
      sample vox_pfad("vocal_nox_nostra"), rate: 0.85, amp: 0.95, lpf: 105
    when 104
      sample fx_pfad("effect_airraid_siren"), rate: 1.0, amp: 0.55, lpf: 90
    when 118
      sample vox_pfad("vocal_vae_victis"), rate: 0.7, amp: 0.9, hpf: 60
    when 124
      sample vox_pfad("vocal_inter_arma_puls"), rate: 0.8, amp: 0.85, hpf: 70
    when 136
      sample vox_pfad("vocal_silent_leges"), rate: 0.8, amp: 0.9, hpf: 70
    when 140
      sample vox_pfad("vocal_inter_arma_puls"), rate: 0.8, amp: 0.85, hpf: 70
    when 156
      sample fx_pfad("effect_craw"), rate: 0.75, amp: 0.5
    when 160
      sample fx_pfad("effect_battlefield"), amp: 0.35, hpf: 50
    end
    sleep 4
  end
end
live_loop :letzter_ton, sync: :puls do
  if takt >= schluss
    set_volume! 0.6
    sleep 2
    with_fx :reverb, room: 1, mix: 0.8 do
      sample vox_pfad("vocal_cedant_arma"), rate: 0.9, amp: 1.0
      use_synth :sine
      play :e2, attack: 0.5, sustain: 4, release: 8, amp: 0.4
    end
    stop
  end
  sleep 4
end