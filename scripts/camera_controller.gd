class_name CameraController
extends Node3D

## Orbit / Pan / Zoom camera rig matching the Modulon Three.js OrbitControls perspective:
## - Camera position (14, 13, 14) looking at (0, 0, 0) -> yaw 45°, pitch 33.3°, distance 23.68
## - Left drag (in Explore mode) or Right drag: Orbit
## - Middle drag or Shift+Right drag: Pan
## - Mouse wheel: Smooth zoom
## - Touch: 1-finger orbit (in Explore mode), 2-finger pinch zoom & pan

@export var orbit_yaw: float = 45.0 # degrees
@export var orbit_pitch: float = 33.3 # degrees (matches atan2(13, sqrt(14^2+14^2)))
@export var orbit_distance: float = 23.68 # matches length(14, 13, 14)

@export var min_pitch: float = 12.0
@export var max_pitch: float = 82.0
@export var min_distance: float = 5.0
@export var max_distance: float = 45.0

@export var orbit_sensitivity: float = 0.32
@export var pan_sensitivity: float = 0.018
@export var zoom_step: float = 1.6
@export var smoothing_speed: float = 12.0
@export var pan_limit: float = 16.0

var target_position: Vector3 = Vector3.ZERO
var left_drag_orbit_enabled: bool = false

var _current_yaw: float = 45.0
var _current_pitch: float = 33.3
var _current_distance: float = 23.68
var _current_target: Vector3 = Vector3.ZERO

var _is_orbiting: bool = false
var _is_panning: bool = false
var _touches: Dictionary = {} # touch_index -> Vector2

@onready var camera: Camera3D = $Camera3D

func _ready() -> void:
	_current_yaw = orbit_yaw
	_current_pitch = orbit_pitch
	_current_distance = orbit_distance
	_current_target = target_position
	_apply_transform_immediate()

func reset_view(grid_size: int = 12) -> void:
	target_position = Vector3.ZERO
	orbit_yaw = 45.0
	orbit_pitch = 33.3
	# At grid_size 12, distance is 23.68 (position 14, 13, 14); scales proportionally for other sizes
	orbit_distance = clampf(float(grid_size) * 1.973, min_distance, max_distance)

func reset_view_immediate(grid_size: int = 12) -> void:
	reset_view(grid_size)
	_current_yaw = orbit_yaw
	_current_pitch = orbit_pitch
	_current_distance = orbit_distance
	_current_target = target_position
	_apply_transform_immediate()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT:
			if mb.shift_pressed:
				_is_panning = mb.pressed
				_is_orbiting = false
			else:
				_is_orbiting = mb.pressed
				_is_panning = false
		elif mb.button_index == MOUSE_BUTTON_MIDDLE:
			_is_panning = mb.pressed
		elif mb.button_index == MOUSE_BUTTON_LEFT and left_drag_orbit_enabled:
			_is_orbiting = mb.pressed
		elif mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			orbit_distance = clampf(orbit_distance - zoom_step, min_distance, max_distance)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			orbit_distance = clampf(orbit_distance + zoom_step, min_distance, max_distance)

	elif event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		if _is_orbiting:
			_apply_orbit_delta(mm.relative)
		elif _is_panning:
			_apply_pan_delta(mm.relative)

	elif event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		if st.pressed:
			_touches[st.index] = st.position
		else:
			_touches.erase(st.index)

	elif event is InputEventScreenDrag:
		var sd := event as InputEventScreenDrag
		var prev_pos: Vector2 = _touches.get(sd.index, sd.position - sd.relative)
		_touches[sd.index] = sd.position
		
		if _touches.size() == 1 and left_drag_orbit_enabled:
			_apply_orbit_delta(sd.relative)
		elif _touches.size() >= 2:
			var keys = _touches.keys()
			var idx0: int = keys[0]
			var idx1: int = keys[1]
			var p0: Vector2 = _touches[idx0]
			var p1: Vector2 = _touches[idx1]
			
			var old_p0: Vector2 = prev_pos if sd.index == idx0 else p0
			var old_p1: Vector2 = prev_pos if sd.index == idx1 else p1
			
			var old_dist := old_p0.distance_to(old_p1)
			var new_dist := p0.distance_to(p1)
			var pinch_delta := old_dist - new_dist
			orbit_distance = clampf(orbit_distance + pinch_delta * 0.04, min_distance, max_distance)
			_apply_pan_delta(sd.relative * 0.5)

func _apply_orbit_delta(relative: Vector2) -> void:
	orbit_yaw -= relative.x * orbit_sensitivity
	orbit_pitch = clampf(orbit_pitch + relative.y * orbit_sensitivity, min_pitch, max_pitch)

func _apply_pan_delta(relative: Vector2) -> void:
	var scale_factor := orbit_distance * 0.06
	var right_vec := global_transform.basis.x
	var forward_flat := Vector3(global_transform.basis.z.x, 0.0, global_transform.basis.z.z).normalized()
	target_position -= right_vec * (relative.x * pan_sensitivity * scale_factor)
	target_position -= forward_flat * (relative.y * pan_sensitivity * scale_factor)
	target_position.x = clampf(target_position.x, -pan_limit, pan_limit)
	target_position.z = clampf(target_position.z, -pan_limit, pan_limit)

func _process(delta: float) -> void:
	var weight := clampf(delta * smoothing_speed, 0.0, 1.0)
	_current_yaw = lerpf(_current_yaw, orbit_yaw, weight)
	_current_pitch = lerpf(_current_pitch, orbit_pitch, weight)
	_current_distance = lerpf(_current_distance, orbit_distance, weight)
	_current_target = _current_target.lerp(target_position, weight)
	_apply_transform_immediate()

func _apply_transform_immediate() -> void:
	global_position = _current_target
	rotation_degrees = Vector3(-_current_pitch, _current_yaw, 0.0)
	if camera:
		camera.position = Vector3(0.0, 0.0, _current_distance)
