set_volume! 1
set :takt, 0
set_sched_ahead_time! 1
use_bpm 138
use_random_seed 5
define :pfad do |name|
  "/Users/hansradtke/Library/Mobile Documents/com~apple~CloudDocs/SonicPi-Repository/SonicPi-Repository/R03_Hymnus_Noctis/" + name + ".wav"
end
puts "PFAD-TEST: " + pfad("effect_craw").inspect
optionale = ["effect_craw", "effect_rain", "effect_graveyard_bell",
             "effect_ghosts_whispering",
             "vocal_media_vita", "vocal_pallida_mors",
             "vocal_hymnus_1", "vocal_hymnus_2",
             "vocal_hymnus_3", "vocal_hymnus_4"]
optionale.each do |n|
  if File.exist?(pfad(n))
    load_sample pfad(n)
  else
    puts "NOCH NICHT DA: " + n + ".wav (wird uebersprungen)"
  end
end
define :vox do |name, opts = {}|
  if File.exist?(pfad(name))
    puts "VOX SPIELT: " + name + " (Takt #{takt})"
    sample pfad(name), opts
  else
    puts "VOX FEHLT: " + name
  end
end
live_loop :puls do
  stop if takt >= schluss
  tick
  set :takt, look
  sleep 4
end
define :takt do
  get(:takt) || 0
end
define :schluss do 160 end
define :section do
  t = takt
  if t < 8 then :intro
  elsif t < 24 then :aufbau
  elsif t < 56 then :voll1
  elsif t < 72 then :atem
  elsif t < 104 then :voll2
  elsif t < 106 then :stille
  elsif t < 136 then :final
  else :outro
  end
end
define :voll? do [:voll1, :voll2, :final].include?(section) end
define :atem? do section == :atem end
define :stille? do section == :stille end
define :kick? do
  voll? || ((takt >= 16) && (takt < 24)) ||
    ((takt >= 136) && (takt < 144))
end
melodie = (ring :e4, :d4, :e4, :c4, :d4, :b3, :c4, :c4,
           :e4, :f4, :e4, :d4, :c4, :b3, :c4, :b3,
           :e4, :d4, :c4, :b3, :a3, :b3, :c4, :a3,
           :b3, :c4, :b3, :a3, :f3, :e3, :d3, :e3)
melodie_finale = (ring :e4, :d4, :e4, :c4, :d4, :b3, :c4, :c4,
                  :e4, :f4, :e4, :d4, :c4, :b3, :c4, :b3,
                  :e4, :d4, :c4, :b3, :a3, :b3, :c4, :a3,
                  :b3, :c4, :b3, :a3, :f3, :e3, :d4, :e4)
dauern  = (ring 1.5, 0.5, 1.0, 1.0, 0.5, 0.5, 1.0, 2.0)
live_loop :abblende, sync: :puls do
  stop if takt >= schluss
  if takt >= 148
    set_volume! [1.0 - 0.06 * (takt - 148), 0.35].max
  end
  sleep 4
end
with_fx :reverb, room: 0.85, mix: 0.5 do
  with_fx :echo, phase: 0.75, decay: 4, mix: 0.15 do
   with_fx :bitcrusher, bits: 8, sample_rate: 11000, mix: 0.3 do
    live_loop :hook, sync: :puls do
      stop if takt >= schluss
      s = section
      if [:voll2, :final].include?(s)
        mel = (s == :final ? melodie_finale : melodie)
        mel.length.times do |i|
          use_synth :blade
          play mel[i], attack: 0.1, release: dauern[i] * 1.2,
            cutoff: (s == :final ? 80 : 72), amp: 0.5
          if s == :final
            play note(mel[i]) + 12, release: dauern[i],
              cutoff: 95, amp: 0.14
          end
          use_synth :dsaw
          play note(mel[i]) - 12, release: dauern[i] * 1.1,
            cutoff: 60, detune: 0.4, amp: 0.28
          sleep dauern[i]
        end
      elsif s == :voll1
        8.times do |i|
          use_synth :dark_ambience
          play melodie[i], attack: 0.1, release: dauern[i] * 1.2,
            cutoff: 72, amp: 0.5
          use_synth :dsaw
          play note(melodie[i]) - 12, release: dauern[i] * 1.1,
            cutoff: 60, detune: 0.4, amp: 0.28
          sleep dauern[i]
        end
        sleep 24
      elsif [:intro, :aufbau, :atem].include?(s)
        3.times do |i|
          use_synth :dark_ambience
          play melodie[i], attack: 0.3, release: dauern[i] * 3,
            cutoff: 100, amp: 0.7
          sleep dauern[i]
        end
        sleep 30
      else
        sleep 4
      end
    end
   end
  end
end
with_fx :reverb, room: 0.7, mix: 0.35 do
  live_loop :akkorde, sync: :puls do
    stop if takt >= schluss
    if takt == 106
      use_synth :prophet
      play (chord :e2, :minor7), attack: 0.05, sustain: 2,
        release: 2, cutoff: 75, amp: 0.6
      sleep 4
    elsif voll? && ((takt % 16) < 14) &&
          (((takt >= 32) && (takt < 56)) || (takt >= 72))
      use_synth :prophet
      akk = if section == :voll1
        ((takt % 4) < 2) ? (chord :e3, :minor7) : (chord :f3, :major7)
      else
        pos = (section == :final ? takt - 106 : takt - 72)
        (ring (chord :e3, :minor7), (chord :f3, :major7),
         (chord :a2, :minor7),
         [:b2, :d3, :f3, :a3])[(pos / 2) % 4]
      end
      sleep 1.5
      play akk, release: 0.5, cutoff: 70, amp: 0.45
      sleep 2.0
      play akk, release: 0.4, cutoff: 65, amp: 0.35
      sleep 0.5
    else
      sleep 4
    end
  end
end
with_fx :distortion, distort: 0.25, mix: 0.7 do
 live_loop :bass, sync: :puls do
  stop if takt >= schluss
  s = section
  if s == :atem
    if takt < 64
      sleep 4
    else
      8.times do
        use_synth :fm
        play :e1, divisor: 1, depth: 1.0, release: 0.35,
          cutoff: 55, amp: 0.4
        use_synth :bass_foundation
        play :e1, release: 0.35, amp: 0.5
        sleep 0.5
      end
    end
  elsif (takt >= 8) && (takt < 152) && !stille?
    grund = case s
    when :aufbau then 62 + (takt - 8) * 0.5
    when :voll1  then 72 + (takt % 8)
    when :voll2  then 74 + (takt % 8)
    when :final  then 78 + (takt % 8)
    else 65
    end
    root = if [:voll2, :final].include?(s)
      pos = (s == :final ? takt - 106 : takt - 72)
      (ring :e1, :f1, :a1, :b1)[(pos / 2) % 4]
    else
      :e1
    end
    if voll? && ((takt % 8) >= 6)
      4.times do
        use_synth :fm
        play root, divisor: 1, depth: 1.2, release: 0.4,
          cutoff: [grund - 8, 78].min, amp: 0.65
        use_synth :bass_foundation
        play root, release: 0.4, amp: 0.4
        sleep 1
      end
    else
      muster = [[nil, 0.5], [0, 0.5], [nil, 0.25], [0, 0.25], [0, 0.5],
                [nil, 0.5], [7, 0.25], [12, 0.25], [0, 0.5], [nil, 0.5]]
      muster.each do |o, d|
        if o
          use_synth :fm
          play note(root) + o, divisor: 1, depth: 1.2,
            release: d * 0.9, cutoff: [grund, 90].min, amp: 0.9
          use_synth :bass_foundation
          play note(root) + o, release: d * 0.9, amp: 0.5
        end
        sleep d
      end
    end
  else
    sleep 4
  end
 end
end
live_loop :schlag, sync: :puls do
  stop if takt >= schluss
  if takt == 103
    sample :bd_tek, amp: 0.9, lpf: 85
    sleep 2
    sample :bd_tek, amp: 0.8, lpf: 80
    sleep 2
  elsif kick? && !stille?
    laut = (takt < 24 ? 0.7 : (takt >= 136 ? 0.8 : 1.05))
    4.times do
      sample :bd_tek, amp: laut, lpf: 90
      sleep 1
    end
  else
    sleep 4
  end
end
live_loop :offhat, sync: :puls do
  stop if takt >= schluss
  if voll? && !stille? && !((takt >= 102) && (takt < 106))
    4.times do
      sleep 0.5
      sample :drum_cymbal_closed, amp: 0.3, rate: 0.7,
        finish: 0.6, lpf: 85
      sleep 0.5
    end
  else
    sleep 4
  end
end
live_loop :shuffle, sync: :puls do
  stop if takt >= schluss
  if [:voll2, :final].include?(section) && ((takt % 16) >= 8) && !stille?
    16.times do |i|
      sample :drum_cymbal_closed, rate: 1.05, lpf: 95,
        amp: (i.even? ? 0.14 : 0.08)
      sleep (i.even? ? 0.27 : 0.23)
    end
  else
    sleep 4
  end
end
live_loop :uebergang, sync: :puls do
  stop if takt >= schluss
  if [55, 71, 135].include?(takt)
    8.times do |i|
      sample :perc_snap, amp: 0.12 + i * 0.05, rate: 0.85 + i * 0.04
      sleep 0.5
    end
  else
    sleep 4
  end
end
with_fx :reverb, room: 0.9, mix: 0.5 do
  live_loop :grabatem, sync: :puls do
    stop if takt >= schluss
    use_synth :dark_ambience
    lautstark = [:intro, :atem, :stille, :outro].include?(section)
    play :e2, attack: 4, sustain: 8, release: 4,
      amp: (lautstark ? 0.4 : 0.25)
    sleep 16
  end
end
with_fx :reverb, room: 0.9, mix: 0.5 do
  live_loop :stimme, sync: :puls do
    stop if takt >= schluss
    case takt
    when 1
      vox "effect_rain", amp: 0.3, attack: 2
      vox "effect_graveyard_bell", rate: 0.9, amp: 0.5, lpf: 90
    when 4
      vox "vocal_media_vita", rate: 0.8, amp: 0.7, lpf: 100
    when 6
      vox "effect_craw", rate: 0.8, amp: 0.45
    when 32
      vox "vocal_hymnus_1", rate: 0.7, amp: 0.7
    when 44
      vox "vocal_hymnus_2", rate: 0.7, amp: 0.7
    when 56
      vox "effect_graveyard_bell", rate: 0.9, amp: 0.5, lpf: 90
    when 58
      with_fx :pitch_shift, pitch: -4, mix: 0.5 do
        vox "vocal_pallida_mors", amp: 3, lpf: 100
      end
    when 68
      vox "effect_ghosts_whispering", rate: 0.9, amp: 0.6
    when 88
      vox "vocal_hymnus_3", rate: 0.7, amp: 0.7
    when 94
      vox "effect_ghosts_whispering", rate: 0.85, amp: 0.45, hpf: 70
    when 102
      vox "effect_graveyard_bell", rate: 0.8, amp: 0.6
    when 104
      vox "vocal_hymnus_4", rate: 0.7, amp: 0.7
    when 138
      vox "effect_craw", rate: 0.75, amp: 0.45
    when 140
      vox "effect_rain", amp: 0.3, attack: 2
    when 144
      vox "vocal_media_vita", rate: 0.7, amp: 0.7, hpf: 70
    when 148
      vox "effect_graveyard_bell", rate: 0.85, amp: 0.45, lpf: 85
    when 152
      vox "effect_ghosts_whispering", rate: 0.8, amp: 0.5
    end
    sleep 4
  end
end
live_loop :letzter_ton, sync: :puls do
  if takt >= schluss
    set_volume! 0.5
    sleep 1
    with_fx :reverb, room: 1, mix: 0.8 do
      vox "effect_graveyard_bell", rate: 0.75, amp: 0.9
      synth :sine, note: :e2, attack: 0.5, sustain: 3, release: 8, amp: 0.4
    end
    stop
  end
  sleep 4
end