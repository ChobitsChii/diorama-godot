class_name DuckProp
extends Node3D

## Interactive Duck prop with quack sound and wobble animation.

var _is_animating: bool = false
var _base_y: float = 0.0

func _ready() -> void:
	_base_y = position.y

func interact() -> void:
	if _is_animating:
		return
	_is_animating = true
	
	AudioManager.play("duck_quack")
	
	var tween = create_tween()
	tween.tween_property(self, "rotation:y", rotation.y + 0.25, 0.08)
	tween.tween_property(self, "rotation:y", rotation.y - 0.25, 0.08)
	tween.tween_property(self, "rotation:y", rotation.y, 0.08)
	tween.parallel().tween_property(self, "position:y", _base_y + 0.15, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(self, "position:y", _base_y, 0.12).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_callback(func(): _is_animating = false)
