class_name HUD
extends Control

## Adaptive HUD for diorama sandbox with responsive layout switching (Desktop vs. Mobile Portrait).

@onready var day_night_btn: Button = %DayNightBtn
@onready var reset_cam_btn: Button = %ResetCamBtn
@onready var title_label: Label = %TitleLabel
@onready var info_panel: PanelContainer = %InfoPanel

var main_node: Main

func _ready() -> void:
	main_node = get_tree().current_scene as Main
	
	day_night_btn.pressed.connect(_on_day_night_pressed)
	reset_cam_btn.pressed.connect(_on_reset_cam_pressed)
	
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_on_viewport_size_changed()

func _on_day_night_pressed() -> void:
	if main_node and main_node.day_night:
		main_node.day_night.toggle()
		day_night_btn.text = "☀️ Tag" if main_node.day_night.is_night else "🌙 Nacht"

func _on_reset_cam_pressed() -> void:
	if main_node and main_node.camera_controller:
		main_node.camera_controller.reset_view()

func _on_viewport_size_changed() -> void:
	var vp_size = get_viewport().get_visible_rect().size
	var is_portrait = vp_size.y > vp_size.x
	
	if is_portrait:
		# Adapt for smartphone portrait layout
		info_panel.anchor_top = 0.02
		info_panel.anchor_left = 0.05
		info_panel.anchor_right = 0.95
	else:
		# Desktop / Landscape layout
		info_panel.anchor_top = 0.03
		info_panel.anchor_left = 0.03
		info_panel.anchor_right = 0.35
