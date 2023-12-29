extends "res://Scripts/ProjectileScripts/bullet.gd"

var explosion_radius: float
var explosion_duration = 0.2
var target_pos

@export var explosion: Area2D
@export var collision: Area2D
@export var explosion_duration_timer: Timer
@export var explosion_particles: PackedScene

func _ready():
	explosion.get_child(0).shape.radius = explosion_radius
	look_at(target_pos)

func _on_collision_body_entered(body: Node2D):
	explode()

func explode():
	$BulletSprite.visible = false
	explosion_duration_timer.start(explosion_duration)
	explosion.set_deferred("monitoring", true)
	collision.set_deferred("monitoring", false)
	moving = false
	
	var particles = explosion_particles.instantiate()
	particles.global_position = global_position
	get_tree().root.add_child(particles)
	
func on_max_range():
	explode()

func _on_explosion_body_entered(body):
	body.take_dmg(dmg)

func _on_explosion_duration_timeout():
	queue_free()
