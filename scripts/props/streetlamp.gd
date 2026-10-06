class_name Streetlamp
extends Node3D

## Streetlamp that turns its light on at night or when clicked.

@onready var light: OmniLight3D = $OmniLight3D
@onready var glass: MeshInstance3D = $Glass

var is_turned_on: bool = false

func _ready() -> void:
	add_to_group("night_lights")
	set_night_mode(false)

func set_night_mode(night: bool) -> void:
	is_turned_on = night
	_update_visuals()

func toggle_light() -> void:
	is_turned_on = not is_turned_on
	_update_visuals()

func _update_visuals() -> void:
	if light:
		light.visible = is_turned_on
	if glass:
		var mat = glass.get_surface_override_material(0) as StandardMaterial3D
		if mat:
			mat.emission_enabled = is_turned_on
			mat.emission_energy_multiplier = 1.5 if is_turned_on else 0.0
