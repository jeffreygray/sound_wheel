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

  def initialize
    super(600, 300)
    self.caption = "Ruby Synth - Chromatic Wheel"
    @sounds = {}
    NOTE_KEYS.each do |key, _|
      @sounds[key] = Gosu::Sample.new("sounds/#{key}.wav")
    end
    @pressed = {}
    @font = Gosu::Font.new(32)
    @small_font = Gosu::Font.new(18)
  end

  def draw
    # Draw background
    Gosu.draw_rect(0, 0, width, height, Gosu::Color::BLACK, 0)

    # Draw left circle (placeholder)
    draw_circle(width/4, height/2, 80, Gosu::Color::GRAY)
    @font.draw_text("Left", width/4-30, height/2-20, 1, 1, 1, Gosu::Color::WHITE)

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

  def note_active?(note)
    # Map pressed keys to chromatic notes
    @pressed.keys.any? do |key|
      NOTE_KEYS[key] == note
    end
  end

  def button_down(id)
    key = Gosu.button_id_to_char(id).upcase
    if @sounds.key?(key) && !@pressed[key]
      @sounds[key].play
      @pressed[key] = true
    end
  end

  def button_up(id)
    key = Gosu.button_id_to_char(id).upcase
    @pressed.delete(key)
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