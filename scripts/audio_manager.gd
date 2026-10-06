class_name AudioManager
extends Node

## Central Audio Manager playing real CC0 sound assets via AudioStreamPlayer.
## Supports one-shot polyphonic playback, audio caching, and master bus muting.

static var _instance: AudioManager

const SOUND_PATHS: Dictionary = {
	"cat_meow": "res://assets/audio/cat_meow.ogg",
	"dog_bark": "res://assets/audio/dog_bark.ogg",
	"duck_quack": "res://assets/audio/duck_quack.ogg",
	"water_splash": "res://assets/audio/water_splash.ogg",
	"splash": "res://assets/audio/water_splash.ogg",
	"ui_pop": "res://assets/audio/ui_pop.ogg",
	"pop": "res://assets/audio/ui_pop.ogg",
	"click_wood": "res://assets/audio/click_wood.ogg",
	"knock": "res://assets/audio/click_wood.ogg",
	"click": "res://assets/audio/click_wood.ogg",
	"switch": "res://assets/audio/switch.ogg",
	"lamp_click": "res://assets/audio/switch.ogg",
	"demolish": "res://assets/audio/demolish.ogg",
	"remove": "res://assets/audio/demolish.ogg",
}

var _streams: Dictionary = {}

func _init() -> void:
	_instance = self

func _ready() -> void:
	_preload_sounds()

func _preload_sounds() -> void:
	for key in SOUND_PATHS:
		var path: String = SOUND_PATHS[key]
		if not _streams.has(path) and ResourceLoader.exists(path):
			_streams[path] = load(path)

static func play(sound_name: String) -> void:
	if _instance:
		_instance.play_sound(sound_name)

func play_sound(sound_name: String) -> void:
	var path: String = SOUND_PATHS.get(sound_name, "")
	if path.is_empty():
		return
	var stream: AudioStream = _streams.get(path, null)
	if not stream and ResourceLoader.exists(path):
		stream = load(path)
		_streams[path] = stream
	if stream:
		var player = AudioStreamPlayer.new()
		player.stream = stream
		player.bus = "Master"
		player.finished.connect(player.queue_free)
		add_child(player)
		player.play()

static func toggle_mute() -> bool:
	var bus_idx = AudioServer.get_bus_index("Master")
	var is_muted = AudioServer.is_bus_mute(bus_idx)
	AudioServer.set_bus_mute(bus_idx, not is_muted)
	return not is_muted

static func is_muted() -> bool:
	var bus_idx = AudioServer.get_bus_index("Master")
	return AudioServer.is_bus_mute(bus_idx)
