require 'gosu'

# Simple Synth class using Gosu
class SynthWindow < Gosu::Window
  NOTE_KEYS = {
    'A' => 'C4',
    'S' => 'D4',
    'D' => 'E4',
    'F' => 'F4',
    'G' => 'G4',
    'H' => 'A4',
    'J' => 'B4',
    'K' => 'C5'
  }

  def initialize
    super(600, 200)
    self.caption = "Ruby Synth MVP - Type keys to play notes"
    @sounds = {}
    NOTE_KEYS.each do |key, _|
      @sounds[key] = Gosu::Sample.new("sounds/#{key}.wav")
    end
    @pressed = {}
    @font = Gosu::Font.new(32)
  end

  def draw
    @font.draw_text("Type A S D F G H J K to play notes", 20, 20, 0)
    @font.draw_text("Keys pressed: #{@pressed.keys.join(' ')}", 20, 60, 0)
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

SynthWindow.new.show