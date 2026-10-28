class_name ParticleManager
extends Node3D

## Lightweight 3D particle manager ported 1:1 from Modulon `particles.js`.
## Spawns chimney smoke, floating 3D hearts, rustling leaves, water splashes,
## fountain eruptions, and demolish dust puffs.

var _particles: Array[Dictionary] = []

var _smoke_mat: StandardMaterial3D
var _heart_mat: StandardMaterial3D
var _leaf_mat_1: StandardMaterial3D
var _leaf_mat_2: StandardMaterial3D
var _water_mat: StandardMaterial3D
var _puff_mat: StandardMaterial3D

func _ready() -> void:
	name = "ParticleManager"
	_smoke_mat = ProceduralModels._mat(0xe2e8f0, 0.9, 0.0, 0.72)
	_heart_mat = ProceduralModels._mat(0xf43f5e, 0.35, 0.0, 1.0, 0xe11d48, 0.35)
	_leaf_mat_1 = ProceduralModels._mat(0x22c55e, 0.7)
	_leaf_mat_2 = ProceduralModels._mat(0x4ade80, 0.7)
	_water_mat = ProceduralModels._mat(0x7dd3fc, 0.15, 0.1, 0.88)
	_puff_mat = ProceduralModels._mat(0xf1f5f9, 0.85, 0.0, 0.85)

func _process(delta: float) -> void:
	var i := _particles.size() - 1
	while i >= 0:
		var p: Dictionary = _particles[i]
		p["age"] = float(p["age"]) + delta
		var age: float = p["age"]
		var life: float = p["life"]
		var node: Node3D = p["node"]
		if not is_instance_valid(node) or age >= life:
			if is_instance_valid(node):
				node.queue_free()
			_particles.remove_at(i)
			i -= 1
			continue
		
		var t := clampf(age / life, 0.0, 1.0)
		var vel: Vector3 = p["vel"]
		var grav: float = p.get("gravity", 0.0)
		vel.y += grav * delta
		p["vel"] = vel
		node.global_position += vel * delta
		
		var spin: Vector3 = p.get("spin", Vector3.ZERO)
		node.rotation += spin * delta
		
		var scale_mode: String = p.get("scale_mode", "shrink")
		if scale_mode == "smoke":
			var s := lerpf(0.6, 1.8, t) * (1.0 - pow(t, 2.0) * 0.6)
			node.scale = Vector3(s, s, s)
		elif scale_mode == "heart":
			var s := sin(minf(1.0, t * 3.5) * PI * 0.5) * (1.0 - maxf(0.0, (t - 0.65) / 0.35))
			node.scale = Vector3(s, s, s)
		else:
			var s := maxf(0.01, 1.0 - t)
			node.scale = Vector3(s, s, s)
		i -= 1

func spawn_chimney_smoke(world_pos: Vector3) -> void:
	if _particles.size() > 140:
		return
	var puff := ProceduralModels._sphere(self, 0.065, 6, _smoke_mat, Vector3.ZERO, Vector3.ONE, false)
	puff.global_position = world_pos + Vector3(randf_range(-0.03, 0.03), 0.0, randf_range(-0.03, 0.03))
	_particles.append({
		"node": puff,
		"vel": Vector3(randf_range(0.04, 0.12), randf_range(0.28, 0.42), randf_range(-0.05, 0.05)),
		"gravity": 0.0,
		"spin": Vector3.ZERO,
		"age": 0.0,
		"life": 1.8,
		"scale_mode": "smoke",
	})

func spawn_hearts(world_pos: Vector3, count: int = 4) -> void:
	for i in range(count):
		var hg := Node3D.new()
		add_child(hg)
		# Cute 3D heart composed of 2 spheres + bottom diamond cone
		ProceduralModels._sphere(hg, 0.042, 6, _heart_mat, Vector3(-0.028, 0.025, 0.0), Vector3.ONE, false)
		ProceduralModels._sphere(hg, 0.042, 6, _heart_mat, Vector3(0.028, 0.025, 0.0), Vector3.ONE, false)
		ProceduralModels._cone(hg, 0.058, 0.075, 6, _heart_mat, Vector3(0.0, -0.012, 0.0), Vector3(PI, 0.0, 0.0), false)
		hg.global_position = world_pos + Vector3(randf_range(-0.18, 0.18), 0.45 + float(i) * 0.08, randf_range(-0.18, 0.18))
		_particles.append({
			"node": hg,
			"vel": Vector3(randf_range(-0.22, 0.22), randf_range(0.55, 0.85), randf_range(-0.22, 0.22)),
			"gravity": -0.15,
			"spin": Vector3(0.0, randf_range(-2.5, 2.5), 0.0),
			"age": 0.0,
			"life": 1.25,
			"scale_mode": "heart",
		})

func spawn_leaves(world_pos: Vector3, count: int = 8) -> void:
	for i in range(count):
		var mat := _leaf_mat_1 if i % 2 == 0 else _leaf_mat_2
		var leaf := ProceduralModels._box(self, Vector3(0.07, 0.015, 0.045), mat, Vector3.ZERO, Vector3.ZERO, false)
		leaf.global_position = world_pos + Vector3(randf_range(-0.32, 0.32), randf_range(0.55, 1.15), randf_range(-0.32, 0.32))
		_particles.append({
			"node": leaf,
			"vel": Vector3(randf_range(-0.45, 0.45), randf_range(0.15, 0.45), randf_range(-0.45, 0.45)),
			"gravity": -1.4,
			"spin": Vector3(randf_range(-5.0, 5.0), randf_range(-5.0, 5.0), randf_range(-5.0, 5.0)),
			"age": 0.0,
			"life": 1.1,
			"scale_mode": "shrink",
		})

func spawn_splash(world_pos: Vector3, big: bool = false) -> void:
	var count := 18 if big else 8
	var speed := 1.45 if big else 0.75
	for i in range(count):
		var drop := ProceduralModels._sphere(self, 0.042 if big else 0.032, 5, _water_mat, Vector3.ZERO, Vector3.ONE, false)
		var a := (float(i) / float(count)) * TAU + randf_range(-0.2, 0.2)
		var h_spd := randf_range(0.25, 0.65) * speed
		drop.global_position = world_pos + Vector3(cos(a) * 0.12, 0.18 if not big else 0.85, sin(a) * 0.12)
		_particles.append({
			"node": drop,
			"vel": Vector3(cos(a) * h_spd, randf_range(0.85, 1.55) * speed, sin(a) * h_spd),
			"gravity": -3.6,
			"spin": Vector3.ZERO,
			"age": 0.0,
			"life": 0.85,
			"scale_mode": "shrink",
		})

func spawn_demolish_puff(world_pos: Vector3) -> void:
	for i in range(10):
		var puff := ProceduralModels._sphere(self, 0.085, 6, _puff_mat, Vector3.ZERO, Vector3.ONE, false)
		var a := (float(i) / 10.0) * TAU
		puff.global_position = world_pos + Vector3(cos(a) * 0.15, 0.15, sin(a) * 0.15)
		_particles.append({
			"node": puff,
			"vel": Vector3(cos(a) * randf_range(0.35, 0.75), randf_range(0.35, 0.85), sin(a) * randf_range(0.35, 0.75)),
			"gravity": -0.8,
			"spin": Vector3.ZERO,
			"age": 0.0,
			"life": 0.65,
			"scale_mode": "shrink",
		})
