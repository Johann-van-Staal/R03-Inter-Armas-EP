set_volume! 1
set :takt, 0
set_sched_ahead_time! 1
use_bpm 124
use_random_seed 7
live_loop :puls do
  stop if takt >= schluss
  tick
  set :takt, look
  sleep 4
end
define :takt do
  get(:takt) || 0
end
define :schluss do 128 end
define :section do
  t = takt
  if t < 8 then :intro
  elsif t < 16 then :groove_in
  elsif t < 64 then :voll1
  elsif t < 80 then :break
  elsif t < 112 then :voll2
  else :outro
  end
end
define :breakdown? do section == :break end
define :groove? do [:groove_in, :voll1, :voll2].include?(section) end
define :voll? do [:voll1, :voll2].include?(section) end
define :voll2? do section == :voll2 end
define :finale? do takt >= schluss - 8 end
define :fx_pfad do |name|
  "/Users/hansradtke/Library/Mobile Documents/com~apple~CloudDocs/SonicPi-Repository/SonicPi-Repository/R03_Pulvis_et_Umbra_(Remix)/" + name + ".wav"
end
puts "PFAD-TEST: " + fx_pfad("effect_rain").inspect
alle_samples = ["effect_gregorian_chant", "effect_rain", "effect_craw",
                "welcome_home", "the_mourning_is_over", "amen",
                "resurgemus", "lux_perpetua", "requiem_aeternam",
                "pulvis_et_umbra"]
fehlend = alle_samples.reject { |n| File.exist?(fx_pfad(n)) }
unless fehlend.empty?
  fehlend.each { |n| puts "FEHLT: " + fx_pfad(n) }
  raise "Es fehlen #{fehlend.length} Sample-Datei(en) - siehe Log"
end
alle_samples.each { |n| load_sample fx_pfad(n) }
puts "ALLE #{alle_samples.length} SAMPLES GELADEN"
["effect_gregorian_chant", "effect_rain", "effect_craw",
 "welcome_home", "the_mourning_is_over", "amen",
 "resurgemus", "lux_perpetua", "requiem_aeternam",
"pulvis_et_umbra"].each do |n|
  load_sample fx_pfad(n)
end
sample fx_pfad("requiem_aeternam"), rate: 0.8, amp: 0.7, lpf: 85
live_loop :abblende, sync: :puls do
  stop if takt >= schluss
  if finale?
    set_volume! [1.0 - 0.09 * (takt - (schluss - 8)), 0.35].max
  end
  sleep 4
end
live_loop :kick, sync: :puls do
  stop if takt >= schluss
  if !breakdown? && takt < 120
    4.times do
      sample :bd_haus, amp: (takt >= 112 ? 0.8 : 1.1), lpf: 90
      sleep 1
    end
  else
    sleep 4
  end
end
live_loop :offhat, sync: :puls do
  stop if takt >= schluss
  if groove?
    4.times do
      sleep 0.5
      sample :drum_cymbal_closed,
        amp: (voll2? ? 0.35 : 0.3),
        rate: 0.75, finish: (voll2? ? 0.7 : 0.6), lpf: 95
      sleep 0.5
    end
  else
    sleep 4
  end
end
live_loop :shuffle, sync: :puls do
  stop if takt >= schluss
  if voll? && ((takt % 16) >= 8)
    16.times do |i|
      sample :drum_cymbal_closed, rate: 1.1, lpf: 100,
        amp: (i.even? ? 0.16 : 0.09)
      sleep (i.even? ? 0.27 : 0.23)
    end
  else
    sleep 4
  end
end
live_loop :rim, sync: :puls do
  stop if takt >= schluss
  if voll?
    sleep 1
    sample :perc_snap, amp: 0.3, rate: 0.9
    sleep 2
    sample :perc_snap, amp: 0.3, rate: 0.9
    sleep 1
  else
    sleep 4
  end
end
live_loop :uebergang, sync: :puls do
  stop if takt >= schluss
  if [63, 79, 111].include?(takt)
    8.times do |i|
      sample :perc_snap, amp: 0.12 + i * 0.05,
        rate: 0.85 + i * 0.04
      sleep 0.5
    end
  else
    sleep 4
  end
end
live_loop :bass, sync: :puls do
  stop if takt >= schluss
  if groove?
    root = if voll2?
      (ring :e1, :e1, :f1, :g1)[takt / 4]
    else
      (ring :e1, :e1, :e1, :f1)[takt / 4]
    end
    basis = case section
    when :groove_in then 68
    when :voll1     then 75
    when :voll2     then 76 + (takt % 8)
    else 72
    end
    if voll? && ((takt % 8) >= 6)
      4.times do
        use_synth :fm
        play root, divisor: 1, depth: 1.2, release: 0.4,
          cutoff: [basis - 8, 80].min, amp: 0.9
        use_synth :bass_foundation
        play root, release: 0.4, amp: 0.8
        sleep 1
      end
    else
      muster = [[nil, 0.5], [0, 0.5], [nil, 0.25], [0, 0.25], [0, 0.5],
                [nil, 0.5], [3, 0.25], [5, 0.25], [0, 0.5], [nil, 0.5]]
      muster.each do |o, d|
        if o
          hoch = (voll2? && o == 0 && one_in(12) ? 12 : 0)
          use_synth :fm
          play note(root) + o + hoch, divisor: 1, depth: 1.2,
            release: d * 0.9, cutoff: [basis, 90].min, amp: 1.2
          use_synth :bass_foundation
          play note(root) + o + hoch, release: d * 0.9, amp: 0.9
        end
        sleep d
      end
    end
  else
    sleep 4
  end
end
with_fx :reverb, room: 0.7, mix: 0.35 do
  live_loop :akkorde, sync: :puls do
    stop if takt >= schluss
    if voll? && ((takt % 16) < 14) &&
        (((takt >= 24) && (takt < 64)) || (takt >= 88))
      use_synth :piano
      akk = if voll2?
        (ring (chord :e3, :minor7), (chord :f3, :major7),
         (chord :e3, :minor7), (chord :g3, :major7))[(takt / 2) % 4]
      else
        ((takt % 4) < 2) ? (chord :e3, :minor7) : (chord :f3, :major7)
      end
      sleep 1.5
      play akk, release: 0.5, hard: 0.4, amp: 0.55, lpf: 100
      sleep 2.0
      play akk, release: 0.4, hard: 0.3, amp: 0.45, lpf: 95
      sleep 0.5
    else
      sleep 4
    end
  end
end
with_fx :reverb, room: 0.9, mix: 0.6 do
  live_loop :pad, sync: :puls do
    stop if takt >= schluss
    if takt >= 16
      use_synth :hollow
      noten = if voll2? && ((takt % 8) >= 4)
        [:g3, :d4]
      elsif (takt % 8) < 4
        [:e3, :b3]
      else
        [:f3, :c4]
      end
      noten.each do |n|
        play n, attack: 2, sustain: 4, release: 2,
          cutoff: (breakdown? ? 95 : 85),
          amp: (breakdown? ? 0.8 : 0.45)
      end
      sleep 8
    else
      sleep 4
    end
  end
end
with_fx :hpf, cutoff: 90 do
  live_loop :chops, sync: :puls do
    stop if takt >= schluss
    if voll?
      8.times do |i|
        if i.odd? && one_in(3)
          anfang = rrand(0.1, 0.7)
          sample :ambi_choir, rate: [0.95, 1.05, 0.9].choose,
            start: anfang, finish: [anfang + rrand(0.04, 0.1), 1.0].min,
            amp: 0.45, pan: rrand(-0.4, 0.4)
        end
        sleep 0.5
      end
    else
      sleep 4
    end
  end
end
with_fx :echo, phase: 0.75, decay: 4, mix: 0.3 do
  live_loop :pings, sync: :puls do
    stop if takt >= schluss
    if ((takt >= 48) && (takt < 64)) || ((takt >= 96) && (takt < 112))
      sleep 1.5
      synth :dull_bell, note: :e5, release: 1.2, amp: 0.3
      sleep 2.0
      synth :dull_bell, note: ((takt % 2).zero? ? :f5 : :gs5),
        release: 1.2, amp: 0.25
      sleep 0.5
    else
      sleep 4
    end
  end
end
live_loop :zitat, sync: :puls do
  stop if takt >= schluss
  if takt == 68
    phrase = [[:e5, 1.5], [:f5, 0.5], [:e5, 2.0],
              [:b4, 1.5], [:c5, 0.5], [:b4, 2.0]]
    with_fx :reverb, room: 1, mix: 0.7 do
      with_fx :echo, phase: 1.0, decay: 8, mix: 0.3 do
        phrase.each do |n, d|
          synth :dull_bell, note: n, release: d * 2.5, amp: 0.35
          sleep d
        end
      end
    end
  else
    sleep 4
  end
end
live_loop :vox, sync: :puls do
  stop if takt >= schluss
  with_fx :reverb, room: 0.9, mix: 0.45 do
    case takt
    when 32, 88
      with_fx :echo, phase: 0.75, decay: 4, mix: 0.3 do
        sample fx_pfad("lux_perpetua"), rate: 0.75, amp: 1.0
        sample fx_pfad("lux_perpetua"), rate: 0.475, amp: 0.3
      end
    when 64
      sample fx_pfad("effect_gregorian_chant"), rate: 0.8,
        amp: 1.2, lpf: 95
    when 66
      sample fx_pfad("pulvis_et_umbra"), rate: 0.8, amp: 1.1
    when 76
      sample fx_pfad("amen"), rate: 0.75, amp: 0.9
    when 78
      sample fx_pfad("resurgemus"), rate: 0.8, amp: 1.0
    when 112
      sample fx_pfad("the_mourning_is_over"), rate: 0.6, amp: 1.1
    when 116
      sample fx_pfad("welcome_home"), rate: 0.6, amp: 0.7
    end
  end
  sleep 4
end
define :regenpegel do
  t = takt
  if t < 12
    0.35
  elsif t < 16
    0.35 * (16 - t) / 4.0
  elsif (t >= 60) && (t < 64)
    0.3 * (t - 60) / 4.0
  elsif (t >= 64) && (t < 76)
    0.3
  elsif (t >= 76) && (t < 80)
    0.3 * (80 - t) / 4.0
  elsif (t >= 112) && (t < 116)
    0.35 * (t - 112) / 4.0
  elsif t >= 116
    0.35
  else
    0
  end
end
live_loop :regen, sync: :puls do
  stop if takt >= schluss
  pegel = regenpegel
  if (takt % 2).zero? && pegel > 0.01
    sample fx_pfad("effect_rain"), amp: pegel, attack: 2
  end
  if (takt < 16 || takt >= 112) && ((takt % 2) == 1) && one_in(3)
    sample fx_pfad("effect_craw"), rate: [0.9, 0.7].choose, amp: 0.4
  end
  sleep 4
end
live_loop :sog, sync: :puls do
  stop if takt >= schluss
  if takt == 76
    n = synth :noise, sustain: 15, release: 1,
      amp: 0.04, amp_slide: 15, cutoff: 60, cutoff_slide: 15
    control n, cutoff: 120, amp: 0.45
    sleep 16
  else
    sleep 4
  end
end
live_loop :portal, sync: :puls do
  stop if takt >= schluss
  if takt < 8 || takt >= 112
    sample :ambi_haunted_hum, rate: 0.6, attack: 1, amp: 0.4
  end
  sleep 8
end
live_loop :letzter_ton, sync: :puls do
  if takt >= schluss
    set_volume! 0.5
    sleep 1
    with_fx :reverb, room: 1, mix: 0.8 do
      synth :dull_bell, note: :e5, release: 8, amp: 0.6
      synth :sine, note: :e2, attack: 0.5, sustain: 2,
        release: 8, amp: 0.4
    end
    stop
  end
  sleep 4
end