extends Camera2D

@export var camera_speed = 10
@export var tilemap: TileMap
@export var min_zoom = 0.1
@export var max_zoom = 4
@export var zoom_speed = 0.1

var motion_vector = Vector2.ZERO

func _ready():
	var map_limits = tilemap.get_used_rect()
	var map_cellsize = tilemap.tile_set.tile_size
	
	set_limit(SIDE_BOTTOM, map_limits.end.y * map_cellsize.y)
	set_limit(SIDE_TOP, map_limits.position.y * map_cellsize.y)
	set_limit(SIDE_RIGHT, map_limits.end.x * map_cellsize.x)
	set_limit(SIDE_LEFT, map_limits.position.x * map_cellsize.x)

func _input(event):
	#camera zoom
	var zoom_vector = get_zoom()
	
	if event is InputEventMouseButton and event.pressed:
		if event.is_action("ZoomOut") :
			zoom_vector -= Vector2(zoom_speed, zoom_speed)
		if event.is_action("ZoomIn"):
			zoom_vector += Vector2(zoom_speed, zoom_speed)

	zoom_vector.x = clamp(zoom_vector.x, min_zoom, max_zoom)
	zoom_vector.y = clamp(zoom_vector.y, min_zoom, max_zoom)
	set_zoom(zoom_vector)

func _process(_delta):
	#camera control
	motion_vector = Vector2.ZERO
	if Input.is_action_pressed("CameraDown"):
		motion_vector.y = 1.0
	if Input.is_action_pressed("CameraLeft"):
		motion_vector.x = -1.0
	if Input.is_action_pressed("CameraUp"):
		motion_vector.y = -1.0
	if Input.is_action_pressed("CameraRight"):
		motion_vector.x = 1.0
		
	translate(motion_vector.normalized() *  camera_speed)
