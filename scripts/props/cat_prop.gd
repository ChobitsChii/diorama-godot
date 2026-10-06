class_name CatProp
extends Node3D

## Interactive Cat prop with jump, tail wag, and meow sound.

var _is_jumping: bool = false
var _base_y: float = 0.0

func _ready() -> void:
	_base_y = position.y

func interact() -> void:
	if _is_jumping:
		return
	_is_jumping = true
	_base_y = position.y
	
	AudioSynthesizer.play("cat_meow")
	
	var tween = create_tween()
	# Upward spring with stretch
	tween.parallel().tween_property(self, "position:y", _base_y + 0.35, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "scale", Vector3(0.85, 1.25, 0.85), 0.18)
	
	# Downward landing with squash
	tween.chain().parallel().tween_property(self, "position:y", _base_y, 0.16).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "scale", Vector3(1.18, 0.82, 1.18), 0.16)
	
	# Settle back to normal scale
	tween.chain().tween_property(self, "scale", Vector3.ONE, 0.12)
	tween.tween_callback(func(): _is_jumping = false)
