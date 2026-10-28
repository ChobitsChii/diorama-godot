class_name AudioSynthesizer
extends RefCounted

## Procedural PCM AudioStreamWAV generator matching the Web Audio API synthesizer in Modulon `audio.js`.
## Generates crisp, low-latency retro/organic sound effects for harvesting, eating/feeding,
## doorbell chimes, rustling leaves, and all 12 creature vocalizations.

const MIX_RATE: int = 22050

static func generate_sound(sound_name: String) -> AudioStreamWAV:
	match sound_name:
		"harvest": return _synth_harvest()
		"eat_crunch": return _synth_eat_crunch()
		"doorbell": return _synth_doorbell()
		"leaf_rustle": return _synth_leaf_rustle()
		"squirrel_chirp": return _synth_squirrel_chirp()
		"axolotl_bubble": return _synth_axolotl_bubble()
		"pig_oink": return _synth_pig_oink()
		"parrot_squawk": return _synth_parrot_squawk()
		"horse_whinny": return _synth_horse_whinny()
		"elephant_trumpet": return _synth_elephant_trumpet()
		"lion_roar": return _synth_lion_roar()
		"tiger_purr": return _synth_tiger_purr()
		_: return null

static func _make_wav(samples: PackedFloat32Array) -> AudioStreamWAV:
	var pcm := PackedByteArray()
	pcm.resize(samples.size() * 2)
	for i in range(samples.size()):
		var v := int(clampf(samples[i], -1.0, 1.0) * 32767.0)
		pcm.encode_s16(i * 2, v)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = pcm
	return stream

static func _synth_harvest() -> AudioStreamWAV:
	var dur := 0.34
	var n := int(dur * MIX_RATE)
	var buf := PackedFloat32Array()
	buf.resize(n)
	var notes := [523.25, 659.25, 783.99, 1046.5]
	for i in range(n):
		var t := float(i) / float(MIX_RATE)
		var idx := clampi(int(t / 0.075), 0, 3)
		var local_t := t - float(idx) * 0.075
		var env := exp(-local_t * 18.0) * 0.45
		buf[i] = sin(TAU * notes[idx] * t) * env
	return _make_wav(buf)

static func _synth_eat_crunch() -> AudioStreamWAV:
	var dur := 0.46
	var n := int(dur * MIX_RATE)
	var buf := PackedFloat32Array()
	buf.resize(n)
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for i in range(n):
		var t := float(i) / float(MIX_RATE)
		var v := 0.0
		# 3 crispy crunches at 0.0, 0.11, 0.22 + happy chirp at 0.31
		for c_start in [0.0, 0.11, 0.22]:
			var cs: float = float(c_start)
			if t >= cs and t < cs + 0.08:
				var lt: float = t - cs
				v += rng.randf_range(-1.0, 1.0) * exp(-lt * 35.0) * 0.45
		if t >= 0.30:
			var lt := t - 0.30
			var freq := lerpf(540.0, 880.0, clampf(lt / 0.14, 0.0, 1.0))
			v += sin(TAU * freq * lt) * exp(-lt * 14.0) * 0.38
		buf[i] = v
	return _make_wav(buf)

static func _synth_doorbell() -> AudioStreamWAV:
	var dur := 0.55
	var n := int(dur * MIX_RATE)
	var buf := PackedFloat32Array()
	buf.resize(n)
	for i in range(n):
		var t := float(i) / float(MIX_RATE)
		var v := 0.0
		if t < 0.24:
			v += sin(TAU * 659.25 * t) * exp(-t * 9.0) * 0.42
		if t >= 0.20:
			var lt := t - 0.20
			v += sin(TAU * 523.25 * lt) * exp(-lt * 7.0) * 0.42
		buf[i] = v
	return _make_wav(buf)

static func _synth_leaf_rustle() -> AudioStreamWAV:
	var dur := 0.28
	var n := int(dur * MIX_RATE)
	var buf := PackedFloat32Array()
	buf.resize(n)
	var rng := RandomNumberGenerator.new()
	rng.seed = 101
	var prev := 0.0
	for i in range(n):
		var t := float(i) / float(MIX_RATE)
		var raw := rng.randf_range(-1.0, 1.0)
		prev = prev * 0.65 + raw * 0.35
		var env := sin((t / dur) * PI) * 0.38
		buf[i] = prev * env
	return _make_wav(buf)

static func _synth_squirrel_chirp() -> AudioStreamWAV:
	var dur := 0.30
	var n := int(dur * MIX_RATE)
	var buf := PackedFloat32Array()
	buf.resize(n)
	for i in range(n):
		var t := float(i) / float(MIX_RATE)
		var v := 0.0
		for start in [0.0, 0.09, 0.18]:
			var st_val: float = float(start)
			if t >= st_val and t < st_val + 0.075:
				var lt: float = t - st_val
				var f: float = lerpf(1500.0, 2400.0, lt / 0.075)
				v += sin(TAU * f * lt) * exp(-lt * 26.0) * 0.38
		buf[i] = v
	return _make_wav(buf)

static func _synth_axolotl_bubble() -> AudioStreamWAV:
	var dur := 0.32
	var n := int(dur * MIX_RATE)
	var buf := PackedFloat32Array()
	buf.resize(n)
	var freqs := [380.0, 520.0, 740.0]
	for i in range(n):
		var t := float(i) / float(MIX_RATE)
		var v := 0.0
		for b in range(3):
			var st: float = float(b) * 0.085
			if t >= st and t < st + 0.09:
				var lt: float = t - st
				var f: float = float(freqs[b]) + lt * 1800.0
				v += sin(TAU * f * lt) * exp(-lt * 24.0) * 0.42
		buf[i] = v
	return _make_wav(buf)

static func _synth_pig_oink() -> AudioStreamWAV:
	var dur := 0.34
	var n := int(dur * MIX_RATE)
	var buf := PackedFloat32Array()
	buf.resize(n)
	for i in range(n):
		var t := float(i) / float(MIX_RATE)
		var v := 0.0
		for st in [0.0, 0.16]:
			var st_val: float = float(st)
			if t >= st_val and t < st_val + 0.14:
				var lt: float = t - st_val
				var f: float = 145.0 + sin(lt * 45.0) * 28.0
				var saw := 2.0 * fmod(t * f, 1.0) - 1.0
				v += saw * exp(-lt * 14.0) * 0.35
		buf[i] = v
	return _make_wav(buf)

static func _synth_parrot_squawk() -> AudioStreamWAV:
	var dur := 0.30
	var n := int(dur * MIX_RATE)
	var buf := PackedFloat32Array()
	buf.resize(n)
	for i in range(n):
		var t := float(i) / float(MIX_RATE)
		var f := 850.0 + sin(t * 55.0) * 320.0
		var env := sin((t / dur) * PI) * 0.36
		buf[i] = (sin(TAU * f * t) * 0.7 + sin(TAU * f * 2.0 * t) * 0.3) * env
	return _make_wav(buf)

static func _synth_horse_whinny() -> AudioStreamWAV:
	var dur := 0.50
	var n := int(dur * MIX_RATE)
	var buf := PackedFloat32Array()
	buf.resize(n)
	for i in range(n):
		var t := float(i) / float(MIX_RATE)
		var base_f := lerpf(920.0, 420.0, t / dur) + sin(t * 42.0) * 65.0
		var env := exp(-t * 3.8) * 0.38
		buf[i] = sin(TAU * base_f * t) * env
	return _make_wav(buf)

static func _synth_elephant_trumpet() -> AudioStreamWAV:
	var dur := 0.55
	var n := int(dur * MIX_RATE)
	var buf := PackedFloat32Array()
	buf.resize(n)
	for i in range(n):
		var t := float(i) / float(MIX_RATE)
		var f := lerpf(280.0, 620.0, minf(1.0, t / 0.25))
		var brass := sin(TAU * f * t) * 0.55 + sin(TAU * f * 2.0 * t) * 0.3 + sin(TAU * f * 3.0 * t) * 0.15
		var env := sin((t / dur) * PI) * 0.42
		buf[i] = brass * env
	return _make_wav(buf)

static func _synth_lion_roar() -> AudioStreamWAV:
	var dur := 0.55
	var n := int(dur * MIX_RATE)
	var buf := PackedFloat32Array()
	buf.resize(n)
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	for i in range(n):
		var t := float(i) / float(MIX_RATE)
		var f := lerpf(135.0, 75.0, t / dur)
		var growl := sin(TAU * f * t) * 0.65 + rng.randf_range(-0.35, 0.35)
		var env := sin((t / dur) * PI) * 0.45
		buf[i] = growl * env
	return _make_wav(buf)

static func _synth_tiger_purr() -> AudioStreamWAV:
	var dur := 0.45
	var n := int(dur * MIX_RATE)
	var buf := PackedFloat32Array()
	buf.resize(n)
	for i in range(n):
		var t := float(i) / float(MIX_RATE)
		var f := 110.0 + sin(t * 32.0) * 18.0
		var env := sin((t / dur) * PI) * 0.40
		buf[i] = sin(TAU * f * t) * env
	return _make_wav(buf)
