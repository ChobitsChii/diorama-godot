class_name CottageProp
extends Node3D

## Interactive Cottage prop with door knock sound and subtle wobble feedback.

var _is_animating: bool = false

func interact() -> void:
	if _is_animating:
		return
	_is_animating = true
	
	AudioManager.play("knock")
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(1.05, 0.95, 1.05), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector3(0.96, 1.04, 0.96), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector3.ONE, 0.12).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func(): _is_animating = false)
