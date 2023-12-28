extends TileMap

var min_cell: Vector2i
var max_cell: Vector2i

@export var world_map: TileMap

func _ready():
	var rect = world_map.get_used_rect()
	min_cell = rect.position
	max_cell = rect.end
	
	fill_map()

func fill_map():
	for x in range(min_cell.x, max_cell.x):
		for y in range(min_cell.y, max_cell.y):
			set_cell(0, Vector2i(x, y), 3, Vector2i.ZERO)

func reveal_tiles(start_cell: Vector2i, end_cell: Vector2i):
	for x in range(start_cell.x, end_cell.x + 1):
		for y in range(start_cell.y, end_cell.y + 1):
			set_cell(0, Vector2i(x, y), -1)
