class_name CatProp
extends Node3D

## Interactive Cat prop with jump, squash & stretch, and guaranteed base_y landing.

var _is_jumping: bool = false
var _base_y: float = 0.0
var _has_base_y: bool = false
var _active_tween: Tween

func _ready() -> void:
	if not _has_base_y:
		_base_y = position.y
		_has_base_y = true

func set_base_y(y: float) -> void:
	_base_y = y
	_has_base_y = true
	if not _is_jumping:
		position.y = y

func interact() -> void:
	if _is_jumping:
		return
	_is_jumping = true
	
	if not _has_base_y:
		_base_y = position.y
		_has_base_y = true
	
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	
	AudioManager.play("cat_meow")
	
	_active_tween = create_tween()
	# Upward spring with stretch
	_active_tween.parallel().tween_property(self, "position:y", _base_y + 0.35, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_tween.parallel().tween_property(self, "scale", Vector3(0.85, 1.25, 0.85), 0.18)
	
	# Downward landing with squash
	_active_tween.chain().parallel().tween_property(self, "position:y", _base_y, 0.16).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	_active_tween.parallel().tween_property(self, "scale", Vector3(1.18, 0.82, 1.18), 0.16)
	
	# Settle back to normal scale & guarantee position.y is exactly _base_y
	_active_tween.chain().tween_property(self, "scale", Vector3.ONE, 0.12)
	_active_tween.tween_callback(func():
		position.y = _base_y
		scale = Vector3.ONE
		_is_jumping = false
	)
