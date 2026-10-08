class_name SettingsManager
extends Node

## Central manager for game settings (display modes, persistent preferences).
## Supports Windowed, Borderless Fullscreen, Exclusive Fullscreen, and Borderless Window.
## Automatically persists display settings to user://settings.cfg.

const SETTINGS_FILE: String = "user://settings.cfg"

enum DisplayMode {
	WINDOWED = 0,
	FULLSCREEN_BORDERLESS = 1,
	FULLSCREEN_EXCLUSIVE = 2,
	BORDERLESS_WINDOW = 3,
}

const DISPLAY_MODE_NAMES: Dictionary = {
	DisplayMode.WINDOWED: "Fenstermodus 🪟",
	DisplayMode.FULLSCREEN_BORDERLESS: "Randloses Vollbild 🖥️",
	DisplayMode.FULLSCREEN_EXCLUSIVE: "Exklusives Vollbild ⚡",
	DisplayMode.BORDERLESS_WINDOW: "Randloses Fenster 🔲",
}

static var _current_mode: int = DisplayMode.WINDOWED

## Returns the current DisplayMode enum value based on DisplayServer state.
static func get_display_mode() -> int:
	if OS.has_feature("mobile"):
		return DisplayMode.WINDOWED
	if DisplayServer.get_name() == "headless":
		return _current_mode
	var mode: int = DisplayServer.window_get_mode()
	var borderless: bool = DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS)
	if mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		return DisplayMode.FULLSCREEN_EXCLUSIVE
	elif mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		return DisplayMode.FULLSCREEN_BORDERLESS
	elif mode == DisplayServer.WINDOW_MODE_WINDOWED and borderless:
		return DisplayMode.BORDERLESS_WINDOW
	else:
		return DisplayMode.WINDOWED

## Applies the requested DisplayMode to DisplayServer and persists it.
static func set_display_mode(mode: int) -> void:
	_current_mode = mode
	if OS.has_feature("mobile"):
		return
	if DisplayServer.get_name() != "headless":
		match mode:
			DisplayMode.WINDOWED:
				DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayMode.FULLSCREEN_BORDERLESS:
				DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayMode.FULLSCREEN_EXCLUSIVE:
				DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			DisplayMode.BORDERLESS_WINDOW:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	save_setting("display", "mode", mode)

## Toggles between Windowed and Fullscreen (F11 / Alt+Enter).
static func toggle_fullscreen() -> int:
	if OS.has_feature("mobile"):
		return DisplayMode.WINDOWED
	var current: int = get_display_mode()
	var new_mode: int = DisplayMode.FULLSCREEN_BORDERLESS
	if current == DisplayMode.FULLSCREEN_BORDERLESS or current == DisplayMode.FULLSCREEN_EXCLUSIVE:
		new_mode = DisplayMode.WINDOWED
	set_display_mode(new_mode)
	return new_mode

## Saves a key-value setting to user://settings.cfg.
static func save_setting(section: String, key: String, value: Variant) -> void:
	var cfg = ConfigFile.new()
	cfg.load(SETTINGS_FILE)
	cfg.set_value(section, key, value)
	cfg.save(SETTINGS_FILE)

## Loads a key-value setting from user://settings.cfg with fallback default.
static func load_setting(section: String, key: String, default_val: Variant) -> Variant:
	var cfg = ConfigFile.new()
	if cfg.load(SETTINGS_FILE) != OK:
		return default_val
	return cfg.get_value(section, key, default_val)

## Applies persisted display settings on game launch.
static func apply_saved_settings() -> void:
	if not OS.has_feature("mobile"):
		var saved_mode = load_setting("display", "mode", DisplayMode.WINDOWED)
		set_display_mode(int(saved_mode))
