class_name HUD
extends Control

## 1:1 Modulon Diorama-Sandbox HUD (Floating Brand Pill, Save Status Pill, Grid Size Switcher,
## Round TopBar Icon Controls, Green Foto Pill, 5-Slot Snapshots Modal, 3-Option Reset Modal,
## Floating Right Sidebar with 2-Column Tools & 42-Item Catalog, and Bottom-Left Harvest Basket).

var ICON_CHECK_UNCHECKED = load("res://assets/icons/checkbox_unchecked.svg")
var ICON_CHECK_CHECKED = load("res://assets/icons/checkbox_checked.svg")
var ICON_SLIDER_GRABBER = load("res://assets/icons/slider_grabber.svg")
var ICON_SLIDER_GRABBER_HL = load("res://assets/icons/slider_grabber_hl.svg")
var ICON_WIN_CLOSE = load("res://assets/icons/window_close.svg")
var ICON_WIN_CLOSE_HL = load("res://assets/icons/window_close_pressed.svg")

signal tool_selected(mode: int)
signal category_selected(cat: String)
signal item_chosen(type_id: String)
signal grid_size_requested(new_size: int)
signal reset_island_requested()

# TopBar nodes
@onready var top_bar: PanelContainer = %TopBar
@onready var brand_pill: PanelContainer = %BrandPill
@onready var save_status_pill: PanelContainer = get_node_or_null("%SaveStatusPill")
@onready var status_label: Label = %StatusLabel
@onready var btn_save_now: Button = get_node_or_null("%BtnSaveNow")

# Grid size pill group
@onready var grid_size_group: PanelContainer = %GridSizeGroup
@onready var btn_grid_8: Button = %BtnGrid8
@onready var btn_grid_12: Button = %BtnGrid12
@onready var btn_grid_16: Button = %BtnGrid16
@onready var btn_grid_20: Button = %BtnGrid20
@onready var btn_grid_24: Button = %BtnGrid24

# Top controls
@onready var btn_night_mode: Button = get_node_or_null("%BtnNightMode")
@onready var btn_grid_lines: Button = get_node_or_null("%BtnGridLines")
@onready var btn_reset_cam: Button = get_node_or_null("%BtnResetCam")
@onready var btn_sound_toggle: Button = get_node_or_null("%BtnSoundToggle")
@onready var btn_snapshots: Button = get_node_or_null("%BtnSnapshots")
@onready var btn_snapshot: Button = %BtnSnapshot
@onready var btn_reset_island: Button = get_node_or_null("%BtnResetIsland")
@onready var btn_info: Button = %BtnInfo
@onready var btn_settings: Button = %BtnSettings

# Harvest Basket (Bottom-Left)
@onready var harvest_basket_panel: PanelContainer = get_node_or_null("%HarvestBasketPanel")
@onready var basket_slots_hbox: HBoxContainer = get_node_or_null("%BasketSlotsHBox")
@onready var basket_hint_label: Label = get_node_or_null("%BasketHintLabel")

# Overlays & Feedback
@onready var selection_hint: PanelContainer = %SelectionHint
@onready var selection_hint_label: Label = %SelectionHintLabel
@onready var toast_panel: PanelContainer = %ToastPanel
@onready var toast_label: Label = %ToastLabel
@onready var flash_rect: ColorRect = %FlashRect
@onready var speech_bubble_layer: Control = %SpeechBubbleLayer

# Sidebar nodes
@onready var sidebar_wrapper: Control = %SidebarWrapper
@onready var sidebar_panel: PanelContainer = %SidebarPanel
@onready var btn_toggle_sidebar: Button = %BtnToggleSidebar
@onready var tools_grid: GridContainer = %ToolsGrid

# Tools
@onready var btn_tool_explore: Button = %BtnToolExplore
@onready var btn_tool_select: Button = %BtnToolSelect
@onready var btn_tool_place: Button = %BtnToolPlace
@onready var btn_tool_rotate: Button = %BtnToolRotate
@onready var btn_tool_demolish: Button = %BtnToolDemolish
@onready var btn_undo: Button = %BtnUndo
@onready var btn_redo: Button = %BtnRedo

# Category Tabs
@onready var cat_ground_btn: Button = %CatGroundBtn
@onready var cat_buildings_btn: Button = %CatBuildingsBtn
@onready var cat_nature_btn: Button = %CatNatureBtn
@onready var cat_creatures_btn: Button = %CatCreaturesBtn
@onready var cat_deco_btn: Button = %CatDecoBtn
@onready var category_title_label: Label = %CategoryTitleLabel

# Catalog Grid & Scroll
@onready var scroll_container: ScrollContainer = $SidebarWrapper/SidebarPanel/Margin/VBox/ScrollContainer
@onready var catalog_grid: GridContainer = %CatalogGrid
@onready var tools_label: Label = get_node_or_null("SidebarWrapper/SidebarPanel/Margin/VBox/ToolsLabel")
@onready var h_separator_1: HSeparator = get_node_or_null("SidebarWrapper/SidebarPanel/Margin/VBox/HSeparator1")
@onready var cat_section_label: Label = get_node_or_null("SidebarWrapper/SidebarPanel/Margin/VBox/CatSectionLabel")
@onready var category_tabs: HBoxContainer = get_node_or_null("SidebarWrapper/SidebarPanel/Margin/VBox/CategoryTabs")

# Dialogs
@onready var reset_confirm_dialog: ConfirmationDialog = %ResetConfirmDialog
@onready var credits_dialog: AcceptDialog = %CreditsDialog
@onready var settings_dialog: AcceptDialog = %SettingsDialog
@onready var credits_text: RichTextLabel = %CreditsText

# Settings Controls
@onready var slider_master: HSlider = %SliderMaster
@onready var check_mute: CheckBox = %CheckMute
@onready var display_mode_box: HBoxContainer = get_node_or_null("%DisplayModeBox")
@onready var display_mode_label: Label = get_node_or_null("%DisplayModeLabel")
@onready var option_display_mode: OptionButton = get_node_or_null("%OptionDisplayMode")
@onready var check_grid_lines: CheckBox = %CheckGridLines
@onready var check_night_mode: CheckBox = %CheckNightMode
@onready var btn_reset_cam_settings: Button = %BtnResetCamSettings
@onready var btn_save_settings: Button = %BtnSaveSettings
@onready var btn_load_settings: Button = %BtnLoadSettings
@onready var btn_open_screenshots: Button = %BtnOpenScreenshots
@onready var btn_reset_island_settings: Button = %BtnResetIslandSettings
@onready var btn_quit_game: Button = get_node_or_null("%BtnQuitGame")
@onready var quit_confirm_dialog: ConfirmationDialog = get_node_or_null("%QuitConfirmDialog")

# Settings Tabs
@onready var tab_audio_btn: Button = get_node_or_null("%TabAudioBtn")
@onready var tab_view_btn: Button = get_node_or_null("%TabViewBtn")
@onready var tab_system_btn: Button = get_node_or_null("%TabSystemBtn")
@onready var tab_audio_content: VBoxContainer = get_node_or_null("%TabAudioContent")
@onready var tab_view_content: VBoxContainer = get_node_or_null("%TabViewContent")
@onready var tab_system_content: VBoxContainer = get_node_or_null("%TabSystemContent")
@onready var settings_scroll: ScrollContainer = get_node_or_null("%SettingsScroll")

var current_settings_tab: String = "audio"
var _style_settings_tab_active: StyleBoxFlat
var _style_settings_tab_inactive: StyleBoxFlat

var _pending_snapshot_image: Image = null
var _save_file_dialog: FileDialog = null
var _snapshots_dialog: AcceptDialog = null
var _snapshots_vbox: VBoxContainer = null
var _clear_island_btn: Button = null

# References to main scene & controllers
var main_scene: Node3D
var placement_ctrl: PlacementController
var day_night_ctrl: DayNightController
var camera_ctrl: CameraController
var storage_mgr: StorageManager
var history_mgr: HistoryManager
var sync_mgr: SyncManager
var island_base: IslandBase

var current_category: String = "ground"
var is_sidebar_open: bool = true
var is_portrait_mode: bool = false
const SIDEBAR_WIDTH: float = 284.0

var current_grid_size: int = 12
var _toast_tween: Tween

# Harvest Basket state
const BASKET_ITEMS: Array[Dictionary] = [
	{"key": "strawberry", "icon": "🍓", "name": "Erdbeere"},
	{"key": "potato", "icon": "🥔", "name": "Kartoffel"},
	{"key": "mushroom", "icon": "🍄", "name": "Pilz"},
	{"key": "nut", "icon": "🌰", "name": "Nuss"},
]
var basket: Dictionary = {"strawberry": 0, "potato": 0, "mushroom": 0, "nut": 0}
var selected_food: String = ""
var _basket_slot_buttons: Dictionary = {}
var _basket_badge_labels: Dictionary = {}

# UI Styles
var _style_pill_normal: StyleBoxFlat
var _style_pill_hover: StyleBoxFlat
var _style_pill_active: StyleBoxFlat

var _style_round_icon_normal: StyleBoxFlat
var _style_round_icon_hover: StyleBoxFlat
var _style_round_icon_active: StyleBoxFlat
var _style_foto_pill: StyleBoxFlat
var _style_foto_pill_hover: StyleBoxFlat

var _style_save_pill_saved: StyleBoxFlat
var _style_save_pill_saving: StyleBoxFlat

var _style_tool_normal: StyleBoxFlat
var _style_tool_hover: StyleBoxFlat
var _style_tool_active: StyleBoxFlat
var _style_tool_danger_active: StyleBoxFlat

var _style_cat_normal: StyleBoxFlat
var _style_cat_hover: StyleBoxFlat
var _style_cat_active: StyleBoxFlat

var _style_card_normal: StyleBoxFlat
var _style_card_hover: StyleBoxFlat
var _style_card_selected: StyleBoxFlat

var _style_basket_slot_normal: StyleBoxFlat
var _style_basket_slot_hover: StyleBoxFlat
var _style_basket_slot_selected: StyleBoxFlat
var _style_basket_badge: StyleBoxFlat

var _style_sidebar_landscape: StyleBoxFlat
var _style_sidebar_portrait: StyleBoxFlat

var _style_dialog_panel: StyleBoxFlat
var _style_dialog_btn: StyleBoxFlat
var _style_dialog_btn_hover: StyleBoxFlat
var _style_dialog_btn_danger: StyleBoxFlat
var _style_dialog_ok_btn: StyleBoxFlat

func _ready() -> void:
	_init_styles()
	_build_harvest_basket_slots()
	_setup_reset_dialog_extra_button()
	_connect_signals()
	_setup_grid_size_buttons()
	_setup_top_action_buttons()
	_update_tool_buttons(PlacementController.Tool.PLACE)
	_update_category_buttons()
	_update_catalog_items("ground")
	
	if selection_hint:
		selection_hint.visible = false
	if toast_panel:
		toast_panel.visible = false
	if flash_rect:
		flash_rect.color.a = 0.0
	
	if not get_viewport().size_changed.is_connected(_on_viewport_size_changed):
		get_viewport().size_changed.connect(_on_viewport_size_changed)
	_on_viewport_size_changed()

## Main setup entry point called from `scripts/main.gd`.
func setup(main_node: Node3D) -> void:
	main_scene = main_node
	setup_all(
		main_node.get("placement_controller") as PlacementController,
		main_node.get("day_night") as DayNightController,
		main_node.get("camera_rig") as CameraController,
		main_node.get("storage_manager") as StorageManager,
		main_node.get("history_manager") as HistoryManager,
		main_node.get("sync_manager") as SyncManager,
		main_node.get("island_base") as IslandBase
	)

func setup_all(
	pc: PlacementController,
	dn: DayNightController,
	cc: CameraController,
	sm: StorageManager,
	hm: HistoryManager,
	sync: SyncManager,
	ib: IslandBase = null
) -> void:
	placement_ctrl = pc
	day_night_ctrl = dn
	camera_ctrl = cc
	storage_mgr = sm
	history_mgr = hm
	sync_mgr = sync
	island_base = ib
	
	if placement_ctrl:
		if not placement_ctrl.tool_changed.is_connected(_on_placement_mode_changed):
			placement_ctrl.tool_changed.connect(_on_placement_mode_changed)
		if not placement_ctrl.selection_changed.is_connected(_on_selection_entry_changed):
			placement_ctrl.selection_changed.connect(_on_selection_entry_changed)
		if not placement_ctrl.object_interacted.is_connected(_on_object_interacted):
			placement_ctrl.object_interacted.connect(_on_object_interacted)
		if not placement_ctrl.item_harvested.is_connected(_on_item_harvested):
			placement_ctrl.item_harvested.connect(_on_item_harvested)
		if not placement_ctrl.creature_fed.is_connected(_on_creature_fed):
			placement_ctrl.creature_fed.connect(_on_creature_fed)
		if not placement_ctrl.placement_hint.is_connected(_on_placement_hint):
			placement_ctrl.placement_hint.connect(_on_placement_hint)
		_update_tool_buttons(placement_ctrl.current_tool)
		_refresh_catalog_cards_selection(placement_ctrl.active_type_id)
	
	if day_night_ctrl:
		if not day_night_ctrl.mode_changed.is_connected(_on_time_changed):
			day_night_ctrl.mode_changed.connect(_on_time_changed)
		_on_time_changed(day_night_ctrl.is_night)
	
	if history_mgr:
		if not history_mgr.history_changed.is_connected(_on_history_changed):
			history_mgr.history_changed.connect(_on_history_changed)
		_on_history_changed(history_mgr.can_undo(), history_mgr.can_redo())
	
	if storage_mgr:
		if not storage_mgr.save_status_changed.is_connected(_on_storage_status_changed):
			storage_mgr.save_status_changed.connect(_on_storage_status_changed)
		basket = storage_mgr.load_basket()
		_update_harvest_basket_ui()
	
	if sync_mgr:
		if not sync_mgr.sync_finished.is_connected(_on_sync_finished):
			sync_mgr.sync_finished.connect(_on_sync_finished)
	
	_update_top_toggle_buttons()

func sync_grid_size(sz: int) -> void:
	current_grid_size = sz
	_update_grid_size_pills(sz)

func on_display_mode_changed(new_mode: int) -> void:
	if option_display_mode:
		option_display_mode.selected = new_mode
	var mode_name: String = SettingsManager.DISPLAY_MODE_NAMES.get(new_mode, "")
	show_toast("Bildschirmmodus: %s [F11] ✓" % mode_name)
	AudioManager.play("switch")

func _init_styles() -> void:
	# 1. Grid Size Pill Buttons
	_style_pill_normal = StyleBoxFlat.new()
	_style_pill_normal.bg_color = Color(1.0, 1.0, 1.0, 0.0)
	_style_pill_normal.set_corner_radius_all(9999)
	
	_style_pill_hover = StyleBoxFlat.new()
	_style_pill_hover.bg_color = Color(0.945, 0.961, 0.976, 1.0)
	_style_pill_hover.set_corner_radius_all(9999)
	
	_style_pill_active = StyleBoxFlat.new()
	_style_pill_active.bg_color = Color("#3b82f6")
	_style_pill_active.set_corner_radius_all(9999)
	
	# 2. TopBar Round Icon Buttons (36x36 white circles)
	_style_round_icon_normal = StyleBoxFlat.new()
	_style_round_icon_normal.bg_color = Color(1.0, 1.0, 1.0, 0.94)
	_style_round_icon_normal.set_border_width_all(1)
	_style_round_icon_normal.border_color = Color("#e2e8f0")
	_style_round_icon_normal.set_corner_radius_all(9999)
	_style_round_icon_normal.shadow_size = 4
	_style_round_icon_normal.shadow_color = Color(0, 0, 0, 0.06)
	
	_style_round_icon_hover = StyleBoxFlat.new()
	_style_round_icon_hover.bg_color = Color("#f8fafc")
	_style_round_icon_hover.set_border_width_all(1)
	_style_round_icon_hover.border_color = Color("#93c5fd")
	_style_round_icon_hover.set_corner_radius_all(9999)
	_style_round_icon_hover.shadow_size = 5
	_style_round_icon_hover.shadow_color = Color(0.145, 0.388, 0.922, 0.14)
	
	_style_round_icon_active = StyleBoxFlat.new()
	_style_round_icon_active.bg_color = Color("#3b82f6")
	_style_round_icon_active.set_border_width_all(1)
	_style_round_icon_active.border_color = Color("#2563eb")
	_style_round_icon_active.set_corner_radius_all(9999)
	_style_round_icon_active.shadow_size = 5
	_style_round_icon_active.shadow_color = Color(0.231, 0.51, 0.965, 0.3)
	
	# Green Foto Accent Pill (#10b981)
	_style_foto_pill = StyleBoxFlat.new()
	_style_foto_pill.bg_color = Color("#10b981")
	_style_foto_pill.set_border_width_all(1)
	_style_foto_pill.border_color = Color("#059669")
	_style_foto_pill.set_corner_radius_all(9999)
	_style_foto_pill.shadow_size = 4
	_style_foto_pill.shadow_color = Color(0.063, 0.725, 0.506, 0.28)
	_style_foto_pill.content_margin_left = 12
	_style_foto_pill.content_margin_right = 12
	
	_style_foto_pill_hover = StyleBoxFlat.new()
	_style_foto_pill_hover.bg_color = Color("#059669")
	_style_foto_pill_hover.set_border_width_all(1)
	_style_foto_pill_hover.border_color = Color("#047857")
	_style_foto_pill_hover.set_corner_radius_all(9999)
	_style_foto_pill_hover.shadow_size = 5
	_style_foto_pill_hover.shadow_color = Color(0.063, 0.725, 0.506, 0.38)
	_style_foto_pill_hover.content_margin_left = 12
	_style_foto_pill_hover.content_margin_right = 12
	
	# Save Status Pills
	_style_save_pill_saved = StyleBoxFlat.new()
	_style_save_pill_saved.bg_color = Color("#d1fae5")
	_style_save_pill_saved.set_border_width_all(1)
	_style_save_pill_saved.border_color = Color("#a7f3d0")
	_style_save_pill_saved.set_corner_radius_all(9999)
	
	_style_save_pill_saving = StyleBoxFlat.new()
	_style_save_pill_saving.bg_color = Color("#fef3c7")
	_style_save_pill_saving.set_border_width_all(1)
	_style_save_pill_saving.border_color = Color("#fde68a")
	_style_save_pill_saving.set_corner_radius_all(9999)
	
	# 3. Tool Buttons (2-Column Grid)
	_style_tool_normal = StyleBoxFlat.new()
	_style_tool_normal.bg_color = Color("#f8fafc")
	_style_tool_normal.set_border_width_all(1)
	_style_tool_normal.border_color = Color("#e2e8f0")
	_style_tool_normal.set_corner_radius_all(10)
	
	_style_tool_hover = StyleBoxFlat.new()
	_style_tool_hover.bg_color = Color("#eff6ff")
	_style_tool_hover.set_border_width_all(1)
	_style_tool_hover.border_color = Color("#93c5fd")
	_style_tool_hover.set_corner_radius_all(10)
	
	_style_tool_active = StyleBoxFlat.new()
	_style_tool_active.bg_color = Color("#2563eb")
	_style_tool_active.set_border_width_all(1)
	_style_tool_active.border_color = Color("#1d4ed8")
	_style_tool_active.set_corner_radius_all(10)
	_style_tool_active.shadow_size = 4
	_style_tool_active.shadow_color = Color(0.145, 0.388, 0.922, 0.3)
	
	_style_tool_danger_active = StyleBoxFlat.new()
	_style_tool_danger_active.bg_color = Color("#ef4444")
	_style_tool_danger_active.set_border_width_all(1)
	_style_tool_danger_active.border_color = Color("#dc2626")
	_style_tool_danger_active.set_corner_radius_all(10)
	_style_tool_danger_active.shadow_size = 4
	_style_tool_danger_active.shadow_color = Color(0.937, 0.267, 0.267, 0.3)
	
	# 4. Category Pills (Active = #2563eb Blue like Screenshot 1)
	_style_cat_normal = StyleBoxFlat.new()
	_style_cat_normal.bg_color = Color("#f1f5f9")
	_style_cat_normal.set_corner_radius_all(10)
	
	_style_cat_hover = StyleBoxFlat.new()
	_style_cat_hover.bg_color = Color("#e2e8f0")
	_style_cat_hover.set_corner_radius_all(10)
	
	_style_cat_active = StyleBoxFlat.new()
	_style_cat_active.bg_color = Color("#2563eb")
	_style_cat_active.set_corner_radius_all(10)
	_style_cat_active.shadow_size = 4
	_style_cat_active.shadow_color = Color(0.145, 0.388, 0.922, 0.28)
	
	# 5. Catalog Cards
	_style_card_normal = StyleBoxFlat.new()
	_style_card_normal.bg_color = Color("#ffffff")
	_style_card_normal.set_border_width_all(1)
	_style_card_normal.border_color = Color("#e2e8f0")
	_style_card_normal.set_corner_radius_all(12)
	
	_style_card_hover = StyleBoxFlat.new()
	_style_card_hover.bg_color = Color("#f8fafc")
	_style_card_hover.set_border_width_all(1)
	_style_card_hover.border_color = Color("#93c5fd")
	_style_card_hover.set_corner_radius_all(12)
	
	_style_card_selected = StyleBoxFlat.new()
	_style_card_selected.bg_color = Color("#eff6ff")
	_style_card_selected.set_border_width_all(2)
	_style_card_selected.border_color = Color("#2563eb")
	_style_card_selected.set_corner_radius_all(12)
	
	# 6. Harvest Basket Slots
	_style_basket_slot_normal = StyleBoxFlat.new()
	_style_basket_slot_normal.bg_color = Color("#f8fafc")
	_style_basket_slot_normal.set_border_width_all(2)
	_style_basket_slot_normal.border_color = Color("#e2e8f0")
	_style_basket_slot_normal.set_corner_radius_all(14)
	
	_style_basket_slot_hover = StyleBoxFlat.new()
	_style_basket_slot_hover.bg_color = Color("#f0fdf4")
	_style_basket_slot_hover.set_border_width_all(2)
	_style_basket_slot_hover.border_color = Color("#86efac")
	_style_basket_slot_hover.set_corner_radius_all(14)
	
	_style_basket_slot_selected = StyleBoxFlat.new()
	_style_basket_slot_selected.bg_color = Color("#ecfdf5")
	_style_basket_slot_selected.set_border_width_all(2)
	_style_basket_slot_selected.border_color = Color("#10b981")
	_style_basket_slot_selected.set_corner_radius_all(14)
	_style_basket_slot_selected.shadow_size = 4
	_style_basket_slot_selected.shadow_color = Color(0.063, 0.725, 0.506, 0.25)
	
	_style_basket_badge = StyleBoxFlat.new()
	_style_basket_badge.bg_color = Color("#0284c7")
	_style_basket_badge.set_corner_radius_all(9999)
	_style_basket_badge.content_margin_left = 5
	_style_basket_badge.content_margin_right = 5
	_style_basket_badge.content_margin_top = 1
	_style_basket_badge.content_margin_bottom = 1
	
	# 7. Sidebar Panel Styles (All 4 corners rounded 20px in landscape)
	_style_sidebar_landscape = StyleBoxFlat.new()
	_style_sidebar_landscape.bg_color = Color(0.985, 0.988, 0.995, 0.95)
	_style_sidebar_landscape.set_border_width_all(1)
	_style_sidebar_landscape.border_color = Color(0.886, 0.91, 0.941, 0.9)
	_style_sidebar_landscape.set_corner_radius_all(20)
	_style_sidebar_landscape.shadow_color = Color(0, 0, 0, 0.1)
	_style_sidebar_landscape.shadow_size = 12
	
	_style_sidebar_portrait = StyleBoxFlat.new()
	_style_sidebar_portrait.bg_color = Color(0.985, 0.988, 0.995, 0.95)
	_style_sidebar_portrait.set_border_width_all(1)
	_style_sidebar_portrait.border_color = Color(0.886, 0.91, 0.941, 0.9)
	_style_sidebar_portrait.corner_radius_top_left = 18
	_style_sidebar_portrait.corner_radius_top_right = 18
	_style_sidebar_portrait.shadow_color = Color(0, 0, 0, 0.1)
	_style_sidebar_portrait.shadow_size = 12
	
	# 8. Dialog Styles
	_style_dialog_panel = StyleBoxFlat.new()
	_style_dialog_panel.bg_color = Color(0.985, 0.988, 0.995, 1.0)
	_style_dialog_panel.border_width_left = 1
	_style_dialog_panel.border_width_top = 0
	_style_dialog_panel.border_width_right = 1
	_style_dialog_panel.border_width_bottom = 1
	_style_dialog_panel.border_color = Color(0.85, 0.88, 0.92, 1.0)
	_style_dialog_panel.corner_radius_bottom_left = 16
	_style_dialog_panel.corner_radius_bottom_right = 16
	_style_dialog_panel.content_margin_left = 18
	_style_dialog_panel.content_margin_top = 14
	_style_dialog_panel.content_margin_right = 18
	_style_dialog_panel.content_margin_bottom = 28
	
	_style_dialog_btn = StyleBoxFlat.new()
	_style_dialog_btn.bg_color = Color(1.0, 1.0, 1.0, 0.95)
	_style_dialog_btn.set_border_width_all(1)
	_style_dialog_btn.border_color = Color(0.82, 0.86, 0.91, 1.0)
	_style_dialog_btn.set_corner_radius_all(10)
	
	_style_dialog_btn_hover = StyleBoxFlat.new()
	_style_dialog_btn_hover.bg_color = Color(0.93, 0.96, 1.0, 1.0)
	_style_dialog_btn_hover.set_border_width_all(1)
	_style_dialog_btn_hover.border_color = Color(0.25, 0.55, 0.95, 0.8)
	_style_dialog_btn_hover.set_corner_radius_all(10)
	
	_style_dialog_btn_danger = StyleBoxFlat.new()
	_style_dialog_btn_danger.bg_color = Color(0.99, 0.95, 0.95, 1.0)
	_style_dialog_btn_danger.set_border_width_all(1)
	_style_dialog_btn_danger.border_color = Color(0.95, 0.65, 0.65, 0.9)
	_style_dialog_btn_danger.set_corner_radius_all(10)
	
	_style_dialog_ok_btn = StyleBoxFlat.new()
	_style_dialog_ok_btn.bg_color = Color("#2563eb")
	_style_dialog_ok_btn.set_corner_radius_all(12)
	
	_style_settings_tab_active = StyleBoxFlat.new()
	_style_settings_tab_active.bg_color = Color("#2563eb")
	_style_settings_tab_active.set_corner_radius_all(10)
	
	_style_settings_tab_inactive = StyleBoxFlat.new()
	_style_settings_tab_inactive.bg_color = Color(0.95, 0.965, 0.985, 1.0)
	_style_settings_tab_inactive.set_border_width_all(1)
	_style_settings_tab_inactive.border_color = Color(0.82, 0.86, 0.91, 1.0)
	_style_settings_tab_inactive.set_corner_radius_all(10)

# =============================================================================
# HARVEST BASKET (`🧺 ERNTEKORB`)
# =============================================================================

func _build_harvest_basket_slots() -> void:
	if not basket_slots_hbox:
		return
	for child in basket_slots_hbox.get_children():
		child.queue_free()
	_basket_slot_buttons.clear()
	_basket_badge_labels.clear()
	
	for item in BASKET_ITEMS:
		var k: String = item["key"]
		var icon_str: String = item["icon"]
		var name_str: String = item["name"]
		
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(48, 48)
		btn.text = icon_str
		btn.tooltip_text = "%s verfüttern" % name_str
		btn.focus_mode = Control.FOCUS_NONE
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.add_theme_font_size_override("font_size", 20)
		btn.pressed.connect(func(): _on_basket_slot_pressed(k))
		
		# Top-right count badge
		var badge_panel := PanelContainer.new()
		badge_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge_panel.add_theme_stylebox_override("panel", _style_basket_badge)
		badge_panel.anchor_left = 1.0
		badge_panel.anchor_right = 1.0
		badge_panel.offset_left = -20.0
		badge_panel.offset_top = -5.0
		badge_panel.offset_right = 4.0
		badge_panel.offset_bottom = 13.0
		
		var badge_lbl := Label.new()
		badge_lbl.text = "0"
		badge_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		badge_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		badge_lbl.add_theme_font_size_override("font_size", 10)
		badge_lbl.add_theme_color_override("font_color", Color.WHITE)
		badge_panel.add_child(badge_lbl)
		btn.add_child(badge_panel)
		
		basket_slots_hbox.add_child(btn)
		_basket_slot_buttons[k] = btn
		_basket_badge_labels[k] = badge_lbl
	
	_update_harvest_basket_ui()

func _update_harvest_basket_ui() -> void:
	for item in BASKET_ITEMS:
		var k: String = item["key"]
		var count: int = int(basket.get(k, 0))
		var btn: Button = _basket_slot_buttons.get(k)
		var lbl: Label = _basket_badge_labels.get(k)
		if lbl:
			lbl.text = str(count)
		if btn:
			var is_sel := (selected_food == k and count > 0)
			var st := _style_basket_slot_selected if is_sel else _style_basket_slot_normal
			btn.add_theme_stylebox_override("normal", st)
			btn.add_theme_stylebox_override("hover", _style_basket_slot_selected if is_sel else _style_basket_slot_hover)
			btn.add_theme_stylebox_override("pressed", _style_basket_slot_selected)
			btn.add_theme_stylebox_override("focus", st)
			btn.modulate.a = 1.0 if count > 0 else 0.72
	
	if basket_hint_label:
		if not selected_food.is_empty():
			var fname := _get_food_name(selected_food)
			var ficon := _get_food_icon(selected_food)
			basket_hint_label.text = "%s %s gewählt: Klicke auf ein Tier!" % [ficon, fname]
			basket_hint_label.add_theme_color_override("font_color", Color("#059669"))
		else:
			basket_hint_label.text = "Im Erkunden-Modus ernten & füttern!"
			basket_hint_label.add_theme_color_override("font_color", Color(0.4, 0.45, 0.53, 1.0))

func _on_basket_slot_pressed(food_key: String) -> void:
	var count: int = int(basket.get(food_key, 0))
	var fname := _get_food_name(food_key)
	var ficon := _get_food_icon(food_key)
	if count <= 0:
		AudioManager.play("click")
		show_toast("🧺 Keine %s im Korb! Im Erkunden-Modus (🖐️) ernten." % fname)
		return
	
	if selected_food == food_key:
		selected_food = ""
		if placement_ctrl:
			placement_ctrl.selected_food = ""
		if selection_hint:
			selection_hint.visible = false
		AudioManager.play("click")
	else:
		selected_food = food_key
		if placement_ctrl:
			placement_ctrl.selected_food = food_key
			placement_ctrl.set_tool(PlacementController.Tool.EXPLORE)
		_update_tool_buttons(PlacementController.Tool.EXPLORE)
		if selection_hint and selection_hint_label:
			selection_hint_label.text = "🧺 [%s %s] Klicke auf ein Tier oder einen Menschen zum Füttern! • [Esc] Abbrechen" % [ficon, fname]
			selection_hint.visible = true
		AudioManager.play("ui_pop")
		show_toast("%s %s zum Verfüttern ausgewählt!" % [ficon, fname])
	
	_update_harvest_basket_ui()

func _on_item_harvested(food_key: String, world_pos: Vector3) -> void:
	basket[food_key] = int(basket.get(food_key, 0)) + 1
	if storage_mgr:
		storage_mgr.save_basket(basket)
	_update_harvest_basket_ui()
	
	var ficon := _get_food_icon(food_key)
	var fname := _get_food_name(food_key)
	show_speech_bubble("%s +1 %s!" % [ficon, fname], world_pos)
	show_toast("🧺 %s %s geerntet! (Jetzt %d im Korb)" % [ficon, fname, int(basket[food_key])])
	
	# Pop animation on the harvested basket slot
	var btn: Button = _basket_slot_buttons.get(food_key)
	if btn:
		btn.pivot_offset = btn.size * 0.5
		var tw := create_tween()
		tw.tween_property(btn, "scale", Vector2(1.22, 1.22), 0.12)
		tw.tween_property(btn, "scale", Vector2.ONE, 0.14)

func _on_creature_fed(entry: Dictionary, food_key: String, world_pos: Vector3) -> void:
	var current_count: int = int(basket.get(food_key, 0))
	if current_count <= 0:
		return
	basket[food_key] = current_count - 1
	if int(basket[food_key]) <= 0:
		selected_food = ""
		if placement_ctrl:
			placement_ctrl.selected_food = ""
		if selection_hint:
			selection_hint.visible = false
	if storage_mgr:
		storage_mgr.save_basket(basket)
	_update_harvest_basket_ui()
	
	var c_def := Catalog.get_item(entry.get("type", ""))
	var c_icon: String = c_def.get("icon", "🐾")
	var c_name: String = c_def.get("name", "Tier")
	var f_name := _get_food_name(food_key)
	var f_icon := _get_food_icon(food_key)
	show_speech_bubble("😋 %s Mjam! 💕" % f_icon, world_pos)
	show_toast("%s %s knuspert glücklich %s! 😋💕" % [c_icon, c_name, f_name])

func _get_food_name(k: String) -> String:
	for item in BASKET_ITEMS:
		if item["key"] == k:
			return item["name"]
	return k

func _get_food_icon(k: String) -> String:
	for item in BASKET_ITEMS:
		if item["key"] == k:
			return item["icon"]
	return "🍓"

# =============================================================================
# SIGNALS & TOP BAR CONTROLS
# =============================================================================

func _setup_reset_dialog_extra_button() -> void:
	if reset_confirm_dialog and not _clear_island_btn:
		_clear_island_btn = reset_confirm_dialog.add_button("🗑️ Komplett leeren", false, "clear_empty")
		reset_confirm_dialog.custom_action.connect(_on_reset_custom_action)

func _connect_signals() -> void:
	# Tools
	btn_tool_explore.pressed.connect(func(): _on_tool_btn_pressed(PlacementController.Tool.EXPLORE))
	btn_tool_select.pressed.connect(func(): _on_tool_btn_pressed(PlacementController.Tool.SELECT))
	btn_tool_place.pressed.connect(func(): _on_tool_btn_pressed(PlacementController.Tool.PLACE))
	btn_tool_rotate.pressed.connect(_on_rotate_btn_pressed)
	btn_tool_demolish.pressed.connect(func(): _on_tool_btn_pressed(PlacementController.Tool.DEMOLISH))
	
	btn_undo.pressed.connect(_on_undo_pressed)
	btn_redo.pressed.connect(_on_redo_pressed)
	
	# Categories
	cat_ground_btn.pressed.connect(func(): _set_category("ground"))
	cat_buildings_btn.pressed.connect(func(): _set_category("buildings"))
	cat_nature_btn.pressed.connect(func(): _set_category("nature"))
	cat_creatures_btn.pressed.connect(func(): _set_category("creatures"))
	cat_deco_btn.pressed.connect(func(): _set_category("deco"))
	
	# Sidebar toggle
	btn_toggle_sidebar.pressed.connect(_toggle_sidebar)
	
	# Top Controls
	if btn_save_now:
		btn_save_now.pressed.connect(_on_save_pressed)
	if btn_night_mode:
		btn_night_mode.pressed.connect(_on_top_night_mode_pressed)
	if btn_grid_lines:
		btn_grid_lines.pressed.connect(_on_top_grid_lines_pressed)
	if btn_reset_cam:
		btn_reset_cam.pressed.connect(_on_reset_camera_pressed)
	if btn_sound_toggle:
		btn_sound_toggle.pressed.connect(_on_top_sound_toggle_pressed)
	if btn_snapshots:
		btn_snapshots.pressed.connect(_on_snapshots_pressed)
	if btn_reset_island:
		btn_reset_island.pressed.connect(_on_reset_pressed)
	btn_snapshot.pressed.connect(_on_snapshot_pressed)
	btn_info.pressed.connect(_on_info_pressed)
	btn_settings.pressed.connect(_on_settings_pressed)
	
	# Settings Dialog tabs & controls
	if tab_audio_btn:
		tab_audio_btn.pressed.connect(func(): _set_settings_tab("audio"))
	if tab_view_btn:
		tab_view_btn.pressed.connect(func(): _set_settings_tab("view"))
	if tab_system_btn:
		tab_system_btn.pressed.connect(func(): _set_settings_tab("system"))
	
	slider_master.value_changed.connect(_on_master_slider_changed)
	check_mute.toggled.connect(_on_check_mute_toggled)
	if option_display_mode:
		option_display_mode.clear()
		option_display_mode.add_item("Fenstermodus", SettingsManager.DisplayMode.WINDOWED)
		option_display_mode.add_item("Randloses Vollbild", SettingsManager.DisplayMode.FULLSCREEN_BORDERLESS)
		option_display_mode.add_item("Exklusives Vollbild", SettingsManager.DisplayMode.FULLSCREEN_EXCLUSIVE)
		option_display_mode.add_item("Randloses Fenster", SettingsManager.DisplayMode.BORDERLESS_WINDOW)
		option_display_mode.item_selected.connect(_on_display_mode_selected)
		option_display_mode.selected = SettingsManager.get_display_mode()
	if display_mode_box and OS.has_feature("mobile"):
		display_mode_box.visible = false
	check_grid_lines.toggled.connect(_on_check_grid_lines_toggled)
	check_night_mode.toggled.connect(_on_check_night_mode_toggled)
	btn_reset_cam_settings.pressed.connect(_on_reset_camera_pressed)
	btn_save_settings.pressed.connect(_on_save_pressed)
	btn_load_settings.pressed.connect(_on_load_pressed)
	btn_reset_island_settings.pressed.connect(_on_reset_pressed)
	if btn_quit_game:
		btn_quit_game.pressed.connect(_on_quit_game_pressed)
	if quit_confirm_dialog:
		quit_confirm_dialog.confirmed.connect(_on_quit_confirmed)
		quit_confirm_dialog.canceled.connect(_on_quit_canceled)
	if btn_open_screenshots:
		btn_open_screenshots.pressed.connect(_on_open_screenshots_pressed)
	reset_confirm_dialog.confirmed.connect(_on_reset_confirmed)
	reset_confirm_dialog.canceled.connect(_on_reset_canceled)

func _setup_top_action_buttons() -> void:
	for btn in [btn_save_now, btn_night_mode, btn_grid_lines, btn_reset_cam, btn_sound_toggle, btn_snapshots, btn_reset_island, btn_info, btn_settings]:
		_apply_round_icon_theme(btn, false)
	if btn_snapshot:
		btn_snapshot.add_theme_stylebox_override("normal", _style_foto_pill)
		btn_snapshot.add_theme_stylebox_override("hover", _style_foto_pill_hover)
		btn_snapshot.add_theme_stylebox_override("pressed", _style_foto_pill_hover)
		btn_snapshot.add_theme_stylebox_override("focus", _style_foto_pill)
		btn_snapshot.add_theme_color_override("font_color", Color.WHITE)
		btn_snapshot.add_theme_color_override("font_hover_color", Color.WHITE)
		btn_snapshot.add_theme_color_override("font_pressed_color", Color.WHITE)
		btn_snapshot.add_theme_font_size_override("font_size", 12)
	_update_top_toggle_buttons()

func _apply_round_icon_theme(btn: Button, is_active: bool = false) -> void:
	if not btn:
		return
	var st := _style_round_icon_active if is_active else _style_round_icon_normal
	btn.add_theme_stylebox_override("normal", st)
	btn.add_theme_stylebox_override("hover", _style_round_icon_active if is_active else _style_round_icon_hover)
	btn.add_theme_stylebox_override("pressed", _style_round_icon_active)
	btn.add_theme_stylebox_override("focus", st)
	var col := Color.WHITE if is_active else Color(0.18, 0.23, 0.32, 1.0)
	btn.add_theme_color_override("font_color", col)
	btn.add_theme_color_override("font_hover_color", col)
	btn.add_theme_color_override("font_pressed_color", Color.WHITE)
	btn.add_theme_font_size_override("font_size", 14)

func _update_top_toggle_buttons() -> void:
	if btn_night_mode and day_night_ctrl:
		btn_night_mode.text = "🌙" if day_night_ctrl.is_night else "☀️"
		_apply_round_icon_theme(btn_night_mode, day_night_ctrl.is_night)
	if btn_grid_lines:
		var grid_on := true
		if island_base:
			grid_on = island_base.show_grid_lines
		_apply_round_icon_theme(btn_grid_lines, grid_on)
	if btn_sound_toggle:
		var muted := AudioManager.is_muted()
		btn_sound_toggle.text = "🔇" if muted else "🔊"
		_apply_round_icon_theme(btn_sound_toggle, false)

func _on_top_night_mode_pressed() -> void:
	if day_night_ctrl:
		day_night_ctrl.toggle_mode()
		AudioManager.play("switch")
		_update_top_toggle_buttons()
		show_toast("🌙 Nachtmodus aktiviert" if day_night_ctrl.is_night else "☀️ Tageslicht aktiviert")

func _on_top_grid_lines_pressed() -> void:
	if island_base:
		island_base.show_grid_lines = not island_base.show_grid_lines
		if check_grid_lines:
			check_grid_lines.set_pressed_no_signal(island_base.show_grid_lines)
		AudioManager.play("switch")
		_update_top_toggle_buttons()

func _on_top_sound_toggle_pressed() -> void:
	var muted := AudioManager.toggle_mute()
	if check_mute:
		check_mute.set_pressed_no_signal(muted)
	_update_top_toggle_buttons()
	show_toast("🔇 Ton stummgeschaltet" if muted else "🔊 Ton aktiviert")

# =============================================================================
# 5-SLOT SNAPSHOTS MODAL (`🔗`)
# =============================================================================

func _on_snapshots_pressed() -> void:
	AudioManager.play("click")
	if not _snapshots_dialog:
		_snapshots_dialog = AcceptDialog.new()
		_snapshots_dialog.title = "📸 Insel-Snapshots (5 Speicher-Slots)"
		_snapshots_dialog.ok_button_text = "Schließen"
		var margin := MarginContainer.new()
		margin.name = "SnapshotsMargin"
		margin.add_theme_constant_override("margin_left", 14)
		margin.add_theme_constant_override("margin_right", 14)
		margin.add_theme_constant_override("margin_top", 12)
		margin.add_theme_constant_override("margin_bottom", 12)
		_snapshots_vbox = VBoxContainer.new()
		_snapshots_vbox.add_theme_constant_override("separation", 10)
		margin.add_child(_snapshots_vbox)
		_snapshots_dialog.add_child(margin)
		add_child(_snapshots_dialog)
	
	_rebuild_snapshots_list()
	_apply_dialog_responsive_styling(_snapshots_dialog)
	var dsize := _get_responsive_dialog_size(Vector2i(520, 410), Vector2i(820, 560))
	_snapshots_dialog.reset_size()
	_snapshots_dialog.popup_centered(dsize)

func _rebuild_snapshots_list() -> void:
	if not _snapshots_vbox or not storage_mgr:
		return
	for child in _snapshots_vbox.get_children():
		child.queue_free()
	
	var slots := storage_mgr.load_snapshots()
	for i in range(5):
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		var info_lbl := Label.new()
		info_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_lbl.add_theme_color_override("font_color", Color(0.12, 0.16, 0.24, 1.0))
		info_lbl.add_theme_font_size_override("font_size", 12)
		
		var entry = slots[i]
		if entry is Dictionary:
			info_lbl.text = "Slot %d: %s (%d×%d • %d Obj.)" % [
				i + 1,
				str(entry.get("timestamp", "")),
				int(entry.get("gridSize", 12)),
				int(entry.get("gridSize", 12)),
				int(entry.get("objectCount", 0))
			]
		else:
			info_lbl.text = "Slot %d: — Leer —" % (i + 1)
		row.add_child(info_lbl)
		
		var btn_save_slot := Button.new()
		btn_save_slot.text = "💾 Speichern"
		btn_save_slot.custom_minimum_size = Vector2(96, 30)
		btn_save_slot.add_theme_stylebox_override("normal", _style_dialog_btn)
		btn_save_slot.add_theme_stylebox_override("hover", _style_dialog_btn_hover)
		btn_save_slot.add_theme_color_override("font_color", Color(0.12, 0.16, 0.24, 1.0))
		btn_save_slot.add_theme_font_size_override("font_size", 12)
		btn_save_slot.pressed.connect(func():
			if storage_mgr.save_snapshot_slot(i):
				AudioManager.play("ui_pop")
				show_toast("📸 Snapshot in Slot %d gespeichert ✓" % (i + 1))
				_rebuild_snapshots_list()
		)
		row.add_child(btn_save_slot)
		
		if entry is Dictionary:
			var btn_load_slot := Button.new()
			btn_load_slot.text = "📂 Laden"
			btn_load_slot.custom_minimum_size = Vector2(82, 30)
			btn_load_slot.add_theme_stylebox_override("normal", _style_dialog_btn)
			btn_load_slot.add_theme_stylebox_override("hover", _style_dialog_btn_hover)
			btn_load_slot.add_theme_color_override("font_color", Color("#2563eb"))
			btn_load_slot.add_theme_font_size_override("font_size", 12)
			btn_load_slot.pressed.connect(func():
				if storage_mgr.load_snapshot_slot(i):
					if island_base and storage_mgr.grid_manager:
						island_base.grid_size = storage_mgr.grid_manager.grid_size
						sync_grid_size(storage_mgr.grid_manager.grid_size)
					AudioManager.play("ui_pop")
					show_toast("📂 Snapshot Slot %d geladen ✓" % (i + 1))
					_snapshots_dialog.hide()
			)
			row.add_child(btn_load_slot)
			
			var btn_del_slot := Button.new()
			btn_del_slot.text = "🗑️"
			btn_del_slot.custom_minimum_size = Vector2(34, 30)
			btn_del_slot.add_theme_stylebox_override("normal", _style_dialog_btn_danger)
			btn_del_slot.add_theme_color_override("font_color", Color("#dc2626"))
			btn_del_slot.pressed.connect(func():
				storage_mgr.delete_snapshot_slot(i)
				AudioManager.play("demolish")
				_rebuild_snapshots_list()
			)
			row.add_child(btn_del_slot)
		
		_snapshots_vbox.add_child(row)

# =============================================================================
# TOOLS & CATEGORIES
# =============================================================================

func _on_tool_btn_pressed(mode: int) -> void:
	if mode != PlacementController.Tool.EXPLORE and not selected_food.is_empty():
		selected_food = ""
		if placement_ctrl:
			placement_ctrl.selected_food = ""
		_update_harvest_basket_ui()
	if placement_ctrl:
		placement_ctrl.set_tool(mode)
	_update_tool_buttons(mode)
	tool_selected.emit(mode)

func _on_rotate_btn_pressed() -> void:
	if placement_ctrl:
		placement_ctrl.rotate_step()

func _set_category(cat: String) -> void:
	current_category = cat
	_update_category_buttons()
	_update_catalog_items(cat)
	category_selected.emit(cat)

func _update_tool_buttons(active_mode: int) -> void:
	if btn_tool_explore: btn_tool_explore.button_pressed = (active_mode == PlacementController.Tool.EXPLORE)
	if btn_tool_select: btn_tool_select.button_pressed = (active_mode == PlacementController.Tool.SELECT)
	if btn_tool_place: btn_tool_place.button_pressed = (active_mode == PlacementController.Tool.PLACE)
	if btn_tool_demolish: btn_tool_demolish.button_pressed = (active_mode == PlacementController.Tool.DEMOLISH)
	
	_apply_tool_style(btn_tool_explore, active_mode == PlacementController.Tool.EXPLORE)
	_apply_tool_style(btn_tool_select, active_mode == PlacementController.Tool.SELECT)
	_apply_tool_style(btn_tool_place, active_mode == PlacementController.Tool.PLACE)
	_apply_tool_style(btn_tool_demolish, active_mode == PlacementController.Tool.DEMOLISH, true)
	_apply_tool_style(btn_tool_rotate, false)
	_apply_tool_style(btn_undo, false)
	_apply_tool_style(btn_redo, false)
	
	if camera_ctrl:
		camera_ctrl.left_drag_orbit_enabled = (active_mode == PlacementController.Tool.EXPLORE)

func _apply_tool_style(btn: Button, is_active: bool, is_danger: bool = false) -> void:
	if not btn:
		return
	if is_active:
		var st := _style_tool_danger_active if is_danger else _style_tool_active
		btn.add_theme_stylebox_override("normal", st)
		btn.add_theme_stylebox_override("hover", st)
		btn.add_theme_stylebox_override("pressed", st)
		btn.add_theme_stylebox_override("focus", st)
		btn.add_theme_color_override("font_color", Color.WHITE)
		btn.add_theme_color_override("font_hover_color", Color.WHITE)
		btn.add_theme_color_override("font_pressed_color", Color.WHITE)
		btn.add_theme_color_override("font_focus_color", Color.WHITE)
	else:
		btn.add_theme_stylebox_override("normal", _style_tool_normal)
		btn.add_theme_stylebox_override("hover", _style_tool_hover)
		btn.add_theme_stylebox_override("pressed", _style_tool_normal)
		btn.add_theme_stylebox_override("focus", _style_tool_normal)
		btn.add_theme_stylebox_override("disabled", _style_tool_normal)
		btn.add_theme_color_override("font_color", Color("#334155"))
		btn.add_theme_color_override("font_hover_color", Color("#0f172a"))
		btn.add_theme_color_override("font_pressed_color", Color("#1e293b"))
		btn.add_theme_color_override("font_focus_color", Color("#334155"))
		btn.add_theme_color_override("font_disabled_color", Color("#94a3b8"))

func _update_category_buttons() -> void:
	var tabs := {
		"ground": cat_ground_btn,
		"buildings": cat_buildings_btn,
		"nature": cat_nature_btn,
		"creatures": cat_creatures_btn,
		"deco": cat_deco_btn,
	}
	for cat in tabs:
		var btn: Button = tabs[cat]
		if btn:
			var active: bool = (current_category == str(cat))
			btn.button_pressed = active
			var st := _style_cat_active if active else _style_cat_normal
			btn.add_theme_stylebox_override("normal", st)
			btn.add_theme_stylebox_override("hover", _style_cat_active if active else _style_cat_hover)
			btn.add_theme_stylebox_override("pressed", _style_cat_active)
			btn.add_theme_stylebox_override("focus", st)
			var col := Color.WHITE if active else Color("#475569")
			btn.add_theme_color_override("font_color", col)
			btn.add_theme_color_override("font_hover_color", col)
			btn.add_theme_color_override("font_pressed_color", Color.WHITE)

func _update_catalog_items(category: String) -> void:
	if not catalog_grid:
		catalog_grid = get_node_or_null("%CatalogGrid")
	if not catalog_grid:
		return
	
	for child in catalog_grid.get_children():
		catalog_grid.remove_child(child)
		child.queue_free()
	
	var items := Catalog.get_items_by_category(category)
	var active_type: String = placement_ctrl.active_type_id if placement_ctrl else "grass"
	
	for item in items:
		var card := Button.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		card.focus_mode = Control.FOCUS_NONE
		card.text = "%s\n%s" % [item.get("icon", "📦"), item.get("name", "Item")]
		card.alignment = HORIZONTAL_ALIGNMENT_CENTER
		card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if is_portrait_mode:
			card.custom_minimum_size = Vector2(150, 110)
			card.add_theme_font_size_override("font_size", 22)
			card.add_theme_constant_override("line_spacing", 6)
		else:
			card.custom_minimum_size = Vector2(0, 62)
			card.add_theme_font_size_override("font_size", 11)
			card.add_theme_constant_override("line_spacing", 2)
		
		var type_id: String = item["id"]
		_apply_card_style(card, type_id == active_type)
		card.pressed.connect(func(): _on_catalog_item_selected(type_id))
		card.set_meta("item_id", type_id)
		catalog_grid.add_child(card)

func _apply_card_style(card: Button, is_selected: bool) -> void:
	if is_selected:
		card.add_theme_stylebox_override("normal", _style_card_selected)
		card.add_theme_stylebox_override("hover", _style_card_selected)
		card.add_theme_stylebox_override("pressed", _style_card_selected)
		card.add_theme_stylebox_override("focus", _style_card_selected)
		card.add_theme_color_override("font_color", Color("#1d4ed8"))
		card.add_theme_color_override("font_hover_color", Color("#1d4ed8"))
		card.add_theme_color_override("font_pressed_color", Color("#1d4ed8"))
	else:
		card.add_theme_stylebox_override("normal", _style_card_normal)
		card.add_theme_stylebox_override("hover", _style_card_hover)
		card.add_theme_stylebox_override("pressed", _style_card_selected)
		card.add_theme_stylebox_override("focus", _style_card_normal)
		card.add_theme_color_override("font_color", Color("#334155"))
		card.add_theme_color_override("font_hover_color", Color("#0f172a"))
		card.add_theme_color_override("font_pressed_color", Color("#1d4ed8"))

func _on_catalog_item_selected(type_id: String) -> void:
	if not selected_food.is_empty():
		selected_food = ""
		if placement_ctrl:
			placement_ctrl.selected_food = ""
		_update_harvest_basket_ui()
	if placement_ctrl:
		placement_ctrl.set_active_item(type_id)
		placement_ctrl.set_tool(PlacementController.Tool.PLACE)
	_update_tool_buttons(PlacementController.Tool.PLACE)
	_refresh_catalog_cards_selection(type_id)
	item_chosen.emit(type_id)

func _refresh_catalog_cards_selection(active_type: String) -> void:
	if not catalog_grid:
		return
	for child in catalog_grid.get_children():
		if child is Button and child.has_meta("item_id"):
			var card_id: String = str(child.get_meta("item_id"))
			_apply_card_style(child, card_id == active_type)

# =============================================================================
# GRID SIZE SWITCHER
# =============================================================================

func _setup_grid_size_buttons() -> void:
	var btns := {
		8: btn_grid_8,
		12: btn_grid_12,
		16: btn_grid_16,
		20: btn_grid_20,
		24: btn_grid_24,
	}
	for sz in btns:
		var btn: Button = btns[sz]
		if btn:
			btn.pressed.connect(func(): _on_select_grid_size(sz))
	_update_grid_size_pills(12)

func _on_select_grid_size(sz: int) -> void:
	current_grid_size = sz
	_update_grid_size_pills(sz)
	if main_scene and main_scene.get("grid_manager"):
		var gm: GridManager = main_scene.get("grid_manager")
		if main_scene.get("history_manager"):
			(main_scene.get("history_manager") as HistoryManager).record_State()
		gm.resize_grid(sz)
		if island_base:
			island_base.grid_size = sz
		if camera_ctrl:
			camera_ctrl.reset_view(sz)
	grid_size_requested.emit(sz)
	show_toast("📐 Inselgröße: %d×%d" % [sz, sz])

func _update_grid_size_pills(active_sz: int) -> void:
	var btns := {
		8: btn_grid_8,
		12: btn_grid_12,
		16: btn_grid_16,
		20: btn_grid_20,
		24: btn_grid_24,
	}
	for sz in btns:
		var btn: Button = btns[sz]
		if btn:
			var is_active: bool = (int(sz) == active_sz)
			var st := _style_pill_active if is_active else _style_pill_normal
			btn.add_theme_stylebox_override("normal", st)
			btn.add_theme_stylebox_override("hover", _style_pill_active if is_active else _style_pill_hover)
			btn.add_theme_stylebox_override("pressed", _style_pill_active)
			btn.add_theme_stylebox_override("focus", st)
			var col := Color.WHITE if is_active else Color("#64748b")
			btn.add_theme_color_override("font_color", col)
			btn.add_theme_color_override("font_hover_color", Color.WHITE if is_active else Color("#1e293b"))
			btn.add_theme_color_override("font_pressed_color", Color.WHITE)

# =============================================================================
# SPEECH BUBBLES & TOASTS
# =============================================================================

func show_speech_bubble(text: String, world_pos: Vector3) -> void:
	if not speech_bubble_layer or not camera_ctrl or not camera_ctrl.camera:
		return
	var cam: Camera3D = camera_ctrl.camera
	if not is_instance_valid(cam) or not cam.is_inside_tree():
		return
	var spawn_pos := world_pos + Vector3(0.0, 0.85, 0.0)
	if cam.is_position_behind(spawn_pos):
		return
	var screen_pos := cam.unproject_position(spawn_pos)
	if screen_pos == Vector2.ZERO:
		return
	
	var bubble := PanelContainer.new()
	bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(1.0, 1.0, 1.0, 0.96)
	sb.set_corner_radius_all(14)
	sb.set_border_width_all(1)
	sb.border_color = Color("#cbd5e1")
	sb.shadow_size = 8
	sb.shadow_color = Color(0, 0, 0, 0.12)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	bubble.add_theme_stylebox_override("panel", sb)
	
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", Color("#1e293b"))
	bubble.add_child(lbl)
	speech_bubble_layer.add_child(bubble)
	
	bubble.position = screen_pos - Vector2(60.0, 36.0)
	bubble.scale = Vector2.ZERO
	var tween := create_tween()
	tween.tween_property(bubble, "scale", Vector2(1.1, 1.1), 0.12)
	tween.tween_property(bubble, "scale", Vector2.ONE, 0.08)
	tween.parallel().tween_property(bubble, "position:y", bubble.position.y - 24.0, 1.4)
	tween.chain().tween_interval(0.8)
	tween.tween_property(bubble, "modulate:a", 0.0, 0.3)
	tween.tween_callback(bubble.queue_free)

# =============================================================================
# DIALOGS & SETTINGS
# =============================================================================

func _get_responsive_dialog_size(landscape_size: Vector2i, portrait_size: Vector2i) -> Vector2i:
	var vp_size := get_viewport().get_visible_rect().size
	if is_portrait_mode:
		return Vector2i(clampi(portrait_size.x, 340, int(vp_size.x * 0.94)), clampi(portrait_size.y, 340, int(vp_size.y * 0.86)))
	return Vector2i(clampi(landscape_size.x, 340, int(vp_size.x * 0.85)), clampi(landscape_size.y, 240, int(vp_size.y * 0.85)))

func _apply_dialog_responsive_styling(dlg: Window) -> void:
	if not dlg:
		return
	dlg.transparent = true
	dlg.add_theme_stylebox_override("panel", _style_dialog_panel)
	dlg.add_theme_color_override("title_color", Color(0.96, 0.98, 1.0, 1.0))
	var t_size := 28 if is_portrait_mode else 15
	var t_height := 54 if is_portrait_mode else 42
	dlg.add_theme_font_size_override("title_font_size", t_size)
	dlg.add_theme_font_size_override("title_size", t_size)
	dlg.add_theme_constant_override("title_height", t_height)
	dlg.add_theme_constant_override("close_v_offset", 40 if is_portrait_mode else 34)
	dlg.add_theme_constant_override("close_h_offset", 42 if is_portrait_mode else 40)
	if ICON_WIN_CLOSE:
		dlg.add_theme_icon_override("close", ICON_WIN_CLOSE)
	if ICON_WIN_CLOSE_HL:
		dlg.add_theme_icon_override("close_pressed", ICON_WIN_CLOSE_HL)
	
	var eb := StyleBoxFlat.new()
	eb.draw_center = false
	eb.border_color = Color(0.18, 0.22, 0.30, 1.0)
	eb.border_width_top = t_height
	eb.set_corner_radius_all(16)
	eb.expand_margin_top = t_height
	eb.shadow_color = Color(0, 0, 0, 0.18)
	eb.shadow_size = 14
	dlg.add_theme_stylebox_override("embedded_border", eb)
	dlg.add_theme_stylebox_override("embedded_unfocused_border", eb)
	
	if dlg is AcceptDialog:
		var ok_btn := (dlg as AcceptDialog).get_ok_button()
		if ok_btn:
			var ok_sb := StyleBoxFlat.new()
			ok_sb.bg_color = Color("#2563eb")
			ok_sb.set_corner_radius_all(12)
			ok_sb.content_margin_left = 18
			ok_sb.content_margin_right = 18
			ok_sb.content_margin_top = 6
			ok_sb.content_margin_bottom = 6
			ok_btn.add_theme_stylebox_override("normal", ok_sb)
			ok_btn.add_theme_stylebox_override("hover", ok_sb)
			ok_btn.add_theme_color_override("font_color", Color.WHITE)
			ok_btn.add_theme_font_size_override("font_size", 20 if is_portrait_mode else 13)
	
	if dlg is ConfirmationDialog:
		var cancel_btn := (dlg as ConfirmationDialog).get_cancel_button()
		if cancel_btn:
			var c_sb := StyleBoxFlat.new()
			c_sb.bg_color = Color("#f1f5f9")
			c_sb.set_border_width_all(1)
			c_sb.border_color = Color("#cbd5e1")
			c_sb.set_corner_radius_all(12)
			c_sb.content_margin_left = 16
			c_sb.content_margin_right = 16
			c_sb.content_margin_top = 6
			c_sb.content_margin_bottom = 6
			cancel_btn.add_theme_stylebox_override("normal", c_sb)
			cancel_btn.add_theme_stylebox_override("hover", c_sb)
			cancel_btn.add_theme_color_override("font_color", Color("#1e293b"))
			cancel_btn.add_theme_font_size_override("font_size", 20 if is_portrait_mode else 13)
		if _clear_island_btn and dlg == reset_confirm_dialog:
			var d_sb := StyleBoxFlat.new()
			d_sb.bg_color = Color("#fef2f2")
			d_sb.set_border_width_all(1)
			d_sb.border_color = Color("#fca5a5")
			d_sb.set_corner_radius_all(12)
			d_sb.content_margin_left = 16
			d_sb.content_margin_right = 16
			d_sb.content_margin_top = 6
			d_sb.content_margin_bottom = 6
			_clear_island_btn.add_theme_stylebox_override("normal", d_sb)
			_clear_island_btn.add_theme_stylebox_override("hover", d_sb)
			_clear_island_btn.add_theme_color_override("font_color", Color("#dc2626"))
			_clear_island_btn.add_theme_font_size_override("font_size", 20 if is_portrait_mode else 13)
		var lbl := (dlg as ConfirmationDialog).get_label()
		if lbl:
			lbl.add_theme_color_override("font_color", Color("#1e293b"))
			lbl.add_theme_font_size_override("font_size", 20 if is_portrait_mode else 13)
			lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _set_settings_tab(tab_name: String) -> void:
	current_settings_tab = tab_name
	if tab_audio_content: tab_audio_content.visible = (tab_name == "audio")
	if tab_view_content: tab_view_content.visible = (tab_name == "view")
	if tab_system_content: tab_system_content.visible = (tab_name == "system")
	_update_settings_tab_buttons()

func _update_settings_tab_buttons() -> void:
	var tabs := [
		{"btn": tab_audio_btn, "active": current_settings_tab == "audio"},
		{"btn": tab_view_btn, "active": current_settings_tab == "view"},
		{"btn": tab_system_btn, "active": current_settings_tab == "system"}
	]
	var font_sz := 22 if is_portrait_mode else 12
	var btn_h := 52 if is_portrait_mode else 34
	for t in tabs:
		var btn := t["btn"] as Button
		if not btn:
			continue
		btn.custom_minimum_size = Vector2(0, btn_h)
		btn.add_theme_font_size_override("font_size", font_sz)
		if t["active"]:
			btn.add_theme_stylebox_override("normal", _style_settings_tab_active)
			btn.add_theme_stylebox_override("hover", _style_settings_tab_active)
			btn.add_theme_stylebox_override("pressed", _style_settings_tab_active)
			btn.add_theme_color_override("font_color", Color.WHITE)
		else:
			btn.add_theme_stylebox_override("normal", _style_settings_tab_inactive)
			btn.add_theme_stylebox_override("hover", _style_dialog_btn_hover)
			btn.add_theme_color_override("font_color", Color("#334155"))

func _update_settings_dialog_controls() -> void:
	_update_settings_tab_buttons()
	var font_sz := 26 if is_portrait_mode else 12
	var btn_h := 66 if is_portrait_mode else 34
	var chk_h := 60 if is_portrait_mode else 28
	
	if slider_master:
		var slider_track_sb := StyleBoxFlat.new()
		slider_track_sb.bg_color = Color("#e2e8f0")
		slider_track_sb.set_corner_radius_all(5)
		slider_track_sb.content_margin_top = 5
		slider_track_sb.content_margin_bottom = 5
		var slider_fill_sb := StyleBoxFlat.new()
		slider_fill_sb.bg_color = Color("#2563eb")
		slider_fill_sb.set_corner_radius_all(5)
		slider_fill_sb.content_margin_top = 5
		slider_fill_sb.content_margin_bottom = 5
		slider_master.add_theme_stylebox_override("slider", slider_track_sb)
		slider_master.add_theme_stylebox_override("grabber_area", slider_fill_sb)
		slider_master.add_theme_stylebox_override("grabber_area_highlight", slider_fill_sb)
		slider_master.add_theme_icon_override("grabber", ICON_SLIDER_GRABBER)
		slider_master.add_theme_icon_override("grabber_highlight", ICON_SLIDER_GRABBER_HL)
	
	for chk in [check_mute, check_grid_lines, check_night_mode]:
		if chk:
			chk.add_theme_icon_override("checked", ICON_CHECK_CHECKED)
			chk.add_theme_icon_override("unchecked", ICON_CHECK_UNCHECKED)
			chk.add_theme_font_size_override("font_size", font_sz)
			chk.add_theme_color_override("font_color", Color("#1e293b"))
			chk.custom_minimum_size = Vector2(0, chk_h)
	
	if option_display_mode:
		option_display_mode.add_theme_stylebox_override("normal", _style_dialog_btn)
		option_display_mode.add_theme_stylebox_override("hover", _style_dialog_btn_hover)
		option_display_mode.add_theme_color_override("font_color", Color("#1e293b"))
		option_display_mode.add_theme_font_size_override("font_size", font_sz)
		option_display_mode.custom_minimum_size = Vector2(210, btn_h)
		option_display_mode.selected = SettingsManager.get_display_mode()
		var popup := option_display_mode.get_popup()
		if popup:
			var popup_sb := StyleBoxFlat.new()
			popup_sb.bg_color = Color("#ffffff")
			popup_sb.set_border_width_all(1)
			popup_sb.border_color = Color("#cbd5e1")
			popup_sb.set_corner_radius_all(10)
			popup.add_theme_stylebox_override("panel", popup_sb)
			popup.add_theme_color_override("font_color", Color("#1e293b"))
			popup.add_theme_color_override("font_hover_color", Color("#1d4ed8"))
			var popup_hover_sb := StyleBoxFlat.new()
			popup_hover_sb.bg_color = Color("#eff6ff")
			popup_hover_sb.set_corner_radius_all(6)
			popup.add_theme_stylebox_override("hover", popup_hover_sb)
	
	for b in [btn_reset_cam_settings, btn_save_settings, btn_load_settings, btn_open_screenshots]:
		if b:
			b.add_theme_stylebox_override("normal", _style_dialog_btn)
			b.add_theme_stylebox_override("hover", _style_dialog_btn_hover)
			b.add_theme_color_override("font_color", Color("#1e293b"))
			b.add_theme_font_size_override("font_size", font_sz)
			b.custom_minimum_size = Vector2(0, btn_h)
	for db in [btn_reset_island_settings, btn_quit_game]:
		if db:
			db.add_theme_stylebox_override("normal", _style_dialog_btn_danger)
			db.add_theme_stylebox_override("hover", _style_dialog_btn_danger)
			db.add_theme_color_override("font_color", Color("#dc2626"))
			db.add_theme_font_size_override("font_size", font_sz)
			db.custom_minimum_size = Vector2(0, btn_h)

func _update_credits_dialog_content() -> void:
	if not credits_text:
		return
	credits_text.add_theme_color_override("default_color", Color("#1e293b"))
	var font_sz := 26 if is_portrait_mode else 13
	var title_sz := 34 if is_portrait_mode else 16
	var sub_sz := 20 if is_portrait_mode else 11
	var ver := AppVersion.VERSION
	if not ver.begins_with("v"):
		ver = "v" + ver
	credits_text.text = "[center][b][font_size=%d]🏝️ Diorama Sandbox[/font_size][/b]\n[font_size=%d][color=#2563eb]Native Edition %s • Cross-Platform (Linux / Windows / Android)[/color][/font_size][/center]\n\n[font_size=%d][b]👥 Team & Entwicklung:[/b]\n• [b]Jennifer Graßl:[/b] Architektur & Software-Entwicklung\n• [b]Sara Graßl:[/b] Ideen, Content-Beiträge & Playtesting\n• [b]Gemini:[/b] Konzept & KI-Entwicklungspartner\n\n[b]📜 Third-Party Credits & Lizenzen:[/b]\n• [b]Engine:[/b] Godot Engine 4 (MIT Lizenz)\n• [b]SFX & Audio:[/b] Kenney (CC0) & Prozeduraler AudioSynthesizer\n• [b]Design:[/b] Zero-Asset Low-Poly Modulsystem (42 Elemente + Erntekorb)[/font_size]" % [title_sz, sub_sz, ver, font_sz]

func _on_settings_pressed() -> void:
	slider_master.value = AudioManager.get_master_volume()
	check_mute.button_pressed = AudioManager.is_muted()
	if island_base:
		check_grid_lines.button_pressed = island_base.show_grid_lines
	if day_night_ctrl:
		check_night_mode.button_pressed = day_night_ctrl.is_night
	if option_display_mode:
		option_display_mode.selected = SettingsManager.get_display_mode()
	
	_apply_dialog_responsive_styling(settings_dialog)
	_update_settings_dialog_controls()
	var dsize := _get_responsive_dialog_size(Vector2i(500, 420), Vector2i(780, 580))
	var margin := settings_dialog.find_child("SettingsMargin") as Control
	if margin:
		margin.custom_minimum_size = Vector2(dsize.x - 32, dsize.y - 80)
	settings_dialog.reset_size()
	settings_dialog.popup_centered(dsize)

func _on_display_mode_selected(index: int) -> void:
	SettingsManager.set_display_mode(index)
	var mode_name: String = SettingsManager.DISPLAY_MODE_NAMES.get(index, "")
	show_toast("Bildschirmmodus: %s ✓" % mode_name)
	AudioManager.play("switch")

func _on_master_slider_changed(val: float) -> void:
	AudioManager.set_master_volume(val)
	_update_top_toggle_buttons()

func _on_check_mute_toggled(pressed: bool) -> void:
	if pressed != AudioManager.is_muted():
		AudioManager.toggle_mute()
	_update_top_toggle_buttons()

func _on_check_grid_lines_toggled(pressed: bool) -> void:
	if island_base:
		island_base.show_grid_lines = pressed
	_update_top_toggle_buttons()

func _on_check_night_mode_toggled(pressed: bool) -> void:
	if day_night_ctrl and day_night_ctrl.is_night != pressed:
		day_night_ctrl.set_night_mode(pressed)
	_update_top_toggle_buttons()

func _get_save_file_dialog() -> FileDialog:
	if not _save_file_dialog:
		_save_file_dialog = FileDialog.new()
		_save_file_dialog.title = "Diorama-Foto speichern"
		_save_file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		_save_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
		_save_file_dialog.use_native_dialog = true
		_save_file_dialog.filters = PackedStringArray(["*.png ; PNG-Bilder (*.png)"])
		_save_file_dialog.file_selected.connect(_on_snapshot_file_selected)
		_save_file_dialog.canceled.connect(_on_snapshot_canceled)
		add_child(_save_file_dialog)
	return _save_file_dialog

func _on_snapshot_file_selected(path: String) -> void:
	if not _pending_snapshot_image:
		return
	if _pending_snapshot_image.save_png(path) == OK:
		show_toast("📸 Foto gespeichert: %s ✓" % path.get_file())
	else:
		show_toast("⚠️ Fehler beim Speichern des Fotos")
	_pending_snapshot_image = null

func _on_snapshot_canceled() -> void:
	_pending_snapshot_image = null

func _on_open_screenshots_pressed() -> void:
	var sc_dir := ProjectSettings.globalize_path("user://screenshots")
	if not DirAccess.dir_exists_absolute(sc_dir):
		DirAccess.make_dir_absolute(sc_dir)
	OS.shell_open(sc_dir)
	show_toast("📁 Screenshot-Ordner geöffnet")

func _on_snapshot_pressed() -> void:
	var img := get_viewport().get_texture().get_image()
	if not img:
		show_toast("⚠️ Konnte Bild nicht aufnehmen")
		return
	_pending_snapshot_image = img
	AudioManager.play("click")
	if flash_rect:
		flash_rect.color.a = 0.85
		var tween := create_tween()
		tween.tween_property(flash_rect, "color:a", 0.0, 0.35)
	var ts := Time.get_datetime_string_from_system().replace(":", "-")
	var default_filename := "diorama_%s.png" % ts
	var dir_path := "user://screenshots"
	DirAccess.make_dir_absolute(dir_path)
	img.save_png("%s/%s" % [dir_path, default_filename])
	if not OS.has_feature("mobile"):
		var fd := _get_save_file_dialog()
		var pic_dir := OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)
		if pic_dir.is_empty() or not DirAccess.dir_exists_absolute(pic_dir):
			pic_dir = ProjectSettings.globalize_path("user://screenshots")
		fd.current_dir = pic_dir
		fd.current_file = default_filename
		fd.popup_centered(Vector2i(800, 520))
		show_toast("📸 Foto aufgenommen! Speicherort wählen...")
	else:
		show_toast("📸 Foto in Screenshots gespeichert! ✓")
		_pending_snapshot_image = null

func _on_reset_pressed() -> void:
	if settings_dialog:
		settings_dialog.hide()
	_apply_dialog_responsive_styling(reset_confirm_dialog)
	var dsize := _get_responsive_dialog_size(Vector2i(500, 220), Vector2i(850, 320))
	reset_confirm_dialog.reset_size()
	reset_confirm_dialog.popup_centered(dsize)

func _on_reset_confirmed() -> void:
	if reset_confirm_dialog:
		reset_confirm_dialog.hide()
	if history_mgr:
		history_mgr.record_State()
	if main_scene and main_scene.has_method("spawn_starter_island"):
		main_scene.call("spawn_starter_island")
	if storage_mgr:
		storage_mgr.save_local()
	reset_island_requested.emit()
	AudioManager.play("ui_pop")
	show_toast("🏡 Standard-Insel wiederhergestellt ✓")

func _on_reset_custom_action(action: StringName) -> void:
	if action == &"clear_empty":
		if reset_confirm_dialog:
			reset_confirm_dialog.hide()
		if history_mgr:
			history_mgr.record_State()
		if main_scene and main_scene.has_method("clear_island_completely"):
			main_scene.call("clear_island_completely")
		AudioManager.play("demolish")
		show_toast("🗑️ Insel komplett geleert ✓")

func _on_reset_canceled() -> void:
	if reset_confirm_dialog:
		reset_confirm_dialog.hide()

func _on_quit_game_pressed() -> void:
	AudioManager.play("click")
	if settings_dialog:
		settings_dialog.hide()
	if quit_confirm_dialog:
		_apply_dialog_responsive_styling(quit_confirm_dialog)
		var dsize := _get_responsive_dialog_size(Vector2i(480, 220), Vector2i(850, 320))
		quit_confirm_dialog.reset_size()
		quit_confirm_dialog.popup_centered(dsize)
	else:
		get_tree().quit()

func _on_quit_confirmed() -> void:
	get_tree().quit()

func _on_quit_canceled() -> void:
	if quit_confirm_dialog:
		quit_confirm_dialog.hide()

func _on_info_pressed() -> void:
	_apply_dialog_responsive_styling(credits_dialog)
	_update_credits_dialog_content()
	var dsize := _get_responsive_dialog_size(Vector2i(540, 400), Vector2i(900, 640))
	var cmargin := credits_dialog.find_child("CreditsMargin") as Control
	if cmargin:
		cmargin.custom_minimum_size = Vector2(dsize.x - 32, dsize.y - 90)
	credits_dialog.reset_size()
	credits_dialog.popup_centered(dsize)

func _on_undo_pressed() -> void:
	if history_mgr and history_mgr.undo():
		AudioManager.play("click")
		show_toast("↩ Aktion rückgängig gemacht")

func _on_redo_pressed() -> void:
	if history_mgr and history_mgr.redo():
		AudioManager.play("click")
		show_toast("↪ Aktion wiederholt")

func _on_save_pressed() -> void:
	if storage_mgr:
		if storage_mgr.save_local():
			AudioManager.play("ui_pop")
			show_toast("☁️ Insel gespeichert ✓")
			if sync_mgr and storage_mgr.grid_manager:
				sync_mgr.sync_to_cloud(storage_mgr.grid_manager)

func _on_load_pressed() -> void:
	if storage_mgr and storage_mgr.load_local():
		AudioManager.play("ui_pop")
		show_toast("📂 Speicherstand geladen ✓")

func _on_reset_camera_pressed() -> void:
	if camera_ctrl:
		camera_ctrl.reset_view(current_grid_size)
		AudioManager.play("click")

# =============================================================================
# CONTROLLER CALLBACKS
# =============================================================================

func _on_placement_mode_changed(mode: int) -> void:
	_update_tool_buttons(mode)

func _on_selection_entry_changed(entry: Dictionary) -> void:
	if not selection_hint:
		return
	var has_sel := not entry.is_empty()
	selection_hint.visible = has_sel
	if has_sel and selection_hint_label:
		var def := Catalog.get_item(entry.get("type", ""))
		var item_name: String = def.get("name", entry.get("type", "Objekt"))
		selection_hint_label.text = "✋ [%s] Klick: Absetzen • [R] Drehen • [Entf] Löschen • [Esc] Abbrechen" % item_name

func _on_object_interacted(entry: Dictionary, message: String) -> void:
	var node: Node3D = entry.get("node")
	if is_instance_valid(node):
		show_speech_bubble(message, node.global_position)
	else:
		show_toast(message)

func _on_placement_hint(message: String) -> void:
	if message.is_empty():
		selected_food = ""
		_update_harvest_basket_ui()
		if selection_hint:
			selection_hint.visible = false
	else:
		show_toast(message)

func _on_time_changed(is_night: bool) -> void:
	if check_night_mode:
		check_night_mode.set_pressed_no_signal(is_night)
	_update_top_toggle_buttons()

func _on_history_changed(can_undo: bool, can_redo: bool) -> void:
	if btn_undo:
		btn_undo.disabled = not can_undo
	if btn_redo:
		btn_redo.disabled = not can_redo

func _on_storage_status_changed(status: String) -> void:
	if not status_label:
		return
	match status:
		"saved", "loaded":
			status_label.text = "☁️ Gespeichert ✓"
			status_label.add_theme_color_override("font_color", Color("#047857"))
			if save_status_pill:
				save_status_pill.add_theme_stylebox_override("panel", _style_save_pill_saved)
		"saving":
			status_label.text = "⏳ Speichere..."
			status_label.add_theme_color_override("font_color", Color("#b45309"))
			if save_status_pill:
				save_status_pill.add_theme_stylebox_override("panel", _style_save_pill_saving)
		"error":
			status_label.text = "⚠️ Fehler"

func _on_sync_finished(action: String, success: bool, _message: String) -> void:
	if action == "save" and success and status_label:
		status_label.text = "☁️ Gespeichert ✓"

func show_toast(msg: String, duration: float = 2.0) -> void:
	if not toast_label or not toast_panel:
		return
	toast_label.text = msg
	toast_panel.visible = true
	toast_panel.modulate.a = 1.0
	if _toast_tween and _toast_tween.is_valid():
		_toast_tween.kill()
	_toast_tween = create_tween()
	_toast_tween.tween_interval(duration)
	_toast_tween.tween_property(toast_panel, "modulate:a", 0.0, 0.35)
	_toast_tween.tween_callback(func():
		if is_instance_valid(toast_panel):
			toast_panel.visible = false
	)

# =============================================================================
# RESPONSIVE LAYOUT (LANDSCAPE & PORTRAIT)
# =============================================================================

var _is_updating_layout: bool = false
var _last_layout_size: Vector2i = Vector2i.ZERO
var _is_layout_deferred_pending: bool = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		_on_viewport_size_changed()

func _on_viewport_size_changed() -> void:
	if not is_inside_tree():
		return
	if not _is_layout_deferred_pending:
		_is_layout_deferred_pending = true
		_apply_layout_deferred.call_deferred()

func _apply_layout_deferred() -> void:
	_is_layout_deferred_pending = false
	if not is_inside_tree() or _is_updating_layout:
		return
	var vp := get_viewport()
	var vp_size: Vector2i = vp.size if vp else DisplayServer.window_get_size()
	if vp_size.x <= 0 or vp_size.y <= 0 or vp_size == _last_layout_size:
		return
	_is_updating_layout = true
	_last_layout_size = vp_size
	var is_portrait := (vp_size.y > vp_size.x)
	var prev_portrait := is_portrait_mode
	is_portrait_mode = is_portrait
	if prev_portrait != is_portrait:
		_update_catalog_items(current_category)
	if is_portrait:
		_apply_portrait_layout()
	else:
		_apply_landscape_layout()
	_is_updating_layout = false

func _apply_landscape_layout() -> void:
	if not sidebar_wrapper or not btn_toggle_sidebar:
		return
	if sidebar_panel:
		sidebar_panel.add_theme_stylebox_override("panel", _style_sidebar_landscape)
	if save_status_pill: save_status_pill.visible = true
	if btn_save_now: btn_save_now.visible = true
	if btn_snapshots: btn_snapshots.visible = true
	if harvest_basket_panel:
		harvest_basket_panel.offset_left = 18.0
		harvest_basket_panel.offset_top = -132.0
		harvest_basket_panel.offset_right = 266.0
		harvest_basket_panel.offset_bottom = -18.0
	if tools_grid: tools_grid.columns = 2
	if catalog_grid: catalog_grid.columns = 2
	
	sidebar_wrapper.anchor_left = 1.0
	sidebar_wrapper.anchor_top = 0.0
	sidebar_wrapper.anchor_right = 1.0
	sidebar_wrapper.anchor_bottom = 1.0
	sidebar_wrapper.offset_top = 62.0
	sidebar_wrapper.offset_bottom = -16.0
	sidebar_wrapper.offset_left = -(SIDEBAR_WIDTH + 16.0) if is_sidebar_open else 0.0
	sidebar_wrapper.offset_right = -16.0 if is_sidebar_open else (SIDEBAR_WIDTH + 16.0)
	
	btn_toggle_sidebar.anchor_left = 0.0
	btn_toggle_sidebar.anchor_top = 0.0
	btn_toggle_sidebar.anchor_right = 0.0
	btn_toggle_sidebar.anchor_bottom = 0.0
	btn_toggle_sidebar.offset_left = -28.0
	btn_toggle_sidebar.offset_right = 4.0
	btn_toggle_sidebar.offset_top = 18.0
	btn_toggle_sidebar.offset_bottom = 52.0
	btn_toggle_sidebar.text = "▶" if is_sidebar_open else "◀"

func _apply_portrait_layout() -> void:
	if not sidebar_wrapper or not btn_toggle_sidebar:
		return
	if sidebar_panel:
		sidebar_panel.add_theme_stylebox_override("panel", _style_sidebar_portrait)
	if save_status_pill: save_status_pill.visible = false
	if btn_save_now: btn_save_now.visible = false
	if tools_grid: tools_grid.columns = 3
	if catalog_grid: catalog_grid.columns = 4
	
	var dock_height := 520.0
	sidebar_wrapper.anchor_left = 0.0
	sidebar_wrapper.anchor_top = 1.0
	sidebar_wrapper.anchor_right = 1.0
	sidebar_wrapper.anchor_bottom = 1.0
	sidebar_wrapper.offset_left = 10.0
	sidebar_wrapper.offset_right = -10.0
	sidebar_wrapper.offset_top = -dock_height if is_sidebar_open else 0.0
	sidebar_wrapper.offset_bottom = 0.0 if is_sidebar_open else dock_height
	
	btn_toggle_sidebar.anchor_left = 0.5
	btn_toggle_sidebar.anchor_top = 0.0
	btn_toggle_sidebar.anchor_right = 0.5
	btn_toggle_sidebar.anchor_bottom = 0.0
	btn_toggle_sidebar.offset_left = -80.0
	btn_toggle_sidebar.offset_right = 80.0
	btn_toggle_sidebar.offset_top = -38.0
	btn_toggle_sidebar.offset_bottom = 0.0
	btn_toggle_sidebar.text = "▼ Schließen" if is_sidebar_open else "▲ Werkzeuge"

func _toggle_sidebar() -> void:
	is_sidebar_open = not is_sidebar_open
	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if is_portrait_mode:
		var dock_height := 520.0
		tween.tween_property(sidebar_wrapper, "offset_top", -dock_height if is_sidebar_open else 0.0, 0.22)
		tween.tween_property(sidebar_wrapper, "offset_bottom", 0.0 if is_sidebar_open else dock_height, 0.22)
		btn_toggle_sidebar.text = "▼ Schließen" if is_sidebar_open else "▲ Werkzeuge"
	else:
		tween.tween_property(sidebar_wrapper, "offset_left", -(SIDEBAR_WIDTH + 16.0) if is_sidebar_open else 0.0, 0.22)
		tween.tween_property(sidebar_wrapper, "offset_right", -16.0 if is_sidebar_open else (SIDEBAR_WIDTH + 16.0), 0.22)
		btn_toggle_sidebar.text = "▶" if is_sidebar_open else "◀"
