class_name FountainProp
extends Node3D

## Interactive Fountain prop with water splash sound and ripple pulsing.

var _is_animating: bool = false

func interact() -> void:
	if _is_animating:
		return
	_is_animating = true
	
	AudioManager.play("water_splash")
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(1.08, 0.94, 1.08), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector3(0.95, 1.06, 0.95), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector3.ONE, 0.15).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_callback(func(): _is_animating = false)
