extends CharacterBody2D

var goals: Array[Dictionary]
var move_vector: Vector2
var selected: bool = false
var attack: bool = false
var current_hp: float
var valid_targets: Dictionary
var can_attack = true
var fog_tilemap: TileMap
var current_honey: int = 0

@export var select_highlight: Sprite2D
@export var anim_sprite: AnimatedSprite2D
@export var move_speed: float = 200
@export var min_dist_to_goal = 20
@export var max_hp: int = 100
@export var death_particles: PackedScene
@export var hit_particles: PackedScene
@export var hp_bar: ProgressBar
@export var range_area: CollisionShape2D
@export var max_target_spot_range: float = 500
@export var max_attack_range: float = 60
@export var attack_timer: Timer
@export var attack_cd: float = 2
@export var dmg = 10
@export var vision_range: int = 2
@export var max_range_to_harvest: float = 60
@export var max_honey: int = 100
@export var replicate_cost: int = 50
@export var my_type = "Bear"
@export var honey_bar: ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready():
	range_area.shape.radius = max_target_spot_range
	current_hp = max_hp
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	honey_bar.max_value = max_honey
	honey_bar.value = current_honey
	fog_tilemap = get_tree().root.get_node("World/Fog")

func take_dmg(dmg: float):
	current_hp -= dmg
	hp_bar.visible = true
	hp_bar.value = current_hp
	
	if current_hp <= 0:
		var particles = death_particles.instantiate()
		particles.global_position = global_position
		get_tree().root.add_child(particles)
		queue_free()
	else:
		var particles = hit_particles.instantiate()
		particles.global_position = global_position
		get_tree().root.add_child(particles)	
	
func stop_command() -> void:
	goals.clear()
	$AttackRange.monitoring = false
	valid_targets.clear()
	attack = false
	
func attack_command() -> void:
	$AttackRange.monitoring = true
	attack = true

func get_unit_path() -> Array[Dictionary]:
	var unit_path: Array[Dictionary]
	var prev_end = global_position
	
	for goal in goals:
		var new_goal:Dictionary
		if goal["type"] == "Move":
			new_goal["end"] = goal["target"]
		else:
			if goal["target"] == null:
				continue
			new_goal["end"] = goal["target"].global_position
		
		new_goal["start"] = prev_end
		new_goal["type"] = goal["type"]
		prev_end = new_goal["end"]
		unit_path.push_back(new_goal)

	return unit_path
	
func _process(delta):
	reveal_fog()

func _physics_process(delta):
	var current_goal
	
	if attack:
		get_target()
	
	if goals.is_empty():
		return
	else:
		current_goal = goals[0]
		
	velocity = Vector2.ZERO
	
	match current_goal["type"]:
		"Attack":
			if not current_goal["reached"]:
				if current_goal["target"] != null:
					if global_position.distance_to(current_goal["target"].global_position) > max_attack_range:
						move_to_target(current_goal["target"].global_position)
					else:
						goals[0]["reached"] = true
						do_attack()
				else:
					goals.pop_front()
			else:
				if current_goal["target"] != null:
					do_attack()
				else:
					goals.pop_front()
		"Harvest":
			if not current_goal["reached"]:
				if current_goal["target"] != null:
					if global_position.distance_to(current_goal["target"].global_position) > max_range_to_harvest:
						move_to_target(current_goal["target"].global_position)		
					else:
						goals[0]["reached"] = true
						harvest()
				else:
					goals.pop_front()
			else:
				if current_goal["target"] != null:
					harvest()
				else:
					goals.pop_front()
		"Move":
			if global_position.distance_to(current_goal["target"]) > min_dist_to_goal:
				move_to_target(current_goal["target"])
			else:
				goals.pop_front()
	
func move_to_target(target:Vector2):
	move_vector = global_position.direction_to(target)
	velocity = move_vector.normalized() * move_speed

	$Rotate.look_at(target)
	$Collision.look_at(target)
	$Collision.rotation = wrapf($Collision.rotation + deg_to_rad(90), deg_to_rad(0), deg_to_rad(360))
	move_and_slide()

#starts attacking
func do_attack():
	if can_attack:
		can_attack = false
		anim_sprite.play("Attack")
		attack_timer.start(attack_cd)

#gets closes target to unit	
func get_target():
	var new_goal: Dictionary
	for tmp_target in valid_targets:
		if valid_targets[tmp_target] != null:
			new_goal["type"] = "Attack"
			new_goal["target"] = valid_targets[tmp_target]
			new_goal["reached"] = false
			attack = false
			return

func select():
	selected = true
	select_highlight.visible = true

func deselect():
	selected = false
	select_highlight.visible = false
	
func set_goal(goal_position, clear: bool = false, type= "Move"):
	if clear:
		goals.clear()
		attack = false
	
	var new_goal:Dictionary
	new_goal["type"] = type
	new_goal["target"] = goal_position
	new_goal["reached"] = false
	
	goals.push_back(new_goal)
		
func _on_attack_range_body_entered(body: Node2D):
	valid_targets[body.get_instance_id()] = body

func _on_attack_range_body_exited(body: Node2D):
	valid_targets.erase(body.get_instance_id())
	
func _on_attack_cd_timeout():
	can_attack = true
	
func reveal_fog():
	var tilemap_pos = fog_tilemap.local_to_map(global_position)
	var start_pos: Vector2i = tilemap_pos - Vector2i(vision_range, vision_range)
	var end_pos: Vector2i = tilemap_pos + Vector2i(vision_range, vision_range)
	
	fog_tilemap.reveal_tiles(start_pos, end_pos)
	
func set_target(target, clear = false):
	if clear:
		goals.clear()
		attack = false
	
	var new_goal: Dictionary
	new_goal["target"] = target
	new_goal["type"] = "Attack"
	new_goal["reached"] = false

	goals.push_back(new_goal)
	
func harvest():
	if current_honey < max_honey:
		if can_attack:
			can_attack = false
			current_honey = min(current_honey + goals[0]["target"].eat_honey(dmg), max_honey)
			honey_bar.value = current_honey
			
			if current_honey == max_honey:
				goals.pop_front()
				print("Bear is fucking FAT AS FUCK")
				
			anim_sprite.play("Harvest")
			attack_timer.start(attack_cd)
	else:
		goals.pop_front()
		
func replicate():
	if current_honey >= replicate_cost:
		current_honey -= replicate_cost
		honey_bar.value = current_honey
		
		var my_instance = Replicator.get_my_scene(my_type).instantiate()
		my_instance.global_position = global_position + Vector2(40, 40)
		get_tree().root.get_node("World/Objects/Units").add_child(my_instance)
