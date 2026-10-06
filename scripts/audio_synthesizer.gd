class_name AudioSynthesizer
extends Node

## Procedural Audio Synthesizer in pure GDScript (matching Web Audio API in audio.js).
## Generates clean AudioStreamWAV sounds in memory with zero external asset dependencies.

static var _instance: AudioSynthesizer
var _player: AudioStreamPlayer

var _sound_cache: Dictionary = {}

func _init() -> void:
	_instance = self

func _enter_tree() -> void:
	_player = AudioStreamPlayer.new()
	_player.name = "SynthPlayer"
	add_child(_player)

static func play(sound_name: String) -> void:
	if _instance:
		_instance.play_sound(sound_name)

func play_sound(sound_name: String) -> void:
	var stream: AudioStreamWAV = _sound_cache.get(sound_name, null)
	if not stream:
		stream = _generate_sound(sound_name)
		if stream:
			_sound_cache[sound_name] = stream
	
	if stream:
		# Use one-shot polyphonic playback
		var p = AudioStreamPlayer.new()
		p.stream = stream
		p.finished.connect(p.queue_free)
		add_child(p)
		p.play()

func _generate_sound(sound_name: String) -> AudioStreamWAV:
	match sound_name:
		"cat_meow":
			return _synth_meow()
		"lamp_click":
			return _synth_click()
		"knock":
			return _synth_knock()
		"pop":
			return _synth_pop()
		"demolish":
			return _synth_demolish()
		_:
			return _synth_click()

func _synth_meow() -> AudioStreamWAV:
	var sample_rate: int = 22050
	var duration: float = 0.35
	var num_samples: int = int(sample_rate * duration)
	var data: PackedByteArray = PackedByteArray()
	data.resize(num_samples)
	
	var phase: float = 0.0
	for i in range(num_samples):
		var t: float = float(i) / float(sample_rate)
		# Meow formant pitch glide: 450 -> 820 -> 520 Hz
		var freq: float = 450.0 + 370.0 * sin(PI * (t / duration))
		phase += 2.0 * PI * freq / float(sample_rate)
		
		# Envelope
		var env: float = 1.0
		if t < 0.04:
			env = t / 0.04
		else:
			env = 1.0 - (t - 0.04) / (duration - 0.04)
		
		# Mixed sine + triangle harmonics for vocal cat meow
		var sample_f: float = (0.7 * sin(phase) + 0.3 * (2.0 * abs(fmod(phase / PI, 2.0) - 1.0) - 1.0)) * env * 0.4
		var sample_i: int = int(clamp(sample_f * 127.0 + 128.0, 0.0, 255.0))
		data[i] = sample_i
	
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	return wav

func _synth_click() -> AudioStreamWAV:
	var sample_rate: int = 22050
	var duration: float = 0.05
	var num_samples: int = int(sample_rate * duration)
	var data: PackedByteArray = PackedByteArray()
	data.resize(num_samples)
	
	var phase: float = 0.0
	for i in range(num_samples):
		var t: float = float(i) / float(sample_rate)
		var freq: float = 1100.0 - 500.0 * (t / duration)
		phase += 2.0 * PI * freq / float(sample_rate)
		var env: float = exp(-t * 60.0)
		var sample_f: float = sin(phase) * env * 0.3
		data[i] = int(clamp(sample_f * 127.0 + 128.0, 0.0, 255.0))
	
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	return wav

func _synth_knock() -> AudioStreamWAV:
	var sample_rate: int = 22050
	var duration: float = 0.12
	var num_samples: int = int(sample_rate * duration)
	var data: PackedByteArray = PackedByteArray()
	data.resize(num_samples)
	
	var phase: float = 0.0
	for i in range(num_samples):
		var t: float = float(i) / float(sample_rate)
		var freq: float = 240.0 - 120.0 * (t / duration)
		phase += 2.0 * PI * freq / float(sample_rate)
		var env: float = exp(-t * 30.0)
		var sample_f: float = sin(phase) * env * 0.4
		data[i] = int(clamp(sample_f * 127.0 + 128.0, 0.0, 255.0))
	
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	return wav

func _synth_pop() -> AudioStreamWAV:
	var sample_rate: int = 22050
	var duration: float = 0.08
	var num_samples: int = int(sample_rate * duration)
	var data: PackedByteArray = PackedByteArray()
	data.resize(num_samples)
	
	var phase: float = 0.0
	for i in range(num_samples):
		var t: float = float(i) / float(sample_rate)
		var freq: float = 460.0 * exp(-t * 18.0)
		phase += 2.0 * PI * freq / float(sample_rate)
		var env: float = exp(-t * 22.0)
		var sample_f: float = sin(phase) * env * 0.35
		data[i] = int(clamp(sample_f * 127.0 + 128.0, 0.0, 255.0))
	
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	return wav

func _synth_demolish() -> AudioStreamWAV:
	var sample_rate: int = 22050
	var duration: float = 0.1
	var num_samples: int = int(sample_rate * duration)
	var data: PackedByteArray = PackedByteArray()
	data.resize(num_samples)
	
	for i in range(num_samples):
		var t: float = float(i) / float(sample_rate)
		var noise: float = (randf() * 2.0 - 1.0)
		var env: float = exp(-t * 25.0)
		var sample_f: float = noise * env * 0.35
		data[i] = int(clamp(sample_f * 127.0 + 128.0, 0.0, 255.0))
	
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	return wav
