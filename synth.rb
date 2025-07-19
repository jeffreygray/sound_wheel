require 'gosu'

# Simple Synth class using Gosu
class SynthWindow < Gosu::Window
  NOTE_KEYS = {
    'A' => 'C',
    'S' => 'D',
    'D' => 'E',
    'F' => 'F',
    'G' => 'G',
    'H' => 'A',
    'J' => 'B',
    'K' => 'C'
  }
  CHROMATIC = %w[C C# D D# E F F# G G# A A# B]
  CHORDS = [
    {name: 'Imaj7', tones: %w[C E G B]},
    {name: 'iim7', tones: %w[D F A C]},
    {name: 'iiim7', tones: %w[E G B D]},
    {name: 'IVmaj7', tones: %w[F A C E]},
    {name: 'V7', tones: %w[G B D F]},
    {name: 'vim7', tones: %w[A C E G]},
    {name: 'viim7b5', tones: %w[B D F A]}
  ]

  def initialize
    super(600, 300)
    self.caption = "Ruby Synth - Chord & Chromatic Wheel"
    @sounds = {}
    NOTE_KEYS.each do |key, _|
      @sounds[key] = Gosu::Sample.new("sounds/#{key}.wav")
    end
    @pressed = {}
    @chord_pressed = nil
    @font = Gosu::Font.new(32)
    @small_font = Gosu::Font.new(18)
  end

  def draw
    Gosu.draw_rect(0, 0, width, height, Gosu::Color::BLACK, 0)

    # Draw left chord wheel
    draw_circle(width/4, height/2, 100, Gosu::Color::WHITE)
    draw_chord_wheel(width/4, height/2, 90)

    # Draw right chromatic wheel
    draw_circle(3*width/4, height/2, 100, Gosu::Color::WHITE)
    draw_chromatic_wheel(3*width/4, height/2, 90)
  end

  def draw_circle(cx, cy, r, color)
    segments = 64
    angle_step = 2*Math::PI/segments
    points = []
    segments.times do |i|
      angle = i*angle_step
      x = cx + Math.cos(angle)*r
      y = cy + Math.sin(angle)*r
      points << [x, y]
    end
    points.each_with_index do |(x1, y1), i|
      x2, y2 = points[(i+1)%segments]
      Gosu.draw_line(x1, y1, color, x2, y2, color, 2)
    end
  end

  def draw_chromatic_wheel(cx, cy, r)
    n = CHROMATIC.size
    CHROMATIC.each_with_index do |note, i|
      angle = (2*Math::PI*i/n) - Math::PI/2
      x = cx + Math.cos(angle)*r
      y = cy + Math.sin(angle)*r
      color = note_active?(note) ? Gosu::Color::YELLOW : Gosu::Color::GRAY
      Gosu.draw_circle(x, y, 18, color)
      @small_font.draw_text(note, x-10, y-10, 2, 1, 1, Gosu::Color::BLACK)
    end
    @font.draw_text("Chromatic Wheel", cx-80, cy-120, 2, 1, 1, Gosu::Color::WHITE)
  end

  def draw_chord_wheel(cx, cy, r)
    n = CHORDS.size
    CHORDS.each_with_index do |chord, i|
      angle = (2*Math::PI*i/n) - Math::PI/2
      x = cx + Math.cos(angle)*r
      y = cy + Math.sin(angle)*r
      color = chord_active?(i) ? Gosu::Color::CYAN : Gosu::Color::GRAY
      Gosu.draw_circle(x, y, 22, color)
      @small_font.draw_text(chord[:name], x-30, y-10, 2, 1, 1, Gosu::Color::BLACK)
    end
    @font.draw_text("Chord Wheel", cx-80, cy-120, 2, 1, 1, Gosu::Color::WHITE)
    # Highlight chord tones on wheel
    if @chord_pressed
      chord = CHORDS[@chord_pressed]
      chord[:tones].each do |note|
        i = CHROMATIC.index(note)
        next unless i
        angle = (2*Math::PI*i/CHROMATIC.size) - Math::PI/2
        x = cx + Math.cos(angle)*r*0.7
        y = cy + Math.sin(angle)*r*0.7
        Gosu.draw_circle(x, y, 12, Gosu::Color::YELLOW)
        @small_font.draw_text(note, x-8, y-8, 3, 1, 1, Gosu::Color::BLACK)
      end
    end
  end

  def note_active?(note)
    @pressed.keys.any? { |key| NOTE_KEYS[key] == note }
  end

  def chord_active?(idx)
    @chord_pressed == idx
  end

  def button_down(id)
    key = Gosu.button_id_to_char(id).upcase
    if @sounds.key?(key) && !@pressed[key]
      @sounds[key].play
      @pressed[key] = true
    end
    # Chord keys: '1'..'7'
    if ('1'..'7').include?(key)
      idx = key.to_i - 1
      play_chord(idx)
      @chord_pressed = idx
    end
  end

  def button_up(id)
    key = Gosu.button_id_to_char(id).upcase
    @pressed.delete(key)
    if ('1'..'7').include?(key)
      @chord_pressed = nil
    end
  end

  def play_chord(idx)
    chord = CHORDS[idx]
    return unless chord
    chord[:tones].each do |note|
      key = NOTE_KEYS.key(note)
      @sounds[key].play if key
    end
  end
end

# Helper to draw filled circles
module Gosu
  def self.draw_circle(cx, cy, r, color, z=1)
    segments = 32
    angle_step = 2*Math::PI/segments
    points = []
    segments.times do |i|
      angle = i*angle_step
      x = cx + Math.cos(angle)*r
      y = cy + Math.sin(angle)*r
      points << [x, y]
    end
    (0...segments).each do |i|
      x1, y1 = points[i]
      x2, y2 = points[(i+1)%segments]
      Gosu.draw_triangle(cx, cy, color, x1, y1, color, x2, y2, color, z)
    end
  end
end

SynthWindow.new.show