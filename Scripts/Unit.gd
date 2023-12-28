extends CharacterBody2D

enum State {ATTACK_MOVE, ATTACK, MOVE, IDLE}

var goals: Array[Vector2]
var move_vector: Vector2
var selected: bool = false
var attack: bool = false
var current_hp: float
var current_target = null
var valid_targets: Dictionary
var state: State = State.IDLE
var can_attack = true
var fog_tilemap: TileMap

@export var select_highlight: Sprite2D
@export var anim_sprite: AnimatedSprite2D
@export var move_speed: float = 200
@export var min_dist_to_goal = 20
@export var max_hp: int = 100
@export var death_particles: PackedScene
@export var hit_particles: PackedScene
@export var hp_bar: ProgressBar
@export var range_area: CollisionShape2D
@export var max_range: float = 500
@export var max_attack_range: float = 60
@export var attack_timer: Timer
@export var attack_cd: float = 2
@export var dmg = 10
@export var vision_range: int = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	range_area.shape.radius = max_range
	current_hp = max_hp
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
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

func get_unit_path() -> Array[Vector2]:
	var unit_path: Array[Vector2]
	if state == State.MOVE:
		unit_path = goals.duplicate(true)
		unit_path.push_front(global_position)
	elif state == State.ATTACK_MOVE:
		unit_path.push_front(global_position)
		unit_path.push_back(current_target.global_position)
	
	return unit_path

func _physics_process(delta):
	velocity = Vector2.ZERO
	var current_goal = null
	var current_pos = global_position
	var tmp_min_dist = null

	if attack:
		get_target()
		if current_target != null:
			current_goal = current_target.global_position
			tmp_min_dist = max_attack_range
			state = State.ATTACK_MOVE

	if current_goal == null and not goals.is_empty():
		current_goal = goals[0]
		tmp_min_dist = min_dist_to_goal
		state = State.MOVE
	
	if current_goal != null:
		if current_pos.distance_to(current_goal) > tmp_min_dist:
			move_vector = current_pos.direction_to(current_goal)
			velocity = move_vector.normalized() * move_speed

			$Rotate.look_at(current_goal)
			$Collision.look_at(current_goal)
			$Collision.rotation = wrapf($Collision.rotation + deg_to_rad(90), deg_to_rad(0), deg_to_rad(360))
			move_and_slide()
		else:
			if state == State.MOVE:
				goals.pop_front()
			elif state == State.ATTACK_MOVE:
				state = State.ATTACK
	else:
		state = State.IDLE
		
func _process(delta):
	if state == State.ATTACK:
		if can_attack:
			do_attack()
			can_attack = false
			attack_timer.start(attack_cd)

	reveal_fog()

func do_attack():
	anim_sprite.play("Attack")
			
func get_target():
	current_target = null
	for tmp_target in valid_targets:
		if valid_targets[tmp_target] != null:
			current_target = valid_targets[tmp_target]
			return

func select():
	selected = true
	select_highlight.visible = true

func deselect():
	selected = false
	select_highlight.visible = false
	
func set_goal(goal_position: Vector2, clear: bool = false):
	if clear:
		goals.clear()
	
	goals.push_back(goal_position)	
		
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

func _on_bear_sprite_animation_finished():
	anim_sprite.play("Idle")
	anim_sprite.stop()
