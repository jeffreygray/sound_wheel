# Generates simple sine wave .wav files for synth notes using Ruby and SoX
# Requires SoX installed: brew install sox

NOTES = {
  'A' => 261.63, # C4
  'S' => 293.66, # D4
  'D' => 329.63, # E4
  'F' => 349.23, # F4
  'G' => 392.00, # G4
  'H' => 440.00, # A4
  'J' => 493.88, # B4
  'K' => 523.25  # C5
}

NOTES.each do |key, freq|
  system("sox -n -r 44100 -b 16 -c 1 sounds/#{key}.wav synth 0.2 sine #{freq}")
end
puts "WAV files generated in sounds/ directory."
