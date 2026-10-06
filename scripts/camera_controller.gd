class_name CameraController
extends Node3D

## Isometric Orthographic Camera Controller with smooth orbit, zoom, pan, and dynamic aspect ratio scaling.

@export var target: Vector3 = Vector3(0, 0.4, 0)
@export var base_size: float = 13.0
@export var min_size: float = 4.0
@export var max_size: float = 28.0
@export var orbit_speed: float = 0.005
@export var zoom_speed: float = 0.8
@export var damping: float = 10.0

@onready var camera: Camera3D = $Camera3D

var _yaw: float = PI / 4.0        # 45 degrees
var _pitch: float = deg_to_rad(35.264) # Classic isometric elevation
var _target_yaw: float = PI / 4.0
var _target_pitch: float = deg_to_rad(35.264)
var _target_size: float = 13.0
var _current_size: float = 13.0

var _is_orbiting: bool = false
var _is_panning: bool = false
var _last_mouse_pos: Vector2 = Vector2.ZERO

# Touch tracking for mobile
var _touch_points: Dictionary = {}
var _initial_pinch_distance: float = 0.0
var _initial_pinch_size: float = 13.0

func _ready() -> void:
	_target_size = base_size
	_current_size = base_size
	
	if camera:
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		camera.size = _current_size
	
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_update_aspect_compensation()
	_update_camera_transform(true)

func _process(delta: float) -> void:
	_yaw = lerp_angle(_yaw, _target_yaw, damping * delta)
	_pitch = lerp(_pitch, _target_pitch, damping * delta)
	_current_size = lerp(_current_size, _target_size, damping * delta)
	
	_update_camera_transform(false)

func _update_camera_transform(force: bool = false) -> void:
	if not camera:
		return
	
	# Clamp pitch so camera never goes below the island or directly top-down flip
	_target_pitch = clamp(_target_pitch, deg_to_rad(10.0), deg_to_rad(80.0))
	
	var distance: float = 40.0
	var offset: Vector3 = Vector3(
		distance * cos(_pitch) * sin(_yaw),
		distance * sin(_pitch),
		distance * cos(_pitch) * cos(_yaw)
	)
	
	camera.global_position = target + offset
	camera.look_at(target, Vector3.UP)
	camera.size = _current_size

func _unhandled_input(event: InputEvent) -> void:
	# 1. Mouse Dragging (Right click or Middle click)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT or event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				_is_orbiting = true
				_last_mouse_pos = event.position
			else:
				_is_orbiting = false
		
		# Mouse Wheel Zoom
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom(-zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom(zoom_speed)
	
	elif event is InputEventMouseMotion:
		if _is_orbiting:
			var delta_pos = event.position - _last_mouse_pos
			_last_mouse_pos = event.position
			_target_yaw -= delta_pos.x * orbit_speed
			_target_pitch += delta_pos.y * orbit_speed
	
	# 2. Touch Screen Input (Mobile gestures)
	elif event is InputEventScreenTouch:
		if event.pressed:
			_touch_points[event.index] = event.position
		else:
			_touch_points.erase(event.index)
		
		if _touch_points.size() == 2:
			var pts = _touch_points.values()
			_initial_pinch_distance = pts[0].distance_to(pts[1])
			_initial_pinch_size = _target_size
		
	elif event is InputEventScreenDrag:
		_touch_points[event.index] = event.position
		
		if _touch_points.size() == 1:
			# Single-finger orbit (when permitted)
			_target_yaw -= event.relative.x * orbit_speed * 0.8
			_target_pitch += event.relative.y * orbit_speed * 0.8
		elif _touch_points.size() >= 2:
			# Two-finger pinch to zoom
			var pts = _touch_points.values()
			var current_dist = pts[0].distance_to(pts[1])
			if _initial_pinch_distance > 0.0:
				var factor = _initial_pinch_distance / max(current_dist, 1.0)
				_target_size = clamp(_initial_pinch_size * factor, min_size, max_size)

func zoom(amount: float) -> void:
	_target_size = clamp(_target_size + amount, min_size, max_size)

func reset_view() -> void:
	_target_yaw = PI / 4.0
	_target_pitch = deg_to_rad(35.264)
	target = Vector3(0, 0.4, 0)
	_update_aspect_compensation()

func _on_viewport_size_changed() -> void:
	_update_aspect_compensation()

func _update_aspect_compensation() -> void:
	var vp_size = get_viewport().get_visible_rect().size
	if vp_size.y <= 0.0:
		return
	var current_aspect = vp_size.x / vp_size.y
	var design_aspect = 16.0 / 9.0 # 1.777
	
	# If viewport is narrower than design aspect (especially in Portrait 9:16),
	# scale the orthographic size up proportionally so the diorama island stays fully in view.
	if current_aspect < 1.0:
		# Portrait mode (Smartphone upright)
		var scale_factor = (1.0 / current_aspect) * 0.95
		_target_size = base_size * scale_factor
	else:
		_target_size = base_size
