extends Node2D

var draging = false
var selected = []
var start_pos = Vector2.ZERO
var end_pos = Vector2.ZERO

enum Command {ATTACK, STOP}

func _process(delta):
	queue_redraw()

func _unhandled_input(event):
	#selecting units
	if event.is_action("Select"):
		if event.is_pressed():
			draging = true
			start_pos = get_global_mouse_position()
		elif draging:
			draging = false
			end_pos = get_global_mouse_position()
			queue_redraw()
			deselect_units()
			select_units()
			
	if event is InputEventMouseMotion and draging:
		queue_redraw()
		
func _input(event):
	if event.is_action_pressed("SetGoalQueue"):
		set_goal(get_global_mouse_position(), false)
	elif event.is_action_pressed("SelectTarget"):
		select_target()
	elif event.is_action_pressed("SetGoal"):
		set_goal(get_global_mouse_position(), true)
		
	if event.is_action_pressed("Stop"):
		send_command(Command.STOP)
		
	if event.is_action_pressed("Atack"):
		send_command(Command.ATTACK)
		
func select_target():
	print("selecting Target")

func select_units() -> void:
	var col_shape = PhysicsShapeQueryParameters2D.new()
	var select_rect = RectangleShape2D.new()
	select_rect.extents = abs(end_pos - start_pos) / 2
	col_shape.shape = select_rect
	col_shape.collision_mask = 1
	col_shape.transform = Transform2D(0, (end_pos + start_pos) / 2)
	selected = get_world_2d().direct_space_state.intersect_shape(col_shape)
	
	for unit in selected:
		if unit.collider != null:
			unit.collider.select()

func send_command(com: Command) -> void:
	for unit in selected:
		if unit.collider != null:
			match com:
				Command.ATTACK:
					unit.collider.stop_command()
				Command.STOP:
					unit.collider.attack_command()
				
func deselect_units() -> void:
	for unit in selected:
		if unit.collider != null:
			unit.collider.deselect()

func set_goal(goal_position: Vector2, clear:bool = false) -> void:
	for unit in selected:
		if unit.collider != null:
			unit.collider.set_goal(goal_position, clear)

func _draw():
	#drawing selected are bounding rectangle
	if draging:
		draw_rect(Rect2(start_pos, get_global_mouse_position() - start_pos), Color.BROWN, false, 3.0)

	for unit in selected:
		if unit.collider != null:
			var unit_path = unit.collider.get_unit_path()
			var unit_state = unit.collider.state
			var color: Color
			
			if unit_state == unit.collider.State.MOVE:
				color = Color.WHITE
			elif unit_state == unit.collider.State.ATTACK_MOVE:
				color = Color.RED
			else:
				color = Color.WHITE
			
			if not unit_path.is_empty():
				for i in range(1, len(unit_path)):
					draw_line(unit_path[i - 1], unit_path[i], color, 1)
