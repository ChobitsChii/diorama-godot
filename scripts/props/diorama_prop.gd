class_name DioramaProp
extends Node3D

## Universal controller attached to every procedural 3D model in Diorama-Sandbox.
## Handles continuous idle animations, sitting/perching/floating states,
## autotiling connections (fence, townhouse, apartment), harvest/regrowth timers,
## streetlamp lighting modes, and interactive animations.

var prop_type: String = ""
var is_ground: bool = false
var is_field: bool = false
var field_type: String = ""
var is_interactable: bool = false

# Creature state flags
var is_sitting: bool = false
var is_perched: bool = false
var is_floating: bool = false

# Human customization
var gender: String = "male"
var shirt_color: int = 0xef4444

# Cat state
var is_sleeping: bool = false

# Streetlamp state ("auto", "on", "off")
var lamp_mode: String = "auto"
var _is_night: bool = false

# Harvestable state (strawberry_plant, potato_plant, mushrooms)
var harvest_yield: String = ""
var harvest_ready: bool = true
var _regrow_timer: float = 0.0
const REGROW_DURATION: float = 35.0

# Animation state
var _time: float = 0.0
var _time_offset: float = 0.0
var _action_timer: float = 0.0
var _action_type: String = ""
var _walk_angle: float = 0.0
var _smoke_accum: float = 0.0

# Cached sub-node references for fast animation & state updates
var refs: Dictionary = {}

func _ready() -> void:
	_time_offset = float(get_instance_id() % 1000) * 0.017
	_walk_angle = randf() * TAU

func _process(delta: float) -> void:
	_time += delta
	var t := _time + _time_offset
	
	# Handle harvest regrowth
	if not harvest_ready and not harvest_yield.is_empty():
		_regrow_timer += delta
		var progress := clampf(_regrow_timer / REGROW_DURATION, 0.0, 1.0)
		var harvest_group: Node3D = refs.get("harvest_group")
		if harvest_group:
			var s := lerpf(0.01, 1.0, progress)
			harvest_group.scale = Vector3(s, s, s)
		if _regrow_timer >= REGROW_DURATION:
			harvest_ready = true
			_regrow_timer = 0.0
			if harvest_group:
				harvest_group.visible = true
				harvest_group.scale = Vector3.ONE
	
	# Handle temporary action animations (jump, shake, rear, wave, wiggle, etc.)
	if _action_timer > 0.0:
		_action_timer = maxf(0.0, _action_timer - delta)
		_process_action_animation(delta)
		if _action_timer <= 0.0:
			_reset_action_pose()
	
	# Continuous animations by prop_type
	match prop_type:
		"water":
			var water_surf: Node3D = refs.get("water_surface")
			if water_surf:
				water_surf.position.y = 0.0 + sin(t * 2.2) * 0.012
			var ripples: Array = refs.get("ripples", [])
			for i in range(ripples.size()):
				var rp: Node3D = ripples[i]
				if rp:
					rp.position.y = 0.026 + sin(t * 2.2) * 0.012
					var s := 0.85 + 0.2 * sin(t * 2.8 + float(i) * 1.4)
					rp.scale.x = s
		"pond":
			var water_surf: Node3D = refs.get("water_surface")
			if water_surf:
				water_surf.position.y = 0.03 + sin(t * 2.0) * 0.008
			var lily: Node3D = refs.get("lily")
			if lily:
				lily.position.y = 0.042 + sin(t * 2.0 + 0.5) * 0.008
		"fountain":
			var dome: Node3D = refs.get("water_dome")
			if dome:
				var s := 0.9 + sin(t * 8.0) * 0.12
				dome.scale = Vector3(s, 0.9 + cos(t * 7.0) * 0.15, s)
		"cottage":
			_smoke_accum += delta
			if _smoke_accum >= 0.65:
				_smoke_accum = 0.0
				var pm = get_tree().root.find_child("ParticleManager", true, false)
				if pm and pm.has_method("spawn_chimney_smoke"):
					pm.spawn_chimney_smoke(global_position + Vector3(0.45, 1.88, -0.35))
		"human":
			_animate_human(t, delta)
		"cat":
			_animate_cat(t)
		"dog":
			_animate_dog(t)
		"duck":
			_animate_duck(t)
		"squirrel":
			_animate_squirrel(t)
		"axolotl":
			_animate_axolotl(t)
		"pig":
			_animate_pig(t)
		"parrot":
			_animate_parrot(t)
		"horse":
			_animate_horse(t)
		"elephant":
			_animate_elephant(t)
		"lion":
			_animate_lion(t)
		"whitetiger":
			_animate_whitetiger(t)

func _animate_human(t: float, delta: float) -> void:
	var sub: Node3D = refs.get("sub_group")
	var leg_l: Node3D = refs.get("leg_l")
	var leg_r: Node3D = refs.get("leg_r")
	var arm_l: Node3D = refs.get("arm_l")
	var arm_r: Node3D = refs.get("arm_r")
	if not sub:
		return
	if is_sitting:
		sub.position.x = 0.0
		sub.position.z = 0.0
		if leg_l: leg_l.rotation.x = -PI * 0.5
		if leg_r: leg_r.rotation.x = -PI * 0.5
		if _action_type != "wave":
			if arm_l: arm_l.rotation.x = sin(t * 1.5) * 0.1
			if arm_r: arm_r.rotation.x = -sin(t * 1.5) * 0.1
	else:
		# Subtle strolling in place / circular wander within tile
		var walk_cycle := sin(t * 2.6)
		if abs(walk_cycle) > 0.25 and _action_timer <= 0.0:
			_walk_angle += delta * 0.55
			var radius := 0.12
			sub.position.x = cos(_walk_angle) * radius
			sub.position.z = sin(_walk_angle) * radius
			sub.rotation.y = -_walk_angle + PI
			if leg_l: leg_l.rotation.x = sin(t * 6.5) * 0.35
			if leg_r: leg_r.rotation.x = -sin(t * 6.5) * 0.35
			if arm_l: arm_l.rotation.x = -sin(t * 6.5) * 0.28
			if arm_r and _action_type != "wave": arm_r.rotation.x = sin(t * 6.5) * 0.28
		else:
			if leg_l: leg_l.rotation.x = lerpf(leg_l.rotation.x, 0.0, 0.15)
			if leg_r: leg_r.rotation.x = lerpf(leg_r.rotation.x, 0.0, 0.15)
			if arm_l: arm_l.rotation.x = lerpf(arm_l.rotation.x, 0.0, 0.15)
			if arm_r and _action_type != "wave": arm_r.rotation.x = lerpf(arm_r.rotation.x, 0.0, 0.15)

func _animate_cat(t: float) -> void:
	var tail: Node3D = refs.get("tail")
	var body: Node3D = refs.get("body")
	if tail:
		var speed := 1.2 if is_sleeping else 3.2
		var amp := 0.12 if is_sleeping else 0.32
		tail.rotation.z = sin(t * speed) * amp
	if body and is_sleeping:
		body.scale.y = 0.65 + sin(t * 2.0) * 0.05

func _animate_dog(t: float) -> void:
	var tail: Node3D = refs.get("tail")
	if tail:
		var speed := 14.0 if _action_type == "bark" else 5.5
		tail.rotation.z = sin(t * speed) * 0.38

func _animate_duck(t: float) -> void:
	var sub: Node3D = refs.get("sub_group")
	if not sub:
		return
	if is_floating:
		sub.position.y = -0.02 + sin(t * 2.6) * 0.018
		sub.rotation.z = sin(t * 1.8) * 0.06
	else:
		sub.position.y = 0.0
		sub.rotation.z = sin(t * 2.2) * 0.04

func _animate_squirrel(t: float) -> void:
	var tail_group: Node3D = refs.get("tail_group")
	var head: Node3D = refs.get("head")
	if tail_group:
		var mult := 3.0 if _action_type == "chatter" else 1.0
		tail_group.rotation.x = sin(t * 3.5 * mult) * 0.12
		tail_group.rotation.z = cos(t * 2.5 * mult) * 0.08
	if head:
		head.rotation.y = sin(t * 1.8) * 0.15

func _animate_axolotl(t: float) -> void:
	var tail_group: Node3D = refs.get("tail_group")
	var sub: Node3D = refs.get("sub_group")
	if tail_group:
		var mult := 2.8 if _action_type == "wiggle" else 1.0
		tail_group.rotation.y = sin(t * 3.2 * mult) * (0.42 if _action_type == "wiggle" else 0.22)
	if sub:
		if is_floating:
			sub.position.y = sin(t * 2.0) * 0.025
		else:
			sub.position.y = 0.0

func _animate_pig(t: float) -> void:
	var tail: Node3D = refs.get("tail")
	var head: Node3D = refs.get("head")
	if tail:
		tail.rotation.z = sin(t * 5.0) * 0.25
	if head:
		head.rotation.x = sin(t * 1.8) * 0.06

func _animate_parrot(t: float) -> void:
	var wing_l: Node3D = refs.get("wing_l")
	var wing_r: Node3D = refs.get("wing_r")
	var head: Node3D = refs.get("head")
	if _action_type == "flap":
		if wing_l: wing_l.rotation.z = 0.2 + abs(sin(t * 18.0)) * 0.85
		if wing_r: wing_r.rotation.z = -0.2 - abs(sin(t * 18.0)) * 0.85
	else:
		if wing_l: wing_l.rotation.z = 0.1
		if wing_r: wing_r.rotation.z = -0.1
	if head:
		head.rotation.z = sin(t * 1.6) * 0.1

func _animate_horse(t: float) -> void:
	var tail: Node3D = refs.get("tail")
	var neck_group: Node3D = refs.get("neck_group")
	if tail:
		tail.rotation.z = sin(t * 2.4) * 0.18
	if neck_group and _action_type != "rear":
		neck_group.rotation.x = 0.25 + sin(t * 1.5) * 0.05

func _animate_elephant(t: float) -> void:
	var ear_l: Node3D = refs.get("ear_l")
	var ear_r: Node3D = refs.get("ear_r")
	var trunk_group: Node3D = refs.get("trunk_group")
	var mult := 3.0 if _action_type == "trumpet" else 1.0
	if ear_l: ear_l.rotation.y = 0.25 + sin(t * 2.2 * mult) * 0.15
	if ear_r: ear_r.rotation.y = -0.25 - sin(t * 2.2 * mult) * 0.15
	if trunk_group:
		if _action_type == "trumpet":
			trunk_group.rotation.x = -0.75 + sin(t * 10.0) * 0.2
		else:
			trunk_group.rotation.z = sin(t * 1.6) * 0.12
			trunk_group.rotation.x = sin(t * 1.2) * 0.08

func _animate_lion(t: float) -> void:
	var tail: Node3D = refs.get("tail")
	var head: Node3D = refs.get("head")
	if tail:
		tail.rotation.z = sin(t * 2.5) * 0.25
	if head:
		if _action_type == "roar":
			head.rotation.x = -0.25 + sin(t * 16.0) * 0.08
		else:
			head.rotation.x = sin(t * 1.4) * 0.04

func _animate_whitetiger(t: float) -> void:
	var tail: Node3D = refs.get("tail")
	if tail:
		tail.rotation.z = sin(t * 2.8) * 0.28

func _process_action_animation(_delta: float) -> void:
	var sub: Node3D = refs.get("sub_group")
	match _action_type:
		"wave":
			var arm_r: Node3D = refs.get("arm_r")
			if arm_r:
				arm_r.rotation.x = -2.4
				arm_r.rotation.z = 0.3 + sin(_time * 16.0) * 0.35
		"bark", "oink", "pounce":
			if sub and not is_sitting:
				sub.position.y = abs(sin(_time * 14.0)) * 0.12
		"flap":
			if sub:
				var base_y := float(refs.get("perch_y", 0.0)) if is_perched else 0.0
				sub.position.y = base_y + abs(sin(_time * 12.0)) * 0.14
		"rear":
			if sub:
				sub.rotation.x = -0.35 * sin((1.0 - _action_timer / 0.8) * PI)
		"shake":
			rotation.z = sin(_time * 28.0) * 0.06
			rotation.x = cos(_time * 24.0) * 0.05

func _reset_action_pose() -> void:
	var prev_action := _action_type
	_action_type = ""
	var sub: Node3D = refs.get("sub_group")
	if prev_action == "shake":
		rotation.x = 0.0
		rotation.z = 0.0
	elif prev_action == "wave":
		var arm_r: Node3D = refs.get("arm_r")
		if arm_r:
			arm_r.rotation = Vector3.ZERO
	elif prev_action in ["bark", "oink", "pounce", "flap", "rear"]:
		if sub:
			sub.rotation.x = 0.0
			if is_sitting:
				sub.position.y = float(refs.get("seat_y", 0.18))
			elif is_perched:
				sub.position.y = float(refs.get("perch_y", 1.15))
			elif not is_floating:
				sub.position.y = 0.0

## Sitting state for Human, Cat, Dog, Pig
func set_sitting(sitting: bool, seat_y: float = 0.18) -> void:
	is_sitting = sitting
	refs["seat_y"] = seat_y
	var sub: Node3D = refs.get("sub_group")
	if not sub:
		return
	if sitting:
		sub.position = Vector3(0.0, seat_y, 0.0)
	else:
		sub.position = Vector3.ZERO
		var leg_l: Node3D = refs.get("leg_l")
		var leg_r: Node3D = refs.get("leg_r")
		if leg_l: leg_l.rotation.x = 0.0
		if leg_r: leg_r.rotation.x = 0.0

## Perching state for Parrot and Squirrel (on trees, pines, streetlamps)
func set_perched(perched: bool, perch_y: float = 1.15) -> void:
	is_perched = perched
	refs["perch_y"] = perch_y
	var sub: Node3D = refs.get("sub_group")
	if sub:
		sub.position.y = perch_y if perched else 0.0

## Floating state for Duck and Axolotl (on water tiles and ponds)
func set_floating(floating: bool) -> void:
	is_floating = floating
	var legs: Array = refs.get("legs", [])
	for leg in legs:
		if leg is Node3D:
			leg.visible = not floating

## Streetlamp 3-mode cycle ("auto" -> "on" -> "off")
func cycle_lamp_mode() -> String:
	match lamp_mode:
		"auto": lamp_mode = "on"
		"on": lamp_mode = "off"
		_: lamp_mode = "auto"
	_update_lamp_visuals()
	return lamp_mode

func set_lamp_mode(mode: String) -> void:
	lamp_mode = mode
	_update_lamp_visuals()

func apply_night_mode(night: bool) -> void:
	_is_night = night
	if prop_type == "streetlamp":
		_update_lamp_visuals()

func _update_lamp_visuals() -> void:
	var is_lit := (lamp_mode == "on") or (lamp_mode == "auto" and _is_night)
	var light: OmniLight3D = refs.get("omni_light")
	var bulb_mat: StandardMaterial3D = refs.get("bulb_mat")
	var glass_mat: StandardMaterial3D = refs.get("glass_mat")
	if light:
		light.visible = is_lit
	if bulb_mat:
		bulb_mat.emission_enabled = is_lit
		bulb_mat.albedo_color = Color("#fef08a") if is_lit else Color("#64748b")
	if glass_mat:
		glass_mat.emission_enabled = is_lit

## Harvest check & execution for strawberry_plant, potato_plant, mushrooms
func can_harvest() -> bool:
	return not harvest_yield.is_empty() and harvest_ready

func harvest() -> String:
	if not can_harvest():
		return ""
	harvest_ready = false
	_regrow_timer = 0.0
	var harvest_group: Node3D = refs.get("harvest_group")
	if harvest_group:
		harvest_group.scale = Vector3(0.01, 0.01, 0.01)
	trigger_action("shake", 0.45)
	return harvest_yield

## Trigger a named animation action
func trigger_action(action_name: String, duration: float = 0.7) -> void:
	_action_type = action_name
	_action_timer = duration
	if action_name == "sleep_toggle" and prop_type == "cat":
		is_sleeping = not is_sleeping
		var body: Node3D = refs.get("body")
		var head: Node3D = refs.get("head")
		if body:
			body.scale.y = 0.68 if is_sleeping else 1.0
		if head:
			head.position.y = 0.16 if is_sleeping else 0.24

## Dynamic neighbor autotiling for fence, townhouse, and apartment
func update_connections(mask: Dictionary) -> void:
	var n: bool = mask.get("n", false)
	var e: bool = mask.get("e", false)
	var s: bool = mask.get("s", false)
	var w: bool = mask.get("w", false)
	
	if prop_type == "fence":
		var arm_n: Node3D = refs.get("arm_n")
		var arm_e: Node3D = refs.get("arm_e")
		var arm_s: Node3D = refs.get("arm_s")
		var arm_w: Node3D = refs.get("arm_w")
		var default_arms: Node3D = refs.get("default_arms")
		var any_conn := n or e or s or w
		if default_arms:
			default_arms.visible = not any_conn
		if arm_n: arm_n.visible = n
		if arm_e: arm_e.visible = e
		if arm_s: arm_s.visible = s
		if arm_w: arm_w.visible = w
	elif prop_type in ["townhouse", "apartment"]:
		var ext_n: Node3D = refs.get("ext_n")
		var ext_e: Node3D = refs.get("ext_e")
		var ext_s: Node3D = refs.get("ext_s")
		var ext_w: Node3D = refs.get("ext_w")
		if ext_n: ext_n.visible = n
		if ext_e: ext_e.visible = e
		if ext_s: ext_s.visible = s
		if ext_w: ext_w.visible = w
