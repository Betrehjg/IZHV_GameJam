extends "res://Scripts/turret.gd"

var rockets_to_shoot = 0
var last_target_pos = null

@export var rocket_count: int = 5
@export var rocket_delay: float = 1
@export var rocket_delay_timer: Timer
@export var explosion_radius: float
@export var smoke_out: Node2D
@export var smoke_particles: PackedScene

func _ready():
	smoke_particles = load("res://particles/rocketSmoke.tscn")
	super._ready()

func get_current_target():
	if current_target == null and not targets.is_empty():
		choose_random_target()

func shoot():
	rockets_to_shoot = rocket_count
	
	rockets_to_shoot -= 1
	spawn_projectile(bullet_scene.instantiate(), current_target.global_position)
	rocket_delay_timer.start(rocket_delay)
	
func spawn_projectile(projectile:Node, target: Vector2):
	projectile.explosion_radius = explosion_radius
	projectile.target_pos = target
	super.spawn_projectile(projectile, target)

func choose_random_target():
	#choose_ random target in range
	var max_targets = len(targets)
	if max_targets >= 1:
		var target_idx = RandomNumberGenerator.new().randi_range(0, max_targets - 1)
		current_target = targets.values()[target_idx]
		last_target_pos = current_target.global_position
	else:
		current_target = null

func _on_rocket_delay_timeout():
	if rockets_to_shoot > 0:
		rockets_to_shoot -= 1
		choose_random_target()
		if current_target != null:
			spawn_projectile(bullet_scene.instantiate(), current_target.global_position)
		else:
			spawn_projectile(bullet_scene.instantiate(), last_target_pos)
		rocket_delay_timer.start(rocket_delay)
	else:
		attack_timer.start(shoot_cd)
