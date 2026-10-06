class_name HumanProp
extends Node3D

## Interactive Human prop with cheer bounce and pop sound.

var _is_animating: bool = false
var _base_y: float = 0.0

func _ready() -> void:
	_base_y = position.y

func interact() -> void:
	if _is_animating:
		return
	_is_animating = true
	
	AudioManager.play("ui_pop")
	
	var tween = create_tween()
	tween.parallel().tween_property(self, "position:y", _base_y + 0.22, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "scale", Vector3(0.9, 1.15, 0.9), 0.14)
	
	tween.chain().parallel().tween_property(self, "position:y", _base_y, 0.14).set_trans(Tween.TRANS_BOUNCE)
	tween.parallel().tween_property(self, "scale", Vector3(1.1, 0.9, 1.1), 0.14)
	
	tween.chain().tween_property(self, "scale", Vector3.ONE, 0.1)
	tween.tween_callback(func(): _is_animating = false)
