class_name DayNightController
extends Node

## Handles Day/Night cycles, environment background, directional sunlight, and streetlamp / window emissions.

signal time_changed(is_night: bool)

@export var world_environment: WorldEnvironment
@export var sun_light: DirectionalLight3D
@export var transition_duration: float = 0.6

var is_night: bool = false
var _tween: Tween

func _ready() -> void:
	apply_state(false, true)

func toggle() -> void:
	set_night(not is_night)

func set_night(value: bool) -> void:
	if is_night == value:
		return
	is_night = value
	apply_state(is_night, false)
	time_changed.emit(is_night)

func apply_state(night: bool, immediate: bool = false) -> void:
	var target_bg: Color = Palette.get_color("nightBg") if night else Palette.get_color("dayBg")
	var target_sun_color: Color = Palette.get_color("nightSun") if night else Palette.get_color("daySun")
	var target_sun_energy: float = 0.35 if night else 1.05
	var target_amb_color: Color = Palette.get_color("nightAmbient") if night else Palette.get_color("dayAmbient")
	var target_amb_energy: float = 0.35 if night else 0.75
	
	if immediate or not is_inside_tree():
		if world_environment and world_environment.environment:
			var env = world_environment.environment
			env.background_color = target_bg
			env.ambient_light_color = target_amb_color
			env.ambient_light_energy = target_amb_energy
		if sun_light:
			sun_light.light_color = target_sun_color
			sun_light.light_energy = target_sun_energy
	else:
		if _tween and _tween.is_valid():
			_tween.kill()
		_tween = create_tween().set_parallel(true)
		
		if world_environment and world_environment.environment:
			var env = world_environment.environment
			_tween.tween_property(env, "background_color", target_bg, transition_duration)
			_tween.tween_property(env, "ambient_light_color", target_amb_color, transition_duration)
			_tween.tween_property(env, "ambient_light_energy", target_amb_energy, transition_duration)
			
		if sun_light:
			_tween.tween_property(sun_light, "light_color", target_sun_color, transition_duration)
			_tween.tween_property(sun_light, "light_energy", target_sun_energy, transition_duration)
	
	# Notify any placed lamps or buildings in group "night_lights"
	get_tree().call_group("night_lights", "set_night_mode", night)
