extends StaticBody2D

var targets: Dictionary
var current_target: Node2D
var can_shoot: bool = true
var current_hp: float

@export var fire_range: float = 300
@export var range_collision: CollisionShape2D
@export var turret_top: Sprite2D
@export var attack_timer: Timer
@export var shoot_cd: float = 5
@export var bullet_speed: float = 20
@export var bullet_dmg: float = 10
@export var bullet_scene: PackedScene
@export var max_hp: int = 100
@export var hpBar: ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready():
	range_collision.shape.radius = fire_range
	current_hp = max_hp
	hpBar.max_value = max_hp
	hpBar.value = current_hp

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	get_current_target()
	if current_target != null:
		var new_rotation = get_angle_to(current_target.global_position)
		turret_top.rotation = new_rotation
		
		if can_shoot:
			can_shoot = false
			shoot()
			
func spawn_projectile(projectile:Node, target: Vector2):
	projectile.move_speed = bullet_speed
	projectile.move_vector = $TurretTop/Out.global_position.direction_to(target)
	projectile.dmg = bullet_dmg
	projectile.max_distance = fire_range
	projectile.start_pos = $TurretTop/Out.global_position
	projectile.global_position = $TurretTop/Out.global_position
	get_tree().root.get_node("World/Objects/Bullets").add_child(projectile)
	

func shoot():
	spawn_projectile(bullet_scene.instantiate(), current_target.global_position)
	attack_timer.start(shoot_cd)

func get_current_target():
	var min_dist = fire_range
	var new_target = null
	for target in targets:
		var distance = global_position.distance_to(targets[target].global_position)
		if distance < min_dist:
			min_dist = distance
			new_target = targets[target]

	current_target = new_target

func _on_turret_range_body_entered(body: Node2D):
	targets[body.get_instance_id()] = body

func _on_turret_range_body_exited(body: Node2D):
	targets.erase(body.get_instance_id())

func _on_atack_timer_timeout():
	can_shoot = true
	
func take_dmg(dmg: float):
	current_hp -= dmg
	hpBar.visible = true
	hpBar.value = current_hp
	
	if current_hp <= 0:
		queue_free()
