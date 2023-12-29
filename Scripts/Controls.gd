extends Node2D

var draging = false
var selected = []
var start_pos = Vector2.ZERO
var end_pos = Vector2.ZERO

@export var pause_menu: CanvasLayer

enum Command {ATTACK, STOP, SET_TARGET, MOVE, HARVEST, REPLICATE}

func _process(delta):
	queue_redraw()
	
func _physics_process(delta):
	var mouse_click = 0
	if Input.is_action_just_pressed("SetGoalQueue"):
		mouse_click = 1 
	elif Input.is_action_just_pressed("SetGoal"):
		mouse_click = 2 
		
	if mouse_click == 1:
		select_target(false)
	elif mouse_click == 2:
		select_target(true)

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
	if event.is_action_pressed("Stop"):
		send_command(Command.STOP)
		
	if event.is_action_pressed("Atack"):
		send_command(Command.ATTACK)
		
	if event.is_action_pressed("Replicate"):
		send_command(Command.REPLICATE)
		
func select_target(clear:bool):
	var mouse_pos = get_global_mouse_position()
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collision_mask = 18
	query.collide_with_areas = true
	
	var result = space_state.intersect_point(query)
	
	if not result.is_empty():
		var obj_type = result[0].collider.get_groups()
		if not obj_type.is_empty():
			if obj_type[0] == "Tree":
				send_command(Command.HARVEST, [result[0].collider, clear])
			elif obj_type[0] == "Turret":
				send_command(Command.SET_TARGET, [result[0].collider, clear])
	else:
		send_command(Command.MOVE, [mouse_pos, clear])

func select_units() -> void:
	var col_shape = PhysicsShapeQueryParameters2D.new()
	var select_rect = RectangleShape2D.new()
	select_rect.extents = abs(end_pos - start_pos) / 2
	col_shape.shape = select_rect
	col_shape.collision_mask = 1
	col_shape.transform = Transform2D(0, (end_pos + start_pos) / 2)
	selected = get_world_2d().direct_space_state.intersect_shape(col_shape, 50)
	
	for unit in selected:
		if unit.collider != null:
			unit.collider.select()

func send_command(com: Command, args = null) -> void:
	for unit in selected:
		if unit.collider != null:
			match com:
				Command.ATTACK:
					unit.collider.attack_command()
				Command.STOP:
					unit.collider.stop_command()
				Command.SET_TARGET:
					unit.collider.set_target(args[0], args[1])
				Command.MOVE:
					unit.collider.set_goal(args[0], args[1])
				Command.HARVEST:
					unit.collider.set_goal(args[0], args[1], "Harvest")
				Command.REPLICATE:
					unit.collider.replicate()
				
func deselect_units() -> void:
	for unit in selected:
		if unit.collider != null:
			unit.collider.deselect()

func _draw():
	#drawing selected are bounding rectangle
	if draging:
		draw_rect(Rect2(start_pos, get_global_mouse_position() - start_pos), Color.BROWN, false, 3.0)

	for unit in selected:
		if unit.collider != null:
			var unit_path = unit.collider.get_unit_path()
			
			if not unit_path.is_empty():
				for goal in unit_path:
					var color = Color.BLACK
					
					match goal["type"]:
						"Move":
							color = Color.WHITE
						"Attack":
							color = Color.RED
						"Harvest":
							color = Color.GREEN
					
					draw_line(goal["start"], goal["end"], color, 1)
