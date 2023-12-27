extends CharacterBody2D

var goals: Array[Vector2]
var move_vector: Vector2
var selected: bool = false

@export var select_highlight: Sprite2D
@export var move_speed: float = 200
@export var min_dist_to_goal = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	pass

func get_unit_path() -> Array[Vector2]:
	var unit_path = goals.duplicate(true)
	unit_path.push_front(global_position)
	
	return unit_path

func _physics_process(delta):
	velocity = Vector2.ZERO
	if not goals.is_empty():
		var current_goal = goals[0]
		var current_pos = global_position

		if current_pos.distance_to(current_goal) > min_dist_to_goal:
			move_vector = current_pos.direction_to(current_goal)
			velocity = move_vector.normalized() * move_speed

			look_at(current_goal)
			move_and_slide()
		else:
			goals.pop_front()

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
