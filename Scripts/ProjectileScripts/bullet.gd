extends Node2D

var move_speed:float = 20
var move_vector: Vector2
var dmg: float
var max_distance: float
var start_pos: Vector2
var moving = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if moving:
		translate(move_vector.normalized() * move_speed)
		
		if start_pos.distance_to(global_position) >= max_distance:	
			on_max_range()
			
func on_max_range():
	queue_free()

func _on_collision_body_entered(body: Node2D):
	body.take_dmg(dmg)
	
	queue_free()
