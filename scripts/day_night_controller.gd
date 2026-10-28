class_name DayNightController
extends Node

## Manages smooth transitions between Day and Night lighting modes,
## matching the exact Three.js scene.js lighting parameters.

signal mode_changed(is_night: bool)

@export var world_environment: WorldEnvironment
@export var sun_light: DirectionalLight3D
@export var fill_light: DirectionalLight3D
@export var transition_duration: float = 0.5

var is_night: bool = false
var _tween: Tween

func _ready() -> void:
	apply_mode_instant(is_night)

func toggle_mode() -> void:
	set_night_mode(not is_night)

func set_night_mode(night: bool, animate: bool = true) -> void:
	is_night = night
	if animate and is_inside_tree():
		_animate_to_mode(is_night)
	else:
		apply_mode_instant(is_night)
	mode_changed.emit(is_night)

func apply_mode_instant(night: bool) -> void:
	if not world_environment or not world_environment.environment:
		return
	var env := world_environment.environment
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	if night:
		env.background_color = Color("#0e1628")
		env.ambient_light_color = Color("#151d2f")
		env.ambient_light_energy = 0.08
		if sun_light:
			sun_light.light_color = Color("#60a5fa")
			sun_light.light_energy = 0.10
		if fill_light:
			fill_light.light_color = Color("#1e3a8a")
			fill_light.light_energy = 0.04
	else:
		env.background_color = Color("#cde7ff")
		env.ambient_light_color = Color("#dbeafe")
		env.ambient_light_energy = 0.14
		if sun_light:
			sun_light.light_color = Color("#fff8ee")
			sun_light.light_energy = 0.25
		if fill_light:
			fill_light.light_color = Color("#93c5fd")
			fill_light.light_energy = 0.07

func _animate_to_mode(night: bool) -> void:
	if not world_environment or not world_environment.environment:
		return
	if _tween and _tween.is_valid():
		_tween.kill()
	
	var env := world_environment.environment
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	
	_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	var target_bg := Color("#0e1628") if night else Color("#cde7ff")
	var target_amb := Color("#151d2f") if night else Color("#dbeafe")
	var target_amb_energy := 0.08 if night else 0.14
	var target_sun_col := Color("#60a5fa") if night else Color("#fff8ee")
	var target_sun_energy := 0.10 if night else 0.25
	var target_fill_col := Color("#1e3a8a") if night else Color("#93c5fd")
	var target_fill_energy := 0.04 if night else 0.07
	
	_tween.tween_property(env, "background_color", target_bg, transition_duration)
	_tween.tween_property(env, "ambient_light_color", target_amb, transition_duration)
	_tween.tween_property(env, "ambient_light_energy", target_amb_energy, transition_duration)
	
	if sun_light:
		_tween.tween_property(sun_light, "light_color", target_sun_col, transition_duration)
		_tween.tween_property(sun_light, "light_energy", target_sun_energy, transition_duration)
	if fill_light:
		_tween.tween_property(fill_light, "light_color", target_fill_col, transition_duration)
		_tween.tween_property(fill_light, "light_energy", target_fill_energy, transition_duration)
