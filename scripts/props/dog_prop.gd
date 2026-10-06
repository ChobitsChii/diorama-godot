class_name DogProp
extends Node3D

## Interactive Dog prop with cheerful bark and bounce animation.

var _is_animating: bool = false
var _base_y: float = 0.0

func _ready() -> void:
	_base_y = position.y

func interact() -> void:
	if _is_animating:
		return
	_is_animating = true
	
	AudioManager.play("dog_bark")
	
	var tween = create_tween()
	tween.parallel().tween_property(self, "position:y", _base_y + 0.28, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "scale", Vector3(0.9, 1.2, 0.9), 0.16)
	
	tween.chain().parallel().tween_property(self, "position:y", _base_y, 0.15).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "scale", Vector3(1.15, 0.85, 1.15), 0.15)
	
	tween.chain().tween_property(self, "scale", Vector3.ONE, 0.1)
	tween.tween_callback(func(): _is_animating = false)
