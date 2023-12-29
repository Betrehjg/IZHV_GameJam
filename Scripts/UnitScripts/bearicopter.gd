extends "res://Scripts/UnitScripts/Unit.gd"

@export var animation_player: AnimationPlayer
@export var bullet: PackedScene
@export var bullet_speed: float

func _physics_process(delta):
	super._physics_process(delta)
	if velocity == Vector2.ZERO:
		animation_player.play("Fly")
	else:
		animation_player.stop()
		
func do_attack():
	var current_target = goals[0]["target"]
	look_at(current_target.global_position)
	
	if can_attack:
		var bullet_inst = bullet.instantiate()
		spawn_projectile(bullet_inst, current_target.global_position)
		can_attack = false
		
func spawn_projectile(projectile:Node, target: Vector2):
	projectile.move_speed = bullet_speed
	projectile.move_vector = $Out.global_position.direction_to(target)
	projectile.dmg = dmg
	projectile.max_distance = max_attack_range
	projectile.start_pos = $Out.global_position
	projectile.global_position = $Out.global_position
	get_tree().root.get_node("World/Bullets").add_child(projectile)
